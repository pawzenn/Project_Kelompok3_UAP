import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'firebase_options.dart';

import 'core/notifications/local_notification_service.dart';
import 'core/notifications/fcm_service.dart';

import 'core/local/hive_service.dart';
import 'core/local/local_prefs_services.dart';

import 'core/supabase/supabase_service.dart';

import 'core/theme/app_theme.dart';
import 'core/theme/theme_controller.dart';

import 'modules/cart/cart_controller.dart';

import 'routes/app_pages.dart';
import 'routes/app_routes.dart';

import 'debug_storage_benchmark.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1) Firebase dulu
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  debugPrint('✅ Firebase initialized: ${Firebase.app().options.projectId}');

  // 2) Background handler (harus sebelum runApp)
  FirebaseMessaging.onBackgroundMessage(FcmService.backgroundHandler);

  // 3) Init local notif + FCM
  await LocalNotificationService.init();
  await FcmService().init();

  // 4) Print token biar kamu bisa copy untuk test Firebase
  try {
    final token = await FirebaseMessaging.instance.getToken();
    debugPrint('✅ FCM Token: $token');

    FirebaseMessaging.instance.onTokenRefresh.listen((t) {
      debugPrint('✅ FCM Token refreshed: $t');
    });
  } catch (e) {
    debugPrint('❌ Failed to get FCM token: $e');
  }

  // 5) Env + services
  await dotenv.load(fileName: '.env');
  await SupabaseService.instance.init();
  await HiveService.init();

  // 6) Tentukan initial route berdasarkan login
  final bool isLoggedIn = await LocalPrefsService.isLoggedIn();
  final String initialRoute = isLoggedIn ? AppRoutes.home : AppRoutes.login;

  // 7) GetX dependencies
  Get.put(ThemeController(), permanent: true);
  Get.put(CartController(), permanent: true);

  runApp(MyApp(initialRoute: initialRoute));

  if (kDebugMode) {
    Future.microtask(runStorageBenchmark);
  }
}

class MyApp extends StatelessWidget {
  final String initialRoute;

  const MyApp({super.key, required this.initialRoute});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ThemeController>(
      builder: (themeController) {
        return GetMaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Lalapan Bang Ajey',
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeController.themeMode,
          initialRoute: initialRoute,
          getPages: AppPages.routes,
        );
      },
    );
  }
}
