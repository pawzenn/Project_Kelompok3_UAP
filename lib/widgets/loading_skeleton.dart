import 'package:flutter/material.dart';

class LoadingSkeletonGrid extends StatelessWidget {
  const LoadingSkeletonGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.78,
      ),
      itemCount: 6,
      itemBuilder: (_, __) {
        return Card(
          child: Column(
            children: [
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    color: Color(0xFFE3EFE1),
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Container(
                height: 14,
                margin: const EdgeInsets.symmetric(horizontal: 12),
                color: Color(0xFFE3EFE1),
              ),
              const SizedBox(height: 8),
              Container(
                height: 14,
                margin: const EdgeInsets.symmetric(horizontal: 12),
                color: Color(0xFFE3EFE1),
              ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }
}
