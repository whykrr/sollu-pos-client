import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sollu_pos_client/core/database/app_database.dart';
import 'package:sollu_pos_client/core/database/database_provider.dart';
import 'package:sollu_pos_client/features/pos/data/pos_repository.dart';
import 'package:sollu_pos_client/features/pos/presentation/providers/pos_provider.dart';
import 'package:sollu_pos_client/features/pos/presentation/providers/variant_dialog_provider.dart';
import 'package:sollu_pos_client/features/pos/presentation/widgets/variant_dialog.dart';
import 'package:sollu_pos_client/features/pos/presentation/providers/cart_provider.dart';

void main() {
  group('Adversarial Challenge A & B: Multi-Attribute Variant Resolution & Non-Existent Combinations', () {
    late AppDatabase db;
    late PosRepository posRepo;

    setUp(() async {
      db = AppDatabase.forTesting(NativeDatabase.memory());
      posRepo = PosRepository(db);

      // Product 1: Kopi Multi Atribut (Size: S, M, L; Temp: Hot, Ice; Milk: Oat, Dairy)
      await db.into(db.products).insert(
            ProductsCompanion.insert(
              id: 'prod-multi',
              name: 'Kopi Multi Atribut',
              price: const Value(20000.0),
              isAvailable: const Value(true),
              hasVariants: const Value(true),
              trackInventory: const Value(true),
            ),
          );

      // Product 2: Teh (Collision isolation test)
      await db.into(db.products).insert(
            ProductsCompanion.insert(
              id: 'prod-other',
              name: 'Teh Hijau',
              price: const Value(15000.0),
              isAvailable: const Value(true),
              hasVariants: const Value(true),
              trackInventory: const Value(true),
            ),
          );

      // Groups for Product 1
      await db.into(db.variantGroups).insert(
            VariantGroupsCompanion.insert(id: 'grp-size', productId: 'prod-multi', name: 'Size'),
          );
      await db.into(db.variantGroupOptions).insert(
            VariantGroupOptionsCompanion.insert(id: 'opt-s', variantGroupId: 'grp-size', name: 'Small'),
          );
      await db.into(db.variantGroupOptions).insert(
            VariantGroupOptionsCompanion.insert(id: 'opt-m', variantGroupId: 'grp-size', name: 'Medium'),
          );
      await db.into(db.variantGroupOptions).insert(
            VariantGroupOptionsCompanion.insert(id: 'opt-l', variantGroupId: 'grp-size', name: 'Large'),
          );

      await db.into(db.variantGroups).insert(
            VariantGroupsCompanion.insert(id: 'grp-temp', productId: 'prod-multi', name: 'Temp'),
          );
      await db.into(db.variantGroupOptions).insert(
            VariantGroupOptionsCompanion.insert(id: 'opt-hot', variantGroupId: 'grp-temp', name: 'Hot'),
          );
      await db.into(db.variantGroupOptions).insert(
            VariantGroupOptionsCompanion.insert(id: 'opt-ice', variantGroupId: 'grp-temp', name: 'Ice'),
          );

      await db.into(db.variantGroups).insert(
            VariantGroupsCompanion.insert(id: 'grp-milk', productId: 'prod-multi', name: 'Milk'),
          );
      await db.into(db.variantGroupOptions).insert(
            VariantGroupOptionsCompanion.insert(id: 'opt-oat', variantGroupId: 'grp-milk', name: 'Oat'),
          );
      await db.into(db.variantGroupOptions).insert(
            VariantGroupOptionsCompanion.insert(id: 'opt-dairy', variantGroupId: 'grp-milk', name: 'Dairy'),
          );

      // Option for Product 2
      await db.into(db.variantGroups).insert(
            VariantGroupsCompanion.insert(id: 'grp-other-size', productId: 'prod-other', name: 'Other Size'),
          );
      await db.into(db.variantGroupOptions).insert(
            VariantGroupOptionsCompanion.insert(id: 'opt-other-s', variantGroupId: 'grp-other-size', name: 'Small'),
          );

      // Registered Combinations:
      // Item 1: Small + Hot + Dairy (22,000)
      await db.into(db.productItems).insert(
            ProductItemsCompanion.insert(
              id: 'pi-s-hot-dairy',
              productId: 'prod-multi',
              name: 'Kopi - S Hot Dairy',
              variantCombination: const Value('Small - Hot - Dairy'),
              trackInventory: const Value(true),
              isActive: const Value(true),
              sellable: const Value(true),
            ),
          );
      await db.into(db.productPrices).insert(
            ProductPricesCompanion.insert(
              id: 'pr-s-hot-dairy',
              productId: 'prod-multi',
              productItemId: const Value('pi-s-hot-dairy'),
              amount: const Value(22000.0),
            ),
          );
      for (final opt in ['opt-s', 'opt-hot', 'opt-dairy']) {
        await db.into(db.productItemVariantGroupOptions).insert(
              ProductItemVariantGroupOptionsCompanion.insert(
                productItemId: 'pi-s-hot-dairy',
                variantGroupOptionId: opt,
              ),
            );
      }

      // Item 2: Large + Ice + Oat (32,000)
      await db.into(db.productItems).insert(
            ProductItemsCompanion.insert(
              id: 'pi-l-ice-oat',
              productId: 'prod-multi',
              name: 'Kopi - L Ice Oat',
              variantCombination: const Value('Large - Ice - Oat'),
              trackInventory: const Value(false),
              isActive: const Value(true),
              sellable: const Value(true),
            ),
          );
      await db.into(db.productPrices).insert(
            ProductPricesCompanion.insert(
              id: 'pr-l-ice-oat',
              productId: 'prod-multi',
              productItemId: const Value('pi-l-ice-oat'),
              amount: const Value(32000.0),
            ),
          );
      for (final opt in ['opt-l', 'opt-ice', 'opt-oat']) {
        await db.into(db.productItemVariantGroupOptions).insert(
              ProductItemVariantGroupOptionsCompanion.insert(
                productItemId: 'pi-l-ice-oat',
                variantGroupOptionId: opt,
              ),
            );
      }

      // Item 3 in Product 2 (collision test)
      await db.into(db.productItems).insert(
            ProductItemsCompanion.insert(
              id: 'pi-other-item',
              productId: 'prod-other',
              name: 'Teh - Small',
              variantCombination: const Value('Small'),
              trackInventory: const Value(true),
              isActive: const Value(true),
              sellable: const Value(true),
            ),
          );
      await db.into(db.productPrices).insert(
            ProductPricesCompanion.insert(
              id: 'pr-other-1',
              productId: 'prod-other',
              productItemId: const Value('pi-other-item'),
              amount: const Value(15000.0),
            ),
          );
      await db.into(db.productItemVariantGroupOptions).insert(
            ProductItemVariantGroupOptionsCompanion.insert(
              productItemId: 'pi-other-item',
              variantGroupOptionId: 'opt-other-s',
            ),
          );
    });

    tearDown(() async {
      await db.close();
    });

    test('exact relational division: resolves multi-attribute combination regardless of option order in query', () async {
      // Query with options in scrambled order: Oat, Large, Ice
      final resolvedId = await posRepo.findProductItemIdForVariants(
        'prod-multi',
        ['opt-oat', 'opt-l', 'opt-ice'],
      );
      expect(resolvedId, 'pi-l-ice-oat');

      final posItem = await posRepo.getPosItemByProductItemId(resolvedId!);
      expect(posItem, isNotNull);
      expect(posItem!.price, 32000.0);
      expect(posItem.trackInventory, false);
      expect(posItem.variantCombination, 'Large - Ice - Oat');
    });

    test('exact relational division: partial subset of options returns null (no false positive match)', () async {
      // Pass only 2 out of 3 options: Large and Ice (missing Milk)
      final resolvedId = await posRepo.findProductItemIdForVariants(
        'prod-multi',
        ['opt-l', 'opt-ice'],
      );
      expect(resolvedId, isNull);
    });

    test('exact relational division: superset of options returns null (no false positive match)', () async {
      // Pass 4 options when product items only have 3 options
      final resolvedId = await posRepo.findProductItemIdForVariants(
        'prod-multi',
        ['opt-l', 'opt-ice', 'opt-oat', 'opt-s'],
      );
      expect(resolvedId, isNull);
    });

    test('cross-product isolation: option belonging to another product returns null', () async {
      // Query prod-multi with prod-other option
      final resolvedId = await posRepo.findProductItemIdForVariants(
        'prod-multi',
        ['opt-other-s'],
      );
      expect(resolvedId, isNull);
    });

    test('VariantDialogNotifier: selecting non-existent 3-attribute combination sets isCombinationAvailable=false and disables cart addition', () async {
      final posItem = PosItem(
        id: 'prod-multi',
        name: 'Kopi Multi Atribut',
        price: 20000.0,
        stock: 10.0,
        unit: 'Cup',
        isActive: true,
        hasVariants: true,
        isProductMode: true,
        trackInventory: true,
      );

      final container = ProviderContainer(
        overrides: [
          databaseProvider.overrideWithValue(db),
          posRepositoryProvider.overrideWithValue(posRepo),
        ],
      );
      final sub = container.listen(variantDialogProvider(posItem), (_, _) {});
      addTearDown(sub.close);
      addTearDown(container.dispose);

      final notifier = container.read(variantDialogProvider(posItem).notifier);
      await Future<void>.delayed(const Duration(milliseconds: 100));

      // Initial state is Small + Hot + Oat (which does NOT exist in registered items!)
      final initState = container.read(variantDialogProvider(posItem));
      expect(initState.isCombinationAvailable, false);
      expect(initState.resolvedProductItemId, isNull);
      expect(initState.errorMessage, 'Kombinasi varian ini tidak tersedia');
      expect(initState.canAddToCart, false);

      // Now select Dairy for Milk -> Small + Hot + Dairy (EXISTS: pi-s-hot-dairy)
      await notifier.selectVariant('grp-milk', 'opt-dairy');
      final validState = container.read(variantDialogProvider(posItem));
      expect(validState.isCombinationAvailable, true);
      expect(validState.resolvedProductItemId, 'pi-s-hot-dairy');
      expect(validState.variantPrice, 22000.0);
      expect(validState.errorMessage, isNull);
      expect(validState.canAddToCart, true);

      // Now select Medium for Size -> Medium + Hot + Dairy (DOES NOT EXIST)
      await notifier.selectVariant('grp-size', 'opt-m');
      final invalidState = container.read(variantDialogProvider(posItem));
      expect(invalidState.isCombinationAvailable, false);
      expect(invalidState.resolvedProductItemId, isNull);
      expect(invalidState.variantPrice, 0.0);
      expect(invalidState.errorMessage, 'Kombinasi varian ini tidak tersedia');
      expect(invalidState.canAddToCart, false);
    });

    testWidgets('VariantDialog widget: selecting valid variant after invalid combination clears error banner', (tester) async {
      final posItem = PosItem(
        id: 'prod-multi',
        name: 'Kopi Multi Atribut',
        price: 20000.0,
        stock: 10.0,
        unit: 'Cup',
        isActive: true,
        hasVariants: true,
        isProductMode: true,
        trackInventory: true,
      );

      final container = ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(db),
          posRepositoryProvider.overrideWithValue(posRepo),
        ],
        child: MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => VariantDialog.show(context, posItem),
                child: const Text('Open Dialog'),
              ),
            ),
          ),
        ),
      );

      await tester.pumpWidget(container);
      await tester.tap(find.text('Open Dialog'));
      await tester.pumpAndSettle();

      // Initially invalid combination (Small + Hot + Oat): error banner is shown
      expect(find.text('Kombinasi varian ini tidak tersedia'), findsOneWidget);

      // Tap 'Dairy' choice chip
      await tester.tap(find.text('Dairy'));
      await tester.pumpAndSettle();

      // Error banner should be gone!
      expect(find.text('Kombinasi varian ini tidak tersedia'), findsNothing);
    });
  });


  group('Adversarial Challenge C: Price Calculation Precision & Modifier Accounting', () {
    late AppDatabase db;
    late PosRepository posRepo;

    setUp(() async {
      db = AppDatabase.forTesting(NativeDatabase.memory());
      posRepo = PosRepository(db);

      await db.into(db.products).insert(
            ProductsCompanion.insert(
              id: 'prod-latte',
              name: 'Caramel Latte',
              price: const Value(35000.0),
              isAvailable: const Value(true),
              hasVariants: const Value(false),
              hasModifiers: const Value(true),
              trackInventory: const Value(false),
            ),
          );

      await db.into(db.productItems).insert(
            ProductItemsCompanion.insert(
              id: 'pi-latte-default',
              productId: 'prod-latte',
              name: 'Caramel Latte',
              trackInventory: const Value(false),
              isActive: const Value(true),
              sellable: const Value(true),
            ),
          );

      await db.into(db.productPrices).insert(
            ProductPricesCompanion.insert(
              id: 'pr-latte-default',
              productId: 'prod-latte',
              productItemId: const Value('pi-latte-default'),
              amount: const Value(35000.0),
            ),
          );

      // Modifier Group 1 (Radio: Milk choice)
      await db.into(db.modifierGroups).insert(
            ModifierGroupsCompanion.insert(
              id: 'mod-milk',
              name: 'Pilihan Susu',
              minSelected: const Value(1),
              maxSelected: const Value(1),
              type: const Value('radio'),
            ),
          );
      await db.into(db.modifierOptions).insert(
            ModifierOptionsCompanion.insert(
              id: 'opt-reg-milk',
              modifierGroupId: 'mod-milk',
              name: 'Fresh Milk',
              price: const Value(0.0),
            ),
          );
      await db.into(db.modifierOptions).insert(
            ModifierOptionsCompanion.insert(
              id: 'opt-oat-milk',
              modifierGroupId: 'mod-milk',
              name: 'Oat Milk',
              price: const Value(7500.0),
            ),
          );

      // Modifier Group 2 (Checkbox: Multiple toppings)
      await db.into(db.modifierGroups).insert(
            ModifierGroupsCompanion.insert(
              id: 'mod-toppings',
              name: 'Toppings',
              minSelected: const Value(0),
              maxSelected: const Value(3),
              type: const Value('checkbox'),
            ),
          );
      await db.into(db.modifierOptions).insert(
            ModifierOptionsCompanion.insert(
              id: 'opt-boba',
              modifierGroupId: 'mod-toppings',
              name: 'Boba',
              price: const Value(3000.0),
            ),
          );
      await db.into(db.modifierOptions).insert(
            ModifierOptionsCompanion.insert(
              id: 'opt-jelly',
              modifierGroupId: 'mod-toppings',
              name: 'Jelly',
              price: const Value(4000.0),
            ),
          );
      await db.into(db.modifierOptions).insert(
            ModifierOptionsCompanion.insert(
              id: 'opt-pudding',
              modifierGroupId: 'mod-toppings',
              name: 'Pudding',
              price: const Value(5000.0),
            ),
          );

      await db.into(db.productModifierGroups).insert(
            ProductModifierGroupsCompanion.insert(
              productId: 'prod-latte',
              modifierGroupId: 'mod-milk',
            ),
          );
      await db.into(db.productModifierGroups).insert(
            ProductModifierGroupsCompanion.insert(
              productId: 'prod-latte',
              modifierGroupId: 'mod-toppings',
            ),
          );
    });

    tearDown(() async {
      await db.close();
    });

    test('composite price calculation: base + radio replacement + multi-checkbox modifiers', () async {
      final posItem = PosItem(
        id: 'prod-latte',
        name: 'Caramel Latte',
        price: 35000.0,
        stock: 0.0,
        unit: 'Cup',
        isActive: true,
        isProductMode: true,
        trackInventory: false,
      );

      final container = ProviderContainer(
        overrides: [
          databaseProvider.overrideWithValue(db),
          posRepositoryProvider.overrideWithValue(posRepo),
        ],
      );
      final sub = container.listen(variantDialogProvider(posItem), (_, _) {});
      addTearDown(sub.close);
      addTearDown(container.dispose);

      final notifier = container.read(variantDialogProvider(posItem).notifier);
      await Future<void>.delayed(const Duration(milliseconds: 100));

      // Base price initially 35,000 with no modifiers
      expect(notifier.calculateTotalPrice(), 35000.0);

      // Select Radio: Fresh milk (+0)
      notifier.toggleModifier('mod-milk', 'opt-reg-milk', true);
      expect(notifier.calculateTotalPrice(), 35000.0);

      // Switch Radio to Oat milk (+7,500) -> Radio must replace previous selection
      notifier.toggleModifier('mod-milk', 'opt-oat-milk', true);
      expect(notifier.calculateTotalPrice(), 42500.0);

      // Add Topping 1: Boba (+3,000)
      notifier.toggleModifier('mod-toppings', 'opt-boba', true);
      expect(notifier.calculateTotalPrice(), 45500.0);

      // Add Topping 2: Jelly (+4,000)
      notifier.toggleModifier('mod-toppings', 'opt-jelly', true);
      expect(notifier.calculateTotalPrice(), 49500.0);

      // Add Topping 3: Pudding (+5,000)
      notifier.toggleModifier('mod-toppings', 'opt-pudding', true);
      expect(notifier.calculateTotalPrice(), 54500.0);

      // Uncheck Boba (-3,000)
      notifier.toggleModifier('mod-toppings', 'opt-boba', false);
      expect(notifier.calculateTotalPrice(), 51500.0);
    });

    test('CartItem price and discount precision on composite prices', () {
      final itemPercent = CartItem(
        id: 'ci-comp-1',
        productId: 'prod-latte',
        productItemId: 'pi-latte-default',
        name: 'Caramel Latte Deluxe',
        price: 54500.0, // Composite price (35,000 + 7,500 + 12,000)
        qty: 3,
        discountType: 'percentage',
        discountValue: 20.0, // 20%
      );

      // 20% of 54,500 = 10,900 discount per unit
      expect(itemPercent.calculatedDiscountAmount, 10900.0);
      // Unit price = 43,600 * 3 = 130,800
      expect(itemPercent.calculatedSubtotal, 130800.0);
      expect(itemPercent.totalPrice, 130800.0);

      // Fixed discount capped at unit price
      final itemFixedCapped = CartItem(
        id: 'ci-comp-2',
        productId: 'prod-latte',
        productItemId: 'pi-latte-default',
        name: 'Caramel Latte Free Promo',
        price: 54500.0,
        qty: 2,
        discountType: 'fixed',
        discountValue: 60000.0, // Exceeds unit price
      );
      // Discount capped at 54,500
      expect(itemFixedCapped.calculatedDiscountAmount, 54500.0);
      expect(itemFixedCapped.calculatedSubtotal, 0.0);
    });
  });

  group('Adversarial Challenge D: Cart Deduplication Rigorous Stress Testing', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('deduplicates identically when modifiers within groups are shuffled', () {
      final notifier = container.read(cartProvider.notifier);

      // Item 1: Boba, Jelly, Pudding
      notifier.addItem(
        CartItem(
          id: 'item-1',
          productId: 'prod-1',
          productItemId: 'pi-item-1',
          name: 'Milktea',
          price: 30000.0,
          qty: 2,
          selectedModifiers: {
            'mod-toppings': ['opt-boba', 'opt-jelly', 'opt-pudding'],
          },
        ),
      );

      // Item 2: Same item with modifiers in reverse order
      notifier.addItem(
        CartItem(
          id: 'item-2',
          productId: 'prod-1',
          productItemId: 'pi-item-1',
          name: 'Milktea',
          price: 30000.0,
          qty: 3,
          selectedModifiers: {
            'mod-toppings': ['opt-pudding', 'opt-boba', 'opt-jelly'],
          },
        ),
      );

      final cart = container.read(cartProvider);
      expect(cart.length, 1);
      expect(cart.first.qty, 5); // 2 + 3
    });

    test('deduplicates identically when multiple modifier groups are shuffled across keys', () {
      final notifier = container.read(cartProvider.notifier);

      // Item 1: Group A then Group B
      notifier.addItem(
        CartItem(
          id: 'item-1',
          productId: 'prod-1',
          productItemId: 'pi-item-multi',
          name: 'Espresso Blend',
          price: 25000.0,
          qty: 1,
          selectedModifiers: {
            'grp-milk': ['opt-oat'],
            'grp-syrup': ['opt-vanilla', 'opt-caramel'],
          },
        ),
      );

      // Item 2: Group B (shuffled options) then Group A
      notifier.addItem(
        CartItem(
          id: 'item-2',
          productId: 'prod-1',
          productItemId: 'pi-item-multi',
          name: 'Espresso Blend',
          price: 25000.0,
          qty: 4,
          selectedModifiers: {
            'grp-syrup': ['opt-caramel', 'opt-vanilla'],
            'grp-milk': ['opt-oat'],
          },
        ),
      );

      final cart = container.read(cartProvider);
      expect(cart.length, 1);
      expect(cart.first.qty, 5); // 1 + 4
    });

    test('creates separate lines when modifiers differ by subset, superset, or different options', () {
      final notifier = container.read(cartProvider.notifier);

      // Line 1: Boba + Jelly
      notifier.addItem(
        CartItem(
          id: 'item-1',
          productId: 'prod-1',
          productItemId: 'pi-item-1',
          name: 'Milktea',
          price: 30000.0,
          qty: 1,
          selectedModifiers: {
            'toppings': ['boba', 'jelly'],
          },
        ),
      );

      // Line 2: Boba only (subset)
      notifier.addItem(
        CartItem(
          id: 'item-2',
          productId: 'prod-1',
          productItemId: 'pi-item-1',
          name: 'Milktea',
          price: 27000.0,
          qty: 1,
          selectedModifiers: {
            'toppings': ['boba'],
          },
        ),
      );

      // Line 3: Boba + Grass Jelly (different option)
      notifier.addItem(
        CartItem(
          id: 'item-3',
          productId: 'prod-1',
          productItemId: 'pi-item-1',
          name: 'Milktea',
          price: 30000.0,
          qty: 1,
          selectedModifiers: {
            'toppings': ['boba', 'grass_jelly'],
          },
        ),
      );

      // Line 4: No modifiers
      notifier.addItem(
        CartItem(
          id: 'item-4',
          productId: 'prod-1',
          productItemId: 'pi-item-1',
          name: 'Milktea',
          price: 25000.0,
          qty: 1,
          selectedModifiers: const {},
        ),
      );

      final cart = container.read(cartProvider);
      expect(cart.length, 4);
      for (final line in cart) {
        expect(line.qty, 1);
      }
    });

    test('creates separate lines when same modifiers applied to different productItemIds', () {
      final notifier = container.read(cartProvider.notifier);

      // Line 1: Small with Boba
      notifier.addItem(
        CartItem(
          id: 'item-s',
          productId: 'prod-coffee',
          productItemId: 'pi-small',
          name: 'Kopi Small',
          price: 18000.0,
          qty: 2,
          selectedModifiers: {
            'toppings': ['boba'],
          },
        ),
      );

      // Line 2: Large with identical Boba modifier
      notifier.addItem(
        CartItem(
          id: 'item-l',
          productId: 'prod-coffee',
          productItemId: 'pi-large',
          name: 'Kopi Large',
          price: 24000.0,
          qty: 1,
          selectedModifiers: {
            'toppings': ['boba'],
          },
        ),
      );

      final cart = container.read(cartProvider);
      expect(cart.length, 2);
      expect(cart[0].productItemId, 'pi-small');
      expect(cart[0].qty, 2);
      expect(cart[1].productItemId, 'pi-large');
      expect(cart[1].qty, 1);
    });

    test('deduplication edge case: item with empty modifiers map vs item with empty modifier group list', () {
      final notifier = container.read(cartProvider.notifier);

      // Added via direct scan (empty map)
      notifier.addItem(
        CartItem(
          id: 'item-scan',
          productId: 'prod-1',
          productItemId: 'pi-1',
          name: 'Item 1',
          price: 20000.0,
          qty: 1,
          selectedModifiers: const {},
        ),
      );

      // Added via dialog without selecting optional modifiers
      notifier.addItem(
        CartItem(
          id: 'item-dialog',
          productId: 'prod-1',
          productItemId: 'pi-1',
          name: 'Item 1',
          price: 20000.0,
          qty: 1,
          selectedModifiers: const {'mod-optional': []},
        ),
      );

      final cart = container.read(cartProvider);
      // Normalized: {'mod-optional': []} equals {}
      // Deduplicates properly into a single cart line with incremented quantity
      expect(cart.length, 1);
      expect(cart.first.qty, 2);
    });
  });
}

