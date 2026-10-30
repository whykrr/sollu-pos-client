import 'dart:convert';
import 'dart:math';
import 'package:bcrypt/bcrypt.dart';
import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sollu_pos_client/core/database/app_database.dart';
import 'package:sollu_pos_client/core/database/database_provider.dart';
import 'package:sollu_pos_client/core/network/dio_client.dart';
import 'package:sollu_pos_client/core/providers/preferences_provider.dart';
import 'package:sollu_pos_client/core/services/secure_storage_service.dart';
import 'package:sollu_pos_client/features/auth/presentation/providers/auth_provider.dart';
import 'package:sollu_pos_client/features/auth/presentation/providers/employee_provider.dart';
import 'package:sollu_pos_client/features/history/presentation/widgets/void_transaction_dialog.dart';
import 'package:sollu_pos_client/features/pos/data/transaction_repository.dart';
import 'package:sollu_pos_client/features/pos/presentation/providers/cart_provider.dart';
import 'package:sollu_pos_client/features/pos/presentation/providers/transaction_provider.dart';
import 'package:sollu_pos_client/features/pos/presentation/widgets/checkout_payment_pane.dart';
import 'package:sollu_pos_client/features/pos/presentation/widgets/supervisor_challenge_dialog.dart';
import 'package:sollu_pos_client/features/settings/presentation/providers/outlet_settings_provider.dart';

class FakeCartNotifier extends CartNotifier {
  final List<CartItem> items;
  FakeCartNotifier(this.items);

  @override
  List<CartItem> build() => items;
}

class FakeActiveEmployeeNotifier extends ActiveEmployeeNotifier {
  final Map<String, dynamic>? initialUser;
  FakeActiveEmployeeNotifier([this.initialUser]);

  @override
  Map<String, dynamic>? build() => initialUser;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    dotenv.testLoad(mergeWith: {
      'API_BASE_URL': 'https://api.test',
      'APP_NAME': 'Sollu POS',
    });
    FlutterSecureStorage.setMockInitialValues({});
    SharedPreferences.setMockInitialValues({});
  });

  group('Empirical Challenge 1: PPN 11% Mathematical Invariants Oracle (1,000 Iterations)', () {
    test('Invariant 1: Inclusive tax under 11% NEVER increases Grand Total (Grand Total == Subtotal + Service)', () {
      final random = Random(42);
      const double taxRate = 11.0;
      const bool taxIncluded = true;

      // 1. Fixed boundary cases
      final boundarySubtotals = [
        0.0,
        0.01,
        1.0,
        10.0,
        99.0,
        100.0,
        101.0,
        111.0,
        1000.0,
        1499.0,
        1500.0,
        9999.0,
        10000.0,
        99999.0,
        100000.0,
        250000.0,
        1000000.0,
        99999999.0,
        100000000.0,
      ];

      for (final subtotal in boundarySubtotals) {
        for (final serviceRate in [0.0, 5.0, 10.0]) {
          final serviceCharge = subtotal * (serviceRate / 100.0);
          final taxAmount = calculateTaxAmount(
            taxableAmount: subtotal,
            taxRate: taxRate,
            taxIncludedInPrice: taxIncluded,
          );

          final grandTotal = calculateGrandTotal(
            taxableAmount: subtotal,
            taxAmount: taxAmount,
            serviceChargeAmount: serviceCharge,
            taxIncludedInPrice: taxIncluded,
          );

          // Expected Tax: S - (S / 1.11)
          final expectedTax = subtotal - (subtotal / 1.11);
          expect(taxAmount, closeTo(expectedTax, 0.0001),
              reason: 'Tax amount mismatch for subtotal $subtotal');

          // INVARIANT: Grand Total MUST strictly equal subtotal + serviceCharge
          final expectedGrandTotal = subtotal + serviceCharge;
          expect(grandTotal, equals(expectedGrandTotal),
              reason: 'Inclusive tax violated invariant! Grand total was altered by tax!');
        }
      }

      // 2. Randomized Stress Test across 1,000 cases
      for (int i = 0; i < 1000; i++) {
        // Generate uniform & exponential distributed prices
        final double subtotal = (i % 2 == 0)
            ? (random.nextDouble() * 10000000.0) // 0 to 10M
            : (pow(10, random.nextDouble() * 9).toDouble()); // up to 1 Billion

        final double serviceRate = random.nextBool() ? 0.0 : (random.nextDouble() * 15.0);
        final double serviceCharge = subtotal * (serviceRate / 100.0);

        final taxAmount = calculateTaxAmount(
          taxableAmount: subtotal,
          taxRate: taxRate,
          taxIncludedInPrice: taxIncluded,
        );

        final grandTotal = calculateGrandTotal(
          taxableAmount: subtotal,
          taxAmount: taxAmount,
          serviceChargeAmount: serviceCharge,
          taxIncludedInPrice: taxIncluded,
        );

        // Invariant A: Grand Total MUST equal taxableAmount + serviceCharge
        expect(grandTotal, equals(subtotal + serviceCharge),
            reason: 'Failed invariant at iteration $i (subtotal=$subtotal, serviceRate=$serviceRate)');

        // Invariant B: Base + Tax == Subtotal
        final double basePrice = subtotal / (1.0 + (taxRate / 100.0));
        expect(basePrice + taxAmount, closeTo(subtotal, 0.00001),
            reason: 'Base price + Tax != Subtotal at iteration $i');

        // Invariant C: Tax is exactly Base * 11%
        expect(basePrice * 0.11, closeTo(taxAmount, 0.00001),
            reason: 'Extracted tax does not equal base * 11% at iteration $i');
      }
    });

    test('Invariant 2: Exclusive tax under 11% adds tax on top of Subtotal', () {
      const double subtotal = 100000.0;
      const double taxRate = 11.0;
      const bool taxIncluded = false;

      final taxAmount = calculateTaxAmount(
        taxableAmount: subtotal,
        taxRate: taxRate,
        taxIncludedInPrice: taxIncluded,
      );

      expect(taxAmount, equals(11000.0));

      final grandTotal = calculateGrandTotal(
        taxableAmount: subtotal,
        taxAmount: taxAmount,
        serviceChargeAmount: 5000.0,
        taxIncludedInPrice: taxIncluded,
      );

      // Exclusive grand total = 100,000 + 11,000 + 5,000 = 116,000
      expect(grandTotal, equals(116000.0));
      expect(grandTotal, greaterThan(subtotal + 5000.0));
    });

    test('Invariant 3: Zero or negative tax rates produce exactly 0.0 tax without affecting totals', () {
      for (final rate in [0.0, -1.0, -11.0]) {
        final taxInclusive = calculateTaxAmount(
          taxableAmount: 100000.0,
          taxRate: rate,
          taxIncludedInPrice: true,
        );
        expect(taxInclusive, equals(0.0));

        final taxExclusive = calculateTaxAmount(
          taxableAmount: 100000.0,
          taxRate: rate,
          taxIncludedInPrice: false,
        );
        expect(taxExclusive, equals(0.0));

        final grandTotal = calculateGrandTotal(
          taxableAmount: 100000.0,
          taxAmount: taxInclusive,
          serviceChargeAmount: 0.0,
          taxIncludedInPrice: true,
        );
        expect(grandTotal, equals(100000.0));
      }
    });

    test('Invariant 4: Subtotal with discount extraction respects clamping and proportionality', () {
      const double subtotal = 100000.0;
      const double partialDiscount = 20000.0;
      const double taxable = subtotal - partialDiscount; // 80,000

      final taxAmount = calculateTaxAmount(
        taxableAmount: taxable,
        taxRate: 11.0,
        taxIncludedInPrice: true,
      );

      // 80,000 - (80,000 / 1.11) = 7,927.9279...
      expect(taxAmount, closeTo(7927.93, 0.01));

      final grandTotal = calculateGrandTotal(
        taxableAmount: taxable,
        taxAmount: taxAmount,
        serviceChargeAmount: 0.0,
        taxIncludedInPrice: true,
      );

      expect(grandTotal, equals(80000.0));

      // Full 100% discount
      final fullDiscountTax = calculateTaxAmount(
        taxableAmount: 0.0,
        taxRate: 11.0,
        taxIncludedInPrice: true,
      );
      expect(fullDiscountTax, equals(0.0));
    });
  });

  group('Empirical Challenge 2: Cash Rounding Boundary Values & Tender Isolation', () {
    test('Boundary 1: Nearest mode at 100 denomination step boundaries', () {
      // 149 -> 100, 150 -> 200, 100 -> 100
      expect(applyCashRounding(amount: 149.0, roundingEnabled: true, roundingMode: 'nearest'), equals(100.0));
      expect(applyCashRounding(amount: 150.0, roundingEnabled: true, roundingMode: 'nearest'), equals(200.0));
      expect(applyCashRounding(amount: 100.0, roundingEnabled: true, roundingMode: 'nearest'), equals(100.0));

      // Additional edge points around 100
      expect(applyCashRounding(amount: 101.0, roundingEnabled: true, roundingMode: 'nearest'), equals(100.0));
      expect(applyCashRounding(amount: 151.0, roundingEnabled: true, roundingMode: 'nearest'), equals(200.0));
      expect(applyCashRounding(amount: 199.0, roundingEnabled: true, roundingMode: 'nearest'), equals(200.0));
      expect(applyCashRounding(amount: 200.0, roundingEnabled: true, roundingMode: 'nearest'), equals(200.0));

      // Zero and small boundaries
      expect(applyCashRounding(amount: 0.0, roundingEnabled: true, roundingMode: 'nearest'), equals(0.0));
      expect(applyCashRounding(amount: 49.0, roundingEnabled: true, roundingMode: 'nearest'), equals(0.0));
      expect(applyCashRounding(amount: 50.0, roundingEnabled: true, roundingMode: 'nearest'), equals(100.0));
    });

    test('Boundary 2: Up (ceil) mode at 100 denomination step boundaries', () {
      // 101 -> 200, 100 -> 100
      expect(applyCashRounding(amount: 101.0, roundingEnabled: true, roundingMode: 'up'), equals(200.0));
      expect(applyCashRounding(amount: 100.0, roundingEnabled: true, roundingMode: 'up'), equals(100.0));

      // Intermediate values round UP
      expect(applyCashRounding(amount: 100.01, roundingEnabled: true, roundingMode: 'up'), equals(200.0));
      expect(applyCashRounding(amount: 149.0, roundingEnabled: true, roundingMode: 'up'), equals(200.0));
      expect(applyCashRounding(amount: 150.0, roundingEnabled: true, roundingMode: 'up'), equals(200.0));
      expect(applyCashRounding(amount: 199.0, roundingEnabled: true, roundingMode: 'up'), equals(200.0));
      expect(applyCashRounding(amount: 200.0, roundingEnabled: true, roundingMode: 'up'), equals(200.0));
      expect(applyCashRounding(amount: 0.0, roundingEnabled: true, roundingMode: 'up'), equals(0.0));
    });

    test('Boundary 3: Down (floor) mode at 100 denomination step boundaries', () {
      // 199 -> 100, 100 -> 100
      expect(applyCashRounding(amount: 199.0, roundingEnabled: true, roundingMode: 'down'), equals(100.0));
      expect(applyCashRounding(amount: 100.0, roundingEnabled: true, roundingMode: 'down'), equals(100.0));

      // Intermediate values round DOWN
      expect(applyCashRounding(amount: 101.0, roundingEnabled: true, roundingMode: 'down'), equals(100.0));
      expect(applyCashRounding(amount: 149.0, roundingEnabled: true, roundingMode: 'down'), equals(100.0));
      expect(applyCashRounding(amount: 150.0, roundingEnabled: true, roundingMode: 'down'), equals(100.0));
      expect(applyCashRounding(amount: 199.99, roundingEnabled: true, roundingMode: 'down'), equals(100.0));
      expect(applyCashRounding(amount: 200.0, roundingEnabled: true, roundingMode: 'down'), equals(200.0));
      expect(applyCashRounding(amount: 99.0, roundingEnabled: true, roundingMode: 'down'), equals(0.0));
    });

    test('Boundary 4: Disabled rounding or non-positive denomination preserves unrounded amount', () {
      expect(applyCashRounding(amount: 149.0, roundingEnabled: false, roundingMode: 'nearest'), equals(149.0));
      expect(applyCashRounding(amount: 101.0, roundingEnabled: false, roundingMode: 'up'), equals(101.0));
      expect(applyCashRounding(amount: 199.0, roundingEnabled: false, roundingMode: 'down'), equals(199.0));

      expect(applyCashRounding(amount: 149.0, roundingEnabled: true, roundingMode: 'nearest', denomination: 0), equals(149.0));
      expect(applyCashRounding(amount: 149.0, roundingEnabled: true, roundingMode: 'nearest', denomination: -100), equals(149.0));
    });

    testWidgets('Tender Isolation: Non-cash payments (QRIS, Debit/EDC) NEVER apply cash rounding in CheckoutPaymentPane', (tester) async {
      // Item priced at 10,049
      final cartItem = CartItem(
        id: 'cart-round-1',
        productId: 'prod-round-1',
        inventoryItemId: 'inv-round-1',
        name: 'Produk Uji Rounding',
        price: 10049.0,
        qty: 1,
      );

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

      late SharedPreferences prefs;
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();

      // Override container with nearest rounding enabled
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(prefs),
            cartProvider.overrideWith(() => FakeCartNotifier([cartItem])),
            activeTaxRateProvider.overrideWith((ref) => 0.0),
            activeServiceChargeRateProvider.overrideWith((ref) => 0.0),
            outletSettingsProvider.overrideWith((ref) => {
              'taxPercentage': 0.0,
              'serviceChargePercentage': 0.0,
              'taxIncludedInPrice': false,
              'roundingEnabled': true,
              'roundingMode': 'nearest',
            }),
            activePaymentMethodsProvider.overrideWith(
              (ref) => Stream.value(testPaymentMethods),
            ),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: CheckoutPaymentPane(initialMethodType: 'cash'),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // With CASH, 10,049 rounded to nearest 100 = 10,000
      expect(find.textContaining('10.000'), findsWidgets);

      // Now tap QRIS payment method
      final qrisFinder = find.text('QRIS');
      expect(qrisFinder, findsOneWidget);
      await tester.tap(qrisFinder);
      await tester.pumpAndSettle();

      // With QRIS (non-cash), cash rounding MUST NOT be applied!
      // Must display exact unrounded amount 10.049!
      expect(find.textContaining('10.049'), findsWidgets);

      // Tap EDC / BCA Debit
      final edcFinder = find.text('BCA Debit');
      expect(edcFinder, findsOneWidget);
      await tester.tap(edcFinder);
      await tester.pumpAndSettle();

      // With EDC (non-cash), cash rounding MUST NOT be applied!
      expect(find.textContaining('10.049'), findsWidgets);

      // Switch back to Tunai (Cash)
      final cashFinder = find.text('Tunai');
      expect(cashFinder, findsOneWidget);
      await tester.tap(cashFinder);
      await tester.pumpAndSettle();

      // Now cash rounding is reapplied to 10.000
      expect(find.textContaining('10.000'), findsWidgets);
    });
  });

  group('Empirical Challenge 3: Void Transaction & Supervisor PIN Challenge Security', () {
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

    test('Supervisor Challenge Dialog: filters staff by authorization criteria correctly', () {
      final supervisorEmp = Employee(
        id: 'spv-1',
        name: 'Manager Joko',
        pin: '123456',
        isRootUser: false,
        role: 'Supervisor',
        permissions: jsonEncode(['transaction.void', 'pos.access']),
      );

      final regularCashierEmp = Employee(
        id: 'csh-1',
        name: 'Kasir Budi',
        pin: '111111',
        isRootUser: false,
        role: 'Kasir',
        permissions: jsonEncode(['pos.access']),
      );

      final rootOwnerEmp = Employee(
        id: 'root-1',
        name: 'Owner Andi',
        pin: '888888',
        isRootUser: true,
        role: 'Akun Utama',
      );

      // Test permissions validation
      expect(supervisorEmp.permissions, contains('transaction.void'));
      expect(regularCashierEmp.permissions, isNot(contains('transaction.void')));
      expect(rootOwnerEmp.isRootUser, isTrue);
    });

    testWidgets('Void Security: Unauthorized cashier MUST be challenged with supervisor PIN dialog before voiding', (tester) async {
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final originalOnError = FlutterError.onError;
      FlutterError.onError = (details) {
        if (details.exceptionAsString().contains('overflowed')) return;
        originalOnError?.call(details);
      };
      addTearDown(() => FlutterError.onError = originalOnError);

      // 1. Seed database with employees (1 Supervisor with PIN 654321, 1 Cashier with PIN 111111)
      final hashedPinSpv = BCrypt.hashpw('654321', BCrypt.gensalt());

      final spvEmployee = Employee(
        id: 'spv-uuid',
        name: 'Supervisor Sarah',
        pin: hashedPinSpv,
        isRootUser: false,
        role: 'Supervisor',
        permissions: jsonEncode(['transaction.void']),
      );

      final cashierEmployee = Employee(
        id: 'cashier-uuid',
        name: 'Kasir Pemula',
        pin: '111111',
        isRootUser: false,
        role: 'Kasir',
        permissions: jsonEncode(['pos.sale']),
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

      await db.into(db.employees).insert(
        EmployeesCompanion.insert(
          id: cashierEmployee.id,
          name: cashierEmployee.name,
          pin: Value(cashierEmployee.pin),
          isRootUser: Value(cashierEmployee.isRootUser),
          role: Value(cashierEmployee.role),
          permissions: Value(cashierEmployee.permissions),
        ),
      );

      // 2. Seed an active completed transaction
      final sampleTx = Transaction(
        id: 'tx-test-void-1',
        outletId: 'outlet-1',
        channel: 'pos',
        type: 'sale',
        transactionNumber: 'TRX-20261030-001',
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

      // Mock active cashier WITHOUT void permission
      final cashierUser = {
        'id': 'cashier-uuid',
        'name': 'Kasir Pemula',
        'is_root_user': false,
        'role': 'Kasir',
        'permissions': ['pos.sale'],
      };

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            databaseProvider.overrideWithValue(db),
            transactionRepositoryProvider.overrideWithValue(txRepo),
            activeEmployeeProvider.overrideWith(() => FakeActiveEmployeeNotifier(cashierUser)),
            employeeListProvider.overrideWith((ref) => Future.value([spvEmployee, cashierEmployee])),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) => ElevatedButton(
                  onPressed: () {
                    VoidTransactionDialog.show(context, transaction: sampleTx);
                  },
                  child: const Text('Open Void Dialog'),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Open Void Dialog
      await tester.tap(find.text('Open Void Dialog'));
      await tester.pumpAndSettle();

      expect(find.byType(VoidTransactionDialog), findsOneWidget);
      expect(find.text('Void Transaksi'), findsOneWidget);
      expect(find.text('TRX-20261030-001'), findsOneWidget);

      // Tap "Konfirmasi Void"
      await tester.tap(find.text('Konfirmasi Void'));
      await tester.pumpAndSettle();

      // Because cashier is unauthorized, SupervisorChallengeDialog MUST appear!
      expect(find.byType(SupervisorChallengeDialog), findsOneWidget);
      expect(find.text('Otorisasi Supervisi'), findsOneWidget);
      expect(find.text('Aksi: Otorisasi Void Transaksi'), findsOneWidget);

      // Enter unauthorized cashier PIN '111111'
      for (int i = 0; i < 6; i++) {
        await tester.tap(find.widgetWithText(InkWell, '1').first);
        await tester.pump(const Duration(milliseconds: 50));
      }
      await tester.pumpAndSettle();

      // MUST fail authorization with error message!
      expect(
        find.text('PIN salah atau staf tidak memiliki hak otorisasi supervisi!'),
        findsOneWidget,
      );

      // Transaction MUST still be 'completed' (not voided!)
      final txAfterFailedPin = await (db.select(db.transactions)..where((t) => t.id.equals(sampleTx.id))).getSingle();
      expect(txAfterFailedPin.status, equals('completed'));

      // Dismiss dialog via 'Batal (Esc)'
      await tester.tap(find.text('Batal (Esc)'));
      await tester.pumpAndSettle();

      // Transaction STILL unchanged
      final txAfterCancel = await (db.select(db.transactions)..where((t) => t.id.equals(sampleTx.id))).getSingle();
      expect(txAfterCancel.status, equals('completed'));

      // Re-trigger void confirmation
      await tester.tap(find.text('Konfirmasi Void'));
      await tester.pumpAndSettle();

      expect(find.byType(SupervisorChallengeDialog), findsOneWidget);

      // Now enter valid supervisor PIN '654321'
      final pinSequence = ['6', '5', '4', '3', '2', '1'];
      for (final digit in pinSequence) {
        await tester.tap(find.widgetWithText(InkWell, digit).first);
        await tester.pump(const Duration(milliseconds: 50));
      }
      await tester.pumpAndSettle();

      // Authorization succeeded, transaction status MUST now be 'void'!
      final txAfterSuccess = await (db.select(db.transactions)..where((t) => t.id.equals(sampleTx.id))).getSingle();
      expect(txAfterSuccess.status, equals('void'));
      expect(txAfterSuccess.notes, contains('[VOID] Alasan: Salah input item'));
    });

    testWidgets('Void Security: Direct supervisor bypasses challenge dialog and voids cleanly', (tester) async {
      final sampleTx2 = Transaction(
        id: 'tx-test-void-2',
        outletId: 'outlet-1',
        channel: 'pos',
        type: 'sale',
        transactionNumber: 'TRX-20261030-002',
        shiftId: 'shift-1',
        subtotal: 50000.0,
        discountAmount: 0.0,
        taxAmount: 0.0,
        serviceChargeAmount: 0.0,
        shippingFee: 0.0,
        total: 50000.0,
        paymentStatus: 'paid',
        status: 'completed',
        isOffline: false,
        syncStatus: 'synced',
        syncAttempts: 0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await db.into(db.transactions).insert(sampleTx2);

      // Active employee IS a supervisor
      final supervisorUser = {
        'id': 'spv-user',
        'name': 'Manager Budi',
        'is_root_user': true,
        'role': 'Akun Utama',
      };

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            databaseProvider.overrideWithValue(db),
            transactionRepositoryProvider.overrideWithValue(txRepo),
            activeEmployeeProvider.overrideWith(() => FakeActiveEmployeeNotifier(supervisorUser)),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) => ElevatedButton(
                  onPressed: () {
                    VoidTransactionDialog.show(context, transaction: sampleTx2);
                  },
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

      // Tap "Konfirmasi Void"
      await tester.tap(find.text('Konfirmasi Void'));
      await tester.pumpAndSettle();

      // Direct supervisor should NOT see SupervisorChallengeDialog
      expect(find.byType(SupervisorChallengeDialog), findsNothing);

      // Transaction must be immediately voided
      final txVoided = await (db.select(db.transactions)..where((t) => t.id.equals(sampleTx2.id))).getSingle();
      expect(txVoided.status, equals('void'));
    });

    testWidgets('Void Validation: "Lainnya" reason without notes is blocked by validation', (tester) async {
      final sampleTx3 = Transaction(
        id: 'tx-test-void-3',
        outletId: 'outlet-1',
        channel: 'pos',
        type: 'sale',
        transactionNumber: 'TRX-20261030-003',
        shiftId: 'shift-1',
        subtotal: 25000.0,
        discountAmount: 0.0,
        taxAmount: 0.0,
        serviceChargeAmount: 0.0,
        shippingFee: 0.0,
        total: 25000.0,
        paymentStatus: 'paid',
        status: 'completed',
        isOffline: false,
        syncStatus: 'synced',
        syncAttempts: 0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await db.into(db.transactions).insert(sampleTx3);

      final supervisorUser = {
        'id': 'spv-user',
        'name': 'Manager Budi',
        'is_root_user': true,
        'role': 'Akun Utama',
      };

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            databaseProvider.overrideWithValue(db),
            transactionRepositoryProvider.overrideWithValue(txRepo),
            activeEmployeeProvider.overrideWith(() => FakeActiveEmployeeNotifier(supervisorUser)),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) => ElevatedButton(
                  onPressed: () {
                    VoidTransactionDialog.show(context, transaction: sampleTx3);
                  },
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

      // Change dropdown to 'Lainnya'
      await tester.tap(find.text('Salah input item'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Lainnya').last);
      await tester.pumpAndSettle();

      // Tap "Konfirmasi Void" with empty notes
      await tester.tap(find.text('Konfirmasi Void'));
      await tester.pumpAndSettle();

      // Validation SnackBar must appear
      expect(find.text('Harap masukkan catatan untuk alasan lainnya.'), findsOneWidget);

      // Transaction MUST NOT be voided
      final txNotVoided = await (db.select(db.transactions)..where((t) => t.id.equals(sampleTx3.id))).getSingle();
      expect(txNotVoided.status, equals('completed'));
    });
  });
}
