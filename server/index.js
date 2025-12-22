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

// Supabase
const SUPA_URL = process.env.SUPA_URL || process.env.SUPABASE_URL;
const SUPA_SERVICE_ROLE_KEY = process.env.SUPA_SERVICE_ROLE_KEY;

// Firebase Admin
const FIREBASE_SERVICE_ACCOUNT_JSON = process.env.FIREBASE_SERVICE_ACCOUNT_JSON; // recommended
const FIREBASE_SERVICE_ACCOUNT_PATH = process.env.FIREBASE_SERVICE_ACCOUNT_PATH; // optional

// Admin access (comma separated emails)
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
    serviceAccount = JSON.parse(FIREBASE_SERVICE_ACCOUNT_JSON);
  } else if (
    FIREBASE_SERVICE_ACCOUNT_PATH &&
    FIREBASE_SERVICE_ACCOUNT_PATH.trim()
  ) {
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
  databaseURL: process.env.FIREBASE_DATABASE_URL,
});

if (!process.env.FIREBASE_DATABASE_URL) {
  console.warn(
    "⚠️ FIREBASE_DATABASE_URL belum diset. Fitur RTDB notif tidak akan jalan."
  );
}

// =================== INIT SUPABASE ===================
const supabase = createClient(SUPA_URL, SUPA_SERVICE_ROLE_KEY);

// =================== AUTH MIDDLEWARE ===================
async function requireAuth(req, res, next) {
  try {
    const authHeader = req.headers.authorization || "";
    const token = authHeader.startsWith("Bearer ")
      ? authHeader.slice(7)
      : null;

    if (!token) {
      return res
        .status(401)
        .json({ message: "Missing Authorization Bearer token" });
    }

    const decoded = await admin.auth().verifyIdToken(token);
    req.user = decoded; // decoded.uid, decoded.email, decoded.admin (custom claim)
    return next();
  } catch (err) {
    return res.status(401).json({ message: "Invalid token", error: err.message });
  }
}

function isAdminUser(decoded) {
  if (decoded && decoded.admin === true) return true;

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
    return res
      .status(500)
      .json({ message: "Admin check failed", error: e.message });
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

// =================== NOTIF HELPERS (RTDB + FCM) ===================

// ✅ Ambil token dari SUPABASE (table fcm_tokens)
async function getUserFcmTokens(uid) {
  const { data, error } = await supabase
    .from("fcm_tokens")
    .select("fcm_token")
    .eq("firebase_uid", uid);

  if (error) {
    console.warn("⚠️ getUserFcmTokens supabase error:", error.message);
    return [];
  }

  return (data || []).map((r) => r.fcm_token).filter(Boolean);
}

// ✅ Inbox notifikasi tetap di RTDB (notifications/{uid})
async function saveInboxNotification(uid, payload) {
  if (!process.env.FIREBASE_DATABASE_URL) return null;
  const ref = admin.database().ref(`notifications/${uid}`).push();
  await ref.set({
    ...payload,
    created_at: admin.database.ServerValue.TIMESTAMP,
    read: false,
  });
  return ref.key;
}

// label status
function statusLabel(s) {
  const st = normalizeStatus(s);
  if (st === ORDER_STATUS.RECEIVED) return "Pesanan Diterima";
  if (st === ORDER_STATUS.PROCESSING) return "Pesanan Diproses";
  if (st === ORDER_STATUS.READY) return "Pesanan Siap";
  return st;
}

async function notifyUser(uid, { title, body, data = {}, type = "general" }) {
  // simpan inbox dulu (biar ada riwayat walau token kosong)
  await saveInboxNotification(uid, {
    title,
    body,
    type,
    data,
  });

  const tokens = await getUserFcmTokens(uid);
  if (!tokens.length) return { sent: 0, reason: "no_tokens" };

  const message = {
    tokens,
    notification: { title, body },
    data: {
      type: String(type),
      ...Object.fromEntries(
        Object.entries(data).map(([k, v]) => [k, String(v)])
      ),
    },
    android: {
      notification: {
        channelId: "promo_channel",
        sound: "bang_ajeyy",
      },
    },
    apns: {
      payload: {
        aps: {
          sound: "bang_ajeyy.mp3",
        },
      },
    },
  };

  const resp = await admin.messaging().sendEachForMulticast(message);

  // bersihkan token invalid (hapus dari SUPABASE)
  const invalidTokens = [];
  resp.responses.forEach((r, idx) => {
    if (!r.success) {
      const code = r.error?.code || "";
      if (
        code.includes("registration-token-not-registered") ||
        code.includes("invalid-argument")
      ) {
        invalidTokens.push(tokens[idx]);
      }
    }
  });

  if (invalidTokens.length) {
    await supabase.from("fcm_tokens").delete().in("fcm_token", invalidTokens);
  }

  return { sent: resp.successCount, failed: resp.failureCount };
}

async function broadcastPromo({ title, body, data = {} }) {
  if (!process.env.FIREBASE_DATABASE_URL) {
    // Promo broadcast di contoh kamu pakai RTDB users untuk list uid
    return { ok: false, reason: "no_database_url" };
  }

  const usersSnap = await admin.database().ref("users").once("value");
  const usersVal = usersSnap.val() || {};
  const uids = Object.keys(usersVal);

  let totalSent = 0;
  for (const uid of uids) {
    const r = await notifyUser(uid, { title, body, data, type: "promo" });
    totalSent += r.sent || 0;
  }

  return { ok: true, users: uids.length, totalSent };
}

// =================== ROUTES ===================
app.get("/health", async (req, res) => {
  // optional: cek apakah table fcm_tokens ada (biar gampang debug)
  let tokens_table_ok = null;
  try {
    const { error } = await supabase
      .from("fcm_tokens")
      .select("id")
      .limit(1);
    tokens_table_ok = !error;
  } catch (_) {
    tokens_table_ok = false;
  }

  res.json({
    ok: true,
    message: "Server is running",
    port: Number(PORT),
    admin_emails_count: ADMIN_EMAILS.length,
    has_database_url: Boolean(process.env.FIREBASE_DATABASE_URL),
    tokens_table_ok,
  });
});

// ✅ CHECK LOGIN + ADMIN VIA BACKEND
app.get("/api/me", requireAuth, (req, res) => {
  const decoded = req.user || {};
  const email = (decoded.email || "").toLowerCase();
  const is_admin = isAdminUser(decoded);

  return res.json({
    uid: decoded.uid,
    email,
    is_admin,
    admin_reason:
      decoded.admin === true
        ? "custom_claim"
        : ADMIN_EMAILS.includes(email)
        ? "env_admin_emails"
        : "none",
  });
});

// ✅ REGISTER/UPDATE FCM TOKEN KE SUPABASE
app.post("/api/fcm/register", requireAuth, async (req, res) => {
  try {
    const uid = req.user.uid;

    const token = String(req.body.token || "").trim();
    const platform = req.body.platform ? String(req.body.platform) : null;
    const device_id = req.body.device_id ? String(req.body.device_id) : null;

    if (!token) return res.status(400).json({ message: "token is required" });

    const { data, error } = await supabase
      .from("fcm_tokens")
      .upsert(
        [
          {
            firebase_uid: uid,
            fcm_token: token,
            platform,
            device_id,
          },
        ],
        { onConflict: "fcm_token" } // token unique
      )
      .select()
      .single();

    if (error) return res.status(500).json({ message: "Supabase error", error });

    return res.json({ ok: true, saved: data });
  } catch (e) {
    return res.status(500).json({ message: "Server error", error: e.message });
  }
});

// (optional) revoke token (logout / disable notif)
app.post("/api/fcm/revoke", requireAuth, async (req, res) => {
  try {
    const uid = req.user.uid;
    const token = String(req.body.token || "").trim();
    if (!token) return res.status(400).json({ message: "token is required" });

    const { error } = await supabase
      .from("fcm_tokens")
      .delete()
      .eq("firebase_uid", uid)
      .eq("fcm_token", token);

    if (error) return res.status(500).json({ message: "Supabase error", error });

    return res.json({ ok: true });
  } catch (e) {
    return res.status(500).json({ message: "Server error", error: e.message });
  }
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
      return res
        .status(400)
        .json({ message: "address is required (min 3 chars)" });
    }
    if (!Array.isArray(items) || items.length === 0) {
      return res
        .status(400)
        .json({ message: "items must be a non-empty array" });
    }

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
      return res
        .status(500)
        .json({ message: "Insert order failed", error: orderErr });
    }

    const orderItemsPayload = items.map((it) => ({
      order_id: order.id,
      product_id: String(it.product_id),
      name: it.name ?? null,
      price: typeof it.price === "number" ? it.price : null,
      qty: typeof it.qty === "number" ? it.qty : 1,
    }));

    const { error: itemsErr } = await supabase
      .from("order_items")
      .insert(orderItemsPayload);

    if (itemsErr) {
      return res
        .status(500)
        .json({ message: "Insert items failed", error: itemsErr });
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

// GET /api/admin/orders/:id
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
app.patch(
  "/api/admin/orders/:id/status",
  requireAuth,
  requireAdmin,
  async (req, res) => {
    try {
      const orderId = req.params.id;
      const next = normalizeStatus(req.body.status);

      if (!isValidStatus(next)) {
        return res.status(400).json({
          message: "Invalid status value",
          allowed: Object.values(ORDER_STATUS),
        });
      }

      const { data: order, error: getErr } = await supabase
        .from("orders")
        .select("id, status, user_id, total")
        .eq("id", orderId)
        .single();

      if (getErr)
        return res.status(500).json({ message: "Supabase error", error: getErr });
      if (!order) return res.status(404).json({ message: "Order not found" });

      const current = normalizeStatus(order.status) || ORDER_STATUS.RECEIVED;
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

      if (updErr)
        return res.status(500).json({ message: "Update failed", error: updErr });

      // notif user
      const title = "Update Pesanan";
      const body = `Pesanan kamu sekarang: ${statusLabel(next)}`;

      await notifyUser(order.user_id, {
        title,
        body,
        type: "order_status",
        data: {
          order_id: orderId,
          status: next,
        },
      });

      return res.json({ ok: true, order: updated });
    } catch (e) {
      return res.status(500).json({ message: "Server error", error: e.message });
    }
  }
);

// =================== ADMIN PROMO NOTIF (Firebase) ===================
app.post("/api/admin/promos/notify", requireAuth, requireAdmin, async (req, res) => {
  try {
    const title = String(req.body.title || "Promo Baru 🎉");
    const body = String(req.body.body || "Ada promo baru, cek sekarang!");
    const promoCode = req.body.promo_code ? String(req.body.promo_code) : null;

    const result = await broadcastPromo({
      title,
      body,
      data: promoCode ? { promo_code: promoCode } : {},
    });

    return res.json({ ok: true, result });
  } catch (e) {
    return res.status(500).json({ message: "Server error", error: e.message });
  }
});

// =================== START ===================
app.listen(PORT, "0.0.0.0", () => {
  console.log(`✅ Server listening on port ${PORT}`);
});
