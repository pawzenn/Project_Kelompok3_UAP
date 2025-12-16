import 'package:dio/dio.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/supabase/supabase_service.dart';
import '../models/product.dart';

class ProductApiProvider {
  final Dio _dio;
  final SupabaseClient _client;

  ProductApiProvider({Dio? dio, SupabaseClient? client})
    : _dio = dio ?? Dio(),
      _client = client ?? SupabaseService.instance.client;

  static const _mealDbBaseUrl =
      'https://www.themealdb.com/api/json/v1/1/search.php';

  /// Ambil menu chicken dari TheMealDB,
  /// lalu gabungkan dengan tabel `products` di Supabase (id + price).
  Future<List<Product>> fetchChickenMenus() async {
    try {
      // 1) Panggil API TheMealDB
      final response = await _dio.get(
        _mealDbBaseUrl,
        queryParameters: {'s': 'chicken'},
      );

      final data = response.data;
      final meals = (data['meals'] as List<dynamic>?);

      if (meals == null || meals.isEmpty) {
        return [];
      }

      // 2) Ambil semua idMeal dari API
      final ids = meals
          .map((m) => (m as Map<String, dynamic>)['idMeal']?.toString())
          .whereType<String>()
          .toList();

      if (ids.isEmpty) return [];

      // 3) Query Supabase: tabel `products` (id, price) untuk id-id itu
      final productsRows = await _client
          .from('products')
          .select('id, price')
          .inFilter('id', ids);

      final productsList = List<Map<String, dynamic>>.from(productsRows);

      // bikin map id -> price
      final priceMap = <String, double>{};
      for (final row in productsList) {
        final id = row['id']?.toString();
        final priceNum = row['price'] as num?;
        if (id != null && priceNum != null) {
          priceMap[id] = priceNum.toDouble();
        }
      }

      // 4) Gabungkan hasil API + harga Supabase jadi List<Product>
      final products = <Product>[];

      for (final raw in meals) {
        final meal = raw as Map<String, dynamic>;
        final idMeal = meal['idMeal']?.toString();
        if (idMeal == null) continue;

        // kalau id tidak ada di tabel products, bisa:
        // a) skip, atau b) kasih harga default.
        // di sini kita pilih: kalau tak ada, skip.
        final price = priceMap[idMeal];
        if (price == null) continue;

        products.add(
          Product(
            id: idMeal,
            name: meal['strMeal']?.toString() ?? 'Tanpa Nama',
            description: meal['strInstructions']?.toString(),
            price: price,
            imageUrl: meal['strMealThumb']?.toString(),
            category: meal['strCategory']?.toString(),
          ),
        );
      }

      return products;
    } on DioException catch (e) {
      throw Exception('Gagal memuat data dari API: ${e.message}');
    } on PostgrestException catch (e) {
      throw Exception('Gagal memuat harga dari Supabase: ${e.message}');
    } catch (e) {
      throw Exception('Terjadi kesalahan saat memuat menu: $e');
    }
  }
}
