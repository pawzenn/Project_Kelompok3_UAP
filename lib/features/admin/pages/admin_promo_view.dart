import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controller/admin_promo_controller.dart';
import '../../../data/models/promo.dart';

class AdminPromoView extends GetView<AdminPromoController> {
  const AdminPromoView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F0F0F),
        elevation: 0,
        title: const Text('Kelola Promo'),
        actions: [
          IconButton(
            onPressed: controller.loadPromos,
            icon: const Icon(Icons.refresh),
          ),
          const SizedBox(width: 6),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFFE6F06A),
        foregroundColor: const Color(0xFF1C4A0B),
        onPressed: () => _openForm(context),
        child: const Icon(Icons.add),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation(Color(0xFFE6F06A)),
            ),
          );
        }

        final list = controller.promos;

        if (list.isEmpty) {
          return const Center(
            child: Text(
              'Belum ada promo',
              style: TextStyle(color: Colors.white70),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: list.length,
          itemBuilder: (_, i) {
            final p = list[i];
            final badge = p.isActive ? 'AKTIF' : 'NONAKTIF';

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A1A),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Colors.white10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          p.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: p.isActive
                              ? const Color(0xFF22590A)
                              : Colors.white12,
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(color: Colors.white12),
                        ),
                        child: Text(
                          badge,
                          style: TextStyle(
                            color: p.isActive
                                ? const Color(0xFFE6F06A)
                                : Colors.white70,
                            fontWeight: FontWeight.w900,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Kode: ${p.code}',
                    style: const TextStyle(
                      color: Color(0xFFE6F06A),
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _descLine(p),
                    style: const TextStyle(color: Colors.white70),
                  ),
                  if ((p.description ?? '').trim().isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      p.description!,
                      style: const TextStyle(
                        color: Colors.white60,
                        height: 1.3,
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => _openForm(context, existing: p),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFFE6F06A),
                            side: const BorderSide(color: Color(0xFFE6F06A)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: const Text(
                            'Edit',
                            style: TextStyle(fontWeight: FontWeight.w900),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => controller.toggleActive(p),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                            side: const BorderSide(color: Colors.white24),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: Text(
                            p.isActive ? 'Nonaktifkan' : 'Aktifkan',
                            style: const TextStyle(fontWeight: FontWeight.w900),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      IconButton(
                        onPressed: () => _confirmDelete(context, p),
                        icon: const Icon(Icons.delete, color: Colors.redAccent),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      }),
    );
  }

  String _descLine(Promo p) {
    final diskon = p.type == 'percent' ? '${p.value}%' : 'Rp${p.value}';
    final min = 'Min Rp${p.minOrder}';
    final max = (p.type == 'percent' && p.maxDiscount != null)
        ? ' • Maks Rp${p.maxDiscount}'
        : '';
    return '$diskon • $min$max';
  }

  void _confirmDelete(BuildContext context, Promo promo) {
    Get.dialog(
      AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: const Text('Hapus Promo', style: TextStyle(color: Colors.white)),
        content: Text(
          'Yakin hapus promo ${promo.code}?',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: Get.back,
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () async {
              Get.back();
              await controller.removePromo(promo);
            },
            child: const Text(
              'Hapus',
              style: TextStyle(color: Colors.redAccent),
            ),
          ),
        ],
      ),
    );
  }

  void _openForm(BuildContext context, {Promo? existing}) {
    final isEdit = existing != null;

    final codeC = TextEditingController(text: existing?.code ?? '');
    final titleC = TextEditingController(text: existing?.title ?? '');
    final descC = TextEditingController(text: existing?.description ?? '');
    final valueC = TextEditingController(
      text: existing == null ? '' : existing.value.toString(),
    );
    final minC = TextEditingController(
      text: existing == null ? '10000' : existing.minOrder.toString(),
    );
    final maxC = TextEditingController(
      text: existing?.maxDiscount?.toString() ?? '',
    );

    // ✅ FIX: DB kamu pakai 'fixed' & 'percent'
    String type = existing?.type ?? 'fixed';
    if (type != 'fixed' && type != 'percent') {
      type = 'fixed';
    }

    bool active = existing?.isActive ?? true;

    Get.bottomSheet(
      StatefulBuilder(
        builder: (_, setState) {
          return Container(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 18),
            decoration: const BoxDecoration(
              color: Color(0xFF1A1A1A),
              borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
            ),
            child: SafeArea(
              top: false,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 46,
                        height: 5,
                        decoration: BoxDecoration(
                          color: Colors.white24,
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      isEdit ? 'Edit Promo' : 'Tambah Promo',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 14),
                    _field('Kode Promo', codeC, hint: 'UAPMOBILE'),
                    const SizedBox(height: 10),
                    _field('Judul', titleC, hint: 'Diskon Akhir Tahun'),
                    const SizedBox(height: 10),
                    _field(
                      'Deskripsi (opsional)',
                      descC,
                      hint: 'Syarat & ketentuan',
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _dropdown(
                            label: 'Tipe',
                            value: type,
                            items: const [
                              DropdownMenuItem(
                                value: 'fixed',
                                child: Text('Potongan nominal'),
                              ),
                              DropdownMenuItem(
                                value: 'percent',
                                child: Text('Potongan persen'),
                              ),
                            ],
                            onChanged: (v) => setState(() {
                              type = v ?? 'fixed';
                              if (type == 'fixed') {
                                maxC.text = '';
                              }
                            }),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _field(
                            'Nilai',
                            valueC,
                            hint: type == 'percent' ? '20' : '5000',
                            keyboard: TextInputType.number,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: _field(
                            'Min Order',
                            minC,
                            hint: '10000',
                            keyboard: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _field(
                            'Maks Diskon (opsional)',
                            maxC,
                            hint: '20000',
                            keyboard: TextInputType.number,
                            enabled: type == 'percent',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    SwitchListTile(
                      value: active,
                      onChanged: (v) => setState(() => active = v),
                      activeColor: const Color(0xFFE6F06A),
                      title: const Text(
                        'Aktif',
                        style: TextStyle(color: Colors.white),
                      ),
                      subtitle: const Text(
                        'Jika nonaktif, user tidak melihat promo ini',
                        style: TextStyle(color: Colors.white70),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFE6F06A),
                          foregroundColor: const Color(0xFF1C4A0B),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        onPressed: () async {
                          final code = codeC.text.trim().toUpperCase();
                          final title = titleC.text.trim();
                          final v = int.tryParse(valueC.text.trim()) ?? 0;
                          final min = int.tryParse(minC.text.trim()) ?? 10000;
                          final max = int.tryParse(maxC.text.trim());

                          if (code.isEmpty || title.isEmpty || v <= 0) {
                            Get.snackbar(
                              'Validasi',
                              'Kode, judul, dan nilai wajib valid',
                              snackPosition: SnackPosition.TOP,
                            );
                            return;
                          }

                          // rule: min order minimal 10k (sesuai requirement kamu)
                          if (min < 10000) {
                            Get.snackbar(
                              'Validasi',
                              'Min order minimal Rp10000',
                              snackPosition: SnackPosition.TOP,
                            );
                            return;
                          }

                          Get.back();

                          if (!isEdit) {
                            await controller.addPromo(
                              code: code,
                              title: title,
                              description: descC.text,
                              type: type, // ✅ fixed/percent
                              value: v,
                              minOrder: min,
                              maxDiscount: type == 'percent' ? max : null,
                              isActive: active,
                            );
                          } else {
                            await controller.editPromo(
                              existing!.copyWith(
                                code: code,
                                title: title,
                                description: descC.text.trim().isEmpty
                                    ? null
                                    : descC.text.trim(),
                                type: type, // ✅ fixed/percent
                                value: v,
                                minOrder: min,
                                maxDiscount: type == 'percent' ? max : null,
                                isActive: active,
                              ),
                            );
                          }
                        },
                        child: Text(
                          isEdit ? 'Simpan Perubahan' : 'Tambah Promo',
                          style: const TextStyle(fontWeight: FontWeight.w900),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(0.35),
    );
  }

  Widget _field(
    String label,
    TextEditingController c, {
    String? hint,
    TextInputType? keyboard,
    bool enabled = true,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white70)),
        const SizedBox(height: 6),
        TextField(
          controller: c,
          enabled: enabled,
          keyboardType: keyboard,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.white38),
            filled: true,
            fillColor: const Color(0xFF2A2A2A),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }

  Widget _dropdown({
    required String label,
    required String value,
    required List<DropdownMenuItem<String>> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white70)),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: const Color(0xFF2A2A2A),
            borderRadius: BorderRadius.circular(14),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              items: items,
              dropdownColor: const Color(0xFF2A2A2A),
              iconEnabledColor: Colors.white70,
              style: const TextStyle(color: Colors.white),
              onChanged: onChanged,
              isExpanded: true,
            ),
          ),
        ),
      ],
    );
  }
}
