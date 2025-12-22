import 'package:get/get.dart';

class CartBinding extends Bindings {
  @override
  void dependencies() {
    // ❌ Jangan daftarkan CartController di sini
    // CartController hanya didaftarkan di HomeBinding
  }
}
