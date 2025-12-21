require("dotenv").config();

const express = require("express");
const cors = require("cors");
const bodyParser = require("body-parser");

const admin = require("firebase-admin");
const { createClient } = require("@supabase/supabase-js");

const app = express();
app.use(cors());
app.use(bodyParser.json());

// ---------- ENV CHECK ----------
const PORT = process.env.PORT || 3000;

// Supabase
const SUPA_URL = process.env.SUPA_URL || process.env.SUPABASE_URL;
const SUPA_SERVICE_ROLE_KEY = process.env.SUPA_SERVICE_ROLE_KEY;

// Firebase Admin via JSON env (recommended for hosting)
const FIREBASE_SERVICE_ACCOUNT_JSON = process.env.FIREBASE_SERVICE_ACCOUNT_JSON;

if (!SUPA_URL) {
  console.error("❌ Missing env: SUPA_URL (or SUPABASE_URL)");
  process.exit(1);
}
if (!SUPA_SERVICE_ROLE_KEY) {
  console.error("❌ Missing env: SUPA_SERVICE_ROLE_KEY");
  process.exit(1);
}
if (!FIREBASE_SERVICE_ACCOUNT_JSON) {
  console.error("❌ Missing env: FIREBASE_SERVICE_ACCOUNT_JSON");
  process.exit(1);
}

// ---------- INIT FIREBASE ADMIN (JSON ENV) ----------
let serviceAccount;
try {
  serviceAccount = JSON.parse(FIREBASE_SERVICE_ACCOUNT_JSON);
} catch (e) {
  console.error("❌ FIREBASE_SERVICE_ACCOUNT_JSON is not valid JSON:", e.message);
  process.exit(1);
}

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});

// ---------- INIT SUPABASE ----------
const supabase = createClient(SUPA_URL, SUPA_SERVICE_ROLE_KEY);

// ---------- AUTH MIDDLEWARE ----------
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

// ---------- HEALTH CHECK ----------
app.get("/health", (req, res) => {
  res.json({ ok: true, message: "Server is running" });
});

// ---------- GET ORDERS ----------
app.get("/api/orders", requireAuth, async (req, res) => {
  const uid = req.user.uid;

  const { data, error } = await supabase
    .from("orders")
    .select("*, order_items(*)")
    .eq("user_id", uid)
    .order("created_at", { ascending: false });

  if (error) return res.status(500).json({ message: "Supabase error", error });

  res.json({ orders: data || [] });
});

// ---------- CREATE ORDER ----------
app.post("/api/orders", requireAuth, async (req, res) => {
  const uid = req.user.uid;
  const { address, items } = req.body;

  if (!address || typeof address !== "string") {
    return res.status(400).json({ message: "address is required" });
  }
  if (!Array.isArray(items) || items.length === 0) {
    return res.status(400).json({ message: "items must be a non-empty array" });
  }

  // 1) insert order
  const { data: order, error: orderErr } = await supabase
    .from("orders")
    .insert([{ user_id: uid, address }])
    .select()
    .single();

  if (orderErr) return res.status(500).json({ message: "Insert order failed", error: orderErr });

  // 2) insert order items
  const orderItemsPayload = items.map((it) => ({
    order_id: order.id,
    product_id: it.product_id,
    name: it.name,
    price: it.price,
    qty: it.qty,
  }));

  const { error: itemsErr } = await supabase.from("order_items").insert(orderItemsPayload);

  if (itemsErr) return res.status(500).json({ message: "Insert items failed", error: itemsErr });

  res.json({ ok: true, order_id: order.id });
});

// ---------- START ----------
app.listen(PORT, () => {
  console.log(`✅ Server listening on port ${PORT}`);
});
