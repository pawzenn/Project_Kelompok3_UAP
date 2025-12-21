import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../data/models/product.dart';
import '../../data/models/promo.dart';

class SupabaseService {
  SupabaseService._();
  static final SupabaseService instance = SupabaseService._();

  SupabaseClient? _client;
  bool _initialized = false;

  SupabaseClient get client {
    final c = _client;
    if (c == null) {
      throw Exception(
        'SupabaseService belum di-init. Pastikan panggil await SupabaseService.instance.init() di main() sebelum runApp().',
      );
    }
    return c;
  }

  Future<void> init() async {
    if (_initialized && _client != null)
      return; // ✅ biar aman dipanggil berkali-kali
    _initialized = true;

    await dotenv.load(fileName: ".env");

    final url = dotenv.env['SUPABASE_URL'];
    final anonKey = dotenv.env['SUPABASE_ANON_KEY'];

    if (url == null || anonKey == null || url.isEmpty || anonKey.isEmpty) {
      throw Exception(
          'SUPABASE_URL atau SUPABASE_ANON_KEY belum diset di .env');
    }

    // ✅ Supabase.initialize cuma boleh sekali (kalau sudah pernah init, jangan init lagi)
    try {
      if (Supabase.instance.client.auth.currentSession == null &&
          Supabase.instance.client == null) {
        // biasanya kondisi ini tidak terjadi, jadi pakai try-catch saja
      }
    } catch (_) {
      // kalau Supabase.instance belum siap, lanjut initialize di bawah
    }

    // Cara paling aman: cek sudah initialize atau belum
    // SupabaseFlutter tidak expose flag, jadi kita protect pakai try-catch:
    try {
      // Kalau belum init, ini aman
      await Supabase.initialize(url: url, anonKey: anonKey);
    } catch (_) {
      // Kalau sudah init, akan throw -> kita abaikan
    }

    _client = Supabase.instance.client;
  }

  // =========================================================
  // PRODUCTS
  // =========================================================
  Future<List<Product>> fetchProducts() async {
    final res = await client
        .from('products')
        .select('id, name, category, area, image_url, price')
        .order('price', ascending: false);

    final list = (res as List).cast<Map<String, dynamic>>();
    return list.map((e) => Product.fromMap(e)).toList();
  }

  // =========================================================
  // ROLE (user_roles)
  // =========================================================
  Future<String> getRoleByFirebaseUid({
    required String firebaseUid,
    String? email,
  }) async {
    final res = await client
        .from('user_roles')
        .select('role')
        .eq('firebase_uid', firebaseUid)
        .maybeSingle();

    if (res == null) return 'user';
    return (res['role'] ?? 'user').toString();
  }

  // =========================================================
  // PROMOS (CRUD) Table: public.promos
  // =========================================================
  Future<List<Promo>> fetchPromos({bool onlyActive = false}) async {
    var q = client.from('promos').select('*');

    if (onlyActive) {
      q = q.eq('is_active', true);
    }

    final res = await q.order('created_at', ascending: false);
    final list = (res as List).cast<Map<String, dynamic>>();
    return list.map((e) => Promo.fromMap(e)).toList();
  }

  Future<Promo> createPromo(Promo promo) async {
    final res =
        await client.from('promos').insert(promo.toInsert()).select().single();
    return Promo.fromMap((res as Map).cast<String, dynamic>());
  }

  Future<Promo> updatePromo(Promo promo) async {
    final res = await client
        .from('promos')
        .update(promo.toUpdate())
        .eq('id', promo.id)
        .select()
        .single();

    return Promo.fromMap((res as Map).cast<String, dynamic>());
  }

  Future<void> deletePromo(String promoId) async {
    await client.from('promos').delete().eq('id', promoId);
  }

  Future<Promo?> getPromoByCode(String code) async {
    final res = await client
        .from('promos')
        .select('*')
        .eq('code', code.trim().toUpperCase())
        .maybeSingle();

    if (res == null) return null;
    return Promo.fromMap((res as Map).cast<String, dynamic>());
  }
}
