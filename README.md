# project_uap

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

---

## Backend for Orders (Firebase Auth + Supabase)

This project includes a small Express server (in `/server`) that verifies Firebase ID tokens and proxies requests to Supabase using the service role key. This keeps Supabase service keys secure and lets you use Firebase Authentication for users while storing orders in Supabase.

- See `/server/README.md` for setup and env variables.
- Update `lib/services/api_service.dart` constant `_BASE_URL` to your deployed server URL.
- The app now uses the server for creating orders (from Checkout) and fetching orders (Orders screen).
