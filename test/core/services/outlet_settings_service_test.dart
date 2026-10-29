import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sollu_pos_client/core/services/outlet_settings_service.dart';
import 'package:sollu_pos_client/core/providers/preferences_provider.dart';
import 'package:sollu_pos_client/features/settings/presentation/providers/outlet_settings_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('OutletSettingsService & enableSupervisorPinProvider', () {
    test('defaults enable_supervisor_pin to false when absent', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final service = OutletSettingsService(prefs);

      await service.syncSettingsPayload(data: {
        'settings': {
          'tax_percentage': 10.0,
        },
      });

      expect(service.isSupervisorPinEnabled(), false);

      final container = ProviderContainer(
        overrides: [
          outletSettingsServiceProvider.overrideWithValue(service),
        ],
      );

      expect(container.read(enableSupervisorPinProvider), false);
    });

    test('stores and reads enable_supervisor_pin when true in payload', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final service = OutletSettingsService(prefs);

      await service.syncSettingsPayload(data: {
        'settings': {
          'enable_supervisor_pin': true,
          'tax_percentage': 10.0,
        },
      });

      expect(service.isSupervisorPinEnabled(), true);

      final container = ProviderContainer(
        overrides: [
          outletSettingsServiceProvider.overrideWithValue(service),
        ],
      );

      expect(container.read(enableSupervisorPinProvider), true);
    });
  });
}
