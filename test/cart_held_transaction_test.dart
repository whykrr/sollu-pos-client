import 'dart:convert';
import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sollu_pos_client/core/database/app_database.dart';
import 'package:sollu_pos_client/features/pos/data/database/daos/held_bills_dao.dart';
import 'package:sollu_pos_client/features/pos/presentation/providers/cart_provider.dart';

void main() {
  group('CartItem Serialization Tests', () {
    test('toJson and fromJson serializes and deserializes correctly', () {
      final originalItem = CartItem(
        id: 'cart-item-1',
        productId: 'prod-101',
        inventoryItemId: 'inv-202',
        variantGroupOptionId: 'vgo-303',
        name: 'Kopi Susu Gula Aren',
        price: 25000.0,
        qty: 3,
        discountType: 'percentage',
        discountValue: 10.0,
        notes: 'Less sugar, less ice',
        selectedVariants: {'Size': 'Large', 'Bean': 'Arabica'},
        selectedModifiers: {
          'Extra Shot': ['1 Shot'],
        },
      );

      final jsonMap = originalItem.toJson();
      final jsonString = jsonEncode(jsonMap);
      final decodedMap = jsonDecode(jsonString) as Map<String, dynamic>;
      final restoredItem = CartItem.fromJson(decodedMap);

      expect(restoredItem.id, originalItem.id);
      expect(restoredItem.productId, originalItem.productId);
      expect(restoredItem.inventoryItemId, originalItem.inventoryItemId);
      expect(restoredItem.variantGroupOptionId, originalItem.variantGroupOptionId);
      expect(restoredItem.name, originalItem.name);
      expect(restoredItem.price, originalItem.price);
      expect(restoredItem.qty, originalItem.qty);
      expect(restoredItem.discountType, originalItem.discountType);
      expect(restoredItem.discountValue, originalItem.discountValue);
      expect(restoredItem.notes, originalItem.notes);
      expect(restoredItem.selectedVariants, originalItem.selectedVariants);
      expect(restoredItem.selectedModifiers, originalItem.selectedModifiers);
    });
  });

  group('HeldBillsDao In-Memory Database Tests', () {
    late AppDatabase db;
    late HeldBillsDao dao;

    setUp(() {
      db = AppDatabase.forTesting(NativeDatabase.memory());
      dao = HeldBillsDao(db);
    });

    tearDown(() async {
      await db.close();
    });

    test('insertHeldTransaction, getHeldTransactionById, and deleteHeldTransaction work', () async {
      final heldId = 'held-uuid-v7-001';
      final outletId = 'outlet-test-123';

      final cartItems = [
        CartItem(
          id: 'item-1',
          productId: 'prod-1',
          inventoryItemId: 'inv-1',
          name: 'Latte',
          price: 30000.0,
          qty: 2,
        ),
      ];

      final cartPayload = jsonEncode(cartItems.map((e) => e.toJson()).toList());

      await dao.insertHeldTransaction(
        HeldTransactionsCompanion.insert(
          id: heldId,
          outletId: outletId,
          holdLabel: 'Meja 5 - Budi',
          customerName: const Value('Budi'),
          tableNumber: const Value('5'),
          subtotal: 60000.0,
          total: 60000.0,
          cartPayload: cartPayload,
          heldAt: DateTime.now(),
        ),
      );

      final retrieved = await dao.getHeldTransactionById(heldId);
      expect(retrieved, isNotNull);
      expect(retrieved!.id, heldId);
      expect(retrieved.holdLabel, 'Meja 5 - Budi');
      expect(retrieved.customerName, 'Budi');
      expect(retrieved.tableNumber, '5');
      expect(retrieved.total, 60000.0);

      // Verify deserializing cartPayload back to CartItem
      final decodedList = (jsonDecode(retrieved.cartPayload) as List)
          .map((item) => CartItem.fromJson(item as Map<String, dynamic>))
          .toList();
      expect(decodedList.length, 1);
      expect(decodedList.first.name, 'Latte');
      expect(decodedList.first.qty, 2);

      // Verify deletion
      await dao.deleteHeldTransaction(heldId);
      final afterDelete = await dao.getHeldTransactionById(heldId);
      expect(afterDelete, isNull);
    });
  });
}
