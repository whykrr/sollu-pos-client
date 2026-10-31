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
import 'package:sollu_pos_client/features/pos/presentation/providers/transaction_provider.dart';
import 'package:sollu_pos_client/features/pos/presentation/widgets/checkout_payment_pane.dart';
import 'package:sollu_pos_client/features/pos/presentation/widgets/fast_retail_cart_table.dart';
import 'package:sollu_pos_client/features/pos/presentation/widgets/pos_extra_dialogs.dart';
import 'package:sollu_pos_client/features/pos/presentation/widgets/shortcut_cheat_sheet_dialog.dart';
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

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    dotenv.testLoad(mergeWith: {
      'API_BASE_URL': 'https://api.test',
      'APP_NAME': 'Sollu POS Test',
    });
  });

  late SharedPreferences sharedPrefs;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    sharedPrefs = await SharedPreferences.getInstance();
  });

  final testPaymentMethods = [
    const PaymentMethod(id: 'pm-c', name: 'Tunai', type: 'cash', referencePolicy: 'hidden', openCashDrawer: true, isSystem: true, isActive: true),
    const PaymentMethod(id: 'pm-q', name: 'QRIS', type: 'qris', referencePolicy: 'optional', openCashDrawer: false, isSystem: false, isActive: true),
    const PaymentMethod(id: 'pm-d', name: 'Debit Card', type: 'edc', referencePolicy: 'optional', openCashDrawer: false, isSystem: false, isActive: true),
  ];

  List<Override> createPosLayoutOverrides({List<String> activeFeatures = const ['pos', 'crm', 'cash_drawer']}) {
    return [
      sharedPreferencesProvider.overrideWithValue(sharedPrefs),
      connectivityProvider.overrideWith(MockConnectivityNotifier.new),
      activeShiftProvider.overrideWith((ref) => Stream.value(null)),
      heldTransactionsStreamProvider.overrideWith((ref) => Stream.value([])),
      posModeProvider.overrideWith(() => MockPosModeNotifier(PosMode.fastRetail)),
      featureGatingProvider.overrideWith((ref) => FeatureGatingService(activeFeatures: activeFeatures)),
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
      autoSyncProvider.overrideWith(() => MockAutoSyncNotifier()),
      bootstrapProvider.overrideWith((ref) => Future.value(BootstrapResult(isOnline: true, hasActiveShift: false))),
      activePromosProvider.overrideWith((ref) => Stream.value([])),
      customersProvider.overrideWith((ref) => Stream.value([])),
    ];
  }

  group('Adversarial Challenge 1: FastRetailCartTable Multi-Row Deletion & Gesture Arena Independence', () {
    testWidgets('Deleting non-first row (middle and end) removes exact item without swallowing', (tester) async {
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final items = [
        CartItem(id: 'item-1', productId: 'p1', name: 'Espresso', price: 18000.0, qty: 1),
        CartItem(id: 'item-2', productId: 'p2', name: 'Croissant', price: 25000.0, qty: 1),
        CartItem(id: 'item-3', productId: 'p3', name: 'Matcha Latte', price: 30000.0, qty: 1),
        CartItem(id: 'item-4', productId: 'p4', name: 'Mineral Water', price: 8000.0, qty: 1),
      ];

      final container = ProviderContainer();
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

      // 4 delete icons exist
      final deleteIcons = find.byIcon(Icons.delete_outline);
      expect(deleteIcons, findsNWidgets(4));

      // Tap delete on item-2 (index 1)
      await tester.tap(deleteIcons.at(1));
      await tester.pumpAndSettle();

      final cartAfterDelete1 = container.read(cartProvider);
      expect(cartAfterDelete1.length, equals(3));
      expect(cartAfterDelete1.any((i) => i.id == 'item-2'), isFalse);
      expect(cartAfterDelete1[0].id, equals('item-1'));
      expect(cartAfterDelete1[1].id, equals('item-3'));
      expect(cartAfterDelete1[2].id, equals('item-4'));

      // Tap delete on the last item (item-4, now at index 2)
      final remainingDeleteIcons = find.byIcon(Icons.delete_outline);
      expect(remainingDeleteIcons, findsNWidgets(3));
      await tester.tap(remainingDeleteIcons.at(2));
      await tester.pumpAndSettle();

      final cartAfterDelete2 = container.read(cartProvider);
      expect(cartAfterDelete2.length, equals(2));
      expect(cartAfterDelete2.any((i) => i.id == 'item-4'), isFalse);
      expect(cartAfterDelete2[0].id, equals('item-1'));
      expect(cartAfterDelete2[1].id, equals('item-3'));
    });
  });

  group('Adversarial Challenge 2: ShortcutCheatSheetDialog Viewport Stress Matrix (0 Overflows)', () {
    final viewports = [
      const Size(1920, 1080), // Full HD Desktop
      const Size(1366, 768),  // Standard Laptop
      const Size(1024, 600),  // Compact POS / Netbook
      const Size(800, 600),   // SVGA Legacy Terminal
    ];

    for (final size in viewports) {
      testWidgets('No RenderFlex overflow on viewport size ${size.width}x${size.height}', (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() => tester.view.resetPhysicalSize());

        FlutterErrorDetails? caughtError;
        final originalOnError = FlutterError.onError;
        FlutterError.onError = (details) {
          if (details.toString().contains('A RenderFlex overflowed')) {
            caughtError = details;
          }
        };

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              sharedPreferencesProvider.overrideWithValue(sharedPrefs),
            ],
            child: MaterialApp(
              home: Scaffold(
                body: Builder(
                  builder: (context) => ElevatedButton(
                    onPressed: () => ShortcutCheatSheetDialog.show(context),
                    child: const Text('Open Dialog'),
                  ),
                ),
              ),
            ),
          ),
        );

        await tester.tap(find.text('Open Dialog'));
        await tester.pumpAndSettle();

        FlutterError.onError = originalOnError;

        expect(caughtError, isNull, reason: 'RenderFlex overflow occurred on viewport ${size.width}x${size.height}');
      });
    }
  });

  group('Adversarial Challenge 3: CheckoutPaymentPane Reference & Notes Focus Numpad Stress', () {
    testWidgets('Typing digits into Reference No field in EDC mode does NOT switch tabs', (tester) async {
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final testItem = CartItem(id: 'c-1', productId: 'p-1', name: 'Produk Uji', price: 75000.0, qty: 1);

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
      container.read(cartProvider.notifier).addItem(testItem);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: Scaffold(
              body: CheckoutPaymentPane(initialMethodType: 'edc'),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // We are in EDC / Debit Card mode
      expect(find.text('Nomor Referensi / Trace No (Opsional)'), findsOneWidget);

      // Find the reference text field and tap to focus
      final refFieldFinder = find.byType(TextField).first;
      await tester.tap(refFieldFinder);
      await tester.pumpAndSettle();

      // Send digit1, digit2, numpad1, numpad2
      await tester.sendKeyEvent(LogicalKeyboardKey.digit1);
      await tester.sendKeyEvent(LogicalKeyboardKey.digit2);
      await tester.sendKeyEvent(LogicalKeyboardKey.numpad1);
      await tester.sendKeyEvent(LogicalKeyboardKey.numpad2);
      await tester.pumpAndSettle();

      // CRITICAL: We MUST STILL BE in EDC mode!
      expect(find.text('Nomor Referensi / Trace No (Opsional)'), findsOneWidget);
      expect(find.text('Uang Diterima'), findsNothing);
    });
  });

  group('Adversarial Challenge 4: Feature Gating Shortcuts Enforcement (CRM & Drawer)', () {
    testWidgets('CRM card shows warning when CRM is disabled', (tester) async {
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      // Override with CRM feature NOT included in activeFeatures
      final container = ProviderContainer(
        overrides: createPosLayoutOverrides(activeFeatures: ['pos']),
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

      // Tap CRM card in Fast Retail Cockpit
      await tester.tap(find.text('Pelanggan'));
      await tester.pumpAndSettle();

      // CustomerDialog must NOT open
      expect(find.byType(CustomerDialog), findsNothing);
      // SnackBar warning must appear
      expect(find.text('Fitur CRM / Pelanggan tidak aktif pada paket langganan ini.'), findsOneWidget);
    });

    testWidgets('Space key is ignored when Cash Drawer feature is disabled', (tester) async {
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final container = ProviderContainer(
        overrides: createPosLayoutOverrides(activeFeatures: ['pos']), // no cash_drawer
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

      // Press Space
      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      await tester.pumpAndSettle();

      // Should not trigger snackbar or drawer action
      expect(find.byType(SnackBar), findsNothing);
    });
  });
}
