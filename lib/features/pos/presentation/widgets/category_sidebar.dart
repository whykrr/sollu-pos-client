import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sollu_pos_app/core/theme/sollu_colors.dart';
import 'package:sollu_pos_app/features/pos/presentation/providers/pos_provider.dart';

class CategorySidebar extends ConsumerWidget {
  const CategorySidebar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(posCategoriesProvider);
    final selectedCategory = ref.watch(posSelectedCategoryProvider);

    return Container(
      width: double.infinity,
      color: Colors.white,
      child: categoriesAsync.when(
        data: (categories) {
          final rootCategories = categories.where((c) => c.parentId == null).toList();

          return ListView(
            padding: const EdgeInsets.symmetric(vertical: 24),
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                child: Text(
                  'KATALOG',
                  style: TextStyle(
                    color: SolluColors.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              // Default "Semua Produk" item
              _buildCategoryItem(
                context, 
                ref, 
                name: 'Semua Produk', 
                icon: Icons.grid_view_rounded, 
                categoryId: null, 
                isSelected: selectedCategory == null,
              ),
              const SizedBox(height: 16),
              
              if (categories.isNotEmpty) ...rootCategories.map((root) {
                final children = categories.where((c) => c.parentId == root.id).toList();

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (children.isNotEmpty) ...[
                      // Root category acts as a group header
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        child: Text(
                          root.name.toUpperCase(),
                          style: const TextStyle(
                            color: SolluColors.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                      ...children.map((child) => _buildCategoryItem(
                        context, 
                        ref, 
                        name: child.name, 
                        icon: Icons.category, 
                        categoryId: child.id, 
                        isSelected: selectedCategory == child.id,
                      )),
                      const SizedBox(height: 16),
                    ] else ...[
                      // Root category without children is a selectable item
                      _buildCategoryItem(
                        context, 
                        ref, 
                        name: root.name, 
                        icon: Icons.category, 
                        categoryId: root.id, 
                        isSelected: selectedCategory == root.id,
                      ),
                    ]
                  ],
                );
              }),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }

  Widget _buildCategoryItem(
    BuildContext context, 
    WidgetRef ref, {
    required String name, 
    required IconData icon, 
    required String? categoryId, 
    required bool isSelected,
  }) {
    return InkWell(
      onTap: () {
        ref.read(posSelectedCategoryProvider.notifier).setCategory(categoryId);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? SolluColors.primary.withValues(alpha: 0.08) : Colors.transparent,
          border: isSelected
              ? const Border(left: BorderSide(color: SolluColors.primary, width: 4))
              : const Border(left: BorderSide(color: Colors.transparent, width: 4)),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? SolluColors.primary : SolluColors.textMuted,
              size: 20,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: isSelected ? SolluColors.primary : SolluColors.textDark,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
