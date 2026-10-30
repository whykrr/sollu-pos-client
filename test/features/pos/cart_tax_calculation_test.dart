import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sollu_pos_client/features/pos/presentation/providers/cart_provider.dart';
import 'package:sollu_pos_client/features/pos/presentation/widgets/checkout_cart_pane.dart';
import 'package:sollu_pos_client/features/settings/presentation/providers/outlet_settings_provider.dart';

class FakeCartNotifier extends CartNotifier {
  final List<CartItem> items;
  FakeCartNotifier(this.items);

  @override
  List<CartItem> build() => items;
}

void main() {
  group('Inclusive Tax 11% Domain Calculation Tests', () {
    test('extracts inclusive tax correctly without double taxation', () {
      const double subtotal = 100000.0;
      const double taxRate = 11.0;
      const bool taxIncluded = true;

      final taxAmount = calculateTaxAmount(
        taxableAmount: subtotal,
        taxRate: taxRate,
        taxIncludedInPrice: taxIncluded,
      );

      // Tax extracted = 100,000 - (100,000 / 1.11) = 9,909.9099...
      expect(taxAmount, closeTo(9909.91, 0.01));

      final grandTotal = calculateGrandTotal(
        taxableAmount: subtotal,
        taxAmount: taxAmount,
        serviceChargeAmount: 0.0,
        taxIncludedInPrice: taxIncluded,
      );

      // Grand total MUST equal subtotal (no tax added on top)
      expect(grandTotal, equals(100000.0));
    });

    test('calculates exclusive tax correctly by adding tax to grand total', () {
      const double subtotal = 100000.0;
      const double taxRate = 11.0;
      const bool taxIncluded = false;

      final taxAmount = calculateTaxAmount(
        taxableAmount: subtotal,
        taxRate: taxRate,
        taxIncludedInPrice: taxIncluded,
      );

      // 11% of 100,000 = 11,000
      expect(taxAmount, equals(11000.0));

      final grandTotal = calculateGrandTotal(
        taxableAmount: subtotal,
        taxAmount: taxAmount,
        serviceChargeAmount: 0.0,
        taxIncludedInPrice: taxIncluded,
      );

      // Grand total = 100,000 + 11,000 = 111,000
      expect(grandTotal, equals(111000.0));
    });

    test('extracts inclusive tax correctly with item discount applied', () {
      const double subtotal = 100000.0;
      const double discount = 10000.0;
      const double taxRate = 11.0;
      const bool taxIncluded = true;

      final taxable = subtotal - discount; // 90,000
      final taxAmount = calculateTaxAmount(
        taxableAmount: taxable,
        taxRate: taxRate,
        taxIncludedInPrice: taxIncluded,
      );

      // 90,000 - (90,000 / 1.11) = 8,918.9189...
      expect(taxAmount, closeTo(8918.92, 0.01));

      final grandTotal = calculateGrandTotal(
        taxableAmount: taxable,
        taxAmount: taxAmount,
        serviceChargeAmount: 0.0,
        taxIncludedInPrice: taxIncluded,
      );

      expect(grandTotal, equals(90000.0));
    });

    test('calculates inclusive tax with service charge correctly', () {
      const double subtotal = 100000.0;
      const double taxRate = 11.0;
      const double serviceRate = 5.0; // 5% = 5,000
      const bool taxIncluded = true;

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

      // Grand total = 100,000 + 5,000 = 105,000
      expect(grandTotal, equals(105000.0));
    });
  });

  group('Cash Rounding Calculation Tests', () {
    test('nearest mode rounds to nearest 100 denomination', () {
      expect(applyCashRounding(amount: 10049.0, roundingEnabled: true, roundingMode: 'nearest'), equals(10000.0));
      expect(applyCashRounding(amount: 10050.0, roundingEnabled: true, roundingMode: 'nearest'), equals(10100.0));
      expect(applyCashRounding(amount: 10099.0, roundingEnabled: true, roundingMode: 'nearest'), equals(10100.0));
    });

    test('up mode rounds up to ceiling 100 denomination', () {
      expect(applyCashRounding(amount: 10001.0, roundingEnabled: true, roundingMode: 'up'), equals(10100.0));
      expect(applyCashRounding(amount: 10049.0, roundingEnabled: true, roundingMode: 'up'), equals(10100.0));
      expect(applyCashRounding(amount: 10000.0, roundingEnabled: true, roundingMode: 'up'), equals(10000.0));
    });

    test('down mode rounds down to floor 100 denomination', () {
      expect(applyCashRounding(amount: 10099.0, roundingEnabled: true, roundingMode: 'down'), equals(10000.0));
      expect(applyCashRounding(amount: 10050.0, roundingEnabled: true, roundingMode: 'down'), equals(10000.0));
      expect(applyCashRounding(amount: 10000.0, roundingEnabled: true, roundingMode: 'down'), equals(10000.0));
    });

    test('disabled rounding returns raw unrounded amount', () {
      expect(applyCashRounding(amount: 10049.0, roundingEnabled: false, roundingMode: 'nearest'), equals(10049.0));
      expect(applyCashRounding(amount: 10001.0, roundingEnabled: false, roundingMode: 'up'), equals(10001.0));
    });
  });

  group('CheckoutCartPane Inclusive Tax Widget Tests', () {
    testWidgets('CheckoutCartPane computes and displays inclusive tax breakdown without inflating total', (tester) async {
      final cartItem = CartItem(
        id: 'cart-1',
        productId: 'prod-1',
        inventoryItemId: 'inv-1',
        name: 'Kopi Kenangan Mantan',
        price: 100000.0,
        qty: 1,
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            cartProvider.overrideWith(() => FakeCartNotifier([cartItem])),
            activeTaxRateProvider.overrideWith((ref) => 11.0),
            activeServiceChargeRateProvider.overrideWith((ref) => 0.0),
            outletSettingsProvider.overrideWith((ref) => {
              'taxPercentage': 11.0,
              'serviceChargePercentage': 0.0,
              'taxIncludedInPrice': true,
              'roundingEnabled': false,
            }),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: CheckoutCartPane(),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Subtotal should be present
      expect(find.text('Subtotal'), findsOneWidget);

      // Verify extracted tax breakdown label and value
      expect(find.text('Pajak Inklusif (11%)'), findsOneWidget);

      // Verify Grand Total remains exactly Rp 100.000 without tax inflation
      expect(find.text('Total Tagihan'), findsOneWidget);
      expect(find.text('Rp 100.000'), findsNWidgets(3)); // Item price, Subtotal & Total Tagihan

      // Verify widget renders without error
      expect(find.byType(CheckoutCartPane), findsOneWidget);
    });
  });
}
