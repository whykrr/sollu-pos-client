import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sollu_pos_client/core/database/app_database.dart';
import 'package:sollu_pos_client/core/providers/connectivity_provider.dart';
import 'package:sollu_pos_client/core/providers/preferences_provider.dart';
import 'package:sollu_pos_client/features/auth/presentation/providers/employee_provider.dart';
import 'package:sollu_pos_client/features/pos/data/pos_repository.dart';
import 'package:sollu_pos_client/features/pos/data/transaction_repository.dart';
import 'package:sollu_pos_client/features/pos/presentation/providers/cart_provider.dart';
import 'package:sollu_pos_client/features/pos/presentation/providers/hold_cart_provider.dart';
import 'package:sollu_pos_client/features/pos/presentation/providers/pos_mode_provider.dart';
import 'package:sollu_pos_client/features/pos/presentation/providers/promo_provider.dart';
import 'package:sollu_pos_client/features/pos/presentation/providers/transaction_provider.dart';
import 'package:sollu_pos_client/features/pos/presentation/views/fast_retail/fast_retail_checkout_dialog.dart';
import 'package:sollu_pos_client/features/pos/presentation/views/fast_retail/fast_retail_header.dart';
import 'package:sollu_pos_client/features/pos/presentation/views/fast_retail/fast_retail_search_dropdown.dart';
import 'package:sollu_pos_client/features/pos/presentation/views/visual_touch/visual_touch_checkout_drawer.dart';
import 'package:sollu_pos_client/features/pos/presentation/views/visual_touch/visual_touch_header.dart';
import 'package:sollu_pos_client/features/pos/presentation/widgets/cart_panel.dart';
import 'package:sollu_pos_client/features/pos/presentation/widgets/pos_extra_dialogs.dart';
import 'package:sollu_pos_client/features/settings/presentation/providers/outlet_settings_provider.dart';
import 'package:sollu_pos_client/features/shift/presentation/providers/shift_provider.dart';

class FakePosModeNotifier extends PosModeNotifier {
  final PosMode _initial;
  FakePosModeNotifier(this._initial);
  @override
  PosMode build() => _initial;
}

class FakeConnectivityNotifier extends ConnectivityNotifier {
  @override
  bool build() => true;
}

class FakeTransactionRepository implements TransactionRepository {
  Transaction? lastCreatedTransaction;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);

  @override
  Future<({Transaction transaction, TransactionDetailData detail})> createTransaction({
    String? shiftId,
    String? cashierId,
    String? customerId,
    required List<CartItem> items,
    required double subtotal,
    required double discountAmount,
    String? discountType,
    double? discountValue,
    String? promoName,
    String? promoId,
    required double taxAmount,
    double serviceChargeAmount = 0.0,
    required double total,
    PaymentMethod? paymentMethod,
    double? cashReceived,
    double? changeAmount,
    List<({
      String? paymentMethodId,
      double amount,
      double changeAmount,
      String? paymentReference,
    })>? multiPayments,
    String? notes,
    String outletId = 'default-outlet',
    String type = 'walk_in',
  }) async {
    final now = DateTime.now();
    final tx = Transaction(
      id: 'tx-test-id-1',
      outletId: outletId,
      shiftId: shiftId,
      customerId: customerId,
      channel: 'pos',
      type: type,
      transactionNumber: 'TRX/2026.10.31/POS.POS/0001',
      subtotal: subtotal,
      discountAmount: discountAmount,
      discountType: discountType,
      discountValue: discountValue,
      promoName: promoName,
      taxAmount: taxAmount,
      serviceChargeAmount: serviceChargeAmount,
      shippingFee: 0.0,
      total: total,
      paymentStatus: 'paid',
      status: 'completed',
      notes: notes,
      isOffline: false,
      offlineId: null,
      syncStatus: 'synced',
      syncAttempts: 0,
      lastSyncError: null,
      lastSyncAttemptAt: null,
      dueDate: null,
      createdAt: now,
      updatedAt: now,
    );
    lastCreatedTransaction = tx;
    final detail = TransactionDetailData(
      transaction: tx,
      items: [],
      modifiersByItemId: {},
      payments: [],
      paymentMethod: paymentMethod,
    );
    return (transaction: tx, detail: detail);
  }
}

List<PosItem> createMockPosItems(int count) {
  return List.generate(
    count,
    (i) => PosItem(
      id: 'item-$i',
      name: 'Produk Uji $i',
      sku: 'SKU-$i',
      barcode: '899000$i',
      price: (10000 + i * 1000).toDouble(),
      stock: 50.0,
      unit: 'pcs',
      isActive: true,
      isProductMode: true,
      trackInventory: true,
    ),
  );
}

final testPaymentMethods = <PaymentMethod>[
  const PaymentMethod(
    id: 'pm-1',
    name: 'Tunai',
    type: 'cash',
    referencePolicy: 'hidden',
    openCashDrawer: true,
    isSystem: true,
    isActive: true,
  ),
  const PaymentMethod(
    id: 'pm-2',
    name: 'QRIS',
    type: 'qris',
    referencePolicy: 'optional',
    openCashDrawer: false,
    isSystem: false,
    isActive: true,
  ),
];

final testPromoList = <Promo>[
  const Promo(
    id: 'promo-101',
    name: 'Promo Gajian 20%',
    promoType: 'percentage',
    discountValue: 20.0,
    targetType: 'bill',
    appliesToAllOutlets: true,
    status: 'active',
  ),
  const Promo(
    id: 'promo-102',
    name: 'Potongan Hemat Rp 10.000',
    promoType: 'fixed',
    discountValue: 10000.0,
    targetType: 'bill',
    appliesToAllOutlets: true,
    status: 'active',
  ),
];

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late SharedPreferences sharedPrefs;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    sharedPrefs = await SharedPreferences.getInstance();
  });

  group('Iteration Refactor 1 & 3: Clean Header (No Switcher, No Hold button in Fast Retail)', () {
    testWidgets('FastRetailHeader has NO mode switcher and NO Hold button in actions', (tester) async {
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final searchCtrl = TextEditingController();
      final focusNode = FocusNode();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(sharedPrefs),
            connectivityProvider.overrideWith(FakeConnectivityNotifier.new),
            activeShiftProvider.overrideWith((ref) => Stream.value(null)),
            employeeListProvider.overrideWith((ref) => Future.value(<Employee>[])),
            posModeProvider.overrideWith(() => FakePosModeNotifier(PosMode.fastRetail)),
          ],
          child: MaterialApp(
            home: Scaffold(
              appBar: FastRetailHeader(
                searchController: searchCtrl,
                searchFocusNode: focusNode,
                onFocusTable: () {},
                onBarcodeOrSearchSubmit: (q, m) {},
                onItemPickedFromDropdown: (item) {},
                onEmptyEnterCheckout: () {},
                onClearCartRequested: () {},
                onBackToDashboard: () {},
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify mode switcher labels are NOT present in header
      expect(find.text('⚡ Kasir Cepat'), findsNothing);
      expect(find.text('☕ Visual Touch'), findsNothing);

      // Verify Hold button is NOT present in Fast Retail Header actions
      expect(find.textContaining('Hold ('), findsNothing);

      // Omni-bar is present
      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('VisualTouchHeader has NO mode switcher', (tester) async {
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final searchCtrl = TextEditingController();
      final focusNode = FocusNode();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(sharedPrefs),
            connectivityProvider.overrideWith(FakeConnectivityNotifier.new),
            activeShiftProvider.overrideWith((ref) => Stream.value(null)),
            employeeListProvider.overrideWith((ref) => Future.value(<Employee>[])),
            posModeProvider.overrideWith(() => FakePosModeNotifier(PosMode.visualTouch)),
            heldTransactionsStreamProvider.overrideWith((ref) => Stream.value([])),
          ],
          child: MaterialApp(
            home: Scaffold(
              appBar: VisualTouchHeader(
                searchController: searchCtrl,
                searchFocusNode: focusNode,
                onBackToDashboard: () {},
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify mode switcher labels are NOT present in visual touch header
      expect(find.text('⚡ Kasir Cepat'), findsNothing);
      expect(find.text('☕ Visual Touch'), findsNothing);
    });
  });

  group('Iteration Refactor 2: Auto-Scroll on FastRetailSearchDropdown', () {
    testWidgets('Scrolling down to index 7 smoothly adjusts scroll offset', (tester) async {
      final items = createMockPosItems(10);
      int selectedIdx = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return Center(
                  child: FastRetailSearchDropdown(
                    items: items,
                    selectedIndex: selectedIdx,
                    onItemSelected: (_) {},
                  ),
                );
              },
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Initial state: index 0
      final scrollableFinder = find.byType(Scrollable).first;
      ScrollableState scrollState = tester.state(scrollableFinder);
      expect(scrollState.position.pixels, equals(0.0));

      // Re-pump widget with selectedIndex: 7 (far down the list)
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: FastRetailSearchDropdown(
                items: items,
                selectedIndex: 7,
                onItemSelected: (_) {},
              ),
            ),
          ),
        ),
      );

      // Animate scroll
      await tester.pump(const Duration(milliseconds: 50));
      await tester.pumpAndSettle();

      scrollState = tester.state(scrollableFinder);
      // Offset must have scrolled down (> 0.0)
      expect(scrollState.position.pixels, greaterThan(0.0));
      // Item 7 is rendered
      expect(find.text('Produk Uji 7'), findsOneWidget);
    });

    testWidgets('Dropdown auto-scrolls when items update from search', (tester) async {
      final initialItems = createMockPosItems(10);
      final newItems = createMockPosItems(5);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: FastRetailSearchDropdown(
                items: initialItems,
                selectedIndex: 8,
                onItemSelected: (_) {},
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      final scrollableFinder = find.byType(Scrollable).first;
      ScrollableState scrollState = tester.state(scrollableFinder);
      expect(scrollState.position.pixels, greaterThan(0.0));

      // Items update with new search result reset to index 0
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: FastRetailSearchDropdown(
                items: newItems,
                selectedIndex: 0,
                onItemSelected: (_) {},
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      scrollState = tester.state(scrollableFinder);
      expect(scrollState.position.pixels, equals(0.0));
    });
  });

  group('Iteration Refactor 4: DiscountDialog Full Keyboard Navigation', () {
    testWidgets('Navigates promo list with ArrowDown, applies with Enter', (tester) async {
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(sharedPrefs),
          activePromosProvider.overrideWith((ref) => Stream.value(testPromoList)),
        ],
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: Scaffold(
              body: DiscountDialog(),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify dialog is open and shows promo list
      expect(find.text('Promo & Diskon'), findsOneWidget);
      expect(find.text('Promo Gajian 20%'), findsOneWidget);
      expect(find.text('Potongan Hemat Rp 10.000'), findsOneWidget);

      // Press ArrowDown to select second promo
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pumpAndSettle();

      // Press Enter to apply second promo
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();

      // Applied promo should be the second promo
      final applied = container.read(appliedDiscountProvider);
      expect(applied, isNotNull);
      expect(applied!.name, equals('Potongan Hemat Rp 10.000'));
    });

    testWidgets('Switches to Manual Discount with Tab, enters value, and applies with Enter', (tester) async {
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(sharedPrefs),
          activePromosProvider.overrideWith((ref) => Stream.value(testPromoList)),
        ],
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: Scaffold(
              body: DiscountDialog(),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Press Tab key to switch to Tab 2 (Diskon Manual)
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pumpAndSettle();

      expect(find.text('Terapkan Diskon Manual'), findsOneWidget);

      // Type 15 into autofocus value TextField
      final textFields = find.byType(TextField);
      await tester.enterText(textFields.first, '15');
      await tester.pumpAndSettle();

      // Press Enter to apply manual discount
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();

      final applied = container.read(appliedDiscountProvider);
      expect(applied, isNotNull);
      expect(applied!.type, equals('percentage'));
      expect(applied.value, equals(15.0));
    });

    testWidgets('Closes DiscountDialog with Escape key', (tester) async {
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(sharedPrefs),
          activePromosProvider.overrideWith((ref) => Stream.value(testPromoList)),
        ],
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: Scaffold(
              body: DiscountDialog(),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.text('Promo & Diskon'), findsOneWidget);

      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();

      expect(find.text('Promo & Diskon'), findsNothing);
    });

    testWidgets('Toggles % vs Rp with Alt+1 and Alt+2, and with ArrowRight and ArrowLeft', (tester) async {
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(sharedPrefs),
          activePromosProvider.overrideWith((ref) => Stream.value(testPromoList)),
        ],
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: Scaffold(
              body: DiscountDialog(),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Switch to Manual tab with Tab
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pumpAndSettle();

      // Default is percentage
      expect(find.text('Persentase Diskon (%)'), findsOneWidget);

      // ArrowRight when empty toggles to Rp (fixed)
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pumpAndSettle();
      expect(find.text('Jumlah Potongan (Rp)'), findsOneWidget);

      // ArrowLeft toggles back to percentage
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
      await tester.pumpAndSettle();
      expect(find.text('Persentase Diskon (%)'), findsOneWidget);

      // Alt+2 toggles to fixed (Rp)
      await tester.sendKeyDownEvent(LogicalKeyboardKey.altLeft);
      await tester.sendKeyEvent(LogicalKeyboardKey.digit2);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.altLeft);
      await tester.pumpAndSettle();
      expect(find.text('Jumlah Potongan (Rp)'), findsOneWidget);

      // Alt+1 toggles back to percentage
      await tester.sendKeyDownEvent(LogicalKeyboardKey.altLeft);
      await tester.sendKeyEvent(LogicalKeyboardKey.digit1);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.altLeft);
      await tester.pumpAndSettle();
      expect(find.text('Persentase Diskon (%)'), findsOneWidget);
    });

    testWidgets('Switches back from Diskon Manual to Promo Master with Ctrl+Tab', (tester) async {
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(sharedPrefs),
          activePromosProvider.overrideWith((ref) => Stream.value(testPromoList)),
        ],
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: Scaffold(
              body: DiscountDialog(),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Go to tab 1
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pumpAndSettle();
      expect(find.text('Terapkan Diskon Manual'), findsOneWidget);

      // Press Ctrl+Tab to switch back to tab 0
      await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
      await tester.pumpAndSettle();

      expect(find.text('Promo Gajian 20%'), findsOneWidget);
    });

    testWidgets('Rejects manual discount percentage > 100 with SnackBar', (tester) async {
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(sharedPrefs),
          activePromosProvider.overrideWith((ref) => Stream.value(testPromoList)),
        ],
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: Scaffold(
              body: DiscountDialog(),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pumpAndSettle();

      final textFields = find.byType(TextField);
      await tester.enterText(textFields.first, '120');
      await tester.pumpAndSettle();

      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();

      // SnackBar shown and discount NOT applied
      expect(find.text('Persentase diskon tidak boleh melebihi 100%'), findsOneWidget);
      expect(container.read(appliedDiscountProvider), isNull);
    });
  });

  group('Iteration Refactor 5 & 7: FastRetailCheckoutDialog & Walk-In Lock', () {
    testWidgets('FastRetailCheckoutDialog locks order type to walk_in and processes payment', (tester) async {
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final fakeRepo = FakeTransactionRepository();

      final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(sharedPrefs),
          posModeProvider.overrideWith(() => FakePosModeNotifier(PosMode.fastRetail)),
          transactionRepositoryProvider.overrideWithValue(fakeRepo),
          activePaymentMethodsProvider.overrideWith((ref) => Stream.value(testPaymentMethods)),
          posOrderTypesProvider.overrideWithValue(['walk_in', 'dine_in', 'take_away']),
          activeShiftProvider.overrideWith((ref) => Stream.value(null)),
          outletProfileProvider.overrideWithValue({'name': 'Outlet Utama'}),
          allowNegativeStockProvider.overrideWithValue(true),
        ],
      );

      // Add item to cart
      final testItem = CartItem(
        id: 'cart-1',
        productId: 'p-1',
        name: 'Kopi Susu',
        price: 20000.0,
        qty: 1,
      );
      container.read(cartProvider.notifier).addItem(testItem);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: Scaffold(
              body: FastRetailCheckoutDialog(initialMethodType: 'cash'),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify modal dialog title
      expect(find.text('Checkout Pembayaran (Kasir Cepat)'), findsOneWidget);

      // Verify order type selector is HIDDEN in Fast Retail mode
      expect(find.text('Dine-In'), findsNothing);
      expect(find.text('Take-Away'), findsNothing);

      // Cash is auto-filled to exact cash (Rp 20.000)
      expect(find.text('Uang Pas'), findsOneWidget);

      // Press Enter to submit payment
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();

      // Transaction is recorded with type: 'walk_in'
      expect(fakeRepo.lastCreatedTransaction, isNotNull);
      expect(fakeRepo.lastCreatedTransaction!.type, equals('walk_in'));
      expect(fakeRepo.lastCreatedTransaction!.total, equals(20000.0));
    });

    testWidgets('Dismisses FastRetailCheckoutDialog with Escape key', (tester) async {
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(sharedPrefs),
          posModeProvider.overrideWith(() => FakePosModeNotifier(PosMode.fastRetail)),
          activePaymentMethodsProvider.overrideWith((ref) => Stream.value(testPaymentMethods)),
          posOrderTypesProvider.overrideWithValue(['walk_in']),
          activeShiftProvider.overrideWith((ref) => Stream.value(null)),
          outletProfileProvider.overrideWithValue({'name': 'Outlet Utama'}),
        ],
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: Scaffold(
              body: FastRetailCheckoutDialog(),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.text('Checkout Pembayaran (Kasir Cepat)'), findsOneWidget);

      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();

      expect(find.text('Checkout Pembayaran (Kasir Cepat)'), findsNothing);
    });
  });

  group('Iteration Refactor 6: VisualTouchCheckoutDrawer & Order Types Visibility', () {
    testWidgets('VisualTouchCheckoutDrawer displays split layout and order type selector', (tester) async {
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final fakeRepo = FakeTransactionRepository();

      final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(sharedPrefs),
          posModeProvider.overrideWith(() => FakePosModeNotifier(PosMode.visualTouch)),
          transactionRepositoryProvider.overrideWithValue(fakeRepo),
          activePaymentMethodsProvider.overrideWith((ref) => Stream.value(testPaymentMethods)),
          posOrderTypesProvider.overrideWithValue(['walk_in', 'dine_in', 'take_away']),
          activeShiftProvider.overrideWith((ref) => Stream.value(null)),
          outletProfileProvider.overrideWithValue({'name': 'Outlet Utama'}),
          allowNegativeStockProvider.overrideWithValue(true),
        ],
      );

      // Add item to cart
      final testItem = CartItem(
        id: 'cart-vt-1',
        productId: 'p-2',
        name: 'Croissant',
        price: 25000.0,
        qty: 1,
      );
      container.read(cartProvider.notifier).addItem(testItem);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: Scaffold(
              body: VisualTouchCheckoutDrawer(),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify checkout title
      expect(find.text('Checkout Pembayaran'), findsOneWidget);

      // In Visual Touch mode with multiple order types, Dine-In and Take-Away are displayed!
      expect(find.text('Dine-In'), findsOneWidget);
      expect(find.text('Take-Away'), findsOneWidget);
      expect(find.text('Walk-In'), findsOneWidget);

      // Tap Dine-In
      await tester.tap(find.text('Dine-In'));
      await tester.pumpAndSettle();

      // Submit payment
      final submitBtn = find.textContaining('Selesaikan Pembayaran');
      await tester.tap(submitBtn);
      await tester.pumpAndSettle();

      // Transaction is recorded with type: 'dine_in'
      expect(fakeRepo.lastCreatedTransaction, isNotNull);
      expect(fakeRepo.lastCreatedTransaction!.type, equals('dine_in'));
      expect(fakeRepo.lastCreatedTransaction!.total, equals(25000.0));
    });

    testWidgets('Dismisses VisualTouchCheckoutDrawer with Escape key', (tester) async {
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(sharedPrefs),
          posModeProvider.overrideWith(() => FakePosModeNotifier(PosMode.visualTouch)),
          activePaymentMethodsProvider.overrideWith((ref) => Stream.value(testPaymentMethods)),
          posOrderTypesProvider.overrideWithValue(['walk_in', 'dine_in']),
          activeShiftProvider.overrideWith((ref) => Stream.value(null)),
          outletProfileProvider.overrideWithValue({'name': 'Outlet Utama'}),
        ],
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: Scaffold(
              body: VisualTouchCheckoutDrawer(),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.text('Checkout Pembayaran'), findsOneWidget);

      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();

      expect(find.text('Checkout Pembayaran'), findsNothing);
    });

    testWidgets('CartPanel in Fast Retail mode opens FastRetailCheckoutDialog', (tester) async {
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(sharedPrefs),
          posModeProvider.overrideWith(() => FakePosModeNotifier(PosMode.fastRetail)),
          activePaymentMethodsProvider.overrideWith((ref) => Stream.value(testPaymentMethods)),
          posOrderTypesProvider.overrideWithValue(['walk_in']),
          activeShiftProvider.overrideWith((ref) => Stream.value(null)),
          outletProfileProvider.overrideWithValue({'name': 'Outlet Utama'}),
          allowNegativeStockProvider.overrideWithValue(true),
          heldTransactionsStreamProvider.overrideWith((ref) => Stream.value([])),
        ],
      );

      final testItem = CartItem(
        id: 'cart-cp-1',
        productId: 'p-cp-1',
        name: 'Item Kasir Cepat',
        price: 15000.0,
        qty: 1,
      );
      container.read(cartProvider.notifier).addItem(testItem);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: Scaffold(
              body: CartPanel(),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Tap BAYAR button
      final bayarButton = find.text('BAYAR');
      expect(bayarButton, findsOneWidget);
      await tester.tap(bayarButton);
      await tester.pumpAndSettle();

      // Opens FastRetailCheckoutDialog
      expect(find.byType(FastRetailCheckoutDialog), findsOneWidget);
    });
  });
}
