import 'dart:convert';
import 'dart:math';
import 'package:bcrypt/bcrypt.dart';
import 'package:dio/dio.dart';
import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:sollu_pos_client/core/database/app_database.dart';
import 'package:sollu_pos_client/core/database/database_provider.dart';
import 'package:sollu_pos_client/core/network/dio_client.dart';
import 'package:sollu_pos_client/core/providers/auto_sync_provider.dart';
import 'package:sollu_pos_client/core/providers/connectivity_provider.dart';
import 'package:sollu_pos_client/core/providers/preferences_provider.dart';
import 'package:sollu_pos_client/core/services/secure_storage_service.dart';
import 'package:sollu_pos_client/features/auth/presentation/providers/auth_provider.dart';
import 'package:sollu_pos_client/features/auth/presentation/providers/employee_provider.dart';
import 'package:sollu_pos_client/features/history/presentation/widgets/void_transaction_dialog.dart';
import 'package:sollu_pos_client/features/pos/data/transaction_repository.dart';
import 'package:sollu_pos_client/features/pos/presentation/pages/pos_layout.dart';
import 'package:sollu_pos_client/features/pos/presentation/providers/cart_provider.dart';
import 'package:sollu_pos_client/features/pos/presentation/providers/hold_cart_provider.dart';
import 'package:sollu_pos_client/features/pos/presentation/providers/pos_mode_provider.dart';
import 'package:sollu_pos_client/features/pos/presentation/providers/pos_provider.dart';
import 'package:sollu_pos_client/features/pos/presentation/providers/shortcut_provider.dart';
import 'package:sollu_pos_client/features/pos/presentation/providers/transaction_provider.dart';
import 'package:sollu_pos_client/features/pos/presentation/views/fast_retail/fast_retail_checkout_dialog.dart';
import 'package:sollu_pos_client/features/pos/presentation/widgets/checkout_payment_pane.dart';
import 'package:sollu_pos_client/features/pos/presentation/widgets/fast_retail_cart_table.dart';
import 'package:sollu_pos_client/features/pos/presentation/widgets/held_bills_drawer.dart';
import 'package:sollu_pos_client/features/pos/presentation/widgets/pos_extra_dialogs.dart';
import 'package:sollu_pos_client/features/pos/presentation/widgets/supervisor_challenge_dialog.dart';
import 'package:sollu_pos_client/features/settings/presentation/providers/bootstrap_provider.dart';
import 'package:sollu_pos_client/features/settings/presentation/providers/feature_gating_provider.dart';
import 'package:sollu_pos_client/features/settings/presentation/providers/outlet_settings_provider.dart';
import 'package:sollu_pos_client/features/shift/presentation/providers/shift_provider.dart';

class MockPosModeNotifier extends PosModeNotifier {
  final PosMode _mode;
  MockPosModeNotifier(this._mode);
  @override
  PosMode build() => _mode;
}

class MockAutoSyncNotifier extends AutoSyncNotifier {
  @override
  AutoSyncState build() => const AutoSyncState();
}

class MockConnectivityNotifier extends ConnectivityNotifier {
  @override
  bool build() => true;
}

class MockActiveEmployeeNotifier extends ActiveEmployeeNotifier {
  final Map<String, dynamic>? initialUser;
  MockActiveEmployeeNotifier([this.initialUser]);
  @override
  Map<String, dynamic>? build() => initialUser;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    dotenv.testLoad(mergeWith: {
      'API_BASE_URL': 'https://api.test',
      'APP_NAME': 'Sollu POS Test',
    });
    FlutterSecureStorage.setMockInitialValues({});
  });

  late SharedPreferences sharedPrefs;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    sharedPrefs = await SharedPreferences.getInstance();
  });

  final testPaymentMethods = [
    const PaymentMethod(id: 'pm-1', name: 'Tunai', type: 'cash', referencePolicy: 'hidden', openCashDrawer: true, isSystem: true, isActive: true),
    const PaymentMethod(id: 'pm-2', name: 'QRIS', type: 'qris', referencePolicy: 'optional', openCashDrawer: false, isSystem: false, isActive: true),
    const PaymentMethod(id: 'pm-3', name: 'BCA Debit', type: 'edc', referencePolicy: 'mandatory', openCashDrawer: false, isSystem: false, isActive: true),
  ];

  List<Override> createBaseOverrides({
    List<String> activeFeatures = const ['pos', 'crm', 'cash_drawer'],
    double taxPercentage = 11.0,
    double serviceChargePercentage = 0.0,
    bool taxIncludedInPrice = true,
    bool roundingEnabled = true,
    String roundingMode = 'nearest',
    bool allowNegativeStock = true,
  }) {
    return [
      sharedPreferencesProvider.overrideWithValue(sharedPrefs),
      connectivityProvider.overrideWith(MockConnectivityNotifier.new),
      activeShiftProvider.overrideWith((ref) => Stream.value(null)),
      heldTransactionsStreamProvider.overrideWith((ref) => Stream.value([])),
      posModeProvider.overrideWith(() => MockPosModeNotifier(PosMode.fastRetail)),
      featureGatingProvider.overrideWith((ref) => FeatureGatingService(activeFeatures: activeFeatures)),
      activeTaxRateProvider.overrideWith((ref) => taxPercentage),
      activeServiceChargeRateProvider.overrideWith((ref) => serviceChargePercentage),
      outletSettingsProvider.overrideWith((ref) => {
        'taxPercentage': taxPercentage,
        'serviceChargePercentage': serviceChargePercentage,
        'taxIncludedInPrice': taxIncludedInPrice,
        'roundingEnabled': roundingEnabled,
        'roundingMode': roundingMode,
        'allowNegativeStock': allowNegativeStock,
      }),
      posCategoriesProvider.overrideWith((ref) => Stream.value([])),
      posItemsProvider.overrideWith((ref) => Stream.value([])),
      activePaymentMethodsProvider.overrideWith((ref) => Stream.value(testPaymentMethods)),
      unsyncedTransactionsCountProvider.overrideWith((ref) => Stream.value(0)),
      failedTransactionsCountProvider.overrideWith((ref) => Stream.value(0)),
      autoSyncProvider.overrideWith(() => MockAutoSyncNotifier()),
      bootstrapProvider.overrideWith((ref) => Future.value(BootstrapResult(isOnline: true, hasActiveShift: false))),
      activePromosProvider.overrideWith((ref) => Stream.value([])),
      customersProvider.overrideWith((ref) => Stream.value([])),
    ];
  }

  // =========================================================================
  // FOCUS 1: Operational Keyboard Shortcuts Matrix Verification
  // =========================================================================
  // =========================================================================
  // FOCUS 1: Operational Keyboard Shortcuts Matrix Verification
  // =========================================================================
  group('Focus 1: Operational Keyboard Shortcuts Matrix Verification', () {
    testWidgets('Operational Keyboard Shortcuts Matrix Verification in Fast Retail', (tester) async {
      tester.view.physicalSize = const Size(1440, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final originalOnError = FlutterError.onError;
      FlutterError.onError = (details) {
        if (details.exceptionAsString().contains('overflowed')) return;
        originalOnError?.call(details);
      };
      addTearDown(() => FlutterError.onError = originalOnError);

      final sampleItem = CartItem(
        id: 'cart-item-1',
        productId: 'prod-1',
        name: 'Caramel Macchiato',
        price: 35000.0,
        qty: 1,
      );

      final container = ProviderContainer(overrides: createBaseOverrides());
      container.read(cartProvider.notifier).addItem(sampleItem);

      String? pushedRoute;
      final router = GoRouter(
        initialLocation: '/',
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => const PosLayout(),
          ),
          GoRoute(
            path: '/checkout',
            builder: (context, state) {
              pushedRoute = '/checkout (extra=${state.extra})';
              return Scaffold(body: Text(pushedRoute!));
            },
          ),
        ],
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp.router(routerConfig: router),
        ),
      );
      await tester.pumpAndSettle();

      // 1. Omni-bar search field is present
      final searchTextFieldFinder = find.byType(TextField).first;
      expect(searchTextFieldFinder, findsOneWidget);

      // 2. Diskon from Cockpit Action Deck (no F2)
      await tester.tap(find.text('[Diskon] Nota'));
      await tester.pumpAndSettle();
      expect(find.byType(DiscountDialog), findsOneWidget);
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();
      expect(find.byType(DiscountDialog), findsNothing);

      // 3. Edit Cart Item dialog from double-tap in Table Pane (no F3)
      await tester.tap(find.text('Caramel Macchiato').first);
      await tester.pump(const Duration(milliseconds: 50));
      await tester.tap(find.text('Caramel Macchiato').first);
      await tester.pumpAndSettle();
      expect(find.byType(EditCartItemDialog), findsOneWidget);
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();
      expect(find.byType(EditCartItemDialog), findsNothing);

      // 4. CRM Member from Cockpit CRM card (no F4)
      await tester.tap(find.text('Pelanggan'));
      await tester.pumpAndSettle();
      expect(find.byType(CustomerDialog), findsOneWidget);
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();
      expect(find.byType(CustomerDialog), findsNothing);

      // 5. Hold Bill from Cockpit Action Deck (no F9)
      await tester.tap(find.text('[Hold] Tahan'));
      await tester.pumpAndSettle();
      expect(find.text('Tahan Pesanan (Hold)'), findsOneWidget);
      await tester.tap(find.text('Batal'));
      await tester.pumpAndSettle();
      expect(find.text('Tahan Pesanan (Hold)'), findsNothing);

      // 6. HeldBillsDrawer from Cockpit Action Deck (no F10)
      await tester.tap(find.text('[Recall] Tagihan'));
      await tester.pumpAndSettle();
      expect(find.byType(HeldBillsDrawer), findsOneWidget);
      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();
      expect(find.byType(HeldBillsDrawer), findsNothing);

      // 7. Focus table and use '+' / '-' to adjust quantity
      await tester.tap(searchTextFieldFinder);
      await tester.pumpAndSettle();
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pumpAndSettle();

      expect(container.read(cartProvider).first.qty, equals(1));
      await tester.sendKeyEvent(LogicalKeyboardKey.numpadAdd);
      await tester.pumpAndSettle();
      expect(container.read(cartProvider).first.qty, equals(2));
      await tester.sendKeyEvent(LogicalKeyboardKey.numpadSubtract);
      await tester.pumpAndSettle();
      expect(container.read(cartProvider).first.qty, equals(1));

      // 8. '?' Shortcut: Guide dialog opens
      container.read(shortcutProvider.notifier).trigger('?');
      await tester.pumpAndSettle();
      expect(find.text('Panduan Operasional Keyboard Kasir Cepat'), findsOneWidget);
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();
      expect(find.text('Panduan Operasional Keyboard Kasir Cepat'), findsNothing);

      // 9. Esc when search has text clears search
      await tester.tap(searchTextFieldFinder);
      await tester.pumpAndSettle();
      await tester.enterText(searchTextFieldFinder, 'coffee');
      await tester.pumpAndSettle();
      expect(find.text('coffee'), findsOneWidget);
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();
      expect(find.text('coffee'), findsNothing);

      // 10. 2-Enter flow: Empty omni-bar Enter triggers checkout
      await tester.tap(searchTextFieldFinder);
      await tester.pumpAndSettle();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();
      expect(find.byType(FastRetailCheckoutDialog), findsOneWidget);
    });
  });

  // =========================================================================
  // FOCUS 2: Checkout Payment Pane & Numpad Isolation
  // =========================================================================
  group('Focus 2: Checkout Payment Pane & Numpad Isolation', () {
    testWidgets('Focusing cash TextField allows numeric typing without switching payment tabs', (tester) async {
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final testItem = CartItem(
        id: 'cart-pay-1',
        productId: 'prod-pay-1',
        name: 'Item Payment Test',
        price: 50000.0,
        qty: 1,
      );

      final container = ProviderContainer(overrides: createBaseOverrides());
      container.read(cartProvider.notifier).addItem(testItem);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: Scaffold(
              body: CheckoutPaymentPane(initialMethodType: 'cash'),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Initially in Cash mode
      expect(find.text('Uang Diterima'), findsOneWidget);

      // Tap Cash Received TextField to focus it
      final cashFieldFinder = find.byType(TextField).first;
      await tester.tap(cashFieldFinder);
      await tester.pumpAndSettle();

      // Send digits 2, 3 from top row
      await tester.sendKeyEvent(LogicalKeyboardKey.digit2);
      await tester.sendKeyEvent(LogicalKeyboardKey.digit3);
      await tester.pumpAndSettle();

      // Send numpad digits 1, 2, 3
      await tester.sendKeyEvent(LogicalKeyboardKey.numpad1);
      await tester.sendKeyEvent(LogicalKeyboardKey.numpad2);
      await tester.sendKeyEvent(LogicalKeyboardKey.numpad3);
      await tester.pumpAndSettle();

      // CRITICAL ASSERTION: We must STILL be in Cash mode! (Tabs must NOT switch to QRIS or EDC)
      expect(find.text('Uang Diterima'), findsOneWidget);
      expect(find.text('Arahkan pelanggan untuk memindai QRIS melalui aplikasi mobile banking atau e-wallet mereka.'), findsNothing);
      expect(find.text('Nomor Referensi / Trace No (Opsional)'), findsNothing);
    });

    testWidgets('Unfocused payment pane switches method tabs with 1, 2, 3 numeric keys', (tester) async {
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final testItem = CartItem(
        id: 'cart-pay-2',
        productId: 'prod-pay-2',
        name: 'Item Payment Test 2',
        price: 50000.0,
        qty: 1,
      );

      final container = ProviderContainer(overrides: createBaseOverrides());
      container.read(cartProvider.notifier).addItem(testItem);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: Scaffold(
              body: CheckoutPaymentPane(initialMethodType: 'cash'),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Initially in Cash mode
      expect(find.text('Uang Diterima'), findsOneWidget);

      // Press '2' without focusing any text field -> switches to QRIS
      await tester.sendKeyEvent(LogicalKeyboardKey.digit2);
      await tester.pumpAndSettle();
      expect(find.text('Arahkan pelanggan untuk memindai QRIS melalui aplikasi mobile banking atau e-wallet mereka.'), findsOneWidget);
      expect(find.text('Uang Diterima'), findsNothing);

      // Press '3' -> switches to BCA Debit (EDC)
      await tester.sendKeyEvent(LogicalKeyboardKey.digit3);
      await tester.pumpAndSettle();
      expect(find.text('Nomor Referensi / Trace No (Wajib Diisi)'), findsOneWidget);

      // Press '1' -> switches back to Tunai (Cash)
      await tester.sendKeyEvent(LogicalKeyboardKey.digit1);
      await tester.pumpAndSettle();
      expect(find.text('Uang Diterima'), findsOneWidget);
    });
  });

  // =========================================================================
  // FOCUS 3: FastRetailCartTable Gesture Safety
  // =========================================================================
  group('Focus 3: FastRetailCartTable Gesture Safety', () {
    testWidgets('Clicking delete on any row directly removes item without being swallowed by row double-tap', (tester) async {
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final items = [
        CartItem(id: 'row-0', productId: 'p0', name: 'Item 0 First', price: 10000.0, qty: 1),
        CartItem(id: 'row-1', productId: 'p1', name: 'Item 1 Middle', price: 20000.0, qty: 1),
        CartItem(id: 'row-2', productId: 'p2', name: 'Item 2 Penultimate', price: 30000.0, qty: 1),
        CartItem(id: 'row-3', productId: 'p3', name: 'Item 3 Last', price: 40000.0, qty: 1),
      ];

      final container = ProviderContainer(overrides: createBaseOverrides());
      for (final it in items) {
        container.read(cartProvider.notifier).addItem(it);
      }

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            home: Scaffold(
              body: SizedBox(
                width: 1280,
                height: 800,
                child: FastRetailCartTable(
                  searchFocusNode: FocusNode(),
                  onFocusSearch: () {},
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(container.read(cartProvider).length, equals(4));

      // 1. Delete middle row: row-1 (at index 1)
      final deleteButtons = find.byIcon(Icons.delete_outline);
      expect(deleteButtons, findsNWidgets(4));

      // Rapidly double tap delete button: should delete cleanly, NOT open EditCartItemDialog!
      await tester.tap(deleteButtons.at(1));
      await tester.pump(const Duration(milliseconds: 50));
      await tester.pumpAndSettle();

      expect(find.byType(EditCartItemDialog), findsNothing, reason: 'Delete button click must not open EditCartItemDialog!');

      final cartAfterFirstDel = container.read(cartProvider);
      expect(cartAfterFirstDel.length, equals(3));
      expect(cartAfterFirstDel.any((i) => i.id == 'row-1'), isFalse);
      expect(cartAfterFirstDel[0].id, equals('row-0'));
      expect(cartAfterFirstDel[1].id, equals('row-2'));
      expect(cartAfterFirstDel[2].id, equals('row-3'));

      // 2. Delete last row: row-3 (now at index 2)
      final remainingDelete = find.byIcon(Icons.delete_outline);
      expect(remainingDelete, findsNWidgets(3));
      await tester.tap(remainingDelete.at(2));
      await tester.pumpAndSettle();

      expect(find.byType(EditCartItemDialog), findsNothing);
      final cartAfterSecondDel = container.read(cartProvider);
      expect(cartAfterSecondDel.length, equals(2));
      expect(cartAfterSecondDel.any((i) => i.id == 'row-3'), isFalse);

      // 3. Delete first row: row-0 (at index 0)
      final finalDelete = find.byIcon(Icons.delete_outline);
      expect(finalDelete, findsNWidgets(2));
      await tester.tap(finalDelete.first);
      await tester.pumpAndSettle();

      expect(find.byType(EditCartItemDialog), findsNothing);
      final cartFinal = container.read(cartProvider);
      expect(cartFinal.length, equals(1));
      expect(cartFinal.first.id, equals('row-2'));

      // 4. Double tap on the row body (Columns 1-8) DOES open EditCartItemDialog
      await tester.tap(find.text('Item 2 Penultimate'));
      await tester.pump(const Duration(milliseconds: 50));
      await tester.tap(find.text('Item 2 Penultimate'));
      await tester.pumpAndSettle();

      expect(find.byType(EditCartItemDialog), findsOneWidget, reason: 'Double tapping row body should open EditCartItemDialog');
    });
  });

  // =========================================================================
  // FOCUS 4: Inclusive PPN 11% Math Invariants
  // =========================================================================
  group('Focus 4: Inclusive PPN 11% Math Invariants', () {
    test('Formula S - (S / 1.11) extracts tax without double taxation across discounts & service', () {
      final random = Random(12345);
      const double taxRate = 11.0;

      // Deterministic test cases with diverse combinations
      final testCases = [
        {'subtotal': 111000.0, 'discount': 0.0, 'serviceRate': 0.0},
        {'subtotal': 111000.0, 'discount': 11000.0, 'serviceRate': 0.0},
        {'subtotal': 100000.0, 'discount': 10000.0, 'serviceRate': 5.0},
        {'subtotal': 250000.0, 'discount': 50000.0, 'serviceRate': 10.0},
        {'subtotal': 50000.0, 'discount': 50000.0, 'serviceRate': 0.0}, // 100% discount
        {'subtotal': 15555.0, 'discount': 555.0, 'serviceRate': 5.0},
      ];

      for (final tc in testCases) {
        final subtotal = tc['subtotal']!;
        final discount = tc['discount']!;
        final serviceRate = tc['serviceRate']!;

        final taxableAmount = (subtotal - discount).clamp(0.0, double.infinity);
        final serviceCharge = taxableAmount * (serviceRate / 100.0);

        final taxAmount = calculateTaxAmount(
          taxableAmount: taxableAmount,
          taxRate: taxRate,
          taxIncludedInPrice: true,
        );

        final grandTotal = calculateGrandTotal(
          taxableAmount: taxableAmount,
          taxAmount: taxAmount,
          serviceChargeAmount: serviceCharge,
          taxIncludedInPrice: true,
        );

        // Invariant 1: Tax amount must equal taxableAmount - (taxableAmount / 1.11)
        final expectedTax = taxableAmount - (taxableAmount / 1.11);
        expect(taxAmount, closeTo(expectedTax, 0.0001));

        // Invariant 2: Inclusive Grand Total MUST NOT add tax on top:
        // Grand Total = taxableAmount + serviceCharge
        expect(grandTotal, equals(taxableAmount + serviceCharge));

        // Invariant 3: Base + Tax = Taxable Amount
        final base = taxableAmount / 1.11;
        expect(base + taxAmount, closeTo(taxableAmount, 0.0001));
      }

      // Zero tax rate test
      final zeroTax = calculateTaxAmount(
        taxableAmount: 100000.0,
        taxRate: 0.0,
        taxIncludedInPrice: true,
      );
      expect(zeroTax, equals(0.0));
      expect(
        calculateGrandTotal(
          taxableAmount: 100000.0,
          taxAmount: zeroTax,
          serviceChargeAmount: 5000.0,
          taxIncludedInPrice: true,
        ),
        equals(105000.0),
      );

      // 500 randomized stress tests
      for (int i = 0; i < 500; i++) {
        final subtotal = random.nextDouble() * 5000000.0;
        final discount = random.nextDouble() * (subtotal * 0.5);
        final serviceRate = random.nextBool() ? 0.0 : (random.nextDouble() * 10.0);

        final taxableAmount = (subtotal - discount).clamp(0.0, double.infinity);
        final serviceCharge = taxableAmount * (serviceRate / 100.0);

        final taxAmount = calculateTaxAmount(
          taxableAmount: taxableAmount,
          taxRate: 11.0,
          taxIncludedInPrice: true,
        );

        final grandTotal = calculateGrandTotal(
          taxableAmount: taxableAmount,
          taxAmount: taxAmount,
          serviceChargeAmount: serviceCharge,
          taxIncludedInPrice: true,
        );

        expect(grandTotal, equals(taxableAmount + serviceCharge));
        expect(taxAmount, closeTo(taxableAmount - (taxableAmount / 1.11), 0.0001));
      }
    });
  });

  // =========================================================================
  // FOCUS 5: Cash Rounding Modes vs Non-Cash Immunity
  // =========================================================================
  group('Focus 5: Cash Rounding Modes vs Non-Cash Immunity', () {
    test('Cash rounding behaves accurately for nearest, up, and down to 100', () {
      // Nearest mode:
      expect(applyCashRounding(amount: 25049.0, roundingEnabled: true, roundingMode: 'nearest'), equals(25000.0));
      expect(applyCashRounding(amount: 25050.0, roundingEnabled: true, roundingMode: 'nearest'), equals(25100.0));
      expect(applyCashRounding(amount: 25099.0, roundingEnabled: true, roundingMode: 'nearest'), equals(25100.0));
      expect(applyCashRounding(amount: 25000.0, roundingEnabled: true, roundingMode: 'nearest'), equals(25000.0));

      // Up mode (ceil):
      expect(applyCashRounding(amount: 25001.0, roundingEnabled: true, roundingMode: 'up'), equals(25100.0));
      expect(applyCashRounding(amount: 25049.0, roundingEnabled: true, roundingMode: 'up'), equals(25100.0));
      expect(applyCashRounding(amount: 25000.0, roundingEnabled: true, roundingMode: 'up'), equals(25000.0));

      // Down mode (floor):
      expect(applyCashRounding(amount: 25099.0, roundingEnabled: true, roundingMode: 'down'), equals(25000.0));
      expect(applyCashRounding(amount: 25050.0, roundingEnabled: true, roundingMode: 'down'), equals(25000.0));
      expect(applyCashRounding(amount: 25000.0, roundingEnabled: true, roundingMode: 'down'), equals(25000.0));

      // Disabled rounding returns raw amount:
      expect(applyCashRounding(amount: 25049.0, roundingEnabled: false, roundingMode: 'nearest'), equals(25049.0));
      expect(applyCashRounding(amount: 25001.0, roundingEnabled: false, roundingMode: 'up'), equals(25001.0));
    });

    testWidgets('Non-cash payment methods (QRIS, EDC) NEVER apply cash rounding in CheckoutPaymentPane', (tester) async {
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      // Item price = 10,049
      final unroundedItem = CartItem(
        id: 'c-round',
        productId: 'p-round',
        name: 'Unrounded Product',
        price: 10049.0,
        qty: 1,
      );

      final container = ProviderContainer(
        overrides: createBaseOverrides(
          taxPercentage: 0.0,
          serviceChargePercentage: 0.0,
          roundingEnabled: true,
          roundingMode: 'nearest',
        ),
      );
      container.read(cartProvider.notifier).addItem(unroundedItem);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: Scaffold(
              body: CheckoutPaymentPane(initialMethodType: 'cash'),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // With Cash: 10,049 rounds to 10.000
      expect(find.textContaining('10.000'), findsWidgets);

      // Switch to QRIS
      await tester.tap(find.text('QRIS'));
      await tester.pumpAndSettle();

      // In QRIS mode: Non-cash MUST display raw unrounded 10.049!
      expect(find.textContaining('10.049'), findsWidgets);

      // Switch to BCA Debit (EDC)
      await tester.tap(find.text('BCA Debit'));
      await tester.pumpAndSettle();

      // In EDC mode: Non-cash MUST display raw unrounded 10.049!
      expect(find.textContaining('10.049'), findsWidgets);

      // Switch back to Cash
      await tester.tap(find.text('Tunai'));
      await tester.pumpAndSettle();

      // Cash re-applies rounding to 10.000
      expect(find.textContaining('10.000'), findsWidgets);
    });
  });

  // =========================================================================
  // FOCUS 6: Void Transaction Security & Local Rollback on Sync Failure
  // =========================================================================
  group('Focus 6: Void Transaction Security & Local Rollback on Sync Failure', () {
    late AppDatabase db;
    late DioClient dioClient;
    late TransactionRepository txRepo;

    setUp(() {
      db = AppDatabase.forTesting(NativeDatabase.memory());
      dioClient = DioClient(SecureStorageService());
      txRepo = TransactionRepository(db, dioClient);
    });

    tearDown(() async {
      await db.close();
    });

    test('HTTP 422 (Invalid Supervisor PIN) atomically rolls back local Drift SQLite record to completed', () async {
      // 1. Seed completed transaction
      final sampleTx = Transaction(
        id: 'tx-rollback-422',
        outletId: 'outlet-1',
        channel: 'pos',
        type: 'sale',
        transactionNumber: 'TRX-422-TEST',
        shiftId: 'shift-1',
        subtotal: 100000.0,
        discountAmount: 0.0,
        taxAmount: 0.0,
        serviceChargeAmount: 0.0,
        shippingFee: 0.0,
        total: 100000.0,
        paymentStatus: 'paid',
        status: 'completed',
        notes: 'Catatan awal transaksi',
        isOffline: false,
        syncStatus: 'synced',
        syncAttempts: 0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await db.into(db.transactions).insert(sampleTx);

      // Verify initial state
      final beforeTx = await (db.select(db.transactions)..where((t) => t.id.equals(sampleTx.id))).getSingle();
      expect(beforeTx.status, equals('completed'));
      expect(beforeTx.notes, equals('Catatan awal transaksi'));

      // 2. Mock Dio Interceptor to reject with HTTP 422
      dioClient.dio.interceptors.clear();
      dioClient.dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            handler.reject(
              DioException(
                requestOptions: options,
                response: Response(
                  requestOptions: options,
                  statusCode: 422,
                  data: {
                    'status': 'error',
                    'message': 'PIN supervisor tidak valid pada server.',
                  },
                ),
                type: DioExceptionType.badResponse,
              ),
            );
          },
        ),
      );

      // 3. Attempt void
      final result = await txRepo.voidTransaction(
        transactionId: sampleTx.id,
        reason: 'Salah input menu',
        notes: 'Disetujui oleh Supervisor',
        supervisorId: 'spv-123',
        supervisorPin: '999999',
      );

      // Must fail
      expect(result.success, isFalse);
      expect(result.message, contains('PIN supervisor tidak valid'));

      // 4. ATOMIC ROLLBACK ASSERTION: Local record MUST be restored to 'completed' and original notes!
      final afterTx = await (db.select(db.transactions)..where((t) => t.id.equals(sampleTx.id))).getSingle();
      expect(afterTx.status, equals('completed'), reason: 'HTTP 422 MUST atomically restore local record status!');
      expect(afterTx.notes, equals('Catatan awal transaksi'), reason: 'HTTP 422 MUST restore original notes!');
    });

    test('HTTP 403 (Forbidden) atomically rolls back local Drift SQLite record to completed', () async {
      final sampleTx = Transaction(
        id: 'tx-rollback-403',
        outletId: 'outlet-1',
        channel: 'pos',
        type: 'sale',
        transactionNumber: 'TRX-403-TEST',
        shiftId: 'shift-1',
        subtotal: 50000.0,
        discountAmount: 0.0,
        taxAmount: 0.0,
        serviceChargeAmount: 0.0,
        shippingFee: 0.0,
        total: 50000.0,
        paymentStatus: 'paid',
        status: 'completed',
        notes: 'Original note',
        isOffline: false,
        syncStatus: 'synced',
        syncAttempts: 0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await db.into(db.transactions).insert(sampleTx);

      // Mock Dio Interceptor to reject with HTTP 403
      dioClient.dio.interceptors.clear();
      dioClient.dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            handler.reject(
              DioException(
                requestOptions: options,
                response: Response(
                  requestOptions: options,
                  statusCode: 403,
                  data: {
                    'status': 'error',
                    'message': 'Tidak memiliki izin untuk membatalkan transaksi.',
                  },
                ),
                type: DioExceptionType.badResponse,
              ),
            );
          },
        ),
      );

      final result = await txRepo.voidTransaction(
        transactionId: sampleTx.id,
        reason: 'Void unauthorized',
      );

      expect(result.success, isFalse);
      expect(result.message, contains('Tidak memiliki izin'));

      // ATOMIC ROLLBACK ASSERTION:
      final afterTx = await (db.select(db.transactions)..where((t) => t.id.equals(sampleTx.id))).getSingle();
      expect(afterTx.status, equals('completed'), reason: 'HTTP 403 MUST atomically restore local record status!');
      expect(afterTx.notes, equals('Original note'));
    });

    test('HTTP 200 (Success) updates local Drift SQLite record to void', () async {
      final sampleTx = Transaction(
        id: 'tx-success-200',
        outletId: 'outlet-1',
        channel: 'pos',
        type: 'sale',
        transactionNumber: 'TRX-200-TEST',
        shiftId: 'shift-1',
        subtotal: 75000.0,
        discountAmount: 0.0,
        taxAmount: 0.0,
        serviceChargeAmount: 0.0,
        shippingFee: 0.0,
        total: 75000.0,
        paymentStatus: 'paid',
        status: 'completed',
        isOffline: false,
        syncStatus: 'synced',
        syncAttempts: 0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await db.into(db.transactions).insert(sampleTx);

      // Mock Dio Interceptor to resolve with HTTP 200
      dioClient.dio.interceptors.clear();
      dioClient.dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            handler.resolve(
              Response(
                requestOptions: options,
                statusCode: 200,
                data: {
                  'status': 'success',
                  'message': 'Transaksi berhasil dibatalkan (void)',
                },
              ),
            );
          },
        ),
      );

      final result = await txRepo.voidTransaction(
        transactionId: sampleTx.id,
        reason: 'Salah pesanan',
        notes: 'Disetujui Spv',
        supervisorId: 'spv-1',
        supervisorPin: '123456',
      );

      expect(result.success, isTrue);

      final afterTx = await (db.select(db.transactions)..where((t) => t.id.equals(sampleTx.id))).getSingle();
      expect(afterTx.status, equals('void'));
      expect(afterTx.notes, contains('[VOID] Alasan: Salah pesanan | Catatan: Disetujui Spv'));
    });

    testWidgets('SupervisorChallengeDialog returns supervisor PIN and VoidTransactionDialog sends it to repository', (tester) async {
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      // Seed supervisor in database
      final hashedPin = BCrypt.hashpw('654321', BCrypt.gensalt());
      final spvEmployee = Employee(
        id: 'spv-sarah',
        name: 'Supervisor Sarah',
        pin: hashedPin,
        isRootUser: false,
        role: 'Supervisor',
        permissions: jsonEncode(['transaction.void']),
      );
      await db.into(db.employees).insert(
        EmployeesCompanion.insert(
          id: spvEmployee.id,
          name: spvEmployee.name,
          pin: Value(spvEmployee.pin),
          isRootUser: Value(spvEmployee.isRootUser),
          role: Value(spvEmployee.role),
          permissions: Value(spvEmployee.permissions),
        ),
      );

      final testTx = Transaction(
        id: 'tx-dialog-test',
        outletId: 'outlet-1',
        channel: 'pos',
        type: 'sale',
        transactionNumber: 'TRX-DIALOG-01',
        shiftId: 'shift-1',
        subtotal: 60000.0,
        discountAmount: 0.0,
        taxAmount: 0.0,
        serviceChargeAmount: 0.0,
        shippingFee: 0.0,
        total: 60000.0,
        paymentStatus: 'paid',
        status: 'completed',
        isOffline: false,
        syncStatus: 'synced',
        syncAttempts: 0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await db.into(db.transactions).insert(testTx);

      // Track payload sent to Dio
      RequestOptions? interceptedOptions;
      dioClient.dio.interceptors.clear();
      dioClient.dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            interceptedOptions = options;
            handler.resolve(
              Response(
                requestOptions: options,
                statusCode: 200,
                data: {'status': 'success'},
              ),
            );
          },
        ),
      );

      // Cashier without void permission
      final cashierUser = {
        'id': 'cashier-1',
        'name': 'Kasir Andi',
        'is_root_user': false,
        'role': 'Kasir',
        'permissions': ['pos.sale'],
      };

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            databaseProvider.overrideWithValue(db),
            transactionRepositoryProvider.overrideWithValue(txRepo),
            activeEmployeeProvider.overrideWith(() => MockActiveEmployeeNotifier(cashierUser)),
            employeeListProvider.overrideWith((ref) => Future.value([spvEmployee])),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) => ElevatedButton(
                  onPressed: () => VoidTransactionDialog.show(context, transaction: testTx),
                  child: const Text('Open Void Dialog'),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Open Void Dialog'));
      await tester.pumpAndSettle();

      // Tap 'Konfirmasi Void' -> prompts SupervisorChallengeDialog
      await tester.tap(find.text('Konfirmasi Void'));
      await tester.pumpAndSettle();

      expect(find.byType(SupervisorChallengeDialog), findsOneWidget);

      // Enter supervisor PIN '654321'
      for (final digit in ['6', '5', '4', '3', '2', '1']) {
        await tester.tap(find.widgetWithText(InkWell, digit).first);
        await tester.pump(const Duration(milliseconds: 50));
      }
      await tester.pumpAndSettle();

      // Verify payload sent over network to backend
      expect(interceptedOptions, isNotNull);
      final sentData = interceptedOptions!.data as Map<String, dynamic>;
      expect(sentData['supervisor_id'], equals('spv-sarah'));
      expect(sentData['supervisor_pin'], equals('654321'));
      expect(sentData['reason'], equals('Salah input item'));
    });
  });
}
