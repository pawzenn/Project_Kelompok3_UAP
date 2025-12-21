import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AdminPromoView extends StatelessWidget {
  const AdminPromoView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F0F0F),
        elevation: 0,
        title: const Text('Kelola Promo'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFFE6F06A),
        foregroundColor: const Color(0xFF1C4A0B),
        onPressed: () {
          Get.bottomSheet(
            const _PromoFormSheet(),
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            barrierColor: Colors.black.withOpacity(0.35),
          );
        },
        icon: const Icon(Icons.add_rounded),
        label: const Text(
          'Tambah Promo',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(14),
        children: [
          _PromoCard(
            title: 'Diskon 20%',
            code: 'UAPMOBILE',
            desc: 'Min. belanja 10.000 • Berlaku 1-31 Des',
            active: true,
            onEdit: () => Get.bottomSheet(
              const _PromoFormSheet(),
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              barrierColor: Colors.black.withOpacity(0.35),
            ),
            onToggle: () => Get.snackbar(
                'Promo', 'Toggle aktif/nonaktif (nanti connect DB)'),
          ),
          const SizedBox(height: 12),
          _PromoCard(
            title: 'Diskon 5K',
            code: 'DISKONPELAJAR',
            desc: 'Min. belanja 10.000',
            active: true,
            onEdit: () =>
                Get.snackbar('Edit', 'Buka form edit (nanti connect DB)'),
            onToggle: () => Get.snackbar(
                'Promo', 'Toggle aktif/nonaktif (nanti connect DB)'),
          ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }
}

class _PromoCard extends StatelessWidget {
  final String title;
  final String code;
  final String desc;
  final bool active;
  final VoidCallback onEdit;
  final VoidCallback onToggle;

  const _PromoCard({
    required this.title,
    required this.code,
    required this.desc,
    required this.active,
    required this.onEdit,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF22590A),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFFE6F06A),
              fontWeight: FontWeight.w900,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Text(
                  'KODE: $code',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: active ? const Color(0xFFE6F06A) : Colors.white24,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  active ? 'AKTIF' : 'NONAKTIF',
                  style: TextStyle(
                    color: active ? const Color(0xFF1C4A0B) : Colors.white70,
                    fontWeight: FontWeight.w900,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            desc,
            style: TextStyle(color: Colors.white.withOpacity(0.85)),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onEdit,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFE6F06A),
                    side: BorderSide(color: Colors.white.withOpacity(0.25)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  icon: const Icon(Icons.edit_rounded),
                  label: const Text(
                    'Edit',
                    style: TextStyle(fontWeight: FontWeight.w900),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: onToggle,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE6F06A),
                    foregroundColor: const Color(0xFF1C4A0B),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  icon: const Icon(Icons.power_settings_new_rounded),
                  label: const Text(
                    'Aktif/Off',
                    style: TextStyle(fontWeight: FontWeight.w900),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PromoFormSheet extends StatefulWidget {
  const _PromoFormSheet();

  @override
  State<_PromoFormSheet> createState() => _PromoFormSheetState();
}

class _PromoFormSheetState extends State<_PromoFormSheet> {
  final _code = TextEditingController(text: 'UAPMOBILE');
  final _title = TextEditingController(text: 'Diskon 20%');
  final _minTotal = TextEditingController(text: '10000');
  final _value = TextEditingController(text: '20'); // persen atau nominal
  String _type = 'percent';

  @override
  void dispose() {
    _code.dispose();
    _title.dispose();
    _minTotal.dispose();
    _value.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      padding:
          EdgeInsets.only(left: 16, right: 16, top: 14, bottom: bottom + 16),
      decoration: const BoxDecoration(
        color: Color(0xFF0F0F0F),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56,
            height: 6,
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(999),
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'Form Promo',
            style: TextStyle(
              color: Color(0xFFE6F06A),
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 14),
          _field(label: 'Judul Promo', controller: _title),
          const SizedBox(height: 10),
          _field(label: 'Kode Promo', controller: _code),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _field(
                    label: 'Min. Total', controller: _minTotal, isNumber: true),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _field(
                    label: _type == 'percent' ? 'Persen (%)' : 'Potongan (Rp)',
                    controller: _value,
                    isNumber: true),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: ChoiceChip(
                  label: const Text('Percent'),
                  selected: _type == 'percent',
                  onSelected: (_) => setState(() => _type = 'percent'),
                  selectedColor: const Color(0xFFE6F06A),
                  labelStyle: TextStyle(
                    fontWeight: FontWeight.w900,
                    color: _type == 'percent'
                        ? const Color(0xFF1C4A0B)
                        : Colors.white70,
                  ),
                  backgroundColor: Colors.white12,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ChoiceChip(
                  label: const Text('Amount'),
                  selected: _type == 'amount',
                  onSelected: (_) => setState(() => _type = 'amount'),
                  selectedColor: const Color(0xFFE6F06A),
                  labelStyle: TextStyle(
                    fontWeight: FontWeight.w900,
                    color: _type == 'amount'
                        ? const Color(0xFF1C4A0B)
                        : Colors.white70,
                  ),
                  backgroundColor: Colors.white12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE6F06A),
                foregroundColor: const Color(0xFF1C4A0B),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
              ),
              onPressed: () {
                // nanti: insert/update ke Supabase promos
                Get.back();
                Get.snackbar('Promo', 'Tersimpan (nanti connect DB)');
              },
              child: const Text(
                'Simpan',
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _field({
    required String label,
    required TextEditingController controller,
    bool isNumber = false,
  }) {
    return TextField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        filled: true,
        fillColor: Colors.white12,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.15)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.15)),
        ),
      ),
    );
  }
}
