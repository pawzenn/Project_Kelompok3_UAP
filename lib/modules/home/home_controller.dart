import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';

import '../../core/local/hive_service.dart';
import '../../data/models/product.dart';
import '../../data/repositories/product_repository.dart';

class HomeController extends GetxController {
  final ProductRepository _productRepository;

  HomeController({ProductRepository? productRepository})
    : _productRepository = productRepository ?? ProductRepository();

  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxList<Product> products = <Product>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchProducts();
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
        // 1) Ambil dari API (Dio + Supabase products)
        final result = await _productRepository.getChickenMenus();
        products.assignAll(result);

        // 2) Cache ke Hive untuk mode offline
        await HiveService.cacheProducts(result);
      } else {
        // OFFLINE → baca dari Hive
        if (HiveService.hasCachedProducts) {
          final cached = HiveService.getCachedProducts();
          products.assignAll(cached);
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
