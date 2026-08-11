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
