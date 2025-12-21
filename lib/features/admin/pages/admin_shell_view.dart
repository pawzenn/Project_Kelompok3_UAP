import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'admin_orders_view.dart';
import 'admin_promo_view.dart';

class AdminShellController extends GetxController {
  final RxInt index = 0.obs;
  void setIndex(int i) => index.value = i;
}

class AdminShellView extends GetView<AdminShellController> {
  const AdminShellView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      body: Obx(() {
        return IndexedStack(
          index: controller.index.value,
          children: const [
            AdminOrdersView(),
            AdminPromoView(),
          ],
        );
      }),
      bottomNavigationBar: Obx(() {
        final active = controller.index.value;
        return Container(
          height: 74,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF22590A),
                Color(0xFF1C4A0B),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.35),
                blurRadius: 18,
                offset: const Offset(0, -6),
              ),
            ],
          ),
          child: SafeArea(
            top: false,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _NavItem(
                  icon: Icons.receipt_long_rounded,
                  label: 'PESANAN',
                  active: active == 0,
                  onTap: () => controller.setIndex(0),
                ),
                _NavItem(
                  icon: Icons.local_offer_rounded,
                  label: 'PROMO',
                  active: active == 1,
                  onTap: () => controller.setIndex(1),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: active ? Colors.white.withOpacity(0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: active ? const Color(0xFFE6F06A) : Colors.white70,
              size: 28,
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                color: active ? const Color(0xFFE6F06A) : Colors.white70,
                fontWeight: active ? FontWeight.w900 : FontWeight.w700,
                fontSize: 11,
                letterSpacing: 0.6,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
