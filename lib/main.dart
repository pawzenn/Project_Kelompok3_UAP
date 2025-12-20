import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';

import 'firebase_options.dart';
import 'app/routes/app_pages.dart';
import 'app/routes/app_routes.dart';

import 'services/supabase/supabase_service.dart';
import 'core/local/hive_service.dart';

// ✅ CartController global
import 'features/cart/controller/cart_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Supabase init (.env)
  await SupabaseService.instance.init();

  // Hive init
  await HiveService.init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Warung Lalapan',

      // ✅ Pastikan controller cart selalu ada untuk seluruh app
      initialBinding: BindingsBuilder(() {
        Get.put(CartController(), permanent: true);
      }),

      initialRoute: AppRoutes.welcome,
      getPages: AppPages.routes,
    );
  }
}
