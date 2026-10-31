import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sollu_pos_client/core/database/app_database.dart';
import 'package:sollu_pos_client/core/providers/auto_sync_provider.dart';
import 'package:sollu_pos_client/core/providers/connectivity_provider.dart';
import 'package:sollu_pos_client/core/providers/preferences_provider.dart';
import 'package:sollu_pos_client/features/pos/data/pos_repository.dart';
import 'package:sollu_pos_client/features/pos/presentation/pages/pos_layout.dart';
import 'package:sollu_pos_client/features/pos/presentation/providers/cart_provider.dart';
import 'package:sollu_pos_client/features/pos/presentation/providers/hold_cart_provider.dart';
import 'package:sollu_pos_client/features/pos/presentation/providers/pos_mode_provider.dart';
import 'package:sollu_pos_client/features/pos/presentation/providers/pos_provider.dart';
import 'package:sollu_pos_client/features/pos/presentation/providers/shortcut_provider.dart';
import 'package:sollu_pos_client/features/pos/presentation/providers/transaction_provider.dart';
import 'package:sollu_pos_client/features/pos/presentation/views/fast_retail/fast_retail_checkout_dialog.dart';
import 'package:sollu_pos_client/features/pos/presentation/views/fast_retail/fast_retail_cockpit.dart';
import 'package:sollu_pos_client/features/pos/presentation/views/fast_retail/fast_retail_header.dart';
import 'package:sollu_pos_client/features/pos/presentation/views/fast_retail/fast_retail_keyboard_guide_dialog.dart';
import 'package:sollu_pos_client/features/pos/presentation/views/fast_retail/fast_retail_table_pane.dart';
import 'package:sollu_pos_client/features/pos/presentation/views/fast_retail/fast_retail_view.dart';
import 'package:sollu_pos_client/features/pos/presentation/views/visual_touch/visual_touch_cart_pane.dart';
import 'package:sollu_pos_client/features/pos/presentation/views/visual_touch/visual_touch_catalog_pane.dart';
import 'package:sollu_pos_client/features/pos/presentation/views/visual_touch/visual_touch_header.dart';
import 'package:sollu_pos_client/features/pos/presentation/views/visual_touch/visual_touch_view.dart';
import 'package:sollu_pos_client/features/pos/presentation/widgets/checkout_payment_pane.dart';
import 'package:sollu_pos_client/features/settings/presentation/providers/bootstrap_provider.dart';
import 'package:sollu_pos_client/features/settings/presentation/providers/feature_gating_provider.dart';
import 'package:sollu_pos_client/features/settings/presentation/providers/outlet_settings_provider.dart';
import 'package:sollu_pos_client/features/shift/presentation/providers/shift_provider.dart';

class FakePosModeNotifier extends PosModeNotifier {
  final PosMode _mode;
  FakePosModeNotifier(this._mode);

  @override
  PosMode build() => _mode;
}

class FakeAutoSyncNotifier extends AutoSyncNotifier {
  @override
  AutoSyncState build() => const AutoSyncState();
}

class FakeConnectivityNotifier extends ConnectivityNotifier {
  @override
  bool build() => true;
}

class MockPosRepository implements PosRepository {
  final List<PosItem> testItems;
  MockPosRepository({this.testItems = const []});

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);

  @override
  Future<List<PosItem>> searchItems(String query, {int limit = 10}) async {
    final lower = query.toLowerCase();
    return testItems
        .where((item) =>
            item.name.toLowerCase().contains(lower) ||
            (item.barcode != null && item.barcode!.toLowerCase().contains(lower)) ||
            (item.sku != null && item.sku!.toLowerCase().contains(lower)))
        .take(limit)
        .toList();
  }

  @override
  Future<PosItem?> findItemByBarcodeOrSku(String code) async {
    final lower = code.toLowerCase();
    for (final item in testItems) {
      if ((item.barcode != null && item.barcode!.toLowerCase() == lower) ||
          (item.sku != null && item.sku!.toLowerCase() == lower)) {
        return item;
      }
    }
    return null;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late SharedPreferences sharedPrefs;
  late MockPosRepository mockRepo;

  setUpAll(() async {
    dotenv.testLoad(mergeWith: {
      'API_BASE_URL': 'https://api.test',
      'APP_NAME': 'Sollu POS',
    });
  });

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    sharedPrefs = await SharedPreferences.getInstance();

    mockRepo = MockPosRepository(testItems: [
      PosItem(
        id: 'prod-indomie',
        name: 'Indomie Goreng Spesial',
        price: 3500.0,
        stock: 100,
        unit: 'pcs',
        productType: 'product',
        isActive: true,
        hasVariants: false,
        isProductMode: true,
        barcode: '89912345',
        sku: 'SKU-INDOMIE',
      ),
      PosItem(
        id: 'prod-aqua',
        name: 'Aqua Botol 600ml',
        price: 4000.0,
        stock: 50,
        unit: 'botol',
        productType: 'product',
        isActive: true,
        hasVariants: false,
        isProductMode: true,
        barcode: '89999999',
        sku: 'SKU-AQUA',
      ),
    ]);
  });

  final testPaymentMethods = [
    const PaymentMethod(id: 'pm-cash', name: 'Tunai', type: 'cash', referencePolicy: 'hidden', openCashDrawer: true, isSystem: true, isActive: true),
    const PaymentMethod(id: 'pm-qris', name: 'QRIS', type: 'qris', referencePolicy: 'optional', openCashDrawer: false, isSystem: false, isActive: true),
  ];

  List<Override> createTestOverrides({PosMode mode = PosMode.fastRetail}) {
    return [
      sharedPreferencesProvider.overrideWithValue(sharedPrefs),
      posRepositoryProvider.overrideWithValue(mockRepo),
      autoSyncProvider.overrideWith(FakeAutoSyncNotifier.new),
      connectivityProvider.overrideWith(FakeConnectivityNotifier.new),
      bootstrapProvider.overrideWith((ref) => Future.value(BootstrapResult(isOnline: true, hasActiveShift: false))),
      posModeProvider.overrideWith(() => FakePosModeNotifier(mode)),
      activeShiftProvider.overrideWith((ref) => Stream.value(null)),
      heldTransactionsStreamProvider.overrideWith((ref) => Stream.value([])),
      featureGatingProvider.overrideWith((ref) => const FeatureGatingService(activeFeatures: ['pos', 'crm', 'cash_drawer'])),
      activeTaxRateProvider.overrideWith((ref) => 0.0),
      activeServiceChargeRateProvider.overrideWith((ref) => 0.0),
      outletSettingsProvider.overrideWith((ref) => {
            'taxPercentage': 0.0,
            'serviceChargePercentage': 0.0,
            'taxIncludedInPrice': false,
            'roundingEnabled': false,
          }),
      posCategoriesProvider.overrideWith((ref) => Stream.value([])),
      posItemsProvider.overrideWith((ref) => Stream.value([])),
      activePaymentMethodsProvider.overrideWith((ref) => Stream.value(testPaymentMethods)),
      unsyncedTransactionsCountProvider.overrideWith((ref) => Stream.value(0)),
      failedTransactionsCountProvider.overrideWith((ref) => Stream.value(0)),
      activePromosProvider.overrideWith((ref) => Stream.value([])),
      customersProvider.overrideWith((ref) => Stream.value([])),
    ];
  }

  group('Requirement 1 & 10: Strict UI Separation Between Fast Retail & Visual Touch', () {
    testWidgets('Fast Retail mode mounts FastRetailView with Header, Table Pane, and Cockpit', (tester) async {
      tester.view.physicalSize = const Size(1366, 768);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final container = ProviderContainer(overrides: createTestOverrides(mode: PosMode.fastRetail));

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(home: PosLayout()),
        ),
      );
      await tester.pumpAndSettle();

      // Fast Retail specific components MUST be present
      expect(find.byType(FastRetailView), findsOneWidget);
      expect(find.byType(FastRetailHeader), findsOneWidget);
      expect(find.byType(FastRetailTablePane), findsOneWidget);
      expect(find.byType(FastRetailCockpit), findsOneWidget);

      // Visual Touch components MUST NOT exist in Fast Retail
      expect(find.byType(VisualTouchView), findsNothing);
      expect(find.byType(VisualTouchHeader), findsNothing);
      expect(find.byType(VisualTouchCatalogPane), findsNothing);
      expect(find.byType(VisualTouchCartPane), findsNothing);
    });

    testWidgets('Visual Touch mode mounts VisualTouchView with NO keyboard guide button or cheat sheet icon', (tester) async {
      tester.view.physicalSize = const Size(1366, 768);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final container = ProviderContainer(overrides: createTestOverrides(mode: PosMode.visualTouch));

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(home: PosLayout()),
        ),
      );
      await tester.pumpAndSettle();

      // Visual Touch components MUST be present
      expect(find.byType(VisualTouchView), findsOneWidget);
      expect(find.byType(VisualTouchHeader), findsOneWidget);
      expect(find.byType(VisualTouchCatalogPane), findsOneWidget);
      expect(find.byType(VisualTouchCartPane), findsOneWidget);

      // Fast Retail components MUST NOT exist in Visual Touch
      expect(find.byType(FastRetailView), findsNothing);
      expect(find.byType(FastRetailTablePane), findsNothing);
      expect(find.byType(FastRetailCockpit), findsNothing);

      // Invariant 10: Keyboard guide is completely absent from Visual Touch header & screen
      expect(find.text('[?] Panduan'), findsNothing);
      expect(find.text('Panduan Keyboard'), findsNothing);
      expect(find.byIcon(Icons.keyboard_alt_outlined), findsNothing);
      expect(find.byIcon(Icons.help_outline), findsNothing);
    });
  });

  group('Requirement 2: Keyboard Guide Dialog Exclusivity in Fast Retail', () {
    testWidgets('Fast Retail opens FastRetailKeyboardGuideDialog via Cockpit button and closes via Esc', (tester) async {
      tester.view.physicalSize = const Size(1366, 768);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final container = ProviderContainer(overrides: createTestOverrides(mode: PosMode.fastRetail));

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(home: PosLayout()),
        ),
      );
      await tester.pumpAndSettle();

      // Cockpit [?] Panduan button exists
      final guideButtonFinder = find.text('[?] Panduan');
      expect(guideButtonFinder, findsOneWidget);

      await tester.tap(guideButtonFinder);
      await tester.pumpAndSettle();

      // Dialog opens
      expect(find.byType(FastRetailKeyboardGuideDialog), findsOneWidget);
      expect(find.text('Panduan Operasional Keyboard Kasir Cepat'), findsOneWidget);
      expect(find.text('1. Scanning, Input & Multiplier (Omni-Bar)'), findsOneWidget);
      expect(find.text('2. Navigasi & Tabel Keranjang'), findsOneWidget);

      // Press Esc to close
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();

      expect(find.byType(FastRetailKeyboardGuideDialog), findsNothing);
    });

    testWidgets('Fast Retail opens FastRetailKeyboardGuideDialog via ? hotkey when not typing in omni', (tester) async {
      tester.view.physicalSize = const Size(1366, 768);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final container = ProviderContainer(overrides: createTestOverrides(mode: PosMode.fastRetail));

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(home: PosLayout()),
        ),
      );
      await tester.pumpAndSettle();

      // Trigger '?' via shortcutProvider
      container.read(shortcutProvider.notifier).trigger('?');
      await tester.pumpAndSettle();

      expect(find.byType(FastRetailKeyboardGuideDialog), findsOneWidget);
      expect(find.text('Panduan Operasional Keyboard Kasir Cepat'), findsOneWidget);

      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();
      expect(find.byType(FastRetailKeyboardGuideDialog), findsNothing);
    });
  });

  group('Requirement 3: Multiplier Prefix Syntax [Qty]*[Barcode/SKU]', () {
    testWidgets('Typing "3*" in omni-bar reveals [3x] badge and adds 3 pcs on submit', (tester) async {
      tester.view.physicalSize = const Size(1366, 768);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final container = ProviderContainer(overrides: createTestOverrides(mode: PosMode.fastRetail));

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(home: PosLayout()),
        ),
      );
      await tester.pumpAndSettle();

      final searchTextFieldFinder = find.byType(TextField).first;

      // 1. Enter multiplier prefix "3*"
      await tester.enterText(searchTextFieldFinder, '3*');
      await tester.pumpAndSettle();

      // Verify multiplier badge [3x] appears in header
      expect(find.text('3x'), findsOneWidget);

      // 2. Append barcode "89912345" -> "3*89912345"
      await tester.enterText(searchTextFieldFinder, '3*89912345');
      await tester.pumpAndSettle();

      // Submit via Enter
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();

      // Verify cart now contains Indomie with quantity 3!
      final cart = container.read(cartProvider);
      expect(cart.length, equals(1));
      expect(cart.first.name, equals('Indomie Goreng Spesial'));
      expect(cart.first.qty, equals(3));
      expect(cart.first.price, equals(3500.0));

      // Multiplier badge is reset after submit
      expect(find.text('3x'), findsNothing);
    });
  });

  group('Requirement 8: Fast Retail Industry-Standard Cockpit Layout (No Duplicate Cart)', () {
    testWidgets('Cockpit renders Hero Card, CRM Member, Financial breakdown, and 38sp Grand Total', (tester) async {
      tester.view.physicalSize = const Size(1366, 768);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final container = ProviderContainer(overrides: createTestOverrides(mode: PosMode.fastRetail));

      final testItem = CartItem(
        id: 'c-hero-1',
        productId: 'prod-indomie',
        name: 'Indomie Goreng Spesial',
        price: 3500.0,
        qty: 2,
        barcode: '89912345',
      );
      container.read(cartProvider.notifier).addItem(testItem);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(home: PosLayout()),
        ),
      );
      await tester.pumpAndSettle();

      // 1. Hero Card displays "BERHASIL TERPINDAI" badge & item details
      expect(find.text('BERHASIL TERPINDAI'), findsOneWidget);
      expect(find.text('89912345'), findsWidgets);

      // 2. CRM Member card
      expect(find.text('Pelanggan'), findsOneWidget);
      expect(find.text('Pelanggan Umum (Walk-in)'), findsOneWidget);

      // 3. Financial breakdown
      expect(find.text('Subtotal'), findsWidgets);
      expect(find.text('TOTAL TAGIHAN'), findsOneWidget);

      // 4. Action Deck buttons
      expect(find.text('[Hold] Tahan'), findsOneWidget);
      expect(find.text('[Diskon] Nota'), findsOneWidget);
      expect(find.text('[Del] Hapus Baris'), findsOneWidget);
      expect(find.text('[Esc] Batal'), findsOneWidget);
      expect(find.text('[?] Panduan'), findsOneWidget);
      expect(find.text('BAYAR (Rp 7.000)'), findsOneWidget);
    });
  });

  group('Requirement 5: 2-Enter Exact Cash Tender Flow', () {
    testWidgets('Empty omni-bar Enter routes directly to checkout with exact cash', (tester) async {
      tester.view.physicalSize = const Size(1366, 768);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final container = ProviderContainer(overrides: createTestOverrides(mode: PosMode.fastRetail));

      final testItem = CartItem(
        id: 'c-cash-1',
        productId: 'prod-indomie',
        name: 'Indomie Goreng Spesial',
        price: 3500.0,
        qty: 2,
      );
      container.read(cartProvider.notifier).addItem(testItem);

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

      // Omni-bar is empty, cart is not empty.
      final searchTextFieldFinder = find.byType(TextField).first;
      await tester.tap(searchTextFieldFinder);
      await tester.pumpAndSettle();

      // First Enter: triggers quick checkout with exact cash!
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();

      expect(find.byType(FastRetailCheckoutDialog), findsOneWidget);
    });
  });

  group('Requirement 6 & 7: Zero-Mouse Navigation in Checkout & Dialogs', () {
    testWidgets('CheckoutPaymentPane allows Tab and Alt+1..4 navigation between payment methods', (tester) async {
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final container = ProviderContainer(overrides: createTestOverrides(mode: PosMode.fastRetail));

      final testItem = CartItem(
        id: 'c-checkout-1',
        productId: 'prod-indomie',
        name: 'Indomie Goreng Spesial',
        price: 3500.0,
        qty: 1,
      );
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

      // Currently Cash is selected
      expect(find.text('Uang Diterima'), findsOneWidget);

      // Press ArrowRight / Tab to switch to QRIS
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pumpAndSettle();

      expect(find.text('Arahkan pelanggan untuk memindai QRIS melalui aplikasi mobile banking atau e-wallet mereka.'), findsOneWidget);

      // Press ArrowLeft to switch back to Cash
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
      await tester.pumpAndSettle();

      expect(find.text('Uang Diterima'), findsOneWidget);
    });
  });
}
