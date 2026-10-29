import 'package:collection/collection.dart';

class CartItem {
  final String id;
  final String productId;
  final String? productItemId;
  final String inventoryItemId;
  final String? variantGroupOptionId;
  final String name;
  final String? variantCombination;
  final bool trackInventory;
  final double price;
  final int qty;
  final String? discountType;
  final double? discountValue;
  final String? notes;

  // Storing this for reference/display
  final Map<String, String> selectedVariants;
  final Map<String, List<String>> selectedModifiers;

  CartItem({
    required this.id,
    required this.productId,
    this.productItemId,
    this.inventoryItemId = '',
    this.variantGroupOptionId,
    required this.name,
    this.variantCombination,
    this.trackInventory = true,
    required this.price,
    this.qty = 1,
    this.discountType,
    this.discountValue,
    this.notes,
    this.selectedVariants = const {},
    this.selectedModifiers = const {},
  });

  double get calculatedDiscountAmount {
    if (discountValue == null || discountValue == 0) return 0.0;
    if (discountType == 'percentage') {
      final val = (price * discountValue!) / 100.0;
      return val > price ? price : val;
    } else if (discountType == 'fixed') {
      return discountValue! > price ? price : discountValue!;
    }
    return 0.0;
  }

  double get calculatedSubtotal {
    return (price - calculatedDiscountAmount) * qty;
  }

  double get totalPrice => calculatedSubtotal;

  CartItem copyWith({
    String? id,
    String? productId,
    String? productItemId,
    String? inventoryItemId,
    String? variantGroupOptionId,
    String? name,
    String? variantCombination,
    bool? trackInventory,
    double? price,
    int? qty,
    String? discountType,
    double? discountValue,
    String? notes,
    Map<String, String>? selectedVariants,
    Map<String, List<String>>? selectedModifiers,
  }) {
    return CartItem(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      productItemId: productItemId ?? this.productItemId,
      inventoryItemId: inventoryItemId ?? this.inventoryItemId,
      variantGroupOptionId: variantGroupOptionId ?? this.variantGroupOptionId,
      name: name ?? this.name,
      variantCombination: variantCombination ?? this.variantCombination,
      trackInventory: trackInventory ?? this.trackInventory,
      price: price ?? this.price,
      qty: qty ?? this.qty,
      discountType: discountType ?? this.discountType,
      discountValue: discountValue ?? this.discountValue,
      notes: notes ?? this.notes,
      selectedVariants: selectedVariants ?? this.selectedVariants,
      selectedModifiers: selectedModifiers ?? this.selectedModifiers,
    );
  }

  Map<String, dynamic> toMap() => toJson();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product_id': productId,
      'product_item_id': productItemId,
      'inventory_item_id': inventoryItemId,
      'variant_group_option_id': variantGroupOptionId,
      'name': name,
      'variant_combination': variantCombination,
      'track_inventory': trackInventory,
      'price': price,
      'qty': qty,
      'discount_type': discountType,
      'discount_value': discountValue,
      'notes': notes,
      'selected_variants': selectedVariants,
      'selected_modifiers': selectedModifiers,
    };
  }

  factory CartItem.fromMap(Map<String, dynamic> map) => CartItem.fromJson(map);

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['id'] as String,
      productId: json['product_id'] as String,
      productItemId: json['product_item_id'] as String?,
      inventoryItemId: (json['inventory_item_id'] as String?) ?? '',
      variantGroupOptionId: json['variant_group_option_id'] as String?,
      name: json['name'] as String,
      variantCombination: json['variant_combination'] as String?,
      trackInventory: json['track_inventory'] as bool? ?? true,
      price: (json['price'] as num).toDouble(),
      qty: (json['qty'] as num?)?.toInt() ?? 1,
      discountType: json['discount_type'] as String?,
      discountValue: (json['discount_value'] as num?)?.toDouble(),
      notes: json['notes'] as String?,
      selectedVariants:
          (json['selected_variants'] as Map<String, dynamic>?)?.map(
                (k, v) => MapEntry(k, v.toString()),
              ) ??
              const {},
      selectedModifiers:
          (json['selected_modifiers'] as Map<String, dynamic>?)?.map(
                (k, v) => MapEntry(
                  k,
                  (v as List).map((e) => e.toString()).toList(),
                ),
              ) ??
              const {},
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CartItem &&
        other.id == id &&
        other.productId == productId &&
        other.productItemId == productItemId &&
        other.inventoryItemId == inventoryItemId &&
        other.variantGroupOptionId == variantGroupOptionId &&
        other.name == name &&
        other.variantCombination == variantCombination &&
        other.trackInventory == trackInventory &&
        other.price == price &&
        other.qty == qty &&
        other.discountType == discountType &&
        other.discountValue == discountValue &&
        other.notes == notes &&
        const DeepCollectionEquality().equals(other.selectedVariants, selectedVariants) &&
        const DeepCollectionEquality.unordered().equals(other.selectedModifiers, selectedModifiers);
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      productId,
      productItemId,
      inventoryItemId,
      variantGroupOptionId,
      name,
      variantCombination,
      trackInventory,
      price,
      qty,
      discountType,
      discountValue,
      notes,
    );
  }
}
