import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/database/database_provider.dart';
import '../../../../core/database/app_database.dart';
import '../../data/pos_repository.dart';
import 'pos_provider.dart';

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

  // Resolution state
  final String? resolvedProductItemId;
  final PosItem? resolvedPosItem;
  final String? variantCombination;
  final bool trackInventory;
  final double stock;
  final bool isCombinationAvailable;
  final String? errorMessage;

  final int qty;
  final String? discountType;
  final double? discountValue;

  VariantDialogState({
    this.isLoading = true,
    this.variantGroups = const [],
    this.variantOptions = const {},
    this.modifierGroups = const [],
    this.modifierOptions = const {},
    this.selectedVariants = const {},
    this.selectedModifiers = const {},
    this.variantPrice = 0.0,
    this.resolvedProductItemId,
    this.resolvedPosItem,
    this.variantCombination,
    this.trackInventory = true,
    this.stock = 0.0,
    this.isCombinationAvailable = true,
    this.errorMessage,
    this.qty = 1,
    this.discountType,
    this.discountValue,
  });

  bool get hasRequiredModifiersSelected {
    for (final group in modifierGroups) {
      if (group.minSelected > 0) {
        final count = (selectedModifiers[group.id] ?? []).length;
        if (count < group.minSelected) {
          return false;
        }
      }
    }
    return true;
  }

  bool get canAddToCart {
    if (isLoading) return false;
    if (variantGroups.isNotEmpty &&
        (resolvedProductItemId == null || !isCombinationAvailable)) {
      return false;
    }
    if (!hasRequiredModifiersSelected) {
      return false;
    }
    return true;
  }

  VariantDialogState copyWith({
    bool? isLoading,
    List<VariantGroup>? variantGroups,
    Map<String, List<VariantGroupOption>>? variantOptions,
    List<ModifierGroup>? modifierGroups,
    Map<String, List<ModifierOption>>? modifierOptions,
    Map<String, String>? selectedVariants,
    Map<String, List<String>>? selectedModifiers,
    double? variantPrice,
    String? resolvedProductItemId,
    PosItem? resolvedPosItem,
    String? variantCombination,
    bool? trackInventory,
    double? stock,
    bool? isCombinationAvailable,
    String? errorMessage,
    int? qty,
    String? discountType,
    double? discountValue,
    bool clearResolvedItem = false,
    bool clearErrorMessage = false,
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
      resolvedProductItemId: clearResolvedItem
          ? null
          : (resolvedProductItemId ?? this.resolvedProductItemId),
      resolvedPosItem: clearResolvedItem
          ? null
          : (resolvedPosItem ?? this.resolvedPosItem),
      variantCombination: clearResolvedItem
          ? null
          : (variantCombination ?? this.variantCombination),
      trackInventory: trackInventory ?? this.trackInventory,
      stock: stock ?? this.stock,
      isCombinationAvailable:
          isCombinationAvailable ?? this.isCombinationAvailable,
      errorMessage: (clearResolvedItem || clearErrorMessage)
          ? errorMessage
          : (errorMessage ?? this.errorMessage),
      qty: qty ?? this.qty,
      discountType: discountType ?? this.discountType,
      discountValue: discountValue ?? this.discountValue,
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
    final db = ref.read(databaseProvider);
    final posRepo = ref.read(posRepositoryProvider);
    final productId = _posItem.isProductMode
        ? _posItem.id
        : (_posItem.product?.id ?? _posItem.inventory?.productId ?? _posItem.id);

    // 1. Fetch variant groups if in product mode
    List<VariantGroup> vGroups = [];
    Map<String, List<VariantGroupOption>> vOptions = {};
    Map<String, String> initialSelectedVariants = {};

    if (_posItem.isProductMode) {
      vGroups = await (db.select(
        db.variantGroups,
      )..where((tbl) => tbl.productId.equals(productId))).get();
      if (!ref.mounted) return;
      for (var group in vGroups) {
        final options = await (db.select(
          db.variantGroupOptions,
        )..where((tbl) => tbl.variantGroupId.equals(group.id))).get();
        if (!ref.mounted) return;
        vOptions[group.id] = options;
        if (options.isNotEmpty) {
          initialSelectedVariants[group.id] = options.first.id;
        }
      }
    }

    if (!ref.mounted) return;

    // 2. Fetch modifiers
    final pmg = await (db.select(
      db.productModifierGroups,
    )..where((tbl) => tbl.productId.equals(productId))).get();
    if (!ref.mounted) return;
    final mGroupIds = pmg.map((e) => e.modifierGroupId).toList();

    List<ModifierGroup> mGroups = [];
    Map<String, List<ModifierOption>> mOptions = {};
    Map<String, List<String>> initialSelectedModifiers = {};

    if (mGroupIds.isNotEmpty) {
      mGroups = await (db.select(
        db.modifierGroups,
      )..where((tbl) => tbl.id.isIn(mGroupIds))).get();
      if (!ref.mounted) return;
      for (var group in mGroups) {
        final options = await (db.select(
          db.modifierOptions,
        )..where((tbl) => tbl.modifierGroupId.equals(group.id))).get();
        if (!ref.mounted) return;
        mOptions[group.id] = options;
        initialSelectedModifiers[group.id] = [];
      }
    }

    if (!ref.mounted) return;

    // 3. Resolve initial product item & price
    String? initialProductItemId;
    PosItem? initialResolvedPosItem;
    String? initialCombination;
    bool initialTrackInv = _posItem.trackInventory;
    double initialStock = _posItem.stock;
    double initialPrice = _posItem.price;
    bool isAvail = true;
    String? error;

    if (_posItem.isProductMode) {
      if (vGroups.isNotEmpty && initialSelectedVariants.isNotEmpty) {
        final optionIds = initialSelectedVariants.values.toList();
        initialProductItemId =
            await posRepo.findProductItemIdForVariants(productId, optionIds);
        if (!ref.mounted) return;
        if (initialProductItemId != null) {
          initialResolvedPosItem =
              await posRepo.getPosItemByProductItemId(initialProductItemId);
          if (!ref.mounted) return;
          if (initialResolvedPosItem != null) {
            initialPrice = initialResolvedPosItem.price;
            initialCombination = initialResolvedPosItem.variantCombination;
            initialTrackInv = initialResolvedPosItem.trackInventory;
            initialStock = initialResolvedPosItem.stock;
            isAvail = initialResolvedPosItem.isActive;
          }
        } else {
          isAvail = false;
          initialPrice = 0.0;
          error = 'Kombinasi varian ini tidak tersedia';
        }
      } else {
        // Single product in product mode
        initialProductItemId =
            await posRepo.findDefaultProductItemId(productId);
        if (!ref.mounted) return;
        if (initialProductItemId != null) {
          initialResolvedPosItem =
              await posRepo.getPosItemByProductItemId(initialProductItemId);
          if (!ref.mounted) return;
          if (initialResolvedPosItem != null) {
            initialPrice = initialResolvedPosItem.price;
            initialCombination = initialResolvedPosItem.variantCombination;
            initialTrackInv = initialResolvedPosItem.trackInventory;
            initialStock = initialResolvedPosItem.stock;
            isAvail = initialResolvedPosItem.isActive;
          }
        }
      }
    } else {
      // Variant mode: already a variant SKU
      initialProductItemId = _posItem.productItemId ?? _posItem.id;
      initialResolvedPosItem = _posItem;
      initialPrice = _posItem.price;
      initialCombination = _posItem.variantCombination;
      initialTrackInv = _posItem.trackInventory;
      initialStock = _posItem.stock;
      isAvail = _posItem.isActive;
    }

    if (!ref.mounted) return;

    state = state.copyWith(
      isLoading: false,
      variantGroups: vGroups,
      variantOptions: vOptions,
      modifierGroups: mGroups,
      modifierOptions: mOptions,
      selectedVariants: initialSelectedVariants,
      selectedModifiers: initialSelectedModifiers,
      resolvedProductItemId: initialProductItemId,
      resolvedPosItem: initialResolvedPosItem,
      variantCombination: initialCombination,
      trackInventory: initialTrackInv,
      stock: initialStock,
      variantPrice: initialPrice,
      isCombinationAvailable: isAvail,
      errorMessage: error,
    );
  }

  Future<void> selectVariant(String groupId, String optionId) async {
    if (!ref.mounted) return;
    final updated = Map<String, String>.from(state.selectedVariants);
    updated[groupId] = optionId;
    state = state.copyWith(selectedVariants: updated);
    await _updateVariantResolution(updated);
  }

  Future<void> _updateVariantResolution(
    Map<String, String> currentVariants,
  ) async {
    if (!ref.mounted || currentVariants.isEmpty) return;

    final posRepo = ref.read(posRepositoryProvider);
    final productId = _posItem.isProductMode
        ? _posItem.id
        : (_posItem.product?.id ?? _posItem.inventory?.productId ?? _posItem.id);

    final optionIds = currentVariants.values.toList();
    final pItemId =
        await posRepo.findProductItemIdForVariants(productId, optionIds);

    if (!ref.mounted) return;

    if (pItemId != null) {
      final resolvedPosItem = await posRepo.getPosItemByProductItemId(pItemId);
      if (!ref.mounted) return;
      if (resolvedPosItem != null) {
        state = state.copyWith(
          resolvedProductItemId: pItemId,
          resolvedPosItem: resolvedPosItem,
          variantCombination: resolvedPosItem.variantCombination,
          trackInventory: resolvedPosItem.trackInventory,
          stock: resolvedPosItem.stock,
          variantPrice: resolvedPosItem.price,
          isCombinationAvailable: resolvedPosItem.isActive,
          errorMessage: null,
          clearErrorMessage: true,
        );
      } else {
        state = state.copyWith(
          resolvedProductItemId: pItemId,
          clearResolvedItem: true,
          isCombinationAvailable: false,
          errorMessage: 'Item varian sedang dinonaktifkan',
        );
      }
    } else {
      state = state.copyWith(
        clearResolvedItem: true,
        variantPrice: 0.0,
        isCombinationAvailable: false,
        errorMessage: 'Kombinasi varian ini tidak tersedia',
      );
    }
  }

  void toggleModifier(String groupId, String optionId, bool isSelected) {
    if (!ref.mounted) return;
    final group = state.modifierGroups.firstWhere((g) => g.id == groupId);
    final updatedList = List<String>.from(
      state.selectedModifiers[groupId] ?? [],
    );

    if (isSelected) {
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

  void setQty(int qty) {
    if (!ref.mounted) return;
    if (qty > 0) {
      state = state.copyWith(qty: qty);
    }
  }

  void setDiscount(String? type, double? value) {
    if (!ref.mounted) return;
    state = state.copyWith(discountType: type, discountValue: value);
  }

  double calculateTotalPrice() {
    double total = state.variantPrice;

    for (var groupId in state.selectedModifiers.keys) {
      final selectedOpts = state.selectedModifiers[groupId]!;
      final opts = state.modifierOptions[groupId] ?? [];
      for (var optId in selectedOpts) {
        final opt = opts.firstWhereOrNull((o) => o.id == optId);
        if (opt != null) {
          total += opt.price;
        }
      }
    }

    return total;
  }
}

final variantDialogProvider = NotifierProvider.autoDispose
    .family<VariantDialogNotifier, VariantDialogState, PosItem>((posItem) {
  return VariantDialogNotifier(posItem);
});
