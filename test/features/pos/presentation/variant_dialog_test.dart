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

void main() {
  group('VariantDialogState Logic Tests', () {
    test('canAddToCart returns false when required modifier is missing', () {
      final state = VariantDialogState(
        isLoading: false,
        variantGroups: [],
        modifierGroups: [
          ModifierGroup(
            id: 'mod-req',
            name: 'Pilihan Gula',
            minSelected: 1,
            maxSelected: 1,
            type: 'radio',
          ),
        ],
        selectedModifiers: {
          'mod-req': [], // Empty!
        },
        resolvedProductItemId: 'pi-1',
        isCombinationAvailable: true,
      );

      expect(state.hasRequiredModifiersSelected, false);
      expect(state.canAddToCart, false);
    });

    test('canAddToCart returns false when combination is unavailable', () {
      final state = VariantDialogState(
        isLoading: false,
        variantGroups: [
          VariantGroup(id: 'grp-size', productId: 'p-1', name: 'Size'),
        ],
        modifierGroups: [],
        resolvedProductItemId: null,
        isCombinationAvailable: false,
        errorMessage: 'Kombinasi varian ini tidak tersedia',
      );

      expect(state.canAddToCart, false);
    });

    test('canAddToCart returns true when combination is available and required modifiers are met', () {
      final state = VariantDialogState(
        isLoading: false,
        variantGroups: [
          VariantGroup(id: 'grp-size', productId: 'p-1', name: 'Size'),
        ],
        modifierGroups: [
          ModifierGroup(
            id: 'mod-req',
            name: 'Pilihan Gula',
            minSelected: 1,
            maxSelected: 1,
            type: 'radio',
          ),
        ],
        selectedModifiers: {
          'mod-req': ['opt-normal'],
        },
        resolvedProductItemId: 'pi-valid',
        isCombinationAvailable: true,
      );

      expect(state.hasRequiredModifiersSelected, true);
      expect(state.canAddToCart, true);
    });
  });

  group('VariantDialogNotifier In-Memory DB Integration Tests', () {
    late AppDatabase db;
    late PosRepository posRepo;
    late PosItem posItemVariant;
    late PosItem posItemSingleUntracked;

    setUp(() async {
      db = AppDatabase.forTesting(NativeDatabase.memory());
      posRepo = PosRepository(db);

      // Setup Product with Variants
      await db.into(db.products).insert(
            ProductsCompanion.insert(
              id: 'prod-coffee',
              name: 'Kopi Susu Senja',
              price: const Value(18000.0),
              isAvailable: const Value(true),
              productType: const Value('food'),
              unit: const Value('Cup'),
              hasVariants: const Value(true),
              hasModifiers: const Value(true),
              trackInventory: const Value(true),
            ),
          );

      // Variant Groups & Options (Size: Regular, Large; Temp: Hot, Ice)
      await db.into(db.variantGroups).insert(
            VariantGroupsCompanion.insert(
              id: 'grp-size',
              productId: 'prod-coffee',
              name: 'Ukuran',
            ),
          );
      await db.into(db.variantGroupOptions).insert(
            VariantGroupOptionsCompanion.insert(
              id: 'opt-reg',
              variantGroupId: 'grp-size',
              name: 'Regular',
            ),
          );
      await db.into(db.variantGroupOptions).insert(
            VariantGroupOptionsCompanion.insert(
              id: 'opt-lrg',
              variantGroupId: 'grp-size',
              name: 'Large',
            ),
          );

      await db.into(db.variantGroups).insert(
            VariantGroupsCompanion.insert(
              id: 'grp-temp',
              productId: 'prod-coffee',
              name: 'Suhu',
            ),
          );
      await db.into(db.variantGroupOptions).insert(
            VariantGroupOptionsCompanion.insert(
              id: 'opt-hot',
              variantGroupId: 'grp-temp',
              name: 'Hot',
            ),
          );
      await db.into(db.variantGroupOptions).insert(
            VariantGroupOptionsCompanion.insert(
              id: 'opt-ice',
              variantGroupId: 'grp-temp',
              name: 'Ice',
            ),
          );

      // Product Items (Combinations)
      // 1. Regular + Hot (18,000, stock: 10)
      await db.into(db.productItems).insert(
            ProductItemsCompanion.insert(
              id: 'pi-reg-hot',
              productId: 'prod-coffee',
              name: 'Kopi Susu Senja - Regular Hot',
              variantCombination: const Value('Regular - Hot'),
              sku: const Value('KSS-REG-HOT'),
              barcode: const Value('8990001'),
              trackInventory: const Value(true),
              isActive: const Value(true),
              sellable: const Value(true),
            ),
          );
      await db.into(db.productPrices).insert(
            ProductPricesCompanion.insert(
              id: 'pr-1',
              productId: 'prod-coffee',
              productItemId: const Value('pi-reg-hot'),
              amount: const Value(18000.0),
            ),
          );
      await db.into(db.inventories).insert(
            InventoriesCompanion.insert(
              id: 'inv-1',
              productId: 'prod-coffee',
              productItemId: const Value('pi-reg-hot'),
              name: 'Kopi Susu Senja - Regular Hot',
              stock: const Value(10.0),
              trackInventory: const Value(true),
            ),
          );
      await db.into(db.productItemVariantGroupOptions).insert(
            ProductItemVariantGroupOptionsCompanion.insert(
              productItemId: 'pi-reg-hot',
              variantGroupOptionId: 'opt-reg',
            ),
          );
      await db.into(db.productItemVariantGroupOptions).insert(
            ProductItemVariantGroupOptionsCompanion.insert(
              productItemId: 'pi-reg-hot',
              variantGroupOptionId: 'opt-hot',
            ),
          );

      // 2. Regular + Ice (20,000, stock: 15)
      await db.into(db.productItems).insert(
            ProductItemsCompanion.insert(
              id: 'pi-reg-ice',
              productId: 'prod-coffee',
              name: 'Kopi Susu Senja - Regular Ice',
              variantCombination: const Value('Regular - Ice'),
              sku: const Value('KSS-REG-ICE'),
              barcode: const Value('8990002'),
              trackInventory: const Value(true),
              isActive: const Value(true),
              sellable: const Value(true),
            ),
          );
      await db.into(db.productPrices).insert(
            ProductPricesCompanion.insert(
              id: 'pr-2',
              productId: 'prod-coffee',
              productItemId: const Value('pi-reg-ice'),
              amount: const Value(20000.0),
            ),
          );
      await db.into(db.inventories).insert(
            InventoriesCompanion.insert(
              id: 'inv-2',
              productId: 'prod-coffee',
              productItemId: const Value('pi-reg-ice'),
              name: 'Kopi Susu Senja - Regular Ice',
              stock: const Value(15.0),
              trackInventory: const Value(true),
            ),
          );
      await db.into(db.productItemVariantGroupOptions).insert(
            ProductItemVariantGroupOptionsCompanion.insert(
              productItemId: 'pi-reg-ice',
              variantGroupOptionId: 'opt-reg',
            ),
          );
      await db.into(db.productItemVariantGroupOptions).insert(
            ProductItemVariantGroupOptionsCompanion.insert(
              productItemId: 'pi-reg-ice',
              variantGroupOptionId: 'opt-ice',
            ),
          );

      // 3. Large + Ice (25,000, trackInventory: false)
      await db.into(db.productItems).insert(
            ProductItemsCompanion.insert(
              id: 'pi-lrg-ice',
              productId: 'prod-coffee',
              name: 'Kopi Susu Senja - Large Ice',
              variantCombination: const Value('Large - Ice'),
              sku: const Value('KSS-LRG-ICE'),
              barcode: const Value('8990003'),
              trackInventory: const Value(false),
              isActive: const Value(true),
              sellable: const Value(true),
            ),
          );
      await db.into(db.productPrices).insert(
            ProductPricesCompanion.insert(
              id: 'pr-3',
              productId: 'prod-coffee',
              productItemId: const Value('pi-lrg-ice'),
              amount: const Value(25000.0),
            ),
          );
      await db.into(db.productItemVariantGroupOptions).insert(
            ProductItemVariantGroupOptionsCompanion.insert(
              productItemId: 'pi-lrg-ice',
              variantGroupOptionId: 'opt-lrg',
            ),
          );
      await db.into(db.productItemVariantGroupOptions).insert(
            ProductItemVariantGroupOptionsCompanion.insert(
              productItemId: 'pi-lrg-ice',
              variantGroupOptionId: 'opt-ice',
            ),
          );

      // Modifiers
      await db.into(db.modifierGroups).insert(
            ModifierGroupsCompanion.insert(
              id: 'mod-sugar',
              name: 'Level Gula',
              minSelected: const Value(1),
              maxSelected: const Value(1),
              type: const Value('radio'),
            ),
          );
      await db.into(db.modifierOptions).insert(
            ModifierOptionsCompanion.insert(
              id: 'opt-normal-sugar',
              modifierGroupId: 'mod-sugar',
              name: 'Normal Sugar',
              price: const Value(0.0),
            ),
          );
      await db.into(db.modifierOptions).insert(
            ModifierOptionsCompanion.insert(
              id: 'opt-less-sugar',
              modifierGroupId: 'mod-sugar',
              name: 'Less Sugar',
              price: const Value(0.0),
            ),
          );

      await db.into(db.modifierGroups).insert(
            ModifierGroupsCompanion.insert(
              id: 'mod-topping',
              name: 'Topping',
              minSelected: const Value(0),
              maxSelected: const Value(2),
              type: const Value('checkbox'),
            ),
          );
      await db.into(db.modifierOptions).insert(
            ModifierOptionsCompanion.insert(
              id: 'opt-boba',
              modifierGroupId: 'mod-topping',
              name: 'Boba',
              price: const Value(3000.0),
            ),
          );
      await db.into(db.modifierOptions).insert(
            ModifierOptionsCompanion.insert(
              id: 'opt-jelly',
              modifierGroupId: 'mod-topping',
              name: 'Grass Jelly',
              price: const Value(4000.0),
            ),
          );

      // Attach modifiers to product
      await db.into(db.productModifierGroups).insert(
            ProductModifierGroupsCompanion.insert(
              productId: 'prod-coffee',
              modifierGroupId: 'mod-sugar',
            ),
          );
      await db.into(db.productModifierGroups).insert(
            ProductModifierGroupsCompanion.insert(
              productId: 'prod-coffee',
              modifierGroupId: 'mod-topping',
            ),
          );

      // Setup Single Untracked Product (Service / Digital)
      await db.into(db.products).insert(
            ProductsCompanion.insert(
              id: 'prod-service',
              name: 'Konsultasi Kopi',
              price: const Value(50000.0),
              isAvailable: const Value(true),
              productType: const Value('service'),
              unit: const Value('Sesi'),
              hasVariants: const Value(false),
              hasModifiers: const Value(false),
              trackInventory: const Value(false),
            ),
          );
      await db.into(db.productItems).insert(
            ProductItemsCompanion.insert(
              id: 'pi-service-default',
              productId: 'prod-service',
              name: 'Konsultasi Kopi',
              trackInventory: const Value(false),
              isActive: const Value(true),
              sellable: const Value(true),
            ),
          );

      posItemVariant = PosItem(
        id: 'prod-coffee',
        name: 'Kopi Susu Senja',
        price: 18000.0,
        stock: 25.0,
        unit: 'Cup',
        isActive: true,
        hasVariants: true,
        hasModifiers: true,
        isProductMode: true,
        trackInventory: true,
      );

      posItemSingleUntracked = PosItem(
        id: 'prod-service',
        name: 'Konsultasi Kopi',
        price: 50000.0,
        stock: 0.0,
        unit: 'Sesi',
        isActive: true,
        hasVariants: false,
        hasModifiers: false,
        isProductMode: true,
        trackInventory: false,
      );
    });

    tearDown(() async {
      await db.close();
    });

    ProviderContainer createContainer() {
      return ProviderContainer(
        overrides: [
          databaseProvider.overrideWithValue(db),
          posRepositoryProvider.overrideWithValue(posRepo),
        ],
      );
    }

    test('initial load resolves first variant combination and loads modifiers', () async {
      final container = createContainer();
      final sub = container.listen(variantDialogProvider(posItemVariant), (_, _) {});
      addTearDown(sub.close);
      addTearDown(container.dispose);
      container.read(variantDialogProvider(posItemVariant).notifier);

      // Wait for async _init
      await Future<void>.delayed(const Duration(milliseconds: 100));

      final state = container.read(variantDialogProvider(posItemVariant));
      expect(state.isLoading, false);
      expect(state.variantGroups.length, 2);
      expect(state.modifierGroups.length, 2);

      // Initial selected: Regular and Hot
      expect(state.selectedVariants['grp-size'], 'opt-reg');
      expect(state.selectedVariants['grp-temp'], 'opt-hot');

      // Resolved product item: pi-reg-hot, 18,000
      expect(state.resolvedProductItemId, 'pi-reg-hot');
      expect(state.variantPrice, 18000.0);
      expect(state.variantCombination, 'Regular - Hot');
      expect(state.trackInventory, true);
      expect(state.isCombinationAvailable, true);
      expect(state.errorMessage, isNull);
    });

    test('selecting Regular and Ice resolves pi-reg-ice at 20,000', () async {
      final container = createContainer();
      final sub = container.listen(variantDialogProvider(posItemVariant), (_, _) {});
      addTearDown(sub.close);
      addTearDown(container.dispose);
      final notifier = container.read(variantDialogProvider(posItemVariant).notifier);
      await Future<void>.delayed(const Duration(milliseconds: 100));

      await notifier.selectVariant('grp-temp', 'opt-ice');

      final state = container.read(variantDialogProvider(posItemVariant));
      expect(state.resolvedProductItemId, 'pi-reg-ice');
      expect(state.variantPrice, 20000.0);
      expect(state.variantCombination, 'Regular - Ice');
      expect(state.trackInventory, true);
      expect(state.isCombinationAvailable, true);
      expect(state.errorMessage, isNull);
    });

    test('selecting Large and Hot (unregistered combination) marks combination unavailable', () async {
      final container = createContainer();
      final sub = container.listen(variantDialogProvider(posItemVariant), (_, _) {});
      addTearDown(sub.close);
      addTearDown(container.dispose);
      final notifier = container.read(variantDialogProvider(posItemVariant).notifier);
      await Future<void>.delayed(const Duration(milliseconds: 100));

      // Select Large (with Hot)
      await notifier.selectVariant('grp-size', 'opt-lrg');

      final state = container.read(variantDialogProvider(posItemVariant));
      expect(state.resolvedProductItemId, isNull);
      expect(state.isCombinationAvailable, false);
      expect(state.errorMessage, 'Kombinasi varian ini tidak tersedia');
      expect(state.canAddToCart, false);
    });

    test('selecting Large and Ice resolves untracked item pi-lrg-ice at 25,000', () async {
      final container = createContainer();
      final sub = container.listen(variantDialogProvider(posItemVariant), (_, _) {});
      addTearDown(sub.close);
      addTearDown(container.dispose);
      final notifier = container.read(variantDialogProvider(posItemVariant).notifier);
      await Future<void>.delayed(const Duration(milliseconds: 100));

      await notifier.selectVariant('grp-size', 'opt-lrg');
      await notifier.selectVariant('grp-temp', 'opt-ice');

      final state = container.read(variantDialogProvider(posItemVariant));
      expect(state.resolvedProductItemId, 'pi-lrg-ice');
      expect(state.variantPrice, 25000.0);
      expect(state.variantCombination, 'Large - Ice');
      expect(state.trackInventory, false);
      expect(state.isCombinationAvailable, true);
      expect(state.errorMessage, isNull);
    });

    test('switching from invalid combination to valid combination clears errorMessage', () async {
      final container = createContainer();
      final sub = container.listen(variantDialogProvider(posItemVariant), (_, _) {});
      addTearDown(sub.close);
      addTearDown(container.dispose);
      final notifier = container.read(variantDialogProvider(posItemVariant).notifier);
      await Future<void>.delayed(const Duration(milliseconds: 100));

      // 1. Initial valid: Regular + Hot
      expect(container.read(variantDialogProvider(posItemVariant)).errorMessage, isNull);

      // 2. Switch to invalid: Large + Hot
      await notifier.selectVariant('grp-size', 'opt-lrg');
      final invalidState = container.read(variantDialogProvider(posItemVariant));
      expect(invalidState.isCombinationAvailable, false);
      expect(invalidState.errorMessage, 'Kombinasi varian ini tidak tersedia');

      // 3. Switch back to valid: Regular + Hot
      await notifier.selectVariant('grp-size', 'opt-reg');
      final recoveredState = container.read(variantDialogProvider(posItemVariant));
      expect(recoveredState.isCombinationAvailable, true);
      expect(recoveredState.resolvedProductItemId, 'pi-reg-hot');
      expect(recoveredState.errorMessage, isNull);

      // Also verify canAddToCart becomes true once required modifier is met
      notifier.toggleModifier('mod-sugar', 'opt-normal-sugar', true);
      expect(container.read(variantDialogProvider(posItemVariant)).canAddToCart, true);
    });

    test('toggleModifier adds prices and enforces radio vs checkbox limits', () async {
      final container = createContainer();
      final sub = container.listen(variantDialogProvider(posItemVariant), (_, _) {});
      addTearDown(sub.close);
      addTearDown(container.dispose);
      final notifier = container.read(variantDialogProvider(posItemVariant).notifier);
      await Future<void>.delayed(const Duration(milliseconds: 100));

      // Radio modifier: select normal sugar then switch to less sugar
      notifier.toggleModifier('mod-sugar', 'opt-normal-sugar', true);
      expect(container.read(variantDialogProvider(posItemVariant)).selectedModifiers['mod-sugar'], ['opt-normal-sugar']);

      notifier.toggleModifier('mod-sugar', 'opt-less-sugar', true);
      // Radio replaces selection
      expect(container.read(variantDialogProvider(posItemVariant)).selectedModifiers['mod-sugar'], ['opt-less-sugar']);

      // Checkbox modifier: add Boba (+3000) and Jelly (+4000)
      notifier.toggleModifier('mod-topping', 'opt-boba', true);
      notifier.toggleModifier('mod-topping', 'opt-jelly', true);

      final state = container.read(variantDialogProvider(posItemVariant));
      expect(state.selectedModifiers['mod-topping'], ['opt-boba', 'opt-jelly']);

      // Base price = 18,000 + Boba (3,000) + Jelly (4,000) = 25,000
      expect(notifier.calculateTotalPrice(), 25000.0);
    });

    test('single product without variants safely resolves default product item without crashing', () async {
      final container = createContainer();
      final sub = container.listen(variantDialogProvider(posItemSingleUntracked), (_, _) {});
      addTearDown(sub.close);
      addTearDown(container.dispose);
      container.read(variantDialogProvider(posItemSingleUntracked).notifier);
      await Future<void>.delayed(const Duration(milliseconds: 100));

      final state = container.read(variantDialogProvider(posItemSingleUntracked));
      expect(state.isLoading, false);
      expect(state.variantGroups, isEmpty);
      expect(state.resolvedProductItemId, 'pi-service-default');
      expect(state.trackInventory, false);
      expect(state.variantPrice, 50000.0);
      expect(state.canAddToCart, true);
    });
  });

  group('VariantDialog Widget Tests', () {
    testWidgets('renders stock infinity symbol for untracked product item and enables Add when valid', (tester) async {
      final db = AppDatabase.forTesting(NativeDatabase.memory());
      final posRepo = PosRepository(db);

      // Create product
      await db.into(db.products).insert(
            ProductsCompanion.insert(
              id: 'prod-w1',
              name: 'Donat Cokelat',
              price: const Value(12000.0),
              isAvailable: const Value(true),
              trackInventory: const Value(false),
            ),
          );
      await db.into(db.productItems).insert(
            ProductItemsCompanion.insert(
              id: 'pi-w1-default',
              productId: 'prod-w1',
              name: 'Donat Cokelat',
              trackInventory: const Value(false),
              isActive: const Value(true),
              sellable: const Value(true),
            ),
          );

      final posItem = PosItem(
        id: 'prod-w1',
        name: 'Donat Cokelat',
        price: 12000.0,
        stock: 0.0,
        unit: 'Pcs',
        isActive: true,
        isProductMode: true,
        trackInventory: false,
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            databaseProvider.overrideWithValue(db),
            posRepositoryProvider.overrideWithValue(posRepo),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) => ElevatedButton(
                  onPressed: () => VariantDialog.show(context, posItem),
                  child: const Text('Open'),
                ),
              ),
            ),
          ),
        ),
      );

      // Tap to open dialog
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      // Verify infinity stock badge is displayed
      expect(find.text('Stok: ∞'), findsOneWidget);
      expect(find.text('Pesan: Donat Cokelat'), findsOneWidget);

      // Verify Tambah button is enabled and clickable
      final tambahBtn = tester.widget<ElevatedButton>(find.widgetWithText(ElevatedButton, 'Tambah'));
      expect(tambahBtn.onPressed, isNotNull);

      await db.close();
    });

    testWidgets('displays error message and disables Tambah button when combination is invalid', (tester) async {
      final db = AppDatabase.forTesting(NativeDatabase.memory());
      final posRepo = PosRepository(db);

      // Product with variant group but NO product items matching
      await db.into(db.products).insert(
            ProductsCompanion.insert(
              id: 'prod-empty-matrix',
              name: 'Kue Kosong',
              price: const Value(10000.0),
              isAvailable: const Value(true),
              hasVariants: const Value(true),
              trackInventory: const Value(true),
            ),
          );
      await db.into(db.variantGroups).insert(
            VariantGroupsCompanion.insert(
              id: 'grp-empty',
              productId: 'prod-empty-matrix',
              name: 'Rasa',
            ),
          );
      await db.into(db.variantGroupOptions).insert(
            VariantGroupOptionsCompanion.insert(
              id: 'opt-empty-1',
              variantGroupId: 'grp-empty',
              name: 'Matcha',
            ),
          );

      final posItem = PosItem(
        id: 'prod-empty-matrix',
        name: 'Kue Kosong',
        price: 10000.0,
        stock: 5.0,
        unit: 'Pcs',
        isActive: true,
        hasVariants: true,
        isProductMode: true,
        trackInventory: true,
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            databaseProvider.overrideWithValue(db),
            posRepositoryProvider.overrideWithValue(posRepo),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) => ElevatedButton(
                  onPressed: () => VariantDialog.show(context, posItem),
                  child: const Text('Open'),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      // Verify error message is rendered
      expect(find.text('Kombinasi varian ini tidak tersedia'), findsOneWidget);

      // Verify Tambah button is disabled
      final tambahBtn = tester.widget<ElevatedButton>(find.widgetWithText(ElevatedButton, 'Tambah'));
      expect(tambahBtn.onPressed, isNull);

      await db.close();
    });
  });
}
