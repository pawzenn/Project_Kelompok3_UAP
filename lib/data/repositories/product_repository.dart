import '../models/product.dart';
import '../providers/product_api_provider.dart';

class ProductRepository {
  final ProductApiProvider _apiProvider;

  ProductRepository({ProductApiProvider? apiProvider})
    : _apiProvider = apiProvider ?? ProductApiProvider();

  /// Ambil menu chicken (TheMealDB + harga dari Supabase)
  Future<List<Product>> getChickenMenus() {
    return _apiProvider.fetchChickenMenus();
  }
}
