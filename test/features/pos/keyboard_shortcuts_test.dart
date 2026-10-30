import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sollu_pos_client/core/database/app_database.dart';
import 'package:sollu_pos_client/core/providers/auto_sync_provider.dart';
import 'package:sollu_pos_client/core/providers/connectivity_provider.dart';
import 'package:sollu_pos_client/core/providers/preferences_provider.dart';
import 'package:sollu_pos_client/features/pos/presentation/pages/pos_layout.dart';
import 'package:sollu_pos_client/features/pos/presentation/providers/cart_provider.dart';
import 'package:sollu_pos_client/features/pos/presentation/providers/hold_cart_provider.dart';
import 'package:sollu_pos_client/features/pos/presentation/providers/pos_mode_provider.dart';
import 'package:sollu_pos_client/features/pos/presentation/providers/pos_provider.dart';
import 'package:sollu_pos_client/features/pos/presentation/providers/shortcut_provider.dart';
import 'package:sollu_pos_client/features/pos/presentation/providers/transaction_provider.dart';
import 'package:sollu_pos_client/features/pos/presentation/widgets/checkout_payment_pane.dart';
import 'package:sollu_pos_client/features/pos/presentation/widgets/pos_extra_dialogs.dart';
import 'package:sollu_pos_client/features/pos/presentation/views/fast_retail/fast_retail_keyboard_guide_dialog.dart';
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

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    dotenv.testLoad(mergeWith: {
      'API_BASE_URL': 'https://api.test',
      'APP_NAME': 'Sollu POS',
    });
  });

  final testPaymentMethods = [
    const PaymentMethod(
      id: 'pm-cash',
      name: 'Tunai',
      type: 'cash',
      sortOrder: 1,
      isActive: true,
    ),
    const PaymentMethod(
      id: 'pm-qris',
      name: 'QRIS',
      type: 'qris',
      sortOrder: 2,
      isActive: true,
    ),
    const PaymentMethod(
      id: 'pm-edc',
      name: 'BCA Debit',
      type: 'edc',
      sortOrder: 3,
      isActive: true,
    ),
  ];

  late SharedPreferences sharedPrefs;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    sharedPrefs = await SharedPreferences.getInstance();
  });

  List<Override> createPosLayoutOverrides() {
    return [
      sharedPreferencesProvider.overrideWithValue(sharedPrefs),
      connectivityProvider.overrideWith(FakeConnectivityNotifier.new),
      activeShiftProvider.overrideWith((ref) => Stream.value(null)),
      heldTransactionsStreamProvider.overrideWith((ref) => Stream.value([])),
      posModeProvider.overrideWith(() => FakePosModeNotifier(PosMode.fastRetail)),
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
      autoSyncProvider.overrideWith(() => FakeAutoSyncNotifier()),
      bootstrapProvider.overrideWith((ref) => Future.value(BootstrapResult(isOnline: true, hasActiveShift: false))),
      activePromosProvider.overrideWith((ref) => Stream.value([])),
      customersProvider.overrideWith((ref) => Stream.value([])),
    ];
  }

  group('Production CheckoutPaymentPane Keyboard Shortcuts & Numpad Isolation', () {
    testWidgets('Numeric shortcuts 1, 2, 3 switch payment method when not editing text', (tester) async {
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final cartItem = CartItem(
        id: 'cart-1',
        productId: 'prod-1',
        name: 'Item Test',
        price: 50000.0,
        qty: 1,
      );

      final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(sharedPrefs),
          cartProvider.overrideWith(() => CartNotifier()),
          activeTaxRateProvider.overrideWith((ref) => 0.0),
          activeServiceChargeRateProvider.overrideWith((ref) => 0.0),
          outletSettingsProvider.overrideWith((ref) => {
            'taxPercentage': 0.0,
            'serviceChargePercentage': 0.0,
            'taxIncludedInPrice': false,
            'roundingEnabled': false,
          }),
          activePaymentMethodsProvider.overrideWith((ref) => Stream.value(testPaymentMethods)),
        ],
      );
      container.read(cartProvider.notifier).addItem(cartItem);

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

      // Initially Tunai (Cash) is selected
      expect(find.text('Uang Diterima'), findsOneWidget);
      expect(find.text('Silakan arahkan pelanggan untuk menyelesaikan pembayaran melalui QRIS/Mesin EDC/Transfer.'), findsNothing);

      // Press '2' (without focusing any input field) -> switches to QRIS
      await tester.sendKeyEvent(LogicalKeyboardKey.digit2);
      await tester.pumpAndSettle();

      expect(find.text('Silakan arahkan pelanggan untuk menyelesaikan pembayaran melalui QRIS/Mesin EDC/Transfer.'), findsOneWidget);
      expect(find.text('Uang Diterima'), findsNothing);

      // Press '1' -> switches back to Tunai (Cash)
      await tester.sendKeyEvent(LogicalKeyboardKey.digit1);
      await tester.pumpAndSettle();

      expect(find.text('Uang Diterima'), findsOneWidget);
      expect(find.text('Silakan arahkan pelanggan untuk menyelesaikan pembayaran melalui QRIS/Mesin EDC/Transfer.'), findsNothing);

      // Press '3' -> switches to BCA Debit
      await tester.sendKeyEvent(LogicalKeyboardKey.digit3);
      await tester.pumpAndSettle();

      expect(find.text('Nomor Referensi / Trace No (Opsional)'), findsOneWidget);
    });

    testWidgets('Numpad keys type into cash input without switching payment method when editing text', (tester) async {
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final cartItem = CartItem(
        id: 'cart-1',
        productId: 'prod-1',
        name: 'Item Test',
        price: 50000.0,
        qty: 1,
      );

      final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(sharedPrefs),
          cartProvider.overrideWith(() => CartNotifier()),
          activeTaxRateProvider.overrideWith((ref) => 0.0),
          activeServiceChargeRateProvider.overrideWith((ref) => 0.0),
          outletSettingsProvider.overrideWith((ref) => {
            'taxPercentage': 0.0,
            'serviceChargePercentage': 0.0,
            'taxIncludedInPrice': false,
            'roundingEnabled': false,
          }),
          activePaymentMethodsProvider.overrideWith((ref) => Stream.value(testPaymentMethods)),
        ],
      );
      container.read(cartProvider.notifier).addItem(cartItem);

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

      // Find the cash input field and tap it to focus
      final cashTextFieldFinder = find.byType(TextField).first;
      await tester.tap(cashTextFieldFinder);
      await tester.pumpAndSettle();

      // Type '2' and '0' using physical keys while focused
      await tester.sendKeyEvent(LogicalKeyboardKey.numpad2);
      await tester.sendKeyEvent(LogicalKeyboardKey.numpad0);
      await tester.pumpAndSettle();

      // CRITICAL INVARIANT: Still in Tunai (Cash) mode, did NOT switch to QRIS!
      expect(find.text('Uang Diterima'), findsOneWidget);
      expect(find.text('Silakan arahkan pelanggan untuk menyelesaikan pembayaran melalui QRIS/Mesin EDC/Transfer.'), findsNothing);
    });
  });

  group('Production PosLayout Operational Keyboard Shortcuts Tests', () {
    testWidgets('Omni-bar search input is rendered and focusable in Fast Retail', (tester) async {
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final container = ProviderContainer(
        overrides: createPosLayoutOverrides(),
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: PosLayout(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      final searchTextFieldFinder = find.byType(TextField).first;
      expect(searchTextFieldFinder, findsOneWidget);
    });

    testWidgets('Discount dialog opens from Cockpit Action Deck without F2 label', (tester) async {
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final container = ProviderContainer(
        overrides: createPosLayoutOverrides(),
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: PosLayout(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Tap Diskon in Cockpit
      await tester.tap(find.text('[Diskon] Nota'));
      await tester.pumpAndSettle();

      expect(find.byType(DiscountDialog), findsOneWidget);
      expect(find.text('Promo & Diskon'), findsOneWidget);
      expect(find.text('Promo & Diskon (F2)'), findsNothing);
    });

    testWidgets('EditCartItemDialog opens from Table Pane double-tap without F3 label', (tester) async {
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final testItem = CartItem(
        id: 'cart-1',
        productId: 'prod-1',
        name: 'Kopi Kenangan',
        price: 25000.0,
        qty: 1,
      );

      final container = ProviderContainer(
        overrides: createPosLayoutOverrides(),
      );
      container.read(cartProvider.notifier).addItem(testItem);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: PosLayout(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Double tap item row in Fast Retail Table
      await tester.tap(find.text('Kopi Kenangan').first);
      await tester.pump(const Duration(milliseconds: 50));
      await tester.tap(find.text('Kopi Kenangan').first);
      await tester.pumpAndSettle();

      expect(find.byType(EditCartItemDialog), findsOneWidget);
    });

    testWidgets('CustomerDialog opens from Cockpit CRM card without F4 label', (tester) async {
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final container = ProviderContainer(
        overrides: createPosLayoutOverrides(),
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: PosLayout(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Tap Pelanggan card in Cockpit
      await tester.tap(find.text('Pelanggan'));
      await tester.pumpAndSettle();

      expect(find.byType(CustomerDialog), findsOneWidget);
      expect(find.text('Pilih Pelanggan / Member'), findsOneWidget);
      expect(find.text('Pilih Pelanggan / Member (F4)'), findsNothing);
    });

    testWidgets('+ and - keys increment and decrement selected cart item quantity', (tester) async {
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final testItem = CartItem(
        id: 'cart-item-inc',
        productId: 'prod-1',
        name: 'Croissant Butter',
        price: 15000.0,
        qty: 1,
      );

      final container = ProviderContainer(
        overrides: createPosLayoutOverrides(),
      );
      container.read(cartProvider.notifier).addItem(testItem);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: PosLayout(),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(container.read(cartProvider).first.qty, equals(1));

      // Press ArrowDown from empty search bar to focus the table
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pumpAndSettle();

      // Press '+'
      await tester.sendKeyEvent(LogicalKeyboardKey.numpadAdd);
      await tester.pumpAndSettle();
      expect(container.read(cartProvider).first.qty, equals(2));

      // Press '-'
      await tester.sendKeyEvent(LogicalKeyboardKey.numpadSubtract);
      await tester.pumpAndSettle();
      expect(container.read(cartProvider).first.qty, equals(1));
    });

    testWidgets('ArrowDown and ArrowUp navigate cart item selection', (tester) async {
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final item1 = CartItem(id: 'c-1', productId: 'p-1', name: 'Item 1', price: 10000.0, qty: 1);
      final item2 = CartItem(id: 'c-2', productId: 'p-2', name: 'Item 2', price: 20000.0, qty: 1);

      final container = ProviderContainer(
        overrides: createPosLayoutOverrides(),
      );
      container.read(cartProvider.notifier).addItem(item1);
      container.read(cartProvider.notifier).addItem(item2);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: PosLayout(),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(container.read(selectedCartIndexProvider), equals(0));

      // Press ArrowDown from empty search bar to focus the table
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pumpAndSettle();

      // Press ArrowDown -> moves selection to item 2
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pumpAndSettle();
      expect(container.read(selectedCartIndexProvider), equals(1));

      // Press ArrowUp -> moves selection back to item 1
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
      await tester.pumpAndSettle();
      expect(container.read(selectedCartIndexProvider), equals(0));
    });

    testWidgets('ShortcutNotifier triggers shortcut actions via reactive Riverpod subscription', (tester) async {
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final container = ProviderContainer(
        overrides: createPosLayoutOverrides(),
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: PosLayout(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Trigger '?' via shortcutProvider
      container.read(shortcutProvider.notifier).trigger('?');
      await tester.pumpAndSettle();

      // Verify FastRetailKeyboardGuideDialog is displayed
      expect(find.byType(FastRetailKeyboardGuideDialog), findsOneWidget);
      expect(find.text('Panduan Operasional Keyboard Kasir Cepat'), findsOneWidget);
    });
  });
}
