import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../local/local_prefs_services.dart';

class ThemeController extends GetxController {
  bool _isDark = false;
  bool get isDark => _isDark;

  ThemeMode get themeMode => _isDark ? ThemeMode.dark : ThemeMode.light;

  @override
  void onInit() {
    super.onInit();
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    _isDark = await LocalPrefsService.isDarkTheme();
    update();
  }

  Future<void> toggleTheme() async {
    _isDark = !_isDark;
    await LocalPrefsService.setDarkTheme(_isDark);
    update();
  }
}
