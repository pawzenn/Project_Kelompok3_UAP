class Recipe {
  final String id;
  final String title;
  final String? thumb;
  final String? area;
  final String? instructions;
  final Map<String, String> ingredients; // ingredient -> measure
  final int price; // harga dummy, stabil berdasar id

  Recipe({
    required this.id,
    required this.title,
    required this.thumb,
    required this.area,
    required this.instructions,
    required this.ingredients,
    required this.price,
  });

  factory Recipe.fromMealDb(Map<String, dynamic> j) {
    final id = (j['idMeal'] ?? '').toString();
    final title = (j['strMeal'] ?? '').toString();
    final thumb = j['strMealThumb']?.toString();
    final area = j['strArea']?.toString();
    final instructions = j['strInstructions']?.toString();

    final ing = <String, String>{};
    for (var i = 1; i <= 20; i++) {
      final name = (j['strIngredient$i'] ?? '').toString().trim();
      final meas = (j['strMeasure$i'] ?? '').toString().trim();
      if (name.isNotEmpty) ing[name] = meas;
    }

    return Recipe(
      id: id,
      title: title,
      thumb: thumb,
      area: area,
      instructions: instructions,
      ingredients: ing,
      price: _priceFromId(id),
    );
  }

  static int _priceFromId(String id) {
    // generator deterministik: hash sederhana → 10000..25000
    int h = 0;
    for (final c in id.codeUnits) {
      h = (h * 31 + c) & 0x7fffffff;
    }
    return 10000 + (h % 15001); // Rp 10k..25k
  }
}
