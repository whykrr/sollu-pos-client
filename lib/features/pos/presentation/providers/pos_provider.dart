import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/database/database_provider.dart';
import '../../../../core/providers/preferences_provider.dart';
import '../../data/pos_repository.dart';

final posRepositoryProvider = Provider<PosRepository>((ref) {
  final database = ref.watch(databaseProvider);
  return PosRepository(database);
});

final posItemsProvider = StreamProvider<List<PosItem>>((ref) {
  final repository = ref.watch(posRepositoryProvider);
  final mode = ref.watch(posDisplayModeProvider);
  
  if (mode == 'product') {
    return repository.watchProductModeItems();
  } else {
    return repository.watchVariantModeItems();
  }
});

class PosSearchQueryNotifier extends Notifier<String> {
  @override
  String build() => '';

  void setQuery(String query) {
    state = query;
  }
}

final posSearchQueryProvider = NotifierProvider<PosSearchQueryNotifier, String>(PosSearchQueryNotifier.new);

final posCategoriesProvider = StreamProvider((ref) {
  final repository = ref.watch(posRepositoryProvider);
  return repository.watchCategories();
});

class PosSelectedCategoryNotifier extends Notifier<String?> {
  @override
  String? build() => null;

  void setCategory(String? categoryId) {
    state = categoryId;
  }
}

final posSelectedCategoryProvider = NotifierProvider<PosSelectedCategoryNotifier, String?>(PosSelectedCategoryNotifier.new);

/// Provider yang menggabungkan filtering kategori + search query secara terpusat.
/// Menggantikan logika filtering yang sebelumnya ada di widget ProductGrid.
final filteredPosItemsProvider = Provider<AsyncValue<List<PosItem>>>((ref) {
  final itemsAsync = ref.watch(posItemsProvider);
  final categoriesAsync = ref.watch(posCategoriesProvider);
  final searchQuery = ref.watch(posSearchQueryProvider).toLowerCase();
  final selectedCategory = ref.watch(posSelectedCategoryProvider);

  return itemsAsync.when(
    loading: () => const AsyncValue.loading(),
    error: (e, st) => AsyncValue.error(e, st),
    data: (items) {
      // Kumpulkan category ID yang relevan (kategori terpilih + sub-kategori anaknya)
      final Set<String> matchingCategoryIds = {};
      if (selectedCategory != null) {
        matchingCategoryIds.add(selectedCategory);
        categoriesAsync.whenData((categories) {
          void addChildIds(String parentId) {
            final children = categories.where((c) => c.parentId == parentId);
            for (final child in children) {
              matchingCategoryIds.add(child.id);
              addChildIds(child.id); // Recursive untuk nested categories
            }
          }
          addChildIds(selectedCategory);
        });
      }

      final filteredItems = items.where((item) {
        final matchesCategory = selectedCategory == null ||
            (item.categoryId != null && matchingCategoryIds.contains(item.categoryId));
        final matchesSearch = searchQuery.isEmpty ||
            item.name.toLowerCase().contains(searchQuery) ||
            (item.product?.barcode?.toLowerCase().contains(searchQuery) ?? false) ||
            (item.inventory?.barcode?.toLowerCase().contains(searchQuery) ?? false);

        return matchesCategory && matchesSearch;
      }).toList();

      return AsyncValue.data(filteredItems);
    },
  );
});
