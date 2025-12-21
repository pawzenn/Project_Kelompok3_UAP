class Promo {
  final String id;
  final String code;
  final String title;
  final String? description;
  final String type; // 'percent' | 'amount'
  final int value;
  final int minOrder;
  final int? maxDiscount;
  final bool isActive;
  final DateTime? startAt;
  final DateTime? endAt;
  final DateTime? createdAt;

  Promo({
    required this.id,
    required this.code,
    required this.title,
    this.description,
    required this.type,
    required this.value,
    required this.minOrder,
    this.maxDiscount,
    required this.isActive,
    this.startAt,
    this.endAt,
    this.createdAt,
  });

  static int _toInt(dynamic v, {int fallback = 0}) {
    if (v == null) return fallback;
    if (v is int) return v;
    if (v is num) return v.toInt();
    return int.tryParse(v.toString()) ?? fallback;
  }

  static bool _toBool(dynamic v, {bool fallback = false}) {
    if (v == null) return fallback;
    if (v is bool) return v;
    final s = v.toString().toLowerCase().trim();
    if (s == 'true' || s == '1' || s == 'yes') return true;
    if (s == 'false' || s == '0' || s == 'no') return false;
    return fallback;
  }

  static DateTime? _dt(dynamic v) {
    if (v == null) return null;
    return DateTime.tryParse(v.toString());
  }

  // ✅ VALIDASI TYPE - Hanya terima 'amount' atau 'percent'
  static String _validateType(dynamic v) {
    if (v == null) return 'amount';
    final str = v.toString().toLowerCase().trim();

    // Hanya terima 'percent' atau 'amount'
    if (str == 'percent') return 'percent';
    if (str == 'amount') return 'amount';

    // Fallback untuk value lain (termasuk 'fixed', null, empty, dll)
    return 'amount';
  }

  factory Promo.fromMap(Map<String, dynamic> m) {
    return Promo(
      id: (m['id'] ?? '').toString(),
      code: (m['code'] ?? '').toString(),
      title: (m['title'] ?? '').toString(),
      description: m['description']?.toString(),
      type: _validateType(m['type']), // ✅ Gunakan validasi
      value: _toInt(m['value'], fallback: 0),
      minOrder: _toInt(m['min_order'], fallback: 10000),
      maxDiscount: m['max_discount'] == null ? null : _toInt(m['max_discount']),
      isActive: _toBool(m['is_active'], fallback: true),
      startAt: _dt(m['start_at']),
      endAt: _dt(m['end_at']),
      createdAt: _dt(m['created_at']),
    );
  }

  Map<String, dynamic> toInsert() => {
        'code': code.trim().toUpperCase(),
        'title': title.trim(),
        'description':
            (description ?? '').trim().isEmpty ? null : description!.trim(),
        'type': type,
        'value': value,
        'min_order': minOrder,
        'max_discount': maxDiscount,
        'is_active': isActive,
        'start_at': startAt?.toIso8601String(),
        'end_at': endAt?.toIso8601String(),
      };

  Map<String, dynamic> toUpdate() => toInsert();

  Promo copyWith({
    String? id,
    String? code,
    String? title,
    String? description,
    String? type,
    int? value,
    int? minOrder,
    int? maxDiscount,
    bool? isActive,
    DateTime? startAt,
    DateTime? endAt,
  }) {
    return Promo(
      id: id ?? this.id,
      code: code ?? this.code,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      value: value ?? this.value,
      minOrder: minOrder ?? this.minOrder,
      maxDiscount: maxDiscount ?? this.maxDiscount,
      isActive: isActive ?? this.isActive,
      startAt: startAt ?? this.startAt,
      endAt: endAt ?? this.endAt,
      createdAt: createdAt,
    );
  }
}
