import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/theme/theme_controller.dart';
import '../../routes/app_routes.dart';
import '../../data/models/product.dart';
import '../cart/cart_controller.dart';
import 'home_controller.dart';

class HomeView extends GetView<HomeController> {
  HomeView({super.key});

  final CartController _cartController = Get.find<CartController>();

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final orientation = media.orientation;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lalapan Bang Ajey'),
        actions: [
          // refresh
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => controller.refreshProducts(),
          ),

          // theme switch
          GetBuilder<ThemeController>(
            builder: (tc) => IconButton(
              icon: Icon(tc.isDark ? Icons.dark_mode : Icons.light_mode),
              onPressed: () => tc.toggleTheme(),
            ),
          ),

          // BADGE keranjang
          Obx(() {
            final count = _cartController.totalQuantity;

            return Stack(
              children: [
                IconButton(
                  icon: const Icon(Icons.shopping_cart),
                  onPressed: () => Get.toNamed(AppRoutes.cart),
                ),
                if (count > 0)
                  Positioned(
                    right: 6,
                    top: 6,
                    child: CircleAvatar(
                      radius: 10,
                      backgroundColor: Colors.red,
                      child: Text(
                        '$count',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ),
              ],
            );
          }),

          // 🔹 TOMBOL BARU: menu fitur lokasi (Modul 5)
          IconButton(
            icon: const Icon(Icons.location_on_outlined),
            tooltip: 'Fitur Lokasi',
            onPressed: () => Get.toNamed(AppRoutes.locationMenu),
          ),

          // 🔔 NOTIFIKASI
          IconButton(
            icon: const Icon(Icons.notifications),
            tooltip: 'Notifikasi',
            onPressed: () => Get.toNamed(AppRoutes.notificationMenu),
          ),

          // profil
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () => Get.toNamed(AppRoutes.profile),
          ),
        ],
      ),

      body: Obx(() {
        final products = controller.products;

        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.errorMessage.isNotEmpty) {
          return Center(child: Text(controller.errorMessage.value));
        }

        if (products.isEmpty) {
          return const Center(child: Text("Menu belum tersedia."));
        }

        return LayoutBuilder(
          builder: (context, constraints) {
            int crossAxisCount = constraints.maxWidth < 600
                ? 2
                : constraints.maxWidth < 900
                ? 3
                : 4;

            return GridView.builder(
              padding: const EdgeInsets.all(12),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: orientation == Orientation.portrait
                    ? 0.75
                    : 1.1,
              ),
              itemCount: products.length,
              itemBuilder: (context, index) {
                final p = products[index];
                return _ProductCard(
                  product: p,
                  onAdd: () => _cartController.addProduct(p),
                );
              },
            );
          },
        );
      }),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onAdd;

  const _ProductCard({super.key, required this.product, required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: Column(
        children: [
          Expanded(
            child: product.imageUrl != null
                ? Image.network(
                    product.imageUrl!,
                    fit: BoxFit.cover,
                    width: double.infinity,
                  )
                : const Icon(Icons.fastfood, size: 42),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              product.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Text(
            "Rp ${product.price.toStringAsFixed(0)}",
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          IconButton(
            icon: const Icon(Icons.add_shopping_cart),
            onPressed: onAdd,
          ),
        ],
      ),
    );
  }
}
