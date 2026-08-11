import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/database/database_provider.dart';
import '../../../../core/database/app_database.dart';
import '../../data/pos_repository.dart';

class VariantDialogState {
  final bool isLoading;
  final List<VariantGroup> variantGroups;
  final Map<String, List<VariantGroupOption>> variantOptions;
  final List<ModifierGroup> modifierGroups;
  final Map<String, List<ModifierOption>> modifierOptions;
  
  // Selected state
  final Map<String, String> selectedVariants; // variantGroupId -> optionId
  final Map<String, List<String>> selectedModifiers; // modifierGroupId -> list of optionId
  final double variantPrice; // specific price for selected variant combination

  VariantDialogState({
    this.isLoading = true,
    this.variantGroups = const [],
    this.variantOptions = const {},
    this.modifierGroups = const [],
    this.modifierOptions = const {},
    this.selectedVariants = const {},
    this.selectedModifiers = const {},
    this.variantPrice = 0.0,
  });

  VariantDialogState copyWith({
    bool? isLoading,
    List<VariantGroup>? variantGroups,
    Map<String, List<VariantGroupOption>>? variantOptions,
    List<ModifierGroup>? modifierGroups,
    Map<String, List<ModifierOption>>? modifierOptions,
    Map<String, String>? selectedVariants,
    Map<String, List<String>>? selectedModifiers,
    double? variantPrice,
  }) {
    return VariantDialogState(
      isLoading: isLoading ?? this.isLoading,
      variantGroups: variantGroups ?? this.variantGroups,
      variantOptions: variantOptions ?? this.variantOptions,
      modifierGroups: modifierGroups ?? this.modifierGroups,
      modifierOptions: modifierOptions ?? this.modifierOptions,
      selectedVariants: selectedVariants ?? this.selectedVariants,
      selectedModifiers: selectedModifiers ?? this.selectedModifiers,
      variantPrice: variantPrice ?? this.variantPrice,
    );
  }
}

class VariantDialogNotifier extends Notifier<VariantDialogState> {
  final PosItem _posItem;

  VariantDialogNotifier(this._posItem);

  @override
  VariantDialogState build() {
    _init();
    return VariantDialogState();
  }

  Future<void> _init() async {
    final db = ref.watch(databaseProvider);
    final productId = _posItem.isProductMode ? _posItem.id : _posItem.inventory!.productId;
    
    // Fetch variant groups if in product mode
    List<VariantGroup> vGroups = [];
    Map<String, List<VariantGroupOption>> vOptions = {};
    Map<String, String> initialSelectedVariants = {};

    if (_posItem.isProductMode) {
      vGroups = await (db.select(db.variantGroups)..where((tbl) => tbl.productId.equals(productId))).get();
      for (var group in vGroups) {
        final options = await (db.select(db.variantGroupOptions)..where((tbl) => tbl.variantGroupId.equals(group.id))).get();
        vOptions[group.id] = options;
        if (options.isNotEmpty) {
          initialSelectedVariants[group.id] = options.first.id; // Auto select first
        }
      }
    }

    // Fetch modifiers
    final pmg = await (db.select(db.productModifierGroups)..where((tbl) => tbl.productId.equals(productId))).get();
    final mGroupIds = pmg.map((e) => e.modifierGroupId).toList();
    
    List<ModifierGroup> mGroups = [];
    Map<String, List<ModifierOption>> mOptions = {};
    Map<String, List<String>> initialSelectedModifiers = {};

    if (mGroupIds.isNotEmpty) {
      mGroups = await (db.select(db.modifierGroups)..where((tbl) => tbl.id.isIn(mGroupIds))).get();
      for (var group in mGroups) {
        final options = await (db.select(db.modifierOptions)..where((tbl) => tbl.modifierGroupId.equals(group.id))).get();
        mOptions[group.id] = options;
        initialSelectedModifiers[group.id] = []; // Empty selection initially
      }
    }

    state = state.copyWith(
      isLoading: false,
      variantGroups: vGroups,
      variantOptions: vOptions,
      modifierGroups: mGroups,
      modifierOptions: mOptions,
      selectedVariants: initialSelectedVariants,
      selectedModifiers: initialSelectedModifiers,
      variantPrice: _posItem.price,
    );
    
    if (_posItem.isProductMode && initialSelectedVariants.isNotEmpty) {
      _updateVariantPrice(initialSelectedVariants);
    }
  }
  
  Future<void> _updateVariantPrice(Map<String, String> currentVariants) async {
    if (currentVariants.isEmpty) return;
  }

  void selectVariant(String groupId, String optionId) {
    final updated = Map<String, String>.from(state.selectedVariants);
    updated[groupId] = optionId;
    state = state.copyWith(selectedVariants: updated);
    _updateVariantPrice(updated);
  }

  void toggleModifier(String groupId, String optionId, bool isSelected) {
    final group = state.modifierGroups.firstWhere((g) => g.id == groupId);
    final updatedList = List<String>.from(state.selectedModifiers[groupId] ?? []);
    
    if (isSelected) {
      // Check max limit if radio type or limited checkbox
      if (group.type == 'radio' || group.maxSelected == 1) {
        updatedList.clear();
        updatedList.add(optionId);
      } else {
        if (group.maxSelected == 0 || updatedList.length < group.maxSelected) {
          updatedList.add(optionId);
        }
      }
    } else {
      updatedList.remove(optionId);
    }

    final updated = Map<String, List<String>>.from(state.selectedModifiers);
    updated[groupId] = updatedList;
    state = state.copyWith(selectedModifiers: updated);
  }

  double calculateTotalPrice() {
    double total = state.variantPrice;

    for (var groupId in state.selectedModifiers.keys) {
      final selectedOpts = state.selectedModifiers[groupId]!;
      final opts = state.modifierOptions[groupId]!;
      for (var optId in selectedOpts) {
        final opt = opts.firstWhere((o) => o.id == optId);
        total += opt.price;
      }
    }
    
    return total;
  }
}

final variantDialogProvider = NotifierProvider.autoDispose.family<VariantDialogNotifier, VariantDialogState, PosItem>((posItem) {
  return VariantDialogNotifier(posItem);
});
