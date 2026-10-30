import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sollu_pos_client/core/database/app_database.dart';
import 'package:sollu_pos_client/core/providers/preferences_provider.dart';
import 'package:sollu_pos_client/features/pos/presentation/providers/cart_provider.dart';
import 'package:sollu_pos_client/features/pos/presentation/providers/pos_mode_provider.dart';
import 'package:sollu_pos_client/features/pos/presentation/providers/transaction_provider.dart';
import 'package:sollu_pos_client/features/pos/presentation/widgets/checkout_payment_pane.dart';
import 'package:sollu_pos_client/features/pos/presentation/widgets/fast_retail_cart_table.dart';
import 'package:sollu_pos_client/features/pos/presentation/widgets/shortcut_cheat_sheet_dialog.dart';
import 'package:sollu_pos_client/features/settings/presentation/providers/outlet_settings_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late SharedPreferences sharedPrefs;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    sharedPrefs = await SharedPreferences.getInstance();
  });

  group('Milestone 4 Challenger: PosMode Platform Detection & Persistence Verification', () {
    test('Desktop environment auto-detects PosMode.fastRetail', () {
      final detected = PosMode.detectAdaptiveDefault();
      expect(detected, equals(PosMode.fastRetail));
    });

    test('fromCode maps properly and defaults gracefully to adaptive default', () {
      expect(PosMode.fromCode('fast_retail'), equals(PosMode.fastRetail));
      expect(PosMode.fromCode('visual_touch'), equals(PosMode.visualTouch));
      expect(PosMode.fromCode(null), equals(PosMode.fastRetail));
      expect(PosMode.fromCode('unknown_code'), equals(PosMode.fastRetail));
    });

    test('PosModeNotifier toggles and persists to SharedPreferences', () async {
      final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(sharedPrefs),
        ],
      );

      // Default initialization
      expect(container.read(posModeProvider), equals(PosMode.fastRetail));
      expect(container.read(isFastRetailProvider), isTrue);
      expect(container.read(posModeProvider.notifier).hasManualOverride, isFalse);

      // Manual switch to visualTouch
      await container.read(posModeProvider.notifier).setMode(PosMode.visualTouch);
      expect(container.read(posModeProvider), equals(PosMode.visualTouch));
      expect(container.read(isFastRetailProvider), isFalse);
      expect(container.read(posModeProvider.notifier).hasManualOverride, isTrue);
      expect(sharedPrefs.getString(PosModeNotifier.storageKey), equals('visual_touch'));

      // Toggle back to fastRetail
      await container.read(posModeProvider.notifier).toggleMode();
      expect(container.read(posModeProvider), equals(PosMode.fastRetail));
      expect(sharedPrefs.getString(PosModeNotifier.storageKey), equals('fast_retail'));

      // Reset to auto clears SharedPreferences key
      await container.read(posModeProvider.notifier).resetToAuto();
      expect(container.read(posModeProvider.notifier).hasManualOverride, isFalse);
      expect(sharedPrefs.containsKey(PosModeNotifier.storageKey), isFalse);
    });
  });

  group('Milestone 4 Challenger: FastRetailCartTable Gesture Collision Bug Verification', () {
    testWidgets('Tapping delete button in FastRetailCartTable is intercepted by row InkWell', (tester) async {
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final searchFocus = FocusNode();
      int focusCallbacks = 0;

      final testItem = CartItem(
        id: 'cart-item-1',
        productId: 'p-1',
        name: 'Item Test',
        price: 25000.0,
        qty: 1,
        barcode: '8990001',
      );

      final container = ProviderContainer();
      container.read(cartProvider.notifier).addItem(testItem);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            home: Scaffold(
              body: SizedBox(
                width: 1280,
                height: 800,
                child: FastRetailCartTable(
                  searchFocusNode: searchFocus,
                  onFocusSearch: () => focusCallbacks++,
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.text('Item Test'), findsOneWidget);

      // Locate the delete icon
      final deleteIcon = find.byIcon(Icons.delete_outline);
      expect(deleteIcon, findsOneWidget);

      // Attempt to tap the delete button
      await tester.tap(deleteIcon);
      await tester.pumpAndSettle();

      // VERIFY REMEDIATION: The item is successfully removed from the cart!
      final cartItems = container.read(cartProvider);
      final itemStillExists = cartItems.isNotEmpty && cartItems.first.id == 'cart-item-1';
      expect(
        itemStillExists,
        isFalse,
        reason: 'REMEDIATION VERIFIED: Delete IconButton reliably removes item without being swallowed by row',
      );
    });
  });

  group('Milestone 4 Challenger: ShortcutCheatSheetDialog Layout Overflow Verification', () {
    testWidgets('ShortcutCheatSheetDialog renders cleanly without RenderFlex overflow', (tester) async {
      tester.view.physicalSize = const Size(1280, 800);
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

      // VERIFY REMEDIATION: No RenderFlex overflow detected on dialog
      expect(caughtError, isNull, reason: 'REMEDIATION VERIFIED: No RenderFlex overflow on ShortcutCheatSheetDialog');
    });
  });

  group('Milestone 4 Challenger: Keyboard Shortcuts Matrix Contract & Remediation Verification', () {
    test('PosLayout implementation strictly matches Dual Mode Architecture & Modern Keyboard Contract', () {
      final posLayoutFile = File('lib/features/pos/presentation/pages/pos_layout.dart');
      expect(posLayoutFile.existsSync(), isTrue);
      final content = posLayoutFile.readAsStringSync();

      // Verify PosLayout is clean root router between FastRetailView and VisualTouchView
      expect(content, contains('FastRetailView'));
      expect(content, contains('VisualTouchView'));

      // Verify zero F1-F12 shortcuts in PosLayout
      expect(content.contains("case 'F1':"), isFalse);
      expect(content.contains("case 'F2':"), isFalse);
      expect(content.contains("case 'F12':"), isFalse);

      final fastRetailFile = File('lib/features/pos/presentation/views/fast_retail/fast_retail_view.dart');
      expect(fastRetailFile.existsSync(), isTrue);
      final fastRetailContent = fastRetailFile.readAsStringSync();
      expect(fastRetailContent, contains('FastRetailHeader'));
      expect(fastRetailContent, contains('FastRetailTablePane'));
      expect(fastRetailContent, contains('FastRetailCockpit'));
      expect(fastRetailContent, contains('FastRetailKeyboardGuideDialog'));
    });

    test('Audit of keyboard_shortcuts_test.dart: Mock facade classes are 100% eliminated', () {
      final shortcutsTestFile = File('test/features/pos/keyboard_shortcuts_test.dart');
      expect(shortcutsTestFile.existsSync(), isTrue);
      final testContent = shortcutsTestFile.readAsStringSync();

      // Ensure dummy mock widgets no longer exist
      expect(testContent.contains('class PosKeyboardHandlerWidget'), isFalse,
          reason: 'Dummy mock PosKeyboardHandlerWidget must not be present');
      expect(testContent.contains('class FakeCheckoutPaymentDialog'), isFalse,
          reason: 'Dummy mock FakeCheckoutPaymentDialog must not be present');

      // Ensure tests mount real PosLayout and CheckoutPaymentPane
      expect(testContent.contains('PosLayout()'), isTrue,
          reason: 'Tests must mount real production PosLayout');
      expect(testContent.contains('CheckoutPaymentPane('), isTrue,
          reason: 'Tests must mount real production CheckoutPaymentPane');
    });

    testWidgets('Payment Dialog Numpad Input Isolation: Numpad digits type into cash field without switching tabs', (tester) async {
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final testPaymentMethods = [
        const PaymentMethod(id: 'pm-1', name: 'Tunai', type: 'cash', sortOrder: 1, isActive: true),
        const PaymentMethod(id: 'pm-2', name: 'QRIS', type: 'qris', sortOrder: 2, isActive: true),
        const PaymentMethod(id: 'pm-3', name: 'Debit', type: 'edc', sortOrder: 3, isActive: true),
      ];

      final testItem = CartItem(id: 'c-1', productId: 'p-1', name: 'Barang Uji', price: 50000.0, qty: 1);

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
              body: CheckoutPaymentPane(initialMethodType: 'cash'),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Cash mode is initially active
      expect(find.text('Uang Diterima'), findsOneWidget);

      // Focus the Cash Received input field
      final cashInputFinder = find.byType(TextField).first;
      await tester.tap(cashInputFinder);
      await tester.pumpAndSettle();

      // Send numpad2 while focused
      await tester.sendKeyEvent(LogicalKeyboardKey.numpad2);
      await tester.sendKeyEvent(LogicalKeyboardKey.numpad0);
      await tester.pumpAndSettle();

      // INVARIANT: Still in Cash mode, did NOT switch to QRIS!
      expect(find.text('Uang Diterima'), findsOneWidget);
      expect(find.text('Silakan arahkan pelanggan untuk menyelesaikan pembayaran melalui QRIS/Mesin EDC/Transfer.'), findsNothing);
    });
  });
}
