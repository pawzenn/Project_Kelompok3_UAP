import 'package:get/get.dart';

class MenuDetailController extends GetxController {
  final RxInt qty = 1.obs;

  void inc() => qty.value++;

  void dec() {
    if (qty.value > 1) qty.value--;
  }
}
