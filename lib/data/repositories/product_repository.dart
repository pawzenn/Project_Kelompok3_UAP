import '../models/product.dart';
import '../providers/product_api_provider.dart';

class ProductRepository {
  final ProductApiProvider _apiProvider;

  ProductRepository({ProductApiProvider? apiProvider})
      : _apiProvider = apiProvider ?? ProductApiProvider();

  Future<List<Product>> getProducts() => _apiProvider.fetchProducts();
}
