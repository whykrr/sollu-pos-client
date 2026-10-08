import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sollu_pos_client/core/providers/preferences_provider.dart';
import 'package:sollu_pos_client/core/theme/sollu_colors.dart';
import 'package:sollu_pos_client/core/utils/currency_formatter.dart';
import 'package:sollu_pos_client/features/pos/data/pos_repository.dart';
import 'package:sollu_pos_client/features/pos/presentation/providers/pos_provider.dart';
import 'package:sollu_pos_client/features/settings/presentation/providers/sync_provider.dart';

class ProductsScreen extends ConsumerStatefulWidget {
  const ProductsScreen({super.key});

  @override
  ConsumerState<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends ConsumerState<ProductsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String? _selectedCategoryId;
  String _sortBy = 'name_asc'; // name_asc, name_desc, stock_desc, stock_asc
  bool _isSyncing = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _syncData() async {
    setState(() {
      _isSyncing = true;
    });

    try {
      final syncRepository = ref.read(syncRepositoryProvider);
      await syncRepository.syncMasterData();

      ref.invalidate(posItemsProvider);
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
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
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

  String _formatStock(double stock) {
    if (stock == stock.roundToDouble()) {
      return stock.toInt().toString();
    }
    return stock.toStringAsFixed(1);
  }

  @override
  Widget build(BuildContext context) {
    final posItemsAsync = ref.watch(posItemsProvider);
    final categoriesAsync = ref.watch(posCategoriesProvider);
    final viewMode = ref.watch(productsViewModeProvider);

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
                      color: lastSync != null
                          ? SolluColors.success
                          : SolluColors.textMuted,
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
              label: Text(
                _isSyncing ? 'Menyinkronkan...' : 'Sinkronisasi Data',
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: SolluColors.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
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
              // Header Filter, Search Bar, & Controls
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  alignment: WrapAlignment.spaceBetween,
                  children: [
                    // Search Box
                    SizedBox(
                      width: 320,
                      child: TextField(
                        controller: _searchController,
                        onChanged: (val) => setState(() => _searchQuery = val),
                        decoration: InputDecoration(
                          hintText: 'Cari nama, barcode, atau SKU...',
                          hintStyle: const TextStyle(fontSize: 13, color: SolluColors.textMuted),
                          prefixIcon: const Icon(
                            Icons.search,
                            size: 20,
                            color: SolluColors.textMuted,
                          ),
                          suffixIcon: _searchQuery.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear, size: 18),
                                  onPressed: () {
                                    _searchController.clear();
                                    setState(() => _searchQuery = '');
                                  },
                                )
                              : null,
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 12,
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
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: SolluColors.primary,
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Filter Kategori Dropdown
                    categoriesAsync.when(
                      data: (categories) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            border: Border.all(color: SolluColors.neutral),
                            borderRadius: BorderRadius.circular(12),
                            color: Colors.white,
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String?>(
                              value: _selectedCategoryId,
                              icon: const Icon(Icons.arrow_drop_down, color: SolluColors.textMuted),
                              isDense: true,
                              style: const TextStyle(
                                fontSize: 13,
                                color: SolluColors.textDark,
                                fontWeight: FontWeight.w500,
                              ),
                              hint: const Row(
                                children: [
                                  Icon(Icons.category_outlined, size: 16, color: SolluColors.textMuted),
                                  SizedBox(width: 8),
                                  Text('Semua Kategori', style: TextStyle(color: SolluColors.textDark, fontSize: 13)),
                                ],
                              ),
                              items: [
                                const DropdownMenuItem<String?>(
                                  value: null,
                                  child: Row(
                                    children: [
                                      Icon(Icons.category_outlined, size: 16, color: SolluColors.textMuted),
                                      SizedBox(width: 8),
                                      Text('Semua Kategori'),
                                    ],
                                  ),
                                ),
                                ...categories.map((c) => DropdownMenuItem<String?>(
                                      value: c.id,
                                      child: Text(c.name),
                                    )),
                              ],
                              onChanged: (val) {
                                setState(() {
                                  _selectedCategoryId = val;
                                });
                              },
                            ),
                          ),
                        );
                      },
                      loading: () => const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2)),
                      error: (_, _) => const SizedBox(),
                    ),

                    // Sort Dropdown
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: SolluColors.neutral),
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.white,
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _sortBy,
                          icon: const Icon(Icons.arrow_drop_down, color: SolluColors.textMuted),
                          isDense: true,
                          style: const TextStyle(
                            fontSize: 13,
                            color: SolluColors.textDark,
                            fontWeight: FontWeight.w500,
                          ),
                          items: const [
                            DropdownMenuItem(
                              value: 'name_asc',
                              child: Row(
                                children: [
                                  Icon(Icons.sort_by_alpha, size: 16, color: SolluColors.textMuted),
                                  SizedBox(width: 8),
                                  Text('Nama (A - Z)'),
                                ],
                              ),
                            ),
                            DropdownMenuItem(
                              value: 'name_desc',
                              child: Row(
                                children: [
                                  Icon(Icons.sort_by_alpha, size: 16, color: SolluColors.textMuted),
                                  SizedBox(width: 8),
                                  Text('Nama (Z - A)'),
                                ],
                              ),
                            ),
                            DropdownMenuItem(
                              value: 'stock_desc',
                              child: Row(
                                children: [
                                  Icon(Icons.inventory_2_outlined, size: 16, color: SolluColors.textMuted),
                                  SizedBox(width: 8),
                                  Text('Stok Terbanyak'),
                                ],
                              ),
                            ),
                            DropdownMenuItem(
                              value: 'stock_asc',
                              child: Row(
                                children: [
                                  Icon(Icons.inventory_2_outlined, size: 16, color: SolluColors.textMuted),
                                  SizedBox(width: 8),
                                  Text('Stok Terendah'),
                                ],
                              ),
                            ),
                          ],
                          onChanged: (val) {
                            if (val != null) {
                              setState(() => _sortBy = val);
                            }
                          },
                        ),
                      ),
                    ),

                    const Spacer(),

                    // View Mode Toggle Switch (Portal App segmented style)
                    _buildViewModeToggle(viewMode),

                    // Counter Badge: Total ... Item
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: SolluColors.primary.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        posItemsAsync.when(
                          data: (items) {
                            final filtered = _applyFiltersAndSort(items, categoriesAsync.value ?? []);
                            return 'Total: ${filtered.length} Item';
                          },
                          loading: () => 'Loading...',
                          error: (_, _) => 'Error',
                        ),
                        style: const TextStyle(
                          color: SolluColors.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, color: SolluColors.neutral),

              // Product Data View (Card vs List)
              Expanded(
                child: posItemsAsync.when(
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (error, _) => Center(child: Text('Error: $error')),
                  data: (items) {
                    final categories = categoriesAsync.value ?? [];
                    final filteredProducts = _applyFiltersAndSort(items, categories);

                    if (filteredProducts.isEmpty) {
                      return _buildEmptyState(items.isEmpty);
                    }

                    if (viewMode == 'card') {
                      return _buildCardView(filteredProducts, categories);
                    } else {
                      return _buildListView(filteredProducts, categories);
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<PosItem> _applyFiltersAndSort(List<PosItem> items, List<dynamic> categories) {
    // 1. Recursive child categories resolution
    final Set<String> targetCategoryIds = {};
    if (_selectedCategoryId != null) {
      targetCategoryIds.add(_selectedCategoryId!);
      void collectChildren(String parentId) {
        final children = categories.where((c) => c.parentId == parentId);
        for (final ch in children) {
          targetCategoryIds.add(ch.id);
          collectChildren(ch.id);
        }
      }

      collectChildren(_selectedCategoryId!);
    }

    final query = _searchQuery.toLowerCase().trim();

    // 2. Filter
    final filtered = items.where((item) {
      final matchesCategory = _selectedCategoryId == null ||
          (item.categoryId != null && targetCategoryIds.contains(item.categoryId));

      final matchesSearch = query.isEmpty ||
          item.name.toLowerCase().contains(query) ||
          (item.product?.barcode?.toLowerCase().contains(query) ?? false) ||
          (item.product?.sku?.toLowerCase().contains(query) ?? false) ||
          (item.inventory?.barcode?.toLowerCase().contains(query) ?? false) ||
          (item.inventory?.sku?.toLowerCase().contains(query) ?? false);

      return matchesCategory && matchesSearch;
    }).toList();

    // 3. Sort
    switch (_sortBy) {
      case 'name_asc':
        filtered.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
        break;
      case 'name_desc':
        filtered.sort((a, b) => b.name.toLowerCase().compareTo(a.name.toLowerCase()));
        break;
      case 'stock_desc':
        filtered.sort((a, b) {
          final cmp = b.stock.compareTo(a.stock);
          return cmp != 0 ? cmp : a.name.toLowerCase().compareTo(b.name.toLowerCase());
        });
        break;
      case 'stock_asc':
        filtered.sort((a, b) {
          final cmp = a.stock.compareTo(b.stock);
          return cmp != 0 ? cmp : a.name.toLowerCase().compareTo(b.name.toLowerCase());
        });
        break;
    }

    return filtered;
  }

  Widget _buildViewModeToggle(String currentMode) {
    return Container(
      height: 38,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9), // Slate 100
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E8F0)), // Slate 200
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildToggleOption(
            icon: Icons.format_list_bulleted_rounded,
            isSelected: currentMode == 'list',
            tooltip: 'Tampilan List',
            onTap: () => ref.read(productsViewModeProvider.notifier).setMode('list'),
          ),
          _buildToggleOption(
            icon: Icons.grid_view_rounded,
            isSelected: currentMode == 'card',
            tooltip: 'Tampilan Card',
            onTap: () => ref.read(productsViewModeProvider.notifier).setMode('card'),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleOption({
    required IconData icon,
    required bool isSelected,
    required String tooltip,
    required VoidCallback onTap,
  }) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: 34,
          height: 32,
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: isSelected
                ? Border.all(color: const Color(0xFFCBD5E1).withValues(alpha: 0.8))
                : null,
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 3,
                      offset: const Offset(0, 1),
                    ),
                  ]
                : null,
          ),
          child: Icon(
            icon,
            size: 18,
            color: isSelected ? SolluColors.textDark : SolluColors.textMuted,
          ),
        ),
      ),
    );
  }

  Widget _buildListView(List<PosItem> products, List<dynamic> categories) {
    return ListView.separated(
      padding: const EdgeInsets.all(12),
      itemCount: products.length,
      separatorBuilder: (_, _) => const Divider(height: 1, color: SolluColors.neutral),
      itemBuilder: (context, index) {
        final item = products[index];
        final bool isActive = item.isActive;
        final String itemName = item.name;
        final double price = item.price;
        final double stock = item.stock;
        final bool isService = item.isService;

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
                  ? (isService ? const Color(0xFFE0F2FE) : SolluColors.background)
                  : Colors.grey.shade200,
              shape: BoxShape.circle,
            ),
            child: Icon(
              isService
                  ? Icons.room_service_rounded
                  : Icons.inventory_2_outlined,
              color: isActive
                  ? (isService ? const Color(0xFF0284C7) : SolluColors.primary)
                  : Colors.grey,
              size: 22,
            ),
          ),
          title: Row(
            children: [
              Flexible(
                child: Text(
                  itemName,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: isActive ? SolluColors.textDark : SolluColors.textMuted,
                    decoration: isActive ? TextDecoration.none : TextDecoration.lineThrough,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              if (isService) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE0F2FE),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    'Layanan',
                    style: TextStyle(
                      color: Color(0xFF0284C7),
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
              ],
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: isActive
                      ? SolluColors.success.withValues(alpha: 0.1)
                      : SolluColors.danger.withValues(alpha: 0.1),
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
            'Kategori: ${item.categoryId != null ? categories.where((c) => c.id == item.categoryId).firstOrNull?.name ?? "-" : "-"}',
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
                      color: isActive ? SolluColors.primary : SolluColors.textMuted,
                    ),
                  ),
                  Text(
                    isService ? 'Produk Layanan' : 'Stok: ${_formatStock(stock)} ${item.unit}',
                    style: TextStyle(
                      color: isService ? const Color(0xFF0284C7) : SolluColors.textMuted,
                      fontSize: 12,
                      fontWeight: isService ? FontWeight.w500 : FontWeight.normal,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 20),
              Switch.adaptive(
                value: isActive,
                activeTrackColor: SolluColors.success,
                onChanged: (bool value) => _handleToggleStatus(item, value),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCardView(List<PosItem> products, List<dynamic> categories) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = (constraints.maxWidth / 250).floor().clamp(2, 6);

        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 0.88,
          ),
          itemCount: products.length,
          itemBuilder: (context, index) {
            final item = products[index];
            final bool isActive = item.isActive;
            final bool isService = item.isService;
            final categoryName = item.categoryId != null
                ? categories.where((c) => c.id == item.categoryId).firstOrNull?.name ?? '-'
                : '-';

            return Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isActive ? const Color(0xFFE2E8F0) : Colors.grey.shade300,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Card Top Section: Icon & Overlay Badges
                  Container(
                    height: 100,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: isActive
                          ? (isService ? const Color(0xFFF0F9FF) : const Color(0xFFF8FAFC))
                          : Colors.grey.shade100,
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                    ),
                    child: Stack(
                      children: [
                        Center(
                          child: Icon(
                            isService
                                ? Icons.room_service_rounded
                                : Icons.inventory_2_outlined,
                            size: 38,
                            color: isActive
                                ? (isService ? const Color(0xFF0284C7) : SolluColors.primary.withValues(alpha: 0.8))
                                : Colors.grey.shade400,
                          ),
                        ),
                        // Type Badge (Left)
                        Positioned(
                          top: 8,
                          left: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                            decoration: BoxDecoration(
                              color: isService ? const Color(0xFFE0F2FE) : const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: isService ? const Color(0xFFBAE6FD) : const Color(0xFFE2E8F0),
                              ),
                            ),
                            child: Text(
                              isService ? 'Layanan' : 'Barang',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: isService ? const Color(0xFF0284C7) : const Color(0xFF475569),
                              ),
                            ),
                          ),
                        ),
                        // Status Badge (Right)
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                            decoration: BoxDecoration(
                              color: isActive
                                  ? SolluColors.success.withValues(alpha: 0.12)
                                  : SolluColors.danger.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              isActive ? 'Aktif' : 'Nonaktif',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: isActive ? SolluColors.success : SolluColors.danger,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Card Body
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            categoryName,
                            style: const TextStyle(
                              fontSize: 11,
                              color: SolluColors.textMuted,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            item.name,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: isActive ? SolluColors.textDark : SolluColors.textMuted,
                              decoration: isActive ? TextDecoration.none : TextDecoration.lineThrough,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const Spacer(),
                          const Divider(height: 12, color: Color(0xFFF1F5F9)),
                          // Price & Stock
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    CurrencyFormatter.format(item.price.toInt()),
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: isActive ? SolluColors.primary : SolluColors.textMuted,
                                    ),
                                  ),
                                  Text(
                                    isService ? 'Layanan' : 'Stok: ${_formatStock(item.stock)} ${item.unit}',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: isService ? const Color(0xFF0284C7) : SolluColors.textMuted,
                                      fontWeight: isService ? FontWeight.w600 : FontWeight.normal,
                                    ),
                                  ),
                                ],
                              ),
                              Transform.scale(
                                scale: 0.8,
                                child: Switch.adaptive(
                                  value: isActive,
                                  activeTrackColor: SolluColors.success,
                                  onChanged: (bool value) => _handleToggleStatus(item, value),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _handleToggleStatus(PosItem item, bool value) async {
    final messenger = ScaffoldMessenger.of(context);
    await ref.read(posRepositoryProvider).toggleInventoryActiveStatus(
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
                ? '${item.name} diaktifkan di kasir'
                : '${item.name} dinonaktifkan dari kasir',
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Widget _buildEmptyState(bool isDbEmpty) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isDbEmpty ? Icons.cloud_download_outlined : Icons.search_off,
            size: 48,
            color: SolluColors.textMuted.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 12),
          Text(
            isDbEmpty ? 'Belum ada data produk tersimpan' : 'Tidak ada produk ditemukan',
            style: const TextStyle(
              color: SolluColors.textDark,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            isDbEmpty
                ? 'Tarik data master produk terbaru dari server untuk mulai menggunakan kasir.'
                : 'Coba ubah kata kunci pencarian atau reset filter kategori.',
            style: const TextStyle(
              color: SolluColors.textMuted,
              fontSize: 13,
            ),
          ),
          if (isDbEmpty) ...[
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
}
