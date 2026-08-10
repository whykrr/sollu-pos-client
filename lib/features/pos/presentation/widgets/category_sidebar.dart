import 'package:flutter/material.dart';
import 'package:sollu_pos_app/core/theme/sollu_colors.dart';

class CategorySidebar extends StatefulWidget {
  const CategorySidebar({super.key});

  @override
  State<CategorySidebar> createState() => _CategorySidebarState();
}

class _CategorySidebarState extends State<CategorySidebar> {
  String _selectedCategory = 'Bakmi';

  final List<Map<String, dynamic>> categoryGroups = [
    {
      'groupName': 'MAIN DISH',
      'items': [
        {'name': 'Bakmi', 'icon': Icons.ramen_dining},
        {'name': 'Nasi Goreng', 'icon': Icons.rice_bowl},
        {'name': 'Beef Steak', 'icon': Icons.restaurant},
        {'name': 'Bakso', 'icon': Icons.soup_kitchen},
      ]
    },
    {
      'groupName': 'LIGHT BITES',
      'items': [
        {'name': 'Crispy Chicken', 'icon': Icons.kebab_dining},
        {'name': 'Roti Bakar', 'icon': Icons.bakery_dining},
        {'name': 'French Fries', 'icon': Icons.fastfood},
        {'name': 'Muffin', 'icon': Icons.cake},
      ]
    },
    {
      'groupName': 'DRINKS',
      'items': [
        {'name': 'Coffee', 'icon': Icons.coffee},
        {'name': 'Tea', 'icon': Icons.emoji_food_beverage},
      ]
    }
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Colors.white,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 24),
        itemCount: categoryGroups.length,
        itemBuilder: (context, groupIndex) {
          final group = categoryGroups[groupIndex];
          final items = group['items'] as List<Map<String, dynamic>>;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                child: Text(
                  group['groupName'],
                  style: const TextStyle(
                    color: SolluColors.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              ...items.map((item) {
                final isSelected = _selectedCategory == item['name'];
                return InkWell(
                  onTap: () {
                    setState(() {
                      _selectedCategory = item['name'];
                    });
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
                          item['icon'],
                          color: isSelected ? SolluColors.primary : SolluColors.textMuted,
                          size: 20,
                        ),
                        const SizedBox(width: 16),
                        Text(
                          item['name'],
                          style: TextStyle(
                            color: isSelected ? SolluColors.primary : SolluColors.textDark,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
              if (groupIndex < categoryGroups.length - 1)
                const SizedBox(height: 16),
            ],
          );
        },
      ),
    );
  }
}
