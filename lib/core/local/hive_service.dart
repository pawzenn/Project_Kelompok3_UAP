import 'package:hive_flutter/hive_flutter.dart';

import '../../data/models/product.dart';

class HiveService {
  HiveService._();

  static const String productsBoxName = 'products_box';

  /// Panggil sekali di main(), setelah WidgetsFlutterBinding.ensureInitialized()
  static Future<void> init() async {
    await Hive.initFlutter();

    // Register adapter Product kalau belum
    if (!Hive.isAdapterRegistered(2)) {
      // 2 = typeId Product
      Hive.registerAdapter(ProductAdapter());
    }

    // Buka box products
    await Hive.openBox<Product>(productsBoxName);
  }

  static Box<Product> get _productsBox => Hive.box<Product>(productsBoxName);

  /// Simpan list produk ke Hive (cache terbaru)
  static Future<void> cacheProducts(List<Product> products) async {
    final box = _productsBox;
    await box.clear();
    await box.addAll(products);
  }

  /// Ambil semua produk dari cache Hive
  static List<Product> getCachedProducts() {
    final box = _productsBox;
    return box.values.toList();
  }

  /// Cek apakah sudah ada data katalog di Hive
  static bool get hasCachedProducts {
    final box = _productsBox;
    return box.isNotEmpty;
  }
}
