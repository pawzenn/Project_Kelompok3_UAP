import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';

import '../../../core/local/hive_service.dart';
import '../../../data/models/product.dart';
import '../../../services/supabase/supabase_service.dart';

class HomeController extends GetxController {
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  final RxList<Product> products = <Product>[].obs;
  final RxString searchQuery = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchProducts();
  }

  void onSearchChanged(String value) => searchQuery.value = value;

  List<Product> get filteredProducts {
    final q = searchQuery.value.trim().toLowerCase();
    if (q.isEmpty) return products;
    return products.where((p) => p.name.toLowerCase().contains(q)).toList();
  }

  Future<bool> _isOnline() async {
    final result = await Connectivity().checkConnectivity();
    return result != ConnectivityResult.none;
  }

  Future<void> fetchProducts() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final online = await _isOnline();

      if (online) {
        // ✅ 100% dari Supabase: public.products
        final result = await SupabaseService.instance.fetchProducts();

        products.assignAll(result);

        // ✅ cache ke Hive untuk offline mode
        await HiveService.cacheProducts(result);
      } else {
        // ✅ offline: pakai cache lokal
        if (HiveService.hasCachedProducts) {
          products.assignAll(HiveService.getCachedProducts());
        } else {
          errorMessage.value =
              'Tidak ada koneksi internet dan belum ada cache katalog lokal.';
        }
      }
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshProducts() => fetchProducts();
}
