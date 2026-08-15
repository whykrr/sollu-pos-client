import 'package:flutter/material.dart';
import 'package:sollu_pos_client/core/theme/sollu_colors.dart';
import 'package:sollu_pos_client/core/utils/currency_formatter.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sollu_pos_client/features/pos/presentation/providers/pos_provider.dart';
import 'package:sollu_pos_client/features/settings/presentation/providers/sync_provider.dart';
import 'package:sollu_pos_client/core/providers/preferences_provider.dart';

class ProductsScreen extends ConsumerStatefulWidget {
  const ProductsScreen({super.key});

  @override
  ConsumerState<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends ConsumerState<ProductsScreen> {
  String _searchQuery = '';
  bool _isSyncing = false;

  Future<void> _syncData() async {
    setState(() {
      _isSyncing = true;
    });

    try {
      final syncRepository = ref.read(syncRepositoryProvider);
      await syncRepository.syncMasterData();

      ref.invalidate(posItemsProvider);

      // Simpan timestamp sinkronisasi terakhir
      ref.read(lastSyncProvider.notifier).updateTimestamp();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 12),
                Text('Sinkronisasi data produk berhasil!'),
              ],
            ),
            backgroundColor: SolluColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal sinkronisasi data: $e'),
            backgroundColor: SolluColors.danger,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSyncing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final posItemsAsync = ref.watch(posItemsProvider);
    final categoriesAsync = ref.watch(posCategoriesProvider);

    return Scaffold(
      backgroundColor: SolluColors.background,
      appBar: AppBar(
        title: const Text(
          'Data Semua Produk',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: SolluColors.surface,
        elevation: 0,
        actions: [
          // Tampilkan info sync terakhir
          Center(
            child: Builder(
              builder: (context) {
                final lastSync = ref.watch(lastSyncProvider);
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: Text(
                    'Sync: ${LastSyncNotifier.formatRelative(lastSync)}',
                    style: TextStyle(
                      fontSize: 11,
                      color: lastSync != null ? SolluColors.success : SolluColors.textMuted,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: ElevatedButton.icon(
              onPressed: _isSyncing ? null : _syncData,
              icon: _isSyncing
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.sync, size: 18),
              label: Text(_isSyncing ? 'Menyinkronkan...' : 'Sinkronisasi Data'),
              style: ElevatedButton.styleFrom(
                backgroundColor: SolluColors.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              ),
            ),
          ),
        ],
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
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              items.isEmpty ? Icons.cloud_download_outlined : Icons.search_off,
                              size: 48,
                              color: SolluColors.textMuted.withValues(alpha: 0.5),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              items.isEmpty
                                  ? 'Belum ada data produk tersimpan'
                                  : 'Tidak ada produk ditemukan',
                              style: const TextStyle(
                                color: SolluColors.textDark,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              items.isEmpty
                                  ? 'Tarik data master produk terbaru dari server untuk mulai menggunakan kasir.'
                                  : 'Coba gunakan kata kunci pencarian yang lain.',
                              style: const TextStyle(
                                color: SolluColors.textMuted,
                                fontSize: 13,
                              ),
                            ),
                            if (items.isEmpty) ...[
                              const SizedBox(height: 16),
                              ElevatedButton.icon(
                                onPressed: _isSyncing ? null : _syncData,
                                icon: _isSyncing
                                    ? const SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : const Icon(Icons.sync, size: 16),
                                label: const Text('Sinkronkan Data Sekarang'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: SolluColors.primary,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              ),
                            ],
                          ],
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
                            'Kategori: ${item.categoryId != null ? categoriesAsync.value?.where((c) => c.id == item.categoryId).firstOrNull?.name ?? "-" : "-"}',
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
                                      final messenger = ScaffoldMessenger.of(context);
                                      await ref
                                          .read(posRepositoryProvider)
                                          .toggleInventoryActiveStatus(
                                            item.id,
                                            value,
                                            item.isProductMode,
                                          );

                                      if (mounted) {
                                        messenger.hideCurrentSnackBar();
                                        messenger.showSnackBar(
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
