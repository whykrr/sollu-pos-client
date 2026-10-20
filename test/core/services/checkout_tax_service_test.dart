import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sollu_pos_client/features/pos/presentation/providers/cart_provider.dart';
import 'package:sollu_pos_client/features/settings/presentation/providers/outlet_settings_provider.dart';
import 'package:sollu_pos_client/features/pos/presentation/widgets/checkout_cart_pane.dart';

class FakeCartNotifier extends CartNotifier {
  final List<CartItem> items;
  FakeCartNotifier(this.items);

  @override
  List<CartItem> build() => items;
}

void main() {
  testWidgets('CheckoutCartPane hides Tax and Service Charge when rates are 0', (tester) async {
    final cartItem = CartItem(
      id: 'cart-1',
      productId: 'prod-1',
      inventoryItemId: 'inv-1',
      name: 'Espresso',
      price: 20000.0,
      qty: 2,
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          cartProvider.overrideWith(() => FakeCartNotifier([cartItem])),
          activeTaxRateProvider.overrideWith((ref) => 0.0),
          activeServiceChargeRateProvider.overrideWith((ref) => 0.0),
        ],
        child: const MaterialApp(
          home: Scaffold(
            body: CheckoutCartPane(),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Subtotal should exist
    expect(find.text('Subtotal'), findsOneWidget);

    // Tax and Service lines must be HIDDEN when 0%
    expect(find.textContaining('Pajak'), findsNothing);
    expect(find.textContaining('Biaya Layanan'), findsNothing);
  });

  testWidgets('CheckoutCartPane shows Tax and Service Charge when rates > 0', (tester) async {
    final cartItem = CartItem(
      id: 'cart-1',
      productId: 'prod-1',
      inventoryItemId: 'inv-1',
      name: 'Espresso',
      price: 20000.0,
      qty: 2,
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          cartProvider.overrideWith(() => FakeCartNotifier([cartItem])),
          activeTaxRateProvider.overrideWith((ref) => 11.0),
          activeServiceChargeRateProvider.overrideWith((ref) => 5.0),
        ],
        child: const MaterialApp(
          home: Scaffold(
            body: CheckoutCartPane(),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Subtotal should exist
    expect(find.text('Subtotal'), findsOneWidget);

    // Tax and Service lines MUST appear when > 0
    expect(find.textContaining('Pajak (11%)'), findsOneWidget);
    expect(find.textContaining('Biaya Layanan (5%)'), findsOneWidget);
  });
}
