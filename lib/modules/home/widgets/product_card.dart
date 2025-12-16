import 'package:flutter/material.dart';
import '../../../data/models/cart_item.dart';

class RecipeCard extends StatelessWidget {
  final Recipe recipe;
  final VoidCallback onTap;

  const RecipeCard({super.key, required this.recipe, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Gambar
            AspectRatio(
              aspectRatio: 1,
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
                child: Image.network(
                  recipe.thumb ?? '',
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const _ImageFallback(),
                  loadingBuilder: (ctx, child, progress) {
                    if (progress == null) return child;
                    return const _ImageFallback();
                  },
                ),
              ),
            ),
            // Info
            Padding(
              padding: const EdgeInsets.all(12),
              child: DefaultTextStyle(
                style: Theme.of(context).textTheme.bodyMedium!,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      recipe.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Rp ${recipe.price.toString()}',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    if ((recipe.area ?? '').isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        recipe.area!,
                        style: TextStyle(
                          color: Colors.black.withOpacity(0.6),
                          fontSize: 12,
                        ),
                      ),
                    ],
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

class _ImageFallback extends StatelessWidget {
  const _ImageFallback();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFE3EFE1),
      child: const Center(child: Text('🍛', style: TextStyle(fontSize: 28))),
    );
  }
}
