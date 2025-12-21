import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/profile_controller.dart';
import '../../../app/routes/app_routes.dart';

class ProfileView extends GetView<ProfileController> {
  const ProfileView({super.key});

  static const Color _darkGreen = Color(0xFF144100);
  static const Color _brightYellow = Color(0xFFE6F06A);
  static const Color _navGreen = Color(0xFF22590A);

  @override
  Widget build(BuildContext context) {
    final bottomH = MediaQuery.of(context).padding.bottom;
    final safeTop = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 0, 62, 0),
      extendBodyBehindAppBar: true,
      bottomNavigationBar: _buildBottomNav(bottomH),
      body: CustomScrollView(
        slivers: [
          // Header dengan gambar background
          SliverAppBar(
            expandedHeight: 280,
            floating: false,
            pinned: true,
            backgroundColor: _darkGreen,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Background Image
                  Image.network(
                    'https://images.unsplash.com/photo-1504674900247-0877df9cc836?auto=format&fit=crop&w=1400&q=80',
                    fit: BoxFit.cover,
                  ),
                  // Gradient Overlay
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(0.5),
                          _darkGreen.withOpacity(0.9),
                        ],
                      ),
                    ),
                  ),
                  // Content
                  Positioned(
                    bottom: 20,
                    left: 0,
                    right: 0,
                    child: Column(
                      children: [
                        // Avatar
                        Obx(() {
                          return Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: _brightYellow,
                                width: 4,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: _brightYellow.withOpacity(0.4),
                                  blurRadius: 20,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: CircleAvatar(
                              radius: 55,
                              backgroundColor: Colors.white.withOpacity(0.1),
                              backgroundImage: controller
                                      .userAvatar.value.isNotEmpty
                                  ? NetworkImage(controller.userAvatar.value)
                                  : null,
                              child: controller.userAvatar.value.isEmpty
                                  ? Icon(
                                      Icons.person_rounded,
                                      size: 55,
                                      color: Colors.white.withOpacity(0.7),
                                    )
                                  : null,
                            ),
                          );
                        }),
                        const SizedBox(height: 16),
                        // User Name
                        Obx(() {
                          return Text(
                            controller.userName.value,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 0.5,
                            ),
                          );
                        }),
                        const SizedBox(height: 6),
                        // User Email
                        Obx(() {
                          return Text(
                            controller.userEmail.value,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white.withOpacity(0.8),
                              letterSpacing: 0.3,
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                ],
              ),
              // title: Obx(() {
              //   return Text(
              //     controller.userName.value,
              //     style: const TextStyle(
              //       fontSize: 18,
              //       fontWeight: FontWeight.bold,
              //     ),
              //   );
              // }),
            ),
          ),

          // Content Section
          SliverToBoxAdapter(
            child: Container(
              decoration: const BoxDecoration(
                color: _darkGreen,
              ),
              child: Column(
                children: [
                  const SizedBox(height: 24),

                  // Info Card - Hanya Telepon
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Obx(() {
                      return Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: _brightYellow.withOpacity(0.2),
                            width: 1.5,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.phone_rounded,
                              color: _brightYellow,
                              size: 24,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              controller.userPhone.value,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ),

                  const SizedBox(height: 28),

                  // Menu Title
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        Container(
                          width: 4,
                          height: 20,
                          decoration: BoxDecoration(
                            color: _brightYellow,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Pengaturan',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Menu Items
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        // Riwayat Pesanan
                        _MenuItem(
                          icon: Icons.receipt_long_rounded,
                          title: 'Riwayat Pesanan',
                          subtitle: 'Lihat pesanan Anda',
                          onTap: () => Get.toNamed(AppRoutes.orders),
                        ),

                        const SizedBox(height: 12),

                        // Mode Tema
                        Obx(() {
                          return _MenuItemWithSwitch(
                            icon: controller.isDarkMode.value
                                ? Icons.dark_mode_rounded
                                : Icons.light_mode_rounded,
                            title: 'Mode Tema',
                            subtitle: controller.isDarkMode.value
                                ? 'Mode Gelap Aktif'
                                : 'Mode Terang Aktif',
                            value: controller.isDarkMode.value,
                            onChanged: (val) => controller.toggleTheme(),
                          );
                        }),

                        const SizedBox(height: 12),

                        // Notifikasi
                        _MenuItem(
                          icon: Icons.notifications_rounded,
                          title: 'Notifikasi',
                          subtitle: 'Atur preferensi notifikasi',
                          onTap: () {
                            Get.snackbar(
                              'Notifikasi',
                              'Fitur pengaturan notifikasi',
                              backgroundColor: _darkGreen,
                              colorText: Colors.white,
                            );
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Logout Button
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Obx(() {
                      return SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: ElevatedButton(
                          onPressed: controller.isLoading.value
                              ? null
                              : () => _showLogoutDialog(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFD32F2F),
                            foregroundColor: Colors.white,
                            disabledBackgroundColor:
                                const Color(0xFFD32F2F).withOpacity(0.5),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: controller.isLoading.value
                              ? const SizedBox(
                                  height: 24,
                                  width: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                )
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: const [
                                    Icon(Icons.logout_rounded, size: 22),
                                    SizedBox(width: 12),
                                    Text(
                                      'Keluar',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      );
                    }),
                  ),

                  const SizedBox(height: 16),

                  // App Version
                  Text(
                    'Lalapan Bang Ajey v1.0.0',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withOpacity(0.4),
                      letterSpacing: 0.3,
                    ),
                  ),

                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav(double bottomH) {
    return Container(
      decoration: BoxDecoration(
        color: _navGreen,
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
                  active: false,
                  onTap: () => Get.offAllNamed(AppRoutes.home),
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
                  onTap: () => Get.snackbar('Promo', 'Halaman promo'),
                ),
                _NavItem(
                  icon: Icons.person_rounded,
                  label: 'Profil',
                  active: true,
                  onTap: () {},
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    Get.dialog(
      AlertDialog(
        backgroundColor: _darkGreen,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: _brightYellow.withOpacity(0.3),
            width: 1.5,
          ),
        ),
        title: const Text(
          'Keluar?',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: const Text(
          'Apakah Anda yakin ingin keluar dari akun?',
          style: TextStyle(
            color: Colors.white70,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'Batal',
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              controller.logout();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD32F2F),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Keluar'),
          ),
        ],
      ),
    );
  }
}

// Menu Item
class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _MenuItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.white.withOpacity(0.1),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFE6F06A).withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: const Color(0xFFE6F06A),
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      letterSpacing: 0.3,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.white.withOpacity(0.6),
                      letterSpacing: 0.2,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: Colors.white.withOpacity(0.4),
              size: 24,
            ),
          ],
        ),
      ),
    );
  }
}

// Menu Item with Switch
class _MenuItemWithSwitch extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final Function(bool) onChanged;

  const _MenuItemWithSwitch({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFE6F06A).withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: const Color(0xFFE6F06A),
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white.withOpacity(0.6),
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: const Color(0xFFE6F06A),
            activeTrackColor: const Color(0xFF22590A),
            inactiveThumbColor: Colors.white60,
            inactiveTrackColor: Colors.white24,
          ),
        ],
      ),
    );
  }
}

// Bottom Nav Item
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
