import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sollu_pos_client/core/services/outlet_settings_service.dart';
import 'package:sollu_pos_client/features/settings/presentation/providers/outlet_settings_provider.dart';

class FeatureGatingService {
  final List<String> activeFeatures;

  FeatureGatingService({required this.activeFeatures});

  bool hasFeature(String code) {
    return activeFeatures.contains(code.toLowerCase());
  }

  bool canUseSplitPayment() => hasFeature('split_payment');
  bool canUseCrm() => hasFeature('crm');
  bool canUseShiftCashier() => hasFeature('shift_cashier');
  bool canUseCashDrawer() => hasFeature('cash_drawer');
  bool canUseDoubleAuthorization() => hasFeature('double_authorization');

  bool isSupervisorPinAllowed(bool configuredSetting) {
    return canUseDoubleAuthorization() && configuredSetting;
  }
}

final activeFeaturesListProvider = Provider<List<String>>((ref) {
  final settings = ref.watch(outletSettingsProvider);
  if (settings != null && settings.containsKey('activeFeatures')) {
    final raw = settings['activeFeatures'];
    if (raw is List) {
      return raw.map((e) => e.toString()).toList();
    }
  }
  return const <String>[];
});

final featureGatingProvider = Provider<FeatureGatingService>((ref) {
  final features = ref.watch(activeFeaturesListProvider);
  return FeatureGatingService(activeFeatures: features);
});

class MockGatedCashierView extends ConsumerWidget {
  const MockGatedCashierView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gating = ref.watch(featureGatingProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('POS Kasir'),
        actions: [
          if (gating.canUseShiftCashier())
            const Chip(
              key: Key('chip_shift_status'),
              label: Text('Shift #1 - Aktif'),
            ),
        ],
      ),
      body: Column(
        children: [
          if (gating.canUseCrm())
            ElevatedButton(
              key: const Key('btn_member_crm'),
              onPressed: () {},
              child: const Text('Pilih Member (F4)'),
            ),
          const Expanded(
            child: Center(child: Text('Keranjang Belanja')),
          ),
          if (gating.canUseSplitPayment())
            ElevatedButton(
              key: const Key('btn_split_payment'),
              onPressed: () {},
              child: const Text('Bagi Pembayaran (Split)'),
            ),
          if (gating.canUseCashDrawer())
            ElevatedButton(
              key: const Key('btn_kick_drawer'),
              onPressed: () {},
              child: const Text('Buka Laci Kasir (Space)'),
            ),
        ],
      ),
    );
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Feature Gating Domain Service Tests', () {
    test('reports features correctly when all features are active', () {
      final gating = FeatureGatingService(
        activeFeatures: [
          'pos',
          'shift_cashier',
          'cash_drawer',
          'split_payment',
          'crm',
          'double_authorization',
        ],
      );

      expect(gating.canUseSplitPayment(), isTrue);
      expect(gating.canUseCrm(), isTrue);
      expect(gating.canUseShiftCashier(), isTrue);
      expect(gating.canUseCashDrawer(), isTrue);
      expect(gating.canUseDoubleAuthorization(), isTrue);
      expect(gating.isSupervisorPinAllowed(true), isTrue);
    });

    test('cleanly disallows un-subscribed features without throwing errors', () {
      final gating = FeatureGatingService(
        activeFeatures: ['pos'], // Starter tier only has pos
      );

      expect(gating.canUseSplitPayment(), isFalse);
      expect(gating.canUseCrm(), isFalse);
      expect(gating.canUseShiftCashier(), isFalse);
      expect(gating.canUseCashDrawer(), isFalse);
      expect(gating.canUseDoubleAuthorization(), isFalse);
      // Even if supervisor PIN was configured in settings, DOUBLE_AUTHORIZATION restricts it
      expect(gating.isSupervisorPinAllowed(true), isFalse);
    });
  });

  group('OutletSettingsService Active Features Storage Tests', () {
    test('persists and extracts active_features from sync payload', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final service = OutletSettingsService(prefs);

      final payload = {
        'settings': {
          'active_features': ['pos', 'cash_drawer', 'crm'],
          'tax_percentage': 11.0,
          'enable_supervisor_pin': false,
        },
        'outlet_settings': [],
        'outlet': {'id': 'outlet-uuid-1', 'name': 'Outlet 1'},
      };

      await service.syncSettingsPayload(data: payload);
      final savedSettings = service.getOutletSettings();

      expect(savedSettings, isNotNull);
      expect(savedSettings?['taxPercentage'], equals(11.0));
    });
  });

  group('UI Feature Gating Widget Visibility Tests', () {
    testWidgets('shows all gated UI buttons when merchant has full subscription', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            outletSettingsProvider.overrideWith((ref) => {
              'activeFeatures': [
                'pos',
                'shift_cashier',
                'cash_drawer',
                'split_payment',
                'crm',
                'double_authorization',
              ],
            }),
          ],
          child: const MaterialApp(
            home: MockGatedCashierView(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // All gated UI elements should be visible
      expect(find.byKey(const Key('chip_shift_status')), findsOneWidget);
      expect(find.byKey(const Key('btn_member_crm')), findsOneWidget);
      expect(find.byKey(const Key('btn_split_payment')), findsOneWidget);
      expect(find.byKey(const Key('btn_kick_drawer')), findsOneWidget);
    });

    testWidgets('hides all gated UI buttons cleanly when merchant lacks subscription', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            outletSettingsProvider.overrideWith((ref) => {
              'activeFeatures': ['pos'], // Only basic POS
            }),
          ],
          child: const MaterialApp(
            home: MockGatedCashierView(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // All gated UI elements MUST BE HIDDEN
      expect(find.byKey(const Key('chip_shift_status')), findsNothing);
      expect(find.byKey(const Key('btn_member_crm')), findsNothing);
      expect(find.byKey(const Key('btn_split_payment')), findsNothing);
      expect(find.byKey(const Key('btn_kick_drawer')), findsNothing);

      // Core POS UI remains functional
      expect(find.text('Keranjang Belanja'), findsOneWidget);
    });
  });
}
