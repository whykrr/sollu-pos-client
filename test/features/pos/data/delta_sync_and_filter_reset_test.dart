import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sollu_pos_client/features/pos/presentation/providers/pos_provider.dart';

void main() {
  group('POS Catalog Filter Reset Tests', () {
    test('posSearchQueryProvider and posSelectedCategoryProvider reset properly', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      // 1. Initial states should be default (empty query and null category)
      expect(container.read(posSearchQueryProvider), '');
      expect(container.read(posSelectedCategoryProvider), isNull);

      // 2. Set search query and category filter
      container.read(posSearchQueryProvider.notifier).setQuery('kopi susu');
      container.read(posSelectedCategoryProvider.notifier).setCategory('cat-beverages-01');

      expect(container.read(posSearchQueryProvider), 'kopi susu');
      expect(container.read(posSelectedCategoryProvider), 'cat-beverages-01');

      // 3. Reset filters (simulating checkout completion / "Transaksi Baru")
      container.read(posSelectedCategoryProvider.notifier).setCategory(null);
      container.read(posSearchQueryProvider.notifier).setQuery('');

      expect(container.read(posSearchQueryProvider), '');
      expect(container.read(posSelectedCategoryProvider), isNull);
    });
  });

  group('POS Reverb Nudge Entity Parsing Tests', () {
    test('parses entities array correctly from nudge payload', () {
      final payloadJson = jsonEncode({
        'event': 'pos.catalog.nudge',
        'data': {
          'outlet_id': 'outlet-uuid-1',
          'entities': ['product', 'product_price', 'product_item'],
          'entity_type': 'product,product_price,product_item',
        },
      });

      final Map<String, dynamic> msg = jsonDecode(payloadJson);
      final dynamic rawData = msg['data'];
      final Map<String, dynamic> data =
          rawData is String ? jsonDecode(rawData) : Map<String, dynamic>.from(rawData);

      List<String> entities = [];
      if (data['entities'] is List) {
        entities = (data['entities'] as List)
            .map((e) => e.toString().trim())
            .where((e) => e.isNotEmpty)
            .toList();
      } else if (data['entity_type'] != null) {
        entities = data['entity_type']
            .toString()
            .split(',')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList();
      }

      expect(entities, equals(['product', 'product_price', 'product_item']));
    });

    test('falls back to entity_type string if entities array is missing', () {
      final payloadJson = jsonEncode({
        'event': 'pos.catalog.nudge',
        'data': {
          'outlet_id': 'outlet-uuid-1',
          'entity_type': 'inventory_balance',
        },
      });

      final Map<String, dynamic> msg = jsonDecode(payloadJson);
      final dynamic rawData = msg['data'];
      final Map<String, dynamic> data =
          rawData is String ? jsonDecode(rawData) : Map<String, dynamic>.from(rawData);

      List<String> entities = [];
      if (data['entities'] is List) {
        entities = (data['entities'] as List)
            .map((e) => e.toString().trim())
            .where((e) => e.isNotEmpty)
            .toList();
      } else if (data['entity_type'] != null) {
        entities = data['entity_type']
            .toString()
            .split(',')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList();
      }

      expect(entities, equals(['inventory_balance']));
    });
  });
}
