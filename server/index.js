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
    req.user = decoded; // decoded.uid
    return next();
  } catch (err) {
    return res.status(401).json({ message: "Invalid token", error: err.message });
  }
}

// =================== ROUTES ===================
app.get("/health", (req, res) => {
  res.json({ ok: true, message: "Server is running", port: Number(PORT) });
});

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

// =================== START ===================
app.listen(PORT, "0.0.0.0", () => {
  console.log(`✅ Server listening on port ${PORT}`);
});
