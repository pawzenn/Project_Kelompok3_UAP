import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'firebase_options.dart';

import 'app/routes/app_pages.dart';
import 'app/routes/app_routes.dart';

// ✅ services
import 'core/local/hive_service.dart';
import '/services/supabase/supabase_service.dart';

// ✅ notif
import 'core/notification/local_notification_service.dart';
import 'core/notification/fcm_service.dart';

/// ✅ Background handler WAJIB top-level + entrypoint
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // kalau mau save notif ke RTDB saat background, biasanya via backend/cloud function
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ background handler
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  // 1) Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // 2) Hive (WAJIB sebelum ada yang manggil cache)
  await HiveService.init();

  // 3) Supabase (biar client gak LateInit)
  await SupabaseService.instance.init();

  // 4) Local Notif (banner + sound)
  await LocalNotificationService.init();

  // 5) FCM (permission + token + listener foreground)
  await FCMService.init(
    onToken: (token) {
      debugPrint('🔥 FCM TOKEN (main): $token');
    },
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: AppRoutes.welcome,
      getPages: AppPages.routes,
    );
  }
}
