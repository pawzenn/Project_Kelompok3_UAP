import 'dart:ui';
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
  static const Color _darkGreen = Color(0xFF144100);
  static const Color _brightYellow = Color(0xFFE6F06A);

  @override
  Widget build(BuildContext context) {
    final bottomH = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 0, 62, 0),
      extendBodyBehindAppBar: true,
      floatingActionButton: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: _brightYellow.withOpacity(0.5),
              blurRadius: 20,
              spreadRadius: 2,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: FloatingActionButton(
          backgroundColor: _brightYellow,
          elevation: 0,
          onPressed: () => Get.toNamed(AppRoutes.cart),
          child: const Icon(
            Icons.shopping_cart_outlined,
            color: Color(0xFF22590A),
            size: 28,
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNav(bottomH),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(_brightYellow),
            ),
          );
        }

        if (controller.errorMessage.value.isNotEmpty) {
          return _buildErrorState();
        }

        final items = controller.filteredProducts;

        return CustomScrollView(
          slivers: [
            // Collapsible Header dengan Carousel
            _CollapsibleCarouselHeaderSliver(),

            // Container Menu
            SliverToBoxAdapter(
              child: Container(
                decoration: const BoxDecoration(
                  color: _darkGreen,
                ),
                child: Column(
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(top: 24, bottom: 8),
                      child: Text(
                        'DAFTAR MENU',
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFFE6F06A),
                          letterSpacing: 1.8,
                          fontFamily: 'Montserrat',
                        ),
                      ),
                    ),

                    // Grid Menu
                    Container(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 98),
                      child: items.isEmpty
                          ? _buildNoItemsState()
                          : GridView.builder(
                              itemCount: items.length,
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                mainAxisSpacing: 12,
                                crossAxisSpacing: 12,
                                childAspectRatio: 0.76,
                              ),
                              itemBuilder: (context, i) {
                                final p = items[i];
                                return _MenuCardNew(
                                  title: p.name,
                                  price: p.price,
                                  imageUrl: p.imageUrl,
                                  onTap: () {
                                    Get.bottomSheet(
                                      MenuDetailSheet(product: p),
                                      isScrollControlled: true,
                                      backgroundColor: Colors.transparent,
                                    );
                                  },
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildBottomNav(double bottomH) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF22590A),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, -8),
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
    );
  }

  Widget _buildErrorState() {
    return Center(
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
            style: const TextStyle(
              color: Colors.white,
              fontFamily: 'Montserrat',
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: controller.refreshProducts,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE6F06A),
              foregroundColor: const Color(0xFF144100),
            ),
            child: const Text('Coba Lagi'),
          ),
        ],
      ),
    );
  }

  Widget _buildNoItemsState() {
    return Column(
      children: [
        Icon(
          Icons.search_off_rounded,
          size: 76,
          color: Colors.white.withOpacity(0.38),
        ),
        const SizedBox(height: 18),
        const Text(
          'Tidak ada menu ditemukan',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

// ================== COLLAPSIBLE CAROUSEL HEADER ==================

class _CollapsibleCarouselHeaderSliver extends StatefulWidget {
  @override
  State<_CollapsibleCarouselHeaderSliver> createState() =>
      _CollapsibleCarouselHeaderSliverState();
}

class _CollapsibleCarouselHeaderSliverState
    extends State<_CollapsibleCarouselHeaderSliver> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  Timer? _autoTimer;

  final List<String> _heroImages = [
    'https://sljlklzqxsxrtfmumnhd.supabase.co/storage/v1/object/public/produk-bangajey/AyamCrispy.jpg',
    'https://sljlklzqxsxrtfmumnhd.supabase.co/storage/v1/object/public/produk-bangajey/AyamBakar.avif',
    'https://sljlklzqxsxrtfmumnhd.supabase.co/storage/v1/object/public/produk-bangajey/AyamGeprek.jpg',
  ];

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _autoTimer?.cancel();
    _autoTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (_pageController.hasClients) {
        _pageController.animateToPage(
          (_currentPage + 1) % _heroImages.length,
          duration: const Duration(milliseconds: 500),
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
    final safeTop = MediaQuery.of(context).padding.top;

    return SliverAppBar(
      expandedHeight: 280,
      floating: false,
      pinned: true,
      backgroundColor: const Color(0xFF144100),
      flexibleSpace: LayoutBuilder(
        builder: (context, constraints) {
          // Hitung progress collapse (0.0 = expanded, 1.0 = collapsed)
          final top = constraints.biggest.height;
          final progress =
              ((top - kToolbarHeight - safeTop) / (280 - kToolbarHeight))
                  .clamp(0.0, 1.0);

          return FlexibleSpaceBar(
            background: Stack(
              fit: StackFit.expand,
              children: [
                // Carousel Images
                PageView.builder(
                  controller: _pageController,
                  itemCount: _heroImages.length,
                  onPageChanged: (i) => setState(() => _currentPage = i),
                  itemBuilder: (context, i) => Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.network(_heroImages[i], fit: BoxFit.cover),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withOpacity(0.3),
                              Colors.black.withOpacity(0.7),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Header Content (Logo, Search, Notif)
                Positioned(
                  top: safeTop + 10,
                  left: 16,
                  right: 16,
                  child: Opacity(
                    opacity: progress,
                    child: Row(
                      children: [
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Lalapan',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontStyle: FontStyle.italic,
                                fontFamily: 'Judson',
                              ),
                            ),
                            Text(
                              'Bang Ajey',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                fontStyle: FontStyle.italic,
                                fontFamily: 'Judson',
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _SearchBar(
                            onChanged:
                                Get.find<HomeController>().onSearchChanged,
                          ),
                        ),
                        const SizedBox(width: 10),
                        const _NotifButton(),
                      ],
                    ),
                  ),
                ),

                // Center Text "Menu Favorit" & Dots
                Positioned(
                  bottom: 40,
                  left: 0,
                  right: 0,
                  child: Opacity(
                    opacity: progress,
                    child: Column(
                      children: [
                        const Text(
                          'Menu Favorit',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 36,
                            fontFamily: 'JimNightshade',
                            fontStyle: FontStyle.italic,
                            shadows: [
                              Shadow(
                                color: Colors.black54,
                                blurRadius: 8,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        _Dots(currentPage: _currentPage),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            // Title yang muncul saat collapsed
            titlePadding: EdgeInsets.only(left: 16, bottom: 16),
            title: Opacity(
              opacity: 1 - progress,
              child: Row(
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Lalapan',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontStyle: FontStyle.italic,
                          fontFamily: 'Judson',
                        ),
                      ),
                      Text(
                        'Bang Ajey',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          fontStyle: FontStyle.italic,
                          fontFamily: 'Judson',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
      // Actions untuk search dan notif saat collapsed
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 8),
          child: _SearchBar(
            onChanged: Get.find<HomeController>().onSearchChanged,
            compact: true,
          ),
        ),
        const Padding(
          padding: EdgeInsets.only(right: 16),
          child: _NotifButton(),
        ),
      ],
    );
  }
}

// ================== MENU CARD ==================

class _MenuCardNew extends StatelessWidget {
  final String title;
  final int price;
  final String imageUrl;
  final VoidCallback onTap;

  const _MenuCardNew({
    required this.title,
    required this.price,
    required this.imageUrl,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 5),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(20)),
                child: imageUrl.isEmpty
                    ? Container(
                        color: Colors.grey[200],
                        child: const Icon(Icons.fastfood, color: Colors.grey),
                      )
                    : Image.network(imageUrl, fit: BoxFit.cover),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF144100),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Rp ${_formatPrice(price)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatPrice(int price) {
    return price.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        );
  }
}

// ================== SMALL UTILS ==================

class _SearchBar extends StatelessWidget {
  final ValueChanged<String> onChanged;
  final bool compact;

  const _SearchBar({
    required this.onChanged,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    if (compact) {
      return Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.25),
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.white.withOpacity(0.4),
            width: 1.5,
          ),
        ),
        child: const Icon(Icons.search, color: Colors.white, size: 20),
      );
    }

    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.25),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: Colors.white.withOpacity(0.4),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.search, color: Colors.white, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              onChanged: onChanged,
              style: const TextStyle(color: Colors.white, fontSize: 14),
              decoration: const InputDecoration(
                hintText: 'Cari menu...',
                hintStyle: TextStyle(color: Colors.white70),
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
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.25),
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white.withOpacity(0.4),
          width: 1.5,
        ),
      ),
      child:
          const Icon(Icons.notifications_none, color: Colors.white, size: 22),
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
      children: List.generate(
        3,
        (i) => AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 5),
          width: currentPage == i ? 28 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: currentPage == i
                ? const Color(0xFFE6F06A)
                : Colors.white.withOpacity(0.5),
            borderRadius: BorderRadius.circular(4),
            boxShadow: currentPage == i
                ? [
                    BoxShadow(
                      color: const Color(0xFFE6F06A).withOpacity(0.5),
                      blurRadius: 8,
                      spreadRadius: 1,
                    )
                  ]
                : null,
          ),
        ),
      ),
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
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: active ? const Color(0xFFE6F56C) : Colors.white60,
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: active ? const Color(0xFFE6F56C) : Colors.white60,
              fontSize: 10,
              fontWeight: active ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
