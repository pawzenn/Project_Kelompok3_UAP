import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/product.dart';

class ProductApiProvider {
  final SupabaseClient _client = Supabase.instance.client;

  Future<List<Product>> fetchProducts() async {
    final res = await _client
        .from('products')
        .select('id, name, category, area, image_url, price')
        .order('id', ascending: true);

    final list = (res as List)
        .map((e) => Product.fromMap(Map<String, dynamic>.from(e)))
        .toList();

    return list;
  }
}
