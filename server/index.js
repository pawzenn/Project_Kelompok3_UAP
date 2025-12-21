require("dotenv").config();

const fs = require("fs");
const path = require("path");

const express = require("express");
const cors = require("cors");
const bodyParser = require("body-parser");

const admin = require("firebase-admin");
const { createClient } = require("@supabase/supabase-js");

const app = express();
app.use(cors());
app.use(bodyParser.json());

// =================== ENV ===================
const PORT = process.env.PORT || 3000;

// Supabase (pakai salah satu: SUPA_URL atau SUPABASE_URL)
const SUPA_URL = process.env.SUPA_URL || process.env.SUPABASE_URL;
const SUPA_SERVICE_ROLE_KEY = process.env.SUPA_SERVICE_ROLE_KEY;

// Firebase (pilih salah satu)
const FIREBASE_SERVICE_ACCOUNT_JSON = process.env.FIREBASE_SERVICE_ACCOUNT_JSON; // recommended
const FIREBASE_SERVICE_ACCOUNT_PATH = process.env.FIREBASE_SERVICE_ACCOUNT_PATH; // optional

// Admin access
// contoh: "admin1@gmail.com,admin2@gmail.com"
const ADMIN_EMAILS = (process.env.ADMIN_EMAILS || "")
  .split(",")
  .map((s) => s.trim().toLowerCase())
  .filter(Boolean);

if (!SUPA_URL) {
  console.error("❌ Missing env: SUPA_URL (or SUPABASE_URL)");
  process.exit(1);
}
if (!SUPA_SERVICE_ROLE_KEY) {
  console.error("❌ Missing env: SUPA_SERVICE_ROLE_KEY");
  process.exit(1);
}

// =================== INIT FIREBASE ADMIN ===================
let serviceAccount = null;

try {
  if (FIREBASE_SERVICE_ACCOUNT_JSON && FIREBASE_SERVICE_ACCOUNT_JSON.trim()) {
    // FIREBASE_SERVICE_ACCOUNT_JSON harus string JSON utuh
    serviceAccount = JSON.parse(FIREBASE_SERVICE_ACCOUNT_JSON);
  } else if (FIREBASE_SERVICE_ACCOUNT_PATH && FIREBASE_SERVICE_ACCOUNT_PATH.trim()) {
    const jsonPath = path.resolve(__dirname, FIREBASE_SERVICE_ACCOUNT_PATH);
    serviceAccount = JSON.parse(fs.readFileSync(jsonPath, "utf8"));
  } else {
    throw new Error(
      "Missing env: FIREBASE_SERVICE_ACCOUNT_JSON (recommended) or FIREBASE_SERVICE_ACCOUNT_PATH"
    );
  }
} catch (e) {
  console.error("❌ Failed to load Firebase service account:", e.message);
  process.exit(1);
}

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});

// =================== INIT SUPABASE ===================
const supabase = createClient(SUPA_URL, SUPA_SERVICE_ROLE_KEY);

// =================== AUTH MIDDLEWARE ===================
async function requireAuth(req, res, next) {
  try {
    const authHeader = req.headers.authorization || "";
    const token = authHeader.startsWith("Bearer ") ? authHeader.slice(7) : null;

    if (!token) {
      return res.status(401).json({ message: "Missing Authorization Bearer token" });
    }

    const decoded = await admin.auth().verifyIdToken(token);
    req.user = decoded; // decoded.uid, decoded.email, decoded.admin (kalau custom claim)
    return next();
  } catch (err) {
    return res.status(401).json({ message: "Invalid token", error: err.message });
  }
}

function isAdminUser(decoded) {
  // Opsi A (paling aman): Firebase custom claims admin=true
  if (decoded && decoded.admin === true) return true;

  // Opsi B (paling gampang): whitelist email dari ENV
  const email = (decoded.email || "").toLowerCase();
  if (email && ADMIN_EMAILS.includes(email)) return true;

  return false;
}

function requireAdmin(req, res, next) {
  try {
    if (!req.user) return res.status(401).json({ message: "Not authenticated" });
    if (!isAdminUser(req.user)) {
      return res.status(403).json({
        message: "Forbidden. Admin only.",
        hint: "Set ADMIN_EMAILS in env OR set Firebase custom claim admin=true",
      });
    }
    return next();
  } catch (e) {
    return res.status(500).json({ message: "Admin check failed", error: e.message });
  }
}

// =================== STATUS HELPERS ===================
const ORDER_STATUS = {
  RECEIVED: "received",
  PROCESSING: "processing",
  READY: "ready",
};

const NEXT_STATUS = {
  [ORDER_STATUS.RECEIVED]: ORDER_STATUS.PROCESSING,
  [ORDER_STATUS.PROCESSING]: ORDER_STATUS.READY,
  [ORDER_STATUS.READY]: null,
};

function normalizeStatus(s) {
  return String(s || "").trim().toLowerCase();
}

function isValidStatus(s) {
  return (
    s === ORDER_STATUS.RECEIVED ||
    s === ORDER_STATUS.PROCESSING ||
    s === ORDER_STATUS.READY
  );
}

// =================== ROUTES ===================
app.get("/health", (req, res) => {
  res.json({ ok: true, message: "Server is running", port: Number(PORT) });
});

// =================== USER ORDERS ===================
app.get("/api/orders", requireAuth, async (req, res) => {
  try {
    const uid = req.user.uid;

    const { data, error } = await supabase
      .from("orders")
      .select("*, order_items(*)")
      .eq("user_id", uid)
      .order("created_at", { ascending: false });

    if (error) return res.status(500).json({ message: "Supabase error", error });

    return res.json({ orders: data || [] });
  } catch (e) {
    return res.status(500).json({ message: "Server error", error: e.message });
  }
});

app.post("/api/orders", requireAuth, async (req, res) => {
  try {
    const uid = req.user.uid;

    const { address, items, note, payment_method, total } = req.body;

    if (!address || typeof address !== "string" || address.trim().length < 3) {
      return res.status(400).json({ message: "address is required (min 3 chars)" });
    }
    if (!Array.isArray(items) || items.length === 0) {
      return res.status(400).json({ message: "items must be a non-empty array" });
    }

    // 1) insert order
    const { data: order, error: orderErr } = await supabase
      .from("orders")
      .insert([
        {
          user_id: uid,
          address: address.trim(),
          note: note ?? null,
          payment_method: payment_method ?? null,
          total: typeof total === "number" ? total : null,
          // status akan otomatis default 'received' dari DB
        },
      ])
      .select()
      .single();

    if (orderErr) {
      return res.status(500).json({ message: "Insert order failed", error: orderErr });
    }

    // 2) insert order items
    const orderItemsPayload = items.map((it) => ({
      order_id: order.id,
      product_id: String(it.product_id), // products.id = text
      name: it.name ?? null,
      price: typeof it.price === "number" ? it.price : null,
      qty: typeof it.qty === "number" ? it.qty : 1,
    }));

    const { error: itemsErr } = await supabase.from("order_items").insert(orderItemsPayload);
    if (itemsErr) {
      return res.status(500).json({ message: "Insert items failed", error: itemsErr });
    }

    return res.json({ ok: true, order_id: order.id });
  } catch (e) {
    return res.status(500).json({ message: "Server error", error: e.message });
  }
});

// =================== ADMIN ORDERS ===================

// GET /api/admin/orders?status=received|processing|ready
app.get("/api/admin/orders", requireAuth, requireAdmin, async (req, res) => {
  try {
    const status = normalizeStatus(req.query.status);

    let q = supabase
      .from("orders")
      .select("*, order_items(*)")
      .order("created_at", { ascending: false });

    if (status) {
      if (!isValidStatus(status)) {
        return res.status(400).json({
          message: "Invalid status filter",
          allowed: Object.values(ORDER_STATUS),
        });
      }
      q = q.eq("status", status);
    }

    const { data, error } = await q;

    if (error) return res.status(500).json({ message: "Supabase error", error });
    return res.json({ orders: data || [] });
  } catch (e) {
    return res.status(500).json({ message: "Server error", error: e.message });
  }
});

// GET /api/admin/orders/:id (detail)
app.get("/api/admin/orders/:id", requireAuth, requireAdmin, async (req, res) => {
  try {
    const orderId = req.params.id;

    const { data, error } = await supabase
      .from("orders")
      .select("*, order_items(*)")
      .eq("id", orderId)
      .single();

    if (error) return res.status(500).json({ message: "Supabase error", error });
    if (!data) return res.status(404).json({ message: "Order not found" });

    return res.json({ order: data });
  } catch (e) {
    return res.status(500).json({ message: "Server error", error: e.message });
  }
});

// PATCH /api/admin/orders/:id/status
// body: { status: "received"|"processing"|"ready" }
// aturan: harus maju (received->processing->ready)
app.patch("/api/admin/orders/:id/status", requireAuth, requireAdmin, async (req, res) => {
  try {
    const orderId = req.params.id;
    const next = normalizeStatus(req.body.status);

    if (!isValidStatus(next)) {
      return res.status(400).json({
        message: "Invalid status value",
        allowed: Object.values(ORDER_STATUS),
      });
    }

    // ambil order dulu
    const { data: order, error: getErr } = await supabase
      .from("orders")
      .select("id, status")
      .eq("id", orderId)
      .single();

    if (getErr) return res.status(500).json({ message: "Supabase error", error: getErr });
    if (!order) return res.status(404).json({ message: "Order not found" });

    const current = normalizeStatus(order.status) || ORDER_STATUS.RECEIVED;

    // validasi alur: hanya boleh naik 1 step
    const allowedNext = NEXT_STATUS[current];
    if (allowedNext === null) {
      return res.status(400).json({
        message: "Order already completed (ready). Cannot advance.",
        current,
      });
    }
    if (next !== allowedNext) {
      return res.status(400).json({
        message: "Invalid status transition",
        current,
        allowed_next: allowedNext,
      });
    }

    const { data: updated, error: updErr } = await supabase
      .from("orders")
      .update({ status: next })
      .eq("id", orderId)
      .select("*, order_items(*)")
      .single();

    if (updErr) return res.status(500).json({ message: "Update failed", error: updErr });

    return res.json({ ok: true, order: updated });
  } catch (e) {
    return res.status(500).json({ message: "Server error", error: e.message });
  }
});

// =================== START ===================
app.listen(PORT, "0.0.0.0", () => {
  console.log(`✅ Server listening on port ${PORT}`);
});
