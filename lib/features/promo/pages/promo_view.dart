import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class PromoView extends StatefulWidget {
  const PromoView({super.key});

  @override
  State<PromoView> createState() => _PromoViewState();
}

class _PromoViewState extends State<PromoView> {
  final scrollC = ScrollController();

  // supaya bisa scroll ke section promo tertentu
  final keyPromo20 = GlobalKey();
  final keyPromo5k = GlobalKey();

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

  void _showPromoDetail({
    required String title,
    required String subtitle,
    required String code,
    required String note,
  }) {
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
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                subtitle,
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
                        code,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () async {
                        await Clipboard.setData(ClipboardData(text: code));
                        Get.back();
                        Get.snackbar(
                          'Promo',
                          'Kode promo disalin: $code',
                          snackPosition: SnackPosition.TOP,
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
                note,
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
                      'Promo $code siap dipakai di checkout (nanti kita hubungkan).',
                      snackPosition: SnackPosition.TOP,
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
      body: SingleChildScrollView(
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
                    // ganti sesuai kebutuhan
                    'https://images.unsplash.com/photo-1540189549336-e6e99c3679fe?auto=format&fit=crop&w=1400&q=80',
                    fit: BoxFit.cover,
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
                          icon:
                              const Icon(Icons.arrow_back, color: Colors.white),
                        ),
                        const SizedBox(width: 6),
                        const Text(
                          'Promo light',
                          style: TextStyle(color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  left: 22,
                  top: 96,
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
                      Row(
                        children: [
                          _PromoChip(
                            label: 'Diskon 20%',
                            onTap: () => _scrollTo(keyPromo20),
                          ),
                          const SizedBox(width: 12),
                          _PromoChip(
                            label: 'Diskon 5k',
                            onTap: () => _scrollTo(keyPromo5k),
                          ),
                        ],
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
                    // ===== CARD PROMO 20% =====
                    Container(
                      key: keyPromo20,
                      child: _PromoPosterCard(
                        imageUrl:
                            'https://images.unsplash.com/photo-1555939594-58d7cb561ad1?auto=format&fit=crop&w=1400&q=80',
                        titleTop: 'Promo semua menu',
                        subtitleTop: 'Spesial Akhir Tahun',
                        bigText: 'Diskon\n20%',
                        smallText: 'Berlaku 1 - 31 Desember\npesan segera!',
                        code: 'UAPMOBILE',
                        onTap: () => _showPromoDetail(
                          title: 'Diskon 20% Semua Menu',
                          subtitle:
                              'Maks potongan sesuai ketentuan • Min order sesuai ketentuan',
                          code: 'UAPMOBILE',
                          note:
                              'Syarat & Ketentuan:\n- Berlaku periode 1-31 Desember\n- Berlaku untuk menu tertentu\n- Tidak dapat digabung promo lain (opsional)',
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // ===== CARD PROMO 5K =====
                    Container(
                      key: keyPromo5k,
                      child: _PromoPosterCard(
                        imageUrl:
                            'https://images.unsplash.com/photo-1604909052743-94e838986d24?auto=format&fit=crop&w=1400&q=80',
                        titleTop: 'Lalapan Bang Ajey',
                        subtitleTop: '',
                        bigText: 'DISKON\n5K',
                        smallText: '',
                        code: 'DISKONPELAJAR',
                        theme: _PromoPosterTheme.red,
                        onTap: () => _showPromoDetail(
                          title: 'Diskon 5K',
                          subtitle: 'Min order sesuai ketentuan',
                          code: 'DISKONPELAJAR',
                          note:
                              'Syarat & Ketentuan:\n- Berlaku untuk pengguna tertentu\n- Berlaku selama periode promo\n- Tidak dapat digabung promo lain (opsional)',
                        ),
                      ),
                    ),

                    const SizedBox(height: 60),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
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
            // background image with dark overlay
            Positioned.fill(
              child: Image.network(imageUrl, fit: BoxFit.cover),
            ),
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.35),
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
              child: Row(
                children: [
                  // left: circle image
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
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),

                  // right: text
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

            // subtle border
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
