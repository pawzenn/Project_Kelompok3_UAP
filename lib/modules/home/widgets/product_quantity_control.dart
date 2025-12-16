import 'package:flutter/material.dart';
import '../../../data/models/cart_item.dart';

class RecipeDetailSheet extends StatelessWidget {
  final Recipe recipe;
  const RecipeDetailSheet({super.key, required this.recipe});

  @override
  Widget build(BuildContext context) {
    final ingredients = recipe.ingredients.entries.toList();
    return DraggableScrollableSheet(
      initialChildSize: 0.8,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (_, controller) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: ListView(
            controller: controller,
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                recipe.title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                (recipe.area ?? '').isNotEmpty ? recipe.area! : 'Menu',
                style: TextStyle(color: Colors.black.withOpacity(0.6)),
              ),
              const SizedBox(height: 8),
              Text(
                'Rp ${recipe.price}',
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 16),
              if (ingredients.isNotEmpty) ...[
                const Text(
                  'Ingredients',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                ...ingredients.map(
                  (e) => Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('• '),
                      Expanded(child: Text('${e.key} ${e.value}'.trim())),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],
              if ((recipe.instructions ?? '').isNotEmpty) ...[
                const Text(
                  'Instructions',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                Text(recipe.instructions!),
              ],
            ],
          ),
        );
      },
    );
  }
}
