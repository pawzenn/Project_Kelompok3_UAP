import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controller/home_controller.dart';
import '../widgets/menu_card.dart';
import '../../menu/pages/menu_detail_sheet.dart';
import '../../../app/routes/app_routes.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final bottomH = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      extendBodyBehindAppBar: true,
      floatingActionButton: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFE6F06A).withOpacity(0.4),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: FloatingActionButton(
          backgroundColor: const Color(0xFFE6F06A),
          elevation: 0,
          onPressed: () => Get.toNamed(AppRoutes.cart),
          child: const Icon(
            Icons.shopping_cart_outlined,
            color: Color(0xFF1C4A0B),
            size: 26,
          ),
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFF22590A),
              const Color(0xFF1C4A0B),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: EdgeInsets.only(bottom: bottomH),
            child: SizedBox(
              height: 70,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _NavItem(
                    icon: Icons.home_rounded,
                    label: 'HOME',
                    active: true,
                    onTap: () {},
                  ),
                  _NavItem(
                    icon: Icons.local_offer_rounded,
                    label: 'PROMO',
                    active: false,
                    onTap: () => Get.snackbar('Promo', 'Nanti ke promo_view'),
                  ),
                  _NavItem(
                    icon: Icons.receipt_long_rounded,
                    label: 'RIWAYAT',
                    active: false,
                    onTap: () => Get.toNamed(AppRoutes.orders),
                  ),
                  _NavItem(
                    icon: Icons.person_rounded,
                    label: 'PROFIL',
                    active: false,
                    onTap: () =>
                        Get.snackbar('Profil', 'Nanti ke profile_view'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFE6F06A)),
            ),
          );
        }

        if (controller.errorMessage.value.isNotEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.error_outline_rounded,
                    size: 64,
                    color: Colors.white.withOpacity(0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    controller.errorMessage.value,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: controller.refreshProducts,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF22590A),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Coba Lagi'),
                  ),
                ],
              ),
            ),
          );
        }

        final items = controller.filteredProducts;

        return SingleChildScrollView(
          child: Column(
            children: [
              // Hero Section - Full Width
              Stack(
                children: [
                  SizedBox(
                    height: 400,
                    width: double.infinity,
                    child: Image.network(
                      'https://images.unsplash.com/photo-1504674900247-0877df9cc836?auto=format&fit=crop&w=1400&q=80',
                      fit: BoxFit.cover,
                    ),
                  ),
                  Container(
                    height: 400,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(0.2),
                          Colors.black.withOpacity(0.7),
                        ],
                      ),
                    ),
                  ),

                  // Branding
                  SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 24, left: 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Lalapan',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.95),
                              fontSize: 28,
                              fontWeight: FontWeight.w300,
                              letterSpacing: 0.5,
                              height: 1.1,
                            ),
                          ),
                          Text(
                            'Bang Ajey',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.5,
                              height: 1.1,
                              shadows: [
                                Shadow(
                                  color: Colors.black.withOpacity(0.3),
                                  offset: const Offset(0, 2),
                                  blurRadius: 8,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Search bar & Notification
                  SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 24, right: 16),
                      child: Row(
                        children: [
                          const SizedBox(width: 180),
                          Expanded(
                            child: Container(
                              height: 48,
                              margin: const EdgeInsets.only(right: 8),
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.2),
                                  width: 1,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: TextField(
                                      onChanged: controller.onSearchChanged,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 13,
                                      ),
                                      decoration: const InputDecoration(
                                        hintText: 'Cari menu favorit...',
                                        hintStyle: TextStyle(
                                          color: Colors.white60,
                                          fontSize: 13,
                                        ),
                                        border: InputBorder.none,
                                        isDense: true,
                                      ),
                                    ),
                                  ),
                                  Icon(
                                    Icons.search_rounded,
                                    color: Colors.white.withOpacity(0.8),
                                    size: 22,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.12),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white.withOpacity(0.2),
                                width: 1,
                              ),
                            ),
                            child: IconButton(
                              onPressed: () => Get.snackbar(
                                'Notifikasi',
                                'Nanti isi notifikasi/promo',
                              ),
                              icon: Icon(
                                Icons.notifications_none_rounded,
                                color: Colors.white.withOpacity(0.9),
                                size: 24,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Menu Favorit Section
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 40,
                    child: Column(
                      children: [
                        Text(
                          '~ Menu Favorit ~',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.95),
                            fontSize: 17,
                            fontStyle: FontStyle.italic,
                            fontWeight: FontWeight.w400,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 14),
                        const _Dots(),
                      ],
                    ),
                  ),
                ],
              ),

              // Menu Section
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(18, 32, 18, 32),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      const Color(0xFF22590A),
                      const Color(0xFF1C4A0B),
                    ],
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      'DAFTAR MENU',
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFFE6F06A),
                        letterSpacing: 2,
                        shadows: [
                          Shadow(
                            color: Colors.black.withOpacity(0.3),
                            offset: const Offset(0, 2),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    GridView.builder(
                      itemCount: items.length,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: EdgeInsets.zero,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 18,
                        crossAxisSpacing: 18,
                        childAspectRatio: 0.70,
                      ),
                      itemBuilder: (_, i) {
                        final p = items[i];
                        return MenuCard(
                          title: p.name,
                          price: p.price,
                          imageUrl: p.imageUrl,
                          onTap: () {
                            Get.bottomSheet(
                              MenuDetailSheet(product: p),
                              isScrollControlled: true,
                              backgroundColor: Colors.transparent,
                              barrierColor: Colors.black
                                  .withOpacity(0.35), // gelap tipis biar fokus
                            );
                          },
                        );
                      },
                    ),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ],
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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
              size: 26,
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                color: active ? const Color(0xFFE6F06A) : Colors.white70,
                fontWeight: active ? FontWeight.w800 : FontWeight.w600,
                fontSize: 10,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Dots extends StatelessWidget {
  const _Dots();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _dot(active: false),
        const SizedBox(width: 10),
        _dot(active: true),
        const SizedBox(width: 10),
        _dot(active: false),
      ],
    );
  }

  Widget _dot({required bool active}) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: active ? 28 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: active ? const Color(0xFFE6F06A) : Colors.white.withOpacity(0.4),
        borderRadius: BorderRadius.circular(999),
        boxShadow: active
            ? [
                BoxShadow(
                  color: const Color(0xFFE6F06A).withOpacity(0.4),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
    );
  }
}
