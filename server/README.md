# Project UAP - API

Simple Express API to bridge Firebase Auth and Supabase.

Environment variables (see `.env.example`):

- `SUPA_URL` - Supabase project URL
- `SUPA_SERVICE_ROLE_KEY` - Supabase service role key (SERVER ONLY)
- `FIREBASE_SERVICE_ACCOUNT_JSON` - JSON of Firebase service account (stringified) OR
- `FIREBASE_SERVICE_ACCOUNT_PATH` - _recommended_: absolute path to a JSON file with the Firebase service account (easier and safer than embedding the JSON in `.env`)
- `PORT` - server port (optional)

Endpoints:

- `GET /api/orders` - requires Authorization: Bearer <firebase_id_token>, returns orders for the user
- `POST /api/orders` - requires token, body: { total, items: [{product_id, qty, price}], address, note, payment_method }

Security: Keep `SUPA_SERVICE_ROLE_KEY` and `FIREBASE_SERVICE_ACCOUNT_JSON` secret and only on server side.
