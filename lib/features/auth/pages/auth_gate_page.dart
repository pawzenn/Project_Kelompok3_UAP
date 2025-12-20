import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../controller/auth_controller.dart';

class AuthGatePage extends GetView<AuthController> {
  const AuthGatePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final loggedIn = controller.isLoggedIn;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (loggedIn) {
          Get.offAllNamed(AppRoutes.home);
        } else {
          // ↓ UBAH DARI login KE welcome
          Get.offAllNamed(AppRoutes.welcome);
        }
      });

      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    });
  }
}
