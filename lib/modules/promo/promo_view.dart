import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PromoView extends StatelessWidget {
  const PromoView({super.key});

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments; // kalau notif ngirim data, bisa kebaca di sini

    return Scaffold(
      appBar: AppBar(title: const Text('Promo')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: Theme.of(context).colorScheme.surface,
              border: Border.all(color: Theme.of(context).dividerColor),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Promo Spesial Hari Ini 🎉',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Diskon 30% untuk pembelian tertentu. Klik tombol di bawah untuk klaim!',
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () {
                    Get.snackbar('Promo', 'Promo berhasil diklaim ✅');
                  },
                  icon: const Icon(Icons.local_offer),
                  label: const Text('Klaim Promo'),
                ),
                const SizedBox(height: 12),
                Text(
                  'Args (opsional): ${args ?? "-"}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).hintColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
