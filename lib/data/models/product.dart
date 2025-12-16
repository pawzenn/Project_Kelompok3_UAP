import 'package:hive/hive.dart';

@HiveType(typeId: 2) // pastikan beda dengan model Hive lain
class Product extends HiveObject {
  @HiveField(0)
  final String id; // bisa id dari API, atau kombinasi custom

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String? description;

  @HiveField(3)
  final double price;

  @HiveField(4)
  final String? imageUrl;

  @HiveField(5)
  final String? category;

  Product({
    required this.id,
    required this.name,
    this.description,
    required this.price,
    this.imageUrl,
    this.category,
  });

  /// Buat dari JSON API (sesuaikan key dengan API-mu)
  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString(),
      price: (json['price'] is num)
          ? (json['price'] as num).toDouble()
          : double.tryParse(json['price']?.toString() ?? '0') ?? 0.0,
      imageUrl: json['imageUrl']?.toString(),
      category: json['category']?.toString(),
    );
  }

  /// Untuk disimpan/dioper ke mana-mana
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'imageUrl': imageUrl,
      'category': category,
    };
  }
}

/// Adapter manual untuk Hive (pengganti product.g.dart)
class ProductAdapter extends TypeAdapter<Product> {
  @override
  final int typeId = 2; // HARUS sama dengan @HiveType(typeId: 2)

  @override
  Product read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };

    return Product(
      id: fields[0] as String,
      name: fields[1] as String,
      description: fields[2] as String?,
      price: fields[3] as double,
      imageUrl: fields[4] as String?,
      category: fields[5] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Product obj) {
    writer
      ..writeByte(6) // jumlah field
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.price)
      ..writeByte(4)
      ..write(obj.imageUrl)
      ..writeByte(5)
      ..write(obj.category);
  }
}
