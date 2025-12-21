import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../data/models/product.dart';
import '../../data/models/promo.dart';

class SupabaseService {
  SupabaseService._();
  static final SupabaseService instance = SupabaseService._();

  late final SupabaseClient client;

  Future<void> init() async {
    await dotenv.load(fileName: ".env");

    final url = dotenv.env['SUPABASE_URL'];
    final anonKey = dotenv.env['SUPABASE_ANON_KEY'];

    if (url == null || anonKey == null) {
      throw Exception(
          'SUPABASE_URL atau SUPABASE_ANON_KEY belum diset di .env');
    }

    await Supabase.initialize(url: url, anonKey: anonKey);
    client = Supabase.instance.client;
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
  // PROMOS (CRUD)
  // Table: public.promos
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
