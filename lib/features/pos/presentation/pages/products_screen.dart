import 'package:flutter/material.dart';
import 'package:sollu_pos_client/core/theme/sollu_colors.dart';
import 'package:sollu_pos_client/core/utils/currency_formatter.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sollu_pos_client/features/pos/presentation/providers/pos_provider.dart';

class ProductsScreen extends ConsumerStatefulWidget {
  const ProductsScreen({super.key});

  @override
  ConsumerState<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends ConsumerState<ProductsScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final posItemsAsync = ref.watch(posItemsProvider);

    return Scaffold(
      backgroundColor: SolluColors.background,
      appBar: AppBar(
        title: const Text(
          'Data Semua Produk',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
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
                          hintText:
                              'Cari produk berdasarkan nama atau kategori...',
                          prefixIcon: const Icon(
                            Icons.search,
                            color: SolluColors.textMuted,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: SolluColors.neutral,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: SolluColors.neutral,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        color: SolluColors.primary.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        posItemsAsync.when(
                          data: (items) => 'Total: ${items.length} Produk',
                          loading: () => 'Loading...',
                          error: (_, _) => 'Error',
                        ),
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
                child: posItemsAsync.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (error, _) => Center(child: Text('Error: $error')),
                  data: (items) {
                    final filteredProducts = items.where((item) {
                      final name = item.name.toLowerCase();
                      final category = item.categoryId?.toLowerCase() ?? '';
                      final query = _searchQuery.toLowerCase();
                      return name.contains(query) || category.contains(query);
                    }).toList();

                    if (filteredProducts.isEmpty) {
                      return const Center(
                        child: Text(
                          'Tidak ada produk ditemukan',
                          style: TextStyle(
                            color: SolluColors.textMuted,
                            fontSize: 16,
                          ),
                        ),
                      );
                    }

                    return ListView.separated(
                      padding: const EdgeInsets.all(12),
                      itemCount: filteredProducts.length,
                      separatorBuilder: (_, _) =>
                          const Divider(height: 1, color: SolluColors.neutral),
                      itemBuilder: (context, index) {
                        final item = filteredProducts[index];
                        final bool isActive = item.isActive;
                        final String itemName = item.name;
                        final double price = item.price;
                        final double stock = item.stock;

                        return ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 4,
                          ),
                          leading: Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: isActive
                                  ? SolluColors.background
                                  : Colors.grey.shade200,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.fastfood,
                              color: isActive
                                  ? SolluColors.primary
                                  : Colors.grey,
                              size: 22,
                            ),
                          ),
                          title: Row(
                            children: [
                              Text(
                                itemName,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  color: isActive
                                      ? SolluColors.textDark
                                      : SolluColors.textMuted,
                                  decoration: isActive
                                      ? TextDecoration.none
                                      : TextDecoration.lineThrough,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: isActive
                                      ? SolluColors.success.withValues(
                                          alpha: 0.1,
                                        )
                                      : SolluColors.danger.withValues(
                                          alpha: 0.1,
                                        ),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  isActive ? 'Aktif' : 'Nonaktif',
                                  style: TextStyle(
                                    color: isActive
                                        ? SolluColors.success
                                        : SolluColors.danger,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          subtitle: Text(
                            'Kategori: ${item.categoryId ?? "-"}',
                            style: const TextStyle(
                              color: SolluColors.textMuted,
                              fontSize: 12,
                            ),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    CurrencyFormatter.format(price.toInt()),
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                      color: isActive
                                          ? SolluColors.primary
                                          : SolluColors.textMuted,
                                    ),
                                  ),
                                  Text(
                                    'Stok: $stock unit',
                                    style: const TextStyle(
                                      color: SolluColors.textMuted,
                                      fontSize: 12,
                                    ),
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
                                    onChanged: (bool value) async {
                                      await ref
                                          .read(posRepositoryProvider)
                                          .toggleInventoryActiveStatus(
                                            item.id,
                                            value,
                                            item.isProductMode,
                                          );

                                      if (mounted) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).hideCurrentSnackBar();
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              value
                                                  ? '$itemName diaktifkan di kasir'
                                                  : '$itemName dinonaktifkan dari kasir',
                                            ),
                                            duration: const Duration(
                                              seconds: 2,
                                            ),
                                          ),
                                        );
                                      }
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
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
