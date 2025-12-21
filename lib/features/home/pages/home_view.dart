import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';

import '../controller/home_controller.dart';
import '../widgets/menu_card.dart';
import '../../menu/pages/menu_detail_sheet.dart';
import '../../../app/routes/app_routes.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  static const Color _menuGreen = Color(0xFF3E7C3E);

  @override
  Widget build(BuildContext context) {
    final bottomH = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: const Color(0xFF3E7C3E),
      extendBodyBehindAppBar: true,
      floatingActionButton: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFE6F06A).withOpacity(0.5),
              blurRadius: 20,
              spreadRadius: 2,
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
            size: 28,
          ),
        ),
      ),
      bottomNavigationBar: Container(
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
              color: Colors.black.withOpacity(0.4),
              blurRadius: 25,
              offset: const Offset(0, -8),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: EdgeInsets.only(bottom: bottomH),
            child: SizedBox(
              height: 72,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _NavItem(
                    icon: Icons.home_rounded,
                    label: 'Beranda',
                    active: true,
                    onTap: () {},
                  ),
                  _NavItem(
                    icon: Icons.receipt_long_rounded,
                    label: 'Pesanan',
                    active: false,
                    onTap: () => Get.toNamed(AppRoutes.orders),
                  ),
                  _NavItem(
                    icon: Icons.local_offer_rounded,
                    label: 'Promo',
                    active: false,
                    onTap: () => Get.toNamed(AppRoutes.promo),
                  ),
                  _NavItem(
                    icon: Icons.person_rounded,
                    label: 'Profil',
                    active: false,
                    onTap: () => Get.toNamed(AppRoutes.profile),
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
                      fontFamily: 'Montserrat',
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
                    child: const Text(
                      'Coba Lagi',
                      style: TextStyle(fontFamily: 'Montserrat'),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        final items = controller.filteredProducts;

        return CustomScrollView(
          slivers: [
            // ✅ Header pinned (brand + search + notif)
            const _PinnedHeaderSliver(menuGreen: _menuGreen),

            // ✅ Hero carousel (geser auto + manual) di bawah header
            const _HeroCarouselSliver(menuGreen: _menuGreen),

            // ✅ DAFTAR MENU pinned (sticky) & full background #3E7C3E
            SliverPersistentHeader(
              pinned: true,
              delegate: _DaftarMenuHeaderDelegate(
                height: 98,
                bg: _menuGreen,
              ),
            ),

            // ✅ Body menu: background juga sama (#3E7C3E), tanpa subtext
            if (items.isEmpty)
              SliverToBoxAdapter(
                child: Container(
                  color: _menuGreen,
                  padding: const EdgeInsets.fromLTRB(22, 40, 22, 120),
                  child: Column(
                    children: [
                      Icon(
                        Icons.search_off_rounded,
                        size: 76,
                        color: Colors.white.withOpacity(0.38),
                      ),
                      const SizedBox(height: 18),
                      Text(
                        'Tidak ada menu ditemukan',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.82),
                          fontSize: 16,
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Coba kata kunci yang berbeda ya.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.62),
                          fontSize: 13,
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
                sliver: SliverToBoxAdapter(
                  child: Container(
                    color: _menuGreen,
                    child: GridView.builder(
                      itemCount: items.length,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: EdgeInsets.zero,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 18,
                        crossAxisSpacing: 18,
                        childAspectRatio: 0.68,
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
                              barrierColor: Colors.black.withOpacity(0.35),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ),
              ),
          ],
        );
      }),
    );
  }
}

// ================== PINNED HEADER (BRAND + SEARCH + NOTIF) ==================

class _PinnedHeaderSliver extends StatelessWidget {
  final Color menuGreen;
  const _PinnedHeaderSliver({required this.menuGreen});

  @override
  Widget build(BuildContext context) {
    final safeTop = MediaQuery.of(context).padding.top;

    return SliverAppBar(
      pinned: true,
      backgroundColor: menuGreen, // ✅ saat scroll FULL hijau, bukan tembus foto
      elevation: 0,
      automaticallyImplyLeading: false,
      toolbarHeight: 110,
      flexibleSpace: Padding(
        padding: EdgeInsets.only(top: safeTop + 14, left: 20, right: 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Brand kiri
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Lalapan',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.97),
                    fontSize: 30,
                    fontWeight: FontWeight.w400,
                    fontStyle: FontStyle.italic,
                    fontFamily: 'Judson',
                    letterSpacing: 0.6,
                    height: 1.0,
                  ),
                ),
                Text(
                  'Bang Ajey',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 34,
                    fontWeight: FontWeight.w700,
                    fontStyle: FontStyle.italic,
                    fontFamily: 'Judson',
                    letterSpacing: 0.6,
                    height: 1.0,
                  ),
                ),
              ],
            ),

            const SizedBox(width: 14),

            // Search bar (UI tetap, hanya layout)
            Expanded(
              child: _SearchBar(
                onChanged: Get.find<HomeController>().onSearchChanged,
              ),
            ),

            const SizedBox(width: 10),

            const _NotifButton(),
          ],
        ),
      ),
    );
  }
}

// ================== HERO CAROUSEL SLIVER (AUTO + MANUAL) ==================

class _HeroCarouselSliver extends StatefulWidget {
  final Color menuGreen;
  const _HeroCarouselSliver({required this.menuGreen});

  @override
  State<_HeroCarouselSliver> createState() => _HeroCarouselSliverState();
}

class _HeroCarouselSliverState extends State<_HeroCarouselSliver> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  Timer? _autoTimer;

  final List<String> _heroImages = [
    'https://images.unsplash.com/photo-1504674900247-0877df9cc836?auto=format&fit=crop&w=1400&q=80',
    'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?auto=format&fit=crop&w=1400&q=80',
    'https://images.unsplash.com/photo-1567620905732-2d1ec7ab7445?auto=format&fit=crop&w=1400&q=80',
  ];

  @override
  void initState() {
    super.initState();
    _restartAuto();
  }

  void _restartAuto() {
    _autoTimer?.cancel();
    _autoTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      final next = (_currentPage + 1) % _heroImages.length;
      if (_pageController.hasClients) {
        _pageController.animateToPage(
          next,
          duration: const Duration(milliseconds: 420),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _autoTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Stack(
        children: [
          SizedBox(
            height: 320,
            child: NotificationListener<UserScrollNotification>(
              onNotification: (notif) {
                if (notif.direction != ScrollDirection.idle) _restartAuto();
                return false;
              },
              child: PageView.builder(
                controller: _pageController,
                itemCount: _heroImages.length,
                onPageChanged: (i) {
                  setState(() => _currentPage = i);
                  _restartAuto();
                },
                itemBuilder: (context, i) {
                  return Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.network(_heroImages[i], fit: BoxFit.cover),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withOpacity(0.25),
                              Colors.black.withOpacity(0.70),
                            ],
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: Container(
                          height: 64,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                widget.menuGreen.withOpacity(0.95),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),

          // Menu Favorit + dots (hanya di hero)
          Positioned(
            left: 0,
            right: 0,
            bottom: 26,
            child: Column(
              children: [
                Text(
                  'Menu Favorit',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.97),
                    fontSize: 24,
                    fontFamily: 'JimNightshade',
                    letterSpacing: 0.8,
                    shadows: [
                      Shadow(
                        color: Colors.black.withOpacity(0.5),
                        offset: const Offset(0, 2),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                _Dots(currentPage: _currentPage),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ================== PINNED "DAFTAR MENU" HEADER ==================

class _DaftarMenuHeaderDelegate extends SliverPersistentHeaderDelegate {
  final double height;
  final Color bg;

  _DaftarMenuHeaderDelegate({
    required this.height,
    required this.bg,
  });

  @override
  double get minExtent => height;

  @override
  double get maxExtent => height;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: bg, // ✅ full sama (bukan beda shade)
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 14),
      child: Center(
        child: Text(
          'DAFTAR MENU',
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.w900,
            color: const Color(0xFFE6F56C),
            letterSpacing: 2.2,
            fontFamily: 'Montserrat',
            shadows: [
              Shadow(
                color: Colors.black.withOpacity(0.35),
                offset: const Offset(0, 3),
                blurRadius: 6,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(covariant _DaftarMenuHeaderDelegate oldDelegate) {
    return oldDelegate.height != height || oldDelegate.bg != bg;
  }
}

// ================== SMALL WIDGETS ==================

class _SearchBar extends StatelessWidget {
  final ValueChanged<String> onChanged;
  const _SearchBar({required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.14),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(
          color: Colors.white.withOpacity(0.26),
          width: 1.4,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.16),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(
            Icons.search_rounded,
            color: Colors.white.withOpacity(0.85),
            size: 22,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              onChanged: onChanged,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13.5,
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.w500,
              ),
              decoration: const InputDecoration(
                hintText: 'Cari menu…',
                hintStyle: TextStyle(
                  color: Colors.white60,
                  fontSize: 13,
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w400,
                ),
                border: InputBorder.none,
                isDense: true,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NotifButton extends StatelessWidget {
  const _NotifButton();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 46,
      height: 46,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.14),
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white.withOpacity(0.26),
          width: 1.4,
        ),
      ),
      child: IconButton(
        onPressed: () => Get.snackbar(
          'Notifikasi',
          'Belum ada notifikasi baru',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.white,
          colorText: const Color(0xFF1C4A0B),
        ),
        icon: Icon(
          Icons.notifications_none_rounded,
          color: Colors.white.withOpacity(0.78),
          size: 26,
        ),
      ),
    );
  }
}

class _Dots extends StatelessWidget {
  final int currentPage;
  const _Dots({required this.currentPage});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (index) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          width: currentPage == index ? 30 : 8,
          height: 8,
          margin: const EdgeInsets.symmetric(horizontal: 5),
          decoration: BoxDecoration(
            color: currentPage == index
                ? const Color(0xFFE6F06A)
                : Colors.white.withOpacity(0.38),
            borderRadius: BorderRadius.circular(999),
            boxShadow: currentPage == index
                ? [
                    BoxShadow(
                      color: const Color(0xFFE6F06A).withOpacity(0.45),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
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
      borderRadius: BorderRadius.circular(18),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: active ? Colors.white.withOpacity(0.18) : Colors.transparent,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: active ? const Color(0xFFE6F56C) : Colors.white70,
              size: 28,
            ),
            const SizedBox(height: 7),
            Text(
              label,
              style: TextStyle(
                color: active ? const Color(0xFFE6F56C) : Colors.white70,
                fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                fontSize: 10.5,
                letterSpacing: 0.4,
                fontFamily: 'Montserrat',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GlowCircle extends StatelessWidget {
  final double size;
  final double opacity;
  final double blur;
  final double spread;

  const _GlowCircle({
    required this.size,
    required this.opacity,
    required this.blur,
    required this.spread,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withOpacity(opacity),
        boxShadow: [
          BoxShadow(
            color: Colors.white.withOpacity(opacity + 0.06),
            blurRadius: blur,
            spreadRadius: spread,
          ),
        ],
      ),
    );
  }
}
