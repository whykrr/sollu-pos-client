import 'package:dio/dio.dart';
import 'package:drift/drift.dart' hide isNull, isNotNull, Column;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sollu_pos_client/core/database/app_database.dart';
import 'package:sollu_pos_client/core/network/api_endpoints.dart';
import 'package:sollu_pos_client/core/network/dio_client.dart';
import 'package:sollu_pos_client/core/services/secure_storage_service.dart';
import 'package:sollu_pos_client/features/cart/domain/cart_item.dart';
import 'package:sollu_pos_client/features/pos/data/transaction_repository.dart';
import 'package:sollu_pos_client/features/settings/presentation/providers/feature_gating_provider.dart';
import 'package:sollu_pos_client/features/settings/presentation/providers/outlet_settings_provider.dart';

final uuidRegex = RegExp(
  r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$',
);

class TestGatedView extends ConsumerWidget {
  const TestGatedView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gating = ref.watch(featureGatingProvider);
    final enablePin = ref.watch(enableSupervisorPinProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('POS Test'),
        actions: [
          if (gating.canUseShiftCashier())
            const Chip(
              key: Key('chip_shift_cashier'),
              label: Text('Shift Aktif'),
            ),
        ],
      ),
      body: Column(
        children: [
          if (gating.canUseCrm())
            ElevatedButton(
              key: const Key('btn_crm_member'),
              onPressed: () {},
              child: const Text('CRM Member'),
            ),
          if (gating.canUseSplitPayment())
            ElevatedButton(
              key: const Key('btn_split_payment'),
              onPressed: () {},
              child: const Text('Split Bill'),
            ),
          if (gating.canUseCashDrawer())
            ElevatedButton(
              key: const Key('btn_cash_drawer'),
              onPressed: () {},
              child: const Text('Kick Drawer'),
            ),
          if (enablePin)
            const Text(
              'PIN Supervisor Aktif',
              key: Key('txt_supervisor_pin'),
            ),
        ],
      ),
    );
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;
  late DioClient dioClient;
  late TransactionRepository repository;

  setUp(() {
    dotenv.testLoad(mergeWith: {
      'API_BASE_URL': 'https://api.test',
      'APP_NAME': 'Sollu POS Challenger',
    });
    FlutterSecureStorage.setMockInitialValues({});
    db = AppDatabase.forTesting(NativeDatabase.memory());
    dioClient = DioClient(SecureStorageService());
    repository = TransactionRepository(db, dioClient);
  });

  tearDown(() async {
    await db.close();
  });

  group('Challenge 1: Multi-Tender Split Payment Payloads', () {
    test('Transaction with 2 payments (Cash + QRIS) sends complete payments array', () async {
      Map<String, dynamic>? capturedPayload;

      dioClient.dio.interceptors.insert(
        0,
        InterceptorsWrapper(
          onRequest: (options, handler) {
            if (options.path == ApiEndpoints.transactions) {
              capturedPayload = options.data as Map<String, dynamic>;
              return handler.resolve(
                Response(
                  requestOptions: options,
                  statusCode: 200,
                  data: {'success': true},
                ),
              );
            }
            return handler.next(options);
          },
        ),
      );

      final result = await repository.createTransaction(
        items: [
          CartItem(
            id: 'cart-1',
            productId: 'prod-1',
            name: 'Kopi Susu Gula Aren',
            price: 50000.0,
            qty: 1,
            trackInventory: false,
          ),
        ],
        subtotal: 50000.0,
        discountAmount: 0.0,
        taxAmount: 0.0,
        total: 50000.0,
        multiPayments: [
          (
            paymentMethodId: 'pm-cash-uuid',
            amount: 30000.0,
            changeAmount: 5000.0,
            paymentReference: null,
          ),
          (
            paymentMethodId: 'pm-qris-uuid',
            amount: 25000.0,
            changeAmount: 0.0,
            paymentReference: 'QRIS-REF-001',
          ),
        ],
      );

      expect(result.detail.payments.length, 2);

      final syncedCount = await repository.syncPendingTransactions();
      expect(syncedCount, 1);
      expect(capturedPayload, isNotNull);

      final payments = capturedPayload!['payments'] as List;
      expect(payments.length, 2, reason: 'Must NOT truncate to .first; both payments must be present');

      expect(payments[0]['payment_method_id'], 'pm-cash-uuid');
      expect(payments[0]['amount'], 30000.0);
      expect(payments[0]['change_amount'], 5000.0);
      expect(payments[0]['payment_reference'], isNull);

      expect(payments[1]['payment_method_id'], 'pm-qris-uuid');
      expect(payments[1]['amount'], 25000.0);
      expect(payments[1]['change_amount'], 0.0);
      expect(payments[1]['payment_reference'], 'QRIS-REF-001');
    });

    test('Transaction with 3 payments (Cash + QRIS + Debit) sends all 3 tenders correctly', () async {
      Map<String, dynamic>? capturedPayload;

      dioClient.dio.interceptors.insert(
        0,
        InterceptorsWrapper(
          onRequest: (options, handler) {
            if (options.path == ApiEndpoints.transactions) {
              capturedPayload = options.data as Map<String, dynamic>;
              return handler.resolve(
                Response(
                  requestOptions: options,
                  statusCode: 200,
                  data: {'success': true},
                ),
              );
            }
            return handler.next(options);
          },
        ),
      );

      await repository.createTransaction(
        items: [
          CartItem(
            id: 'cart-3way',
            productId: 'prod-3way',
            name: 'Menu Pesta 3 Bayar',
            price: 150000.0,
            qty: 1,
            trackInventory: false,
          ),
        ],
        subtotal: 150000.0,
        discountAmount: 0.0,
        taxAmount: 0.0,
        total: 150000.0,
        multiPayments: [
          (
            paymentMethodId: 'pm-cash-01',
            amount: 50000.0,
            changeAmount: 0.0,
            paymentReference: null,
          ),
          (
            paymentMethodId: 'pm-qris-02',
            amount: 60000.0,
            changeAmount: 0.0,
            paymentReference: 'QRIS-TX-9988',
          ),
          (
            paymentMethodId: 'pm-debit-03',
            amount: 40000.0,
            changeAmount: 0.0,
            paymentReference: 'EDC-BCA-12345',
          ),
        ],
      );

      final count = await repository.syncPendingTransactions();
      expect(count, 1);
      expect(capturedPayload, isNotNull);

      final payments = capturedPayload!['payments'] as List;
      expect(payments.length, 3, reason: 'All 3 split tenders must be serialized into payments payload');

      expect(payments[0]['payment_method_id'], 'pm-cash-01');
      expect(payments[0]['amount'], 50000.0);

      expect(payments[1]['payment_method_id'], 'pm-qris-02');
      expect(payments[1]['amount'], 60000.0);
      expect(payments[1]['payment_reference'], 'QRIS-TX-9988');

      expect(payments[2]['payment_method_id'], 'pm-debit-03');
      expect(payments[2]['amount'], 40000.0);
      expect(payments[2]['payment_reference'], 'EDC-BCA-12345');
    });

    test('Transaction with 4 payments on manual retryTransaction preserves all 4 tenders', () async {
      Map<String, dynamic>? capturedPayload;

      dioClient.dio.interceptors.insert(
        0,
        InterceptorsWrapper(
          onRequest: (options, handler) {
            if (options.path == ApiEndpoints.transactions) {
              capturedPayload = options.data as Map<String, dynamic>;
              return handler.resolve(
                Response(
                  requestOptions: options,
                  statusCode: 200,
                  data: {'success': true},
                ),
              );
            }
            return handler.next(options);
          },
        ),
      );

      final result = await repository.createTransaction(
        items: [
          CartItem(
            id: 'cart-4way',
            productId: 'prod-4way',
            name: 'Menu 4 Bayar',
            price: 200000.0,
            qty: 1,
            trackInventory: false,
          ),
        ],
        subtotal: 200000.0,
        discountAmount: 0.0,
        taxAmount: 0.0,
        total: 200000.0,
        multiPayments: [
          (
            paymentMethodId: 'pm-1',
            amount: 50000.0,
            changeAmount: 0.0,
            paymentReference: 'REF-1',
          ),
          (
            paymentMethodId: 'pm-2',
            amount: 50000.0,
            changeAmount: 0.0,
            paymentReference: 'REF-2',
          ),
          (
            paymentMethodId: 'pm-3',
            amount: 50000.0,
            changeAmount: 0.0,
            paymentReference: 'REF-3',
          ),
          (
            paymentMethodId: 'pm-4',
            amount: 50000.0,
            changeAmount: 0.0,
            paymentReference: 'REF-4',
          ),
        ],
      );

      final retrySuccess = await repository.retryTransaction(result.transaction.id);
      expect(retrySuccess, isTrue);
      expect(capturedPayload, isNotNull);

      final payments = capturedPayload!['payments'] as List;
      expect(payments.length, 4, reason: 'Manual retry must send all 4 payments without truncating');
      for (int i = 0; i < 4; i++) {
        expect(payments[i]['payment_method_id'], 'pm-${i + 1}');
        expect(payments[i]['amount'], 50000.0);
        expect(payments[i]['payment_reference'], 'REF-${i + 1}');
      }
    });
  });

  group('Challenge 2: Modifier Option UUID Serialization', () {
    test('Modifier options in transaction item are serialized with UUID modifier_option_id (not null)', () async {
      Map<String, dynamic>? capturedPayload;

      dioClient.dio.interceptors.insert(
        0,
        InterceptorsWrapper(
          onRequest: (options, handler) {
            if (options.path == ApiEndpoints.transactions) {
              capturedPayload = options.data as Map<String, dynamic>;
              return handler.resolve(
                Response(
                  requestOptions: options,
                  statusCode: 200,
                  data: {'success': true},
                ),
              );
            }
            return handler.next(options);
          },
        ),
      );

      const modOpt1Uuid = '11111111-2222-3333-4444-555555555555';
      const modOpt2Uuid = '66666666-7777-8888-9999-000000000000';

      // Insert modifier options into SQLite database
      await db.into(db.modifierOptions).insert(
            ModifierOptionsCompanion.insert(
              id: modOpt1Uuid,
              modifierGroupId: 'mod-group-1',
              name: 'Extra Shot Espresso',
              price: const Value(7000.0),
            ),
          );
      await db.into(db.modifierOptions).insert(
            ModifierOptionsCompanion.insert(
              id: modOpt2Uuid,
              modifierGroupId: 'mod-group-2',
              name: 'Oat Milk Sub',
              price: const Value(10000.0),
            ),
          );

      const modOpt3UuidDirect = 'aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee';

      final cartItem = CartItem(
        id: 'cart-mod-1',
        productId: 'prod-coffee',
        name: 'Cappuccino Custom',
        price: 35000.0,
        qty: 1,
        trackInventory: false,
        selectedModifiers: {
          'mod-group-1': [modOpt1Uuid],
          'mod-group-2': [modOpt2Uuid, modOpt3UuidDirect],
        },
      );

      final result = await repository.createTransaction(
        items: [cartItem],
        subtotal: 35000.0,
        discountAmount: 0.0,
        taxAmount: 0.0,
        total: 52000.0,
        multiPayments: [
          (
            paymentMethodId: 'pm-cash',
            amount: 52000.0,
            changeAmount: 0.0,
            paymentReference: null,
          ),
        ],
      );

      final syncedCount = await repository.syncPendingTransactions();
      expect(syncedCount, 1);
      expect(capturedPayload, isNotNull);

      final items = capturedPayload!['items'] as List;
      expect(items.length, 1);

      final modifiers = items[0]['modifiers'] as List;
      expect(modifiers.length, 3, reason: 'All 3 modifier options must be present in item payload');

      for (final mod in modifiers) {
        final optId = mod['modifier_option_id'];
        expect(optId, isNotNull, reason: 'modifier_option_id MUST NOT be null');
        expect(optId.toString().isNotEmpty, isTrue);
        expect(
          uuidRegex.hasMatch(optId.toString()),
          isTrue,
          reason: 'modifier_option_id must match UUID format: $optId',
        );
      }

      final optionIds = modifiers.map((m) => m['modifier_option_id']).toSet();
      expect(optionIds, containsAll([modOpt1Uuid, modOpt2Uuid, modOpt3UuidDirect]));

      // Also verify retryTransaction serializes valid UUID modifier_option_id
      capturedPayload = null;
      final retrySuccess = await repository.retryTransaction(result.transaction.id);
      expect(retrySuccess, isTrue);
      expect(capturedPayload, isNotNull);

      final retryModifiers = (capturedPayload!['items'] as List)[0]['modifiers'] as List;
      for (final mod in retryModifiers) {
        final optId = mod['modifier_option_id'];
        expect(optId, isNotNull);
        expect(uuidRegex.hasMatch(optId.toString()), isTrue);
      }
    });
  });

  group('Challenge 3: Full Feature Gating Matrix (2^5 = 32 Combinations with base POS)', () {
    for (int mask = 0; mask < 32; mask++) {
      // Base 'pos' is always included as per production standard
      final activeList = <String>['pos'];
      final bool hasSplit = (mask & 1) != 0;
      final bool hasCrm = (mask & 2) != 0;
      final bool hasShift = (mask & 4) != 0;
      final bool hasDrawer = (mask & 8) != 0;
      final bool hasDoubleAuth = (mask & 16) != 0;

      if (hasSplit) activeList.add('split_payment');
      if (hasCrm) activeList.add('crm');
      if (hasShift) activeList.add('shift_cashier');
      if (hasDrawer) activeList.add('cash_drawer');
      if (hasDoubleAuth) activeList.add('double_authorization');

      test('Matrix combination #$mask: [${activeList.join(', ')}]', () {
        final gating = FeatureGatingService(activeFeatures: activeList);

        expect(gating.canUseSplitPayment(), equals(hasSplit));
        expect(gating.canUseCrm(), equals(hasCrm));
        expect(gating.canUseShiftCashier(), equals(hasShift));
        expect(gating.canUseCashDrawer(), equals(hasDrawer));
        expect(gating.canUseDoubleAuthorization(), equals(hasDoubleAuth));

        // When supervisor PIN is configured in settings
        expect(gating.isSupervisorPinAllowed(true), equals(hasDoubleAuth));
        // When supervisor PIN is NOT configured in settings
        expect(gating.isSupervisorPinAllowed(false), equals(false));

        // Test Riverpod provider resolution
        final container = ProviderContainer(
          overrides: [
            outletSettingsProvider.overrideWith((ref) => {
              'activeFeatures': activeList,
              'enableSupervisorPin': true,
            }),
          ],
        );
        addTearDown(container.dispose);

        final riverpodGating = container.read(featureGatingProvider);
        expect(riverpodGating.canUseSplitPayment(), equals(hasSplit));
        expect(riverpodGating.canUseCrm(), equals(hasCrm));
        expect(riverpodGating.canUseShiftCashier(), equals(hasShift));
        expect(riverpodGating.canUseCashDrawer(), equals(hasDrawer));
        expect(riverpodGating.canUseDoubleAuthorization(), equals(hasDoubleAuth));

        final pinAllowed = container.read(enableSupervisorPinProvider);
        expect(pinAllowed, equals(hasDoubleAuth));
      });

      testWidgets('Widget tree rendering without exceptions for combination #$mask', (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              outletSettingsProvider.overrideWith((ref) => {
                'activeFeatures': activeList,
                'enableSupervisorPin': true,
              }),
            ],
            child: const MaterialApp(
              home: TestGatedView(),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Verify shift status chip
        if (hasShift) {
          expect(find.byKey(const Key('chip_shift_cashier')), findsOneWidget);
        } else {
          expect(find.byKey(const Key('chip_shift_cashier')), findsNothing);
        }

        // Verify CRM button
        if (hasCrm) {
          expect(find.byKey(const Key('btn_crm_member')), findsOneWidget);
        } else {
          expect(find.byKey(const Key('btn_crm_member')), findsNothing);
        }

        // Verify Split bill button
        if (hasSplit) {
          expect(find.byKey(const Key('btn_split_payment')), findsOneWidget);
        } else {
          expect(find.byKey(const Key('btn_split_payment')), findsNothing);
        }

        // Verify Cash drawer button
        if (hasDrawer) {
          expect(find.byKey(const Key('btn_cash_drawer')), findsOneWidget);
        } else {
          expect(find.byKey(const Key('btn_cash_drawer')), findsNothing);
        }

        // Verify Supervisor PIN indicator
        if (hasDoubleAuth) {
          expect(find.byKey(const Key('txt_supervisor_pin')), findsOneWidget);
        } else {
          expect(find.byKey(const Key('txt_supervisor_pin')), findsNothing);
        }
      });
    }

    test('Edge case: backward compatibility fallback when activeFeatures is empty list', () {
      final container = ProviderContainer(
        overrides: [
          outletSettingsProvider.overrideWith((ref) => {
            'activeFeatures': <String>[],
            'enableSupervisorPin': true,
          }),
        ],
      );
      addTearDown(container.dispose);

      // In the current implementation, empty activeFeatures allows PIN for backward compatibility
      final pinAllowed = container.read(enableSupervisorPinProvider);
      expect(pinAllowed, isTrue, reason: 'Backward compatibility fallback when activeFeatures is empty');

      // But FeatureGatingService directly strictly checks hasFeature
      final gating = FeatureGatingService(activeFeatures: const []);
      expect(gating.canUseDoubleAuthorization(), isFalse);
      expect(gating.isSupervisorPinAllowed(true), isFalse);
    });

    test('Edge case: activeFeaturesListProvider normalizes uppercase, mixed case, and padded whitespace', () {
      final container = ProviderContainer(
        overrides: [
          outletSettingsProvider.overrideWith((ref) => {
            'activeFeatures': [
              '  SPLIT_PAYMENT  ',
              ' CRM ',
              'Shift_Cashier',
              'CASH_DRAWER',
              '  Double_Authorization  ',
            ],
            'enableSupervisorPin': true,
          }),
        ],
      );
      addTearDown(container.dispose);

      final normalizedList = container.read(activeFeaturesListProvider);
      expect(normalizedList, [
        'split_payment',
        'crm',
        'shift_cashier',
        'cash_drawer',
        'double_authorization',
      ]);

      final gating = container.read(featureGatingProvider);
      expect(gating.canUseSplitPayment(), isTrue);
      expect(gating.canUseCrm(), isTrue);
      expect(gating.canUseShiftCashier(), isTrue);
      expect(gating.canUseCashDrawer(), isTrue);
      expect(gating.canUseDoubleAuthorization(), isTrue);
      expect(gating.isSupervisorPinAllowed(true), isTrue);

      final pinAllowed = container.read(enableSupervisorPinProvider);
      expect(pinAllowed, isTrue);
    });

    test('Edge case: active_features snake_case fallback from outlet settings', () {
      final container = ProviderContainer(
        overrides: [
          outletSettingsProvider.overrideWith((ref) => {
            'active_features': ['crm', 'cash_drawer'],
          }),
        ],
      );
      addTearDown(container.dispose);

      final gating = container.read(featureGatingProvider);
      expect(gating.canUseCrm(), isTrue);
      expect(gating.canUseCashDrawer(), isTrue);
      expect(gating.canUseSplitPayment(), isFalse);
    });
  });
}
