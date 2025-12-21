import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../data/models/promo.dart';
import '../controller/promo_controller.dart';

class PromoView extends StatefulWidget {
  const PromoView({super.key});

  @override
  State<PromoView> createState() => _PromoViewState();
}

class _PromoViewState extends State<PromoView> {
  final scrollC = ScrollController();

  // map key per promo code supaya chip bisa scroll ke card yg sesuai
  final Map<String, GlobalKey> _promoKeys = {};

  PromoController get c => Get.find<PromoController>();

  GlobalKey _keyOf(Promo p) {
    final k = _promoKeys.putIfAbsent(p.code, () => GlobalKey());
    return k;
  }

  void _scrollTo(GlobalKey key) {
    final ctx = key.currentContext;
    if (ctx == null) return;
    Scrollable.ensureVisible(
      ctx,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
      alignment: 0.1,
    );
  }

  String _chipLabel(Promo p) {
    if (p.type == 'percent') return 'Diskon ${p.value}%';
    return 'Diskon ${_rupiah(p.value)}';
  }

  String _subtitleTop(Promo p) {
    final min = _rupiah(p.minOrder);
    if (p.type == 'percent') {
      final max =
          p.maxDiscount != null ? ' • Maks ${_rupiah(p.maxDiscount!)}' : '';
      return 'Min $min$max';
    }
    return 'Min $min';
  }

  String _bigText(Promo p) {
    if (p.type == 'percent') return 'Diskon\n${p.value}%';
    return 'DISKON\n${_rupiahShort(p.value)}';
  }

  String _smallText(Promo p) {
    final min = _rupiah(p.minOrder);
    if (p.type == 'percent' && p.maxDiscount != null) {
      return 'Min $min • Maks ${_rupiah(p.maxDiscount!)}';
    }
    return 'Min $min';
  }

  String _note(Promo p) {
    final min = _rupiah(p.minOrder);
    final diskon = p.type == 'percent' ? '${p.value}%' : _rupiah(p.value);
    final max = (p.type == 'percent' && p.maxDiscount != null)
        ? '\n- Maks potongan: ${_rupiah(p.maxDiscount!)}'
        : '';
    final desc = (p.description ?? '').trim().isEmpty
        ? ''
        : '\n\n${p.description!.trim()}';

    return 'Syarat & Ketentuan:\n'
        '- Diskon: $diskon\n'
        '- Min order: $min'
        '$max'
        '$desc';
  }

  void _showPromoDetail({required Promo p}) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 18),
        decoration: const BoxDecoration(
          color: Color(0xFF1A1A1A),
          borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
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
                p.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                _subtitleTop(p),
                style: const TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFF2A2A2A),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.confirmation_number,
                        color: Color(0xFFE6F06A)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        p.code,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () async {
                        await Clipboard.setData(ClipboardData(text: p.code));
                        Get.back();
                        Get.snackbar(
                          'Promo',
                          'Kode promo disalin: ${p.code}',
                          snackPosition: SnackPosition.TOP,
                          backgroundColor: const Color(0xFF22590A),
                          colorText: Colors.white,
                          margin: const EdgeInsets.all(16),
                        );
                      },
                      child: const Text(
                        'Salin',
                        style: TextStyle(
                          color: Color(0xFFE6F06A),
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Text(
                _note(p),
                style: const TextStyle(color: Colors.white70, height: 1.3),
              ),
              const SizedBox(height: 16),
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
                  onPressed: () {
                    Get.back();
                    Get.snackbar(
                      'Promo',
                      'Promo ${p.code} siap dipakai di checkout',
                      snackPosition: SnackPosition.TOP,
                      backgroundColor: const Color(0xFF22590A),
                      colorText: Colors.white,
                      margin: const EdgeInsets.all(16),
                    );
                  },
                  child: const Text(
                    'Pakai Promo',
                    style: TextStyle(fontWeight: FontWeight.w900),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(0.35),
    );
  }

  @override
  void dispose() {
    scrollC.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      body: Obx(() {
        final isLoading = c.isLoading.value;
        final promos = c.promos;

        return SingleChildScrollView(
          controller: scrollC,
          child: Column(
            children: [
              // ================= HERO =================
              Stack(
                children: [
                  SizedBox(
                    height: 340,
                    width: double.infinity,
                    child: Image.network(
                      'https://images.unsplash.com/photo-1540189549336-e6e99c3679fe?auto=format&fit=crop&w=1400&q=80',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: const Color(0xFF22590A),
                          child: const Center(
                            child: Icon(
                              Icons.image_not_supported,
                              color: Colors.white54,
                              size: 64,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  Container(
                    height: 340,
                    width: double.infinity,
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
                  SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
                      child: Row(
                        children: [
                          IconButton(
                            onPressed: () => Get.back(),
                            icon: const Icon(Icons.arrow_back,
                                color: Colors.white),
                          ),
                          const SizedBox(width: 6),
                          const Text('Promo',
                              style: TextStyle(color: Colors.white70)),
                          const Spacer(),
                          // ✅ FIX: Panggil method dengan benar
                          IconButton(
                            onPressed: () => c.loadPromos(),
                            icon:
                                const Icon(Icons.refresh, color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    left: 22,
                    top: 96,
                    right: 16,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Lalapan\nBang Ajey',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontStyle: FontStyle.italic,
                            height: 1.0,
                          ),
                        ),
                        const SizedBox(height: 18),
                        Text(
                          'Klaim Promomu!!',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.95),
                            fontWeight: FontWeight.w900,
                            fontSize: 26,
                            shadows: [
                              Shadow(
                                color: Colors.black.withOpacity(0.4),
                                offset: const Offset(0, 2),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        if (isLoading)
                          const Padding(
                            padding: EdgeInsets.only(top: 8),
                            child: SizedBox(
                              height: 22,
                              width: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.6,
                                valueColor:
                                    AlwaysStoppedAnimation(Color(0xFFE6F06A)),
                              ),
                            ),
                          )
                        else if (promos.isEmpty)
                          const Text(
                            'Belum ada promo aktif',
                            style: TextStyle(color: Colors.white70),
                          )
                        else
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                for (final p in promos.take(6)) ...[
                                  _PromoChip(
                                    label: _chipLabel(p),
                                    onTap: () => _scrollTo(_keyOf(p)),
                                  ),
                                  const SizedBox(width: 12),
                                ],
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),

              // ================= BODY BG =================
              Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xFF22590A),
                      Color(0xFF0F0F0F),
                    ],
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 18, 16, 24),
                  child: Column(
                    children: [
                      if (isLoading)
                        const Padding(
                          padding: EdgeInsets.only(top: 26, bottom: 26),
                          child: CircularProgressIndicator(
                            valueColor:
                                AlwaysStoppedAnimation(Color(0xFFE6F06A)),
                          ),
                        )
                      else if (promos.isEmpty)
                        const Padding(
                          padding: EdgeInsets.only(top: 18),
                          child: Text(
                            'Belum ada promo aktif',
                            style: TextStyle(color: Colors.white70),
                          ),
                        )
                      else ...[
                        for (int i = 0; i < promos.length; i++) ...[
                          Container(
                            key: _keyOf(promos[i]),
                            child: _PromoPosterCard(
                              imageUrl: _promoImageByIndex(i),
                              titleTop: promos[i].title,
                              subtitleTop: _subtitleTop(promos[i]),
                              bigText: _bigText(promos[i]),
                              smallText: _smallText(promos[i]),
                              code: promos[i].code,
                              theme: promos[i].type == 'percent'
                                  ? _PromoPosterTheme.brown
                                  : _PromoPosterTheme.red,
                              onTap: () => _showPromoDetail(p: promos[i]),
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                        const SizedBox(height: 44),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}

// ===================== WIDGETS =====================

class _PromoChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _PromoChip({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF6B6A24),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: Colors.white12),
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}

enum _PromoPosterTheme { brown, red }

class _PromoPosterCard extends StatelessWidget {
  final String imageUrl;
  final String titleTop;
  final String subtitleTop;
  final String bigText;
  final String smallText;
  final String code;
  final VoidCallback onTap;
  final _PromoPosterTheme theme;

  const _PromoPosterCard({
    required this.imageUrl,
    required this.titleTop,
    required this.subtitleTop,
    required this.bigText,
    required this.smallText,
    required this.code,
    required this.onTap,
    this.theme = _PromoPosterTheme.brown,
  });

  @override
  Widget build(BuildContext context) {
    final cardBg = theme == _PromoPosterTheme.brown
        ? const Color(0xFF4B362A)
        : const Color(0xFF8F1515);

    final accent = theme == _PromoPosterTheme.brown
        ? const Color(0xFFE6F06A)
        : const Color(0xFFFFD25A);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: Container(
        height: 230,
        width: double.infinity,
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.35),
              blurRadius: 18,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            Positioned.fill(
              child: Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: cardBg,
                    child: const Center(
                      child: Icon(
                        Icons.image_not_supported,
                        color: Colors.white24,
                        size: 48,
                      ),
                    ),
                  );
                },
              ),
            ),
            Positioned.fill(
                child: Container(color: Colors.black.withOpacity(0.35))),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
              child: Row(
                children: [
                  Container(
                    width: 92,
                    height: 92,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.black26,
                      border: Border.all(color: Colors.white12),
                      image: DecorationImage(
                        image: NetworkImage(imageUrl),
                        fit: BoxFit.cover,
                        onError: (error, stackTrace) {},
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (titleTop.isNotEmpty)
                          Text(
                            titleTop,
                            style: TextStyle(
                              color: accent,
                              fontWeight: FontWeight.w900,
                              fontSize: 18,
                            ),
                          ),
                        if (subtitleTop.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            subtitleTop,
                            style: TextStyle(
                              color: accent.withOpacity(0.9),
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                            ),
                          ),
                        ],
                        const Spacer(),
                        Text(
                          bigText,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: 40,
                            height: 0.95,
                          ),
                        ),
                        const SizedBox(height: 8),
                        if (smallText.isNotEmpty)
                          Text(
                            smallText,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        const Spacer(),
                        Text(
                          'KODE: $code',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.95),
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.6,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: Colors.white12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ===================== HELPERS =====================

String _rupiah(int n) {
  final s = n.toString();
  final b = StringBuffer();
  for (int i = 0; i < s.length; i++) {
    final idxFromEnd = s.length - i;
    b.write(s[i]);
    if (idxFromEnd > 1 && idxFromEnd % 3 == 1) b.write('.');
  }
  return 'Rp$b';
}

String _rupiahShort(int n) {
  if (n >= 1000000) return '${(n / 1000000).floor()}JT';
  if (n >= 1000) return '${(n / 1000).floor()}K';
  return n.toString();
}

// gambar default per index biar tetap cakep (opsional)
String _promoImageByIndex(int i) {
  const imgs = [
    'https://images.unsplash.com/photo-1555939594-58d7cb561ad1?auto=format&fit=crop&w=1400&q=80',
    'https://images.unsplash.com/photo-1604909052743-94e838986d24?auto=format&fit=crop&w=1400&q=80',
    'https://images.unsplash.com/photo-1525351484163-7529414344d8?auto=format&fit=crop&w=1400&q=80',
    'https://images.unsplash.com/photo-1482049016688-2d3e1b311543?auto=format&fit=crop&w=1400&q=80',
  ];
  return imgs[i % imgs.length];
}
