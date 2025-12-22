import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../auth/controller/auth_controller.dart';
import '../../../app/routes/app_routes.dart';

import '../controller/admin_orders_controller.dart';
import '../controller/admin_promo_controller.dart';

import 'admin_orders_view.dart';
import 'admin_promo_view.dart';

class AdminShellView extends StatefulWidget {
  const AdminShellView({super.key});

  @override
  State<AdminShellView> createState() => _AdminShellViewState();
}

class _AdminShellViewState extends State<AdminShellView> {
  int index = 0;

  Future<void> _confirmLogout() async {
    final ok = await Get.dialog<bool>(
      AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: const Text('Logout', style: TextStyle(color: Colors.white)),
        content: const Text(
          'Yakin ingin logout?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: const Text(
              'Logout',
              style: TextStyle(color: Colors.redAccent),
            ),
          ),
        ],
      ),
    );

    if (ok != true) return;

    final auth = Get.find<AuthController>();

    try {
      await auth.logout();
      Get.offAllNamed(AppRoutes.login);
    } catch (e) {
      Get.snackbar(
        'Logout gagal',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void _onNavTap(int i) async {
    setState(() => index = i);

    // ✅ AUTO REFRESH saat pindah tab
    if (i == 0) {
      // tab Pesanan
      final c = Get.find<AdminOrdersController>();
      await c.fetchOrders();
    } else if (i == 1) {
      // tab Promo
      final c = Get.find<AdminPromoController>();
      await c.loadPromos();
    }
  }

  @override
  Widget build(BuildContext context) {
    final pages = const [
      AdminOrdersView(),
      AdminPromoView(),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F0F0F),
        elevation: 0,
        title: const Text('Admin'),
        actions: [
          IconButton(
            onPressed: _confirmLogout,
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: pages[index],
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Color(0xFF0F0F0F),
          border: Border(top: BorderSide(color: Colors.white12)),
        ),
        child: BottomNavigationBar(
          currentIndex: index,
          onTap: _onNavTap, // ✅ pakai handler baru
          backgroundColor: const Color(0xFF0F0F0F),
          selectedItemColor: const Color(0xFFE6F06A),
          unselectedItemColor: Colors.white54,
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.receipt_long),
              label: 'Pesanan',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.local_offer),
              label: 'Promo',
            ),
          ],
        ),
      ),
    );
  }
}
