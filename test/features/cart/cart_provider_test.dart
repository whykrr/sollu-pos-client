import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sollu_pos_client/features/pos/presentation/providers/cart_provider.dart';

void main() {
  group('CartItem Domain Entity Tests', () {
    test('instantiates with defaults and custom properties', () {
      final item = CartItem(
        id: 'item-1',
        productId: 'prod-1',
        productItemId: 'pi-1',
        name: 'Kopi Susu Large',
        variantCombination: 'Large - Less Ice',
        trackInventory: false,
        price: 25000.0,
        qty: 2,
        notes: 'Less sugar',
      );

      expect(item.id, 'item-1');
      expect(item.productId, 'prod-1');
      expect(item.productItemId, 'pi-1');
      expect(item.inventoryItemId, '');
      expect(item.name, 'Kopi Susu Large');
      expect(item.variantCombination, 'Large - Less Ice');
      expect(item.trackInventory, false);
      expect(item.price, 25000.0);
      expect(item.qty, 2);
      expect(item.notes, 'Less sugar');
      expect(item.totalPrice, 50000.0);
    });

    test('calculates discount correctly for percentage and fixed types', () {
      final itemPercent = CartItem(
        id: 'item-1',
        productId: 'prod-1',
        name: 'Latte',
        price: 30000.0,
        qty: 2,
        discountType: 'percentage',
        discountValue: 10.0,
      );
      // 10% of 30,000 = 3,000 per unit discount
      expect(itemPercent.calculatedDiscountAmount, 3000.0);
      // Subtotal = (30,000 - 3,000) * 2 = 54,000
      expect(itemPercent.calculatedSubtotal, 54000.0);
      expect(itemPercent.totalPrice, 54000.0);

      final itemFixed = CartItem(
        id: 'item-2',
        productId: 'prod-1',
        name: 'Latte',
        price: 30000.0,
        qty: 3,
        discountType: 'fixed',
        discountValue: 5000.0,
      );
      // 5,000 per unit discount
      expect(itemFixed.calculatedDiscountAmount, 5000.0);
      // Subtotal = (30,000 - 5,000) * 3 = 75,000
      expect(itemFixed.calculatedSubtotal, 75000.0);
      expect(itemFixed.totalPrice, 75000.0);
    });

    test('serializes to and from JSON losslessly', () {
      final original = CartItem(
        id: 'item-sync-1',
        productId: 'prod-sync-1',
        productItemId: 'pi-sync-1',
        inventoryItemId: 'inv-sync-1',
        variantGroupOptionId: 'opt-large',
        name: 'Es Kopi Gula Aren',
        variantCombination: 'Large - Hot',
        trackInventory: false,
        price: 22000.0,
        qty: 3,
        discountType: 'fixed',
        discountValue: 2000.0,
        notes: 'Sedotan kertas',
        selectedVariants: {'grp-size': 'opt-large', 'grp-temp': 'opt-hot'},
        selectedModifiers: {
          'mod-topping': ['opt-boba', 'opt-jelly'],
        },
      );

      final json = original.toJson();
      final restored = CartItem.fromJson(json);

      expect(restored.id, original.id);
      expect(restored.productId, original.productId);
      expect(restored.productItemId, original.productItemId);
      expect(restored.inventoryItemId, original.inventoryItemId);
      expect(restored.variantGroupOptionId, original.variantGroupOptionId);
      expect(restored.name, original.name);
      expect(restored.variantCombination, original.variantCombination);
      expect(restored.trackInventory, false);
      expect(restored.price, 22000.0);
      expect(restored.qty, 3);
      expect(restored.discountType, 'fixed');
      expect(restored.discountValue, 2000.0);
      expect(restored.notes, 'Sedotan kertas');
      expect(restored.selectedVariants, original.selectedVariants);
      expect(restored.selectedModifiers, original.selectedModifiers);

      // Verify toMap and fromMap aliases
      final map = original.toMap();
      final fromMap = CartItem.fromMap(map);
      expect(fromMap.id, original.id);
      expect(fromMap.productItemId, original.productItemId);
    });

    test('copyWith updates fields while preserving unedited attributes', () {
      final original = CartItem(
        id: 'item-cw',
        productId: 'prod-cw',
        productItemId: 'pi-cw-1',
        name: 'Kopi',
        variantCombination: 'Small',
        trackInventory: true,
        price: 15000.0,
        qty: 1,
      );

      final updated = original.copyWith(
        productItemId: 'pi-cw-2',
        variantCombination: 'Large',
        trackInventory: false,
        price: 20000.0,
        qty: 4,
      );

      expect(updated.id, original.id);
      expect(updated.productId, original.productId);
      expect(updated.productItemId, 'pi-cw-2');
      expect(updated.variantCombination, 'Large');
      expect(updated.trackInventory, false);
      expect(updated.price, 20000.0);
      expect(updated.qty, 4);
    });
  });

  group('CartNotifier State Management & Deduplication Tests', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('adds new distinct items to cart', () {
      final notifier = container.read(cartProvider.notifier);

      notifier.addItem(
        CartItem(
          id: 'item-1',
          productId: 'prod-1',
          productItemId: 'pi-1',
          name: 'Item 1',
          price: 10000.0,
          qty: 1,
        ),
      );
      notifier.addItem(
        CartItem(
          id: 'item-2',
          productId: 'prod-2',
          productItemId: 'pi-2',
          name: 'Item 2',
          price: 15000.0,
          qty: 2,
        ),
      );

      final cart = container.read(cartProvider);
      expect(cart.length, 2);
      expect(cart[0].productItemId, 'pi-1');
      expect(cart[1].productItemId, 'pi-2');
    });

    test('deduplicates and increments qty when adding matching productItemId and modifiers', () {
      final notifier = container.read(cartProvider.notifier);

      notifier.addItem(
        CartItem(
          id: 'item-1',
          productId: 'prod-1',
          productItemId: 'pi-100',
          name: 'Kopi Varian A',
          price: 20000.0,
          qty: 1,
          selectedModifiers: {
            'mod-1': ['opt-a', 'opt-b'],
          },
        ),
      );

      // Add identical item with modifiers in different order
      notifier.addItem(
        CartItem(
          id: 'item-2',
          productId: 'prod-1',
          productItemId: 'pi-100',
          name: 'Kopi Varian A',
          price: 20000.0,
          qty: 3,
          selectedModifiers: {
            'mod-1': ['opt-b', 'opt-a'], // Unordered match
          },
        ),
      );

      final cart = container.read(cartProvider);
      expect(cart.length, 1);
      expect(cart.first.productItemId, 'pi-100');
      expect(cart.first.qty, 4); // 1 + 3
    });

    test('deduplicates when modifiers contain empty lists vs empty map', () {
      final notifier = container.read(cartProvider.notifier);

      notifier.addItem(
        CartItem(
          id: 'item-1',
          productId: 'prod-1',
          productItemId: 'pi-1',
          name: 'Item 1',
          price: 20000.0,
          qty: 1,
          selectedModifiers: const {},
        ),
      );

      notifier.addItem(
        CartItem(
          id: 'item-2',
          productId: 'prod-1',
          productItemId: 'pi-1',
          name: 'Item 1',
          price: 20000.0,
          qty: 2,
          selectedModifiers: const {'mod-optional': []},
        ),
      );

      final cart = container.read(cartProvider);
      expect(cart.length, 1);
      expect(cart.first.qty, 3);
    });

    test('does NOT deduplicate when productItemId differs', () {
      final notifier = container.read(cartProvider.notifier);

      notifier.addItem(
        CartItem(
          id: 'item-1',
          productId: 'prod-1',
          productItemId: 'pi-size-s',
          name: 'Kopi Small',
          price: 15000.0,
          qty: 1,
        ),
      );

      notifier.addItem(
        CartItem(
          id: 'item-2',
          productId: 'prod-1',
          productItemId: 'pi-size-l',
          name: 'Kopi Large',
          price: 20000.0,
          qty: 1,
        ),
      );

      final cart = container.read(cartProvider);
      expect(cart.length, 2);
      expect(cart[0].productItemId, 'pi-size-s');
      expect(cart[1].productItemId, 'pi-size-l');
    });

    test('does NOT deduplicate when modifiers differ', () {
      final notifier = container.read(cartProvider.notifier);

      notifier.addItem(
        CartItem(
          id: 'item-1',
          productId: 'prod-1',
          productItemId: 'pi-1',
          name: 'Kopi',
          price: 15000.0,
          qty: 1,
          selectedModifiers: {
            'mod-1': ['opt-boba'],
          },
        ),
      );

      notifier.addItem(
        CartItem(
          id: 'item-2',
          productId: 'prod-1',
          productItemId: 'pi-1',
          name: 'Kopi',
          price: 15000.0,
          qty: 1,
          selectedModifiers: {
            'mod-1': ['opt-jelly'],
          },
        ),
      );

      final cart = container.read(cartProvider);
      expect(cart.length, 2);
    });

    test('fallback deduplicates by inventoryItemId, productId, and variants when productItemId is absent', () {
      final notifier = container.read(cartProvider.notifier);

      notifier.addItem(
        CartItem(
          id: 'item-legacy-1',
          productId: 'prod-legacy',
          inventoryItemId: 'inv-legacy-1',
          name: 'Legacy Product',
          price: 10000.0,
          qty: 2,
          selectedVariants: {'v': 'opt-1'},
        ),
      );

      notifier.addItem(
        CartItem(
          id: 'item-legacy-2',
          productId: 'prod-legacy',
          inventoryItemId: 'inv-legacy-1',
          name: 'Legacy Product',
          price: 10000.0,
          qty: 3,
          selectedVariants: {'v': 'opt-1'},
        ),
      );

      final cart = container.read(cartProvider);
      expect(cart.length, 1);
      expect(cart.first.qty, 5);
    });

    test('updateItemDetails preserves productItemId and trackInventory', () {
      final notifier = container.read(cartProvider.notifier);

      notifier.addItem(
        CartItem(
          id: 'item-update',
          productId: 'prod-update',
          productItemId: 'pi-update-1',
          variantCombination: 'Reguler',
          trackInventory: false,
          name: 'Produk Update',
          price: 25000.0,
          qty: 1,
        ),
      );

      notifier.updateItemDetails(
        'item-update',
        qty: 5,
        discountType: 'percentage',
        discountValue: 20.0,
        notes: 'Extra ice',
      );

      final cart = container.read(cartProvider);
      expect(cart.length, 1);
      final item = cart.first;
      expect(item.qty, 5);
      expect(item.discountType, 'percentage');
      expect(item.discountValue, 20.0);
      expect(item.notes, 'Extra ice');
      expect(item.productItemId, 'pi-update-1');
      expect(item.variantCombination, 'Reguler');
      expect(item.trackInventory, false);
    });

    test('updatePrice, updateQty, removeItem, and clearCart', () {
      final notifier = container.read(cartProvider.notifier);

      notifier.addItem(
        CartItem(
          id: 'item-ops',
          productId: 'prod-ops',
          productItemId: 'pi-ops',
          name: 'Ops Product',
          price: 10000.0,
          qty: 2,
        ),
      );

      notifier.updatePrice('item-ops', 12000.0);
      expect(container.read(cartProvider).first.price, 12000.0);

      notifier.updateQty('item-ops', 1);
      expect(container.read(cartProvider).first.qty, 3);

      notifier.updateQty('item-ops', -3);
      expect(container.read(cartProvider).isEmpty, true);

      notifier.addItem(
        CartItem(
          id: 'item-clear',
          productId: 'prod-clear',
          name: 'Clear Me',
          price: 5000.0,
        ),
      );
      expect(container.read(cartProvider).length, 1);
      notifier.clearCart();
      expect(container.read(cartProvider).isEmpty, true);
    });
  });
}
