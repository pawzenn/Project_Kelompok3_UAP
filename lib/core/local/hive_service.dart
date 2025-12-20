import 'package:hive_flutter/hive_flutter.dart';
import '../../data/models/product.dart';

class HiveService {
  static const String _boxName = 'cache_box';
  static const String _productsKey = 'cached_products';

  static late Box _box;

  static Future<void> init() async {
    await Hive.initFlutter();
    _box = await Hive.openBox(_boxName);
  }

  static bool get hasCachedProducts => _box.containsKey(_productsKey);

  static Future<void> cacheProducts(List<Product> products) async {
    final payload = products.map((p) => p.toMap()).toList();
    await _box.put(_productsKey, payload);
  }

  static List<Product> getCachedProducts() {
    final raw = _box.get(_productsKey);
    if (raw is! List) return [];

    final list = raw.map((e) => Map<String, dynamic>.from(e)).toList();
    return list.map(Product.fromMap).toList();
  }

  static Future<void> clearCache() async {
    await _box.delete(_productsKey);
  }
}
