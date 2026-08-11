import 'package:flutter/material.dart';
import 'package:sollu_pos_app/core/theme/sollu_colors.dart';
import 'package:sollu_pos_app/core/utils/currency_formatter.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  String _searchQuery = '';

  final List<Map<String, dynamic>> _allProducts = [
    {'name': 'Bakmi Special', 'category': 'MAIN DISH', 'price': 25455, 'stock': 45, 'isActive': true},
    {'name': 'Bakmi Komplit Special', 'category': 'MAIN DISH', 'price': 31818, 'stock': 30, 'isActive': true},
    {'name': 'Bakmi Ayam Teriyaki', 'category': 'MAIN DISH', 'price': 29091, 'stock': 20, 'isActive': false},
    {'name': 'Bakmi Kuah Sapi', 'category': 'MAIN DISH', 'price': 27273, 'stock': 18, 'isActive': true},
    {'name': 'Bakmi Sapi Lada Hitam', 'category': 'MAIN DISH', 'price': 32727, 'stock': 15, 'isActive': true},
    {'name': 'Bakmi Seafood Pedas', 'category': 'MAIN DISH', 'price': 32727, 'stock': 12, 'isActive': true},
    {'name': 'Bakmi Goreng Ayam', 'category': 'MAIN DISH', 'price': 29091, 'stock': 25, 'isActive': true},
    {'name': 'Bakmi Goreng Seafood', 'category': 'MAIN DISH', 'price': 32727, 'stock': 14, 'isActive': true},
    {'name': 'Bakmi Capcay', 'category': 'MAIN DISH', 'price': 31818, 'stock': 22, 'isActive': true},
    {'name': 'Nasi Goreng Special', 'category': 'MAIN DISH', 'price': 28000, 'stock': 50, 'isActive': true},
    {'name': 'Beef Steak Sirloin', 'category': 'MAIN DISH', 'price': 65000, 'stock': 10, 'isActive': true},
    {'name': 'Bakso Sapi Urat', 'category': 'MAIN DISH', 'price': 22000, 'stock': 35, 'isActive': true},
    {'name': 'Crispy Chicken Extra', 'category': 'LIGHT BITES', 'price': 24000, 'stock': 40, 'isActive': true},
    {'name': 'Roti Bakar Coklat Keju', 'category': 'LIGHT BITES', 'price': 18000, 'stock': 30, 'isActive': true},
    {'name': 'French Fries Original', 'category': 'LIGHT BITES', 'price': 17273, 'stock': 60, 'isActive': true},
    {'name': 'Muffin Chocolate', 'category': 'LIGHT BITES', 'price': 15000, 'stock': 25, 'isActive': true},
    {'name': 'Coffee Latte Large', 'category': 'DRINKS', 'price': 22000, 'stock': 80, 'isActive': true},
    {'name': 'Ice Tea Lemon', 'category': 'DRINKS', 'price': 12000, 'stock': 100, 'isActive': true},
  ];

  @override
  Widget build(BuildContext context) {
    final filteredProducts = _allProducts.where((p) {
      final name = (p['name'] as String).toLowerCase();
      final category = (p['category'] as String).toLowerCase();
      final query = _searchQuery.toLowerCase();
      return name.contains(query) || category.contains(query);
    }).toList();

    return Scaffold(
      backgroundColor: SolluColors.background,
      appBar: AppBar(
        title: const Text('Data Semua Produk', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: SolluColors.surface,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            children: [
              // Header Filter & Search Bar
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        onChanged: (val) => setState(() => _searchQuery = val),
                        decoration: InputDecoration(
                          hintText: 'Cari produk berdasarkan nama atau kategori...',
                          prefixIcon: const Icon(Icons.search, color: SolluColors.textMuted),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: SolluColors.neutral),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: SolluColors.neutral),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: SolluColors.primary.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Total: ${filteredProducts.length} Produk',
                        style: const TextStyle(
                          color: SolluColors.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, color: SolluColors.neutral),
              // Data Table / List
              Expanded(
                child: filteredProducts.isEmpty
                    ? const Center(
                        child: Text(
                          'Tidak ada produk ditemukan',
                          style: TextStyle(color: SolluColors.textMuted, fontSize: 16),
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.all(12),
                        itemCount: filteredProducts.length,
                        separatorBuilder: (_, __) => const Divider(height: 1, color: SolluColors.neutral),
                        itemBuilder: (context, index) {
                          final item = filteredProducts[index];
                          final bool isActive = item['isActive'] ?? true;

                          return ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                            leading: Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: isActive ? SolluColors.background : Colors.grey.shade200,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.fastfood,
                                color: isActive ? SolluColors.primary : Colors.grey,
                                size: 22,
                              ),
                            ),
                            title: Row(
                              children: [
                                Text(
                                  item['name'],
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                    color: isActive ? SolluColors.textDark : SolluColors.textMuted,
                                    decoration: isActive ? TextDecoration.none : TextDecoration.lineThrough,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: isActive ? SolluColors.success.withValues(alpha: 0.1) : SolluColors.danger.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    isActive ? 'Aktif' : 'Nonaktif',
                                    style: TextStyle(
                                      color: isActive ? SolluColors.success : SolluColors.danger,
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            subtitle: Text(
                              'Kategori: ${item['category']}',
                              style: const TextStyle(color: SolluColors.textMuted, fontSize: 12),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      CurrencyFormatter.format(item['price'] as int),
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                        color: isActive ? SolluColors.primary : SolluColors.textMuted,
                                      ),
                                    ),
                                    Text(
                                      'Stok: ${item['stock']} unit',
                                      style: const TextStyle(color: SolluColors.textMuted, fontSize: 12),
                                    ),
                                  ],
                                ),
                                const SizedBox(width: 24),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Switch.adaptive(
                                      value: isActive,
                                      activeTrackColor: SolluColors.success,
                                      onChanged: (bool value) {
                                        setState(() {
                                          item['isActive'] = value;
                                        });
                                        ScaffoldMessenger.of(context).hideCurrentSnackBar();
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              value
                                                  ? '${item['name']} diaktifkan di kasir'
                                                  : '${item['name']} dinonaktifkan dari kasir',
                                            ),
                                            duration: const Duration(seconds: 2),
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
