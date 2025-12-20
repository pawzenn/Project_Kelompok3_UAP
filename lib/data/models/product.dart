class Product {
  final String id;
  final String name;
  final String imageUrl;
  final int price;

  final String? category;
  final String? area; // ini deskripsi kamu

  const Product({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.price,
    this.category,
    this.area,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'image_url': imageUrl,
        'price': price,
        'category': category,
        'area': area,
      };

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: (map['id'] ?? '').toString(),
      name: (map['name'] ?? '').toString(),
      imageUrl: (map['image_url'] ?? '').toString(),
      price: (map['price'] is num) ? (map['price'] as num).toInt() : 0,
      category: map['category']?.toString(),
      area: map['area']?.toString(),
    );
  }
}
