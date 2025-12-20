import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../data/models/product.dart'; // ✅ sesuaikan path Product kamu

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
  // ✅ AMBIL SEMUA MENU DARI public.products
  // =========================================================
  Future<List<Product>> fetchProducts() async {
    final res = await client
        .from('products')
        .select('id, name, category, area, image_url, price')
        .order('price', ascending: false);

    final list = (res as List).cast<Map<String, dynamic>>();
    return list.map((e) => Product.fromMap(e)).toList();
  }
}
