import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sollu_pos_client/core/services/outlet_settings_service.dart';
import 'package:sollu_pos_client/features/auth/presentation/providers/auth_provider.dart';
import 'package:sollu_pos_client/features/pos/presentation/providers/cart_provider.dart';

void main() {
  group('OutletSettingsService Tests', () {
    test('getAutoPrint defaults to true when not set', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final service = OutletSettingsService(prefs);

      expect(service.getAutoPrint(), isTrue);
    });

    test('saveAutoPrint toggles auto-print preference properly', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final service = OutletSettingsService(prefs);

      await service.saveAutoPrint(false);
      expect(service.getAutoPrint(), isFalse);

      await service.saveAutoPrint(true);
      expect(service.getAutoPrint(), isTrue);
    });

    test('clearAll resets autoPrint and other settings', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final service = OutletSettingsService(prefs);

      await service.saveAutoPrint(false);
      await service.clearAll();

      expect(service.getAutoPrint(), isTrue);
    });
  });

  group('ActiveEmployeePermissions Extension Tests', () {
    test('permissions parsing and hasPermission checks', () {
      final employee = <String, dynamic>{
        'id': 'user-123',
        'name': 'Budi Kasir',
        'role': 'Cashier',
        'permissions': ['pos.order.create', 'pos.payment.process'],
      };

      expect(
        employee.permissions,
        containsAll(['pos.order.create', 'pos.payment.process']),
      );
      expect(employee.hasPermission('pos.order.create'), isTrue);
      expect(employee.hasPermission('pos.payment.process'), isTrue);
      expect(employee.hasPermission('pos.discount.manual'), isFalse);
      expect(employee.isSupervisor(), isFalse);
    });

    test('wildcard permission transaction.* matches sub-actions', () {
      final supervisor = <String, dynamic>{
        'id': 'user-admin',
        'name': 'Supervisor Siti',
        'role': 'Store Manager',
        'permissions': ['transaction.*'],
      };

      expect(supervisor.hasPermission('transaction.create'), isTrue);
      expect(supervisor.hasPermission('pos.discount.any'), isFalse);
      expect(supervisor.isSupervisor(), isTrue);
    });

    test('pure permission-based check for setting.device (RBAC)', () {
      final cashier = <String, dynamic>{
        'id': 'user-1',
        'name': 'Budi Kasir',
        'role': 'Cashier',
        'permissions': ['pos.order.create'],
      };

      final managerWithoutDevicePerm = <String, dynamic>{
        'id': 'user-2',
        'name': 'Manager Joko',
        'role': 'Store Manager',
        'permissions': ['setting.printer'],
      };

      final staffWithDevicePerm = <String, dynamic>{
        'id': 'user-3',
        'name': 'Staf IT',
        'role': 'Staf IT',
        'permissions': ['setting.device'],
      };

      final ownerWithWildcard = <String, dynamic>{
        'id': 'user-4',
        'name': 'Owner Rudi',
        'role': 'Pemilik Usaha',
        'permissions': ['*'],
      };

      final adminWithSettingWildcard = <String, dynamic>{
        'id': 'user-5',
        'name': 'Admin Andi',
        'role': 'Admin',
        'permissions': ['setting.*'],
      };

      expect(cashier.hasPermission('setting.device'), isFalse);
      expect(cashier.hasDevicePermission(), isFalse);

      expect(managerWithoutDevicePerm.hasPermission('setting.device'), isFalse);
      expect(managerWithoutDevicePerm.hasDevicePermission(), isFalse);

      expect(staffWithDevicePerm.hasPermission('setting.device'), isTrue);
      expect(staffWithDevicePerm.hasDevicePermission(), isTrue);

      expect(ownerWithWildcard.hasPermission('setting.device'), isTrue);
      expect(ownerWithWildcard.hasDevicePermission(), isTrue);

      expect(adminWithSettingWildcard.hasPermission('setting.device'), isTrue);
      expect(adminWithSettingWildcard.hasDevicePermission(), isTrue);
    });

    test(
      'root user (Akun Utama) has full wildcard access and supervisor privileges',
      () {
        final rootUser = <String, dynamic>{
          'id': 'root-user-1',
          'name': 'Bos Utama',
          'role': 'Akun Utama',
          'is_root_user': true,
          'permissions': ['*'],
        };

        expect(rootUser.isRootUser, isTrue);
        expect(rootUser.hasPermission('setting.device'), isTrue);
        expect(rootUser.hasPermission('pos.order.create'), isTrue);
        expect(rootUser.hasPermission('transaction.void'), isTrue);
        expect(rootUser.hasPermission('inventory.transfer.approve'), isTrue);
        expect(rootUser.hasPermission('any.future.permission'), isTrue);
        expect(rootUser.hasDevicePermission(), isTrue);
        expect(rootUser.isSupervisor(), isTrue);
      },
    );

    test(
      'root user without explicit permissions array still grants full access via isRootUser',
      () {
        final rootUserFallback = <String, dynamic>{
          'id': 'root-user-2',
          'name': 'Bos Utama Cadangan',
          'role': 'Akun Utama',
          'is_root_user': true,
          'permissions': <String>[],
        };

        expect(rootUserFallback.isRootUser, isTrue);
        expect(rootUserFallback.hasPermission('setting.device'), isTrue);
        expect(
          rootUserFallback.hasPermission('transaction.override_price'),
          isTrue,
        );
        expect(rootUserFallback.isSupervisor(), isTrue);
      },
    );

    test(
      'owner template role respects custom permissions without granting unassigned features',
      () {
        final customizedOwner = <String, dynamic>{
          'id': 'owner-custom-1',
          'name': 'Mitra Bisnis',
          'role': 'Pemilik Usaha',
          'is_root_user': false,
          'permissions': ['setting.*', 'report.sales', 'transaction.validation_supervision'],
        };

        expect(customizedOwner.isRootUser, isFalse);
        expect(customizedOwner.hasPermission('setting.device'), isTrue);
        expect(customizedOwner.hasPermission('setting.printer'), isTrue);
        expect(customizedOwner.hasPermission('setting'), isTrue);
        expect(customizedOwner.hasPermission('report.sales'), isTrue);
        expect(customizedOwner.hasPermission('transaction.void'), isFalse);
        expect(customizedOwner.hasPermission('pos.order.delete'), isFalse);
        expect(customizedOwner.isSupervisor(), isTrue);
      },
    );

    test('transaction.validation_supervision grants isSupervisor regardless of role string', () {
      final shiftLeader = <String, dynamic>{
        'id': 'shift-leader-1',
        'name': 'Rian Shift Leader',
        'role': 'Barista Senior', // Custom role string
        'is_root_user': false,
        'permissions': ['pos.order.create', 'transaction.validation_supervision'],
      };

      expect(shiftLeader.hasPermission('transaction.validation_supervision'), isTrue);
      expect(shiftLeader.isSupervisor(), isTrue);

      final regularCashier = <String, dynamic>{
        'id': 'cashier-1',
        'name': 'Dina Kasir',
        'role': 'Supervisor Magang', // Nama role mengandung kata supervisor tapi tidak punya permission!
        'is_root_user': false,
        'permissions': ['pos.order.create'],
      };

      // Harus false karena role dinamis dan tidak punya permission transaction.validation_supervision
      expect(regularCashier.isSupervisor(), isFalse);
    });
  });

  group('Cart Provider & Open Price Tests', () {
    test('CartItem price update via copyWith', () {
      final item = CartItem(
        id: '1',
        productId: 'prod-1',
        inventoryItemId: 'inv-1',
        name: 'Kopi Susu Gula Aren',
        price: 18000.0,
        qty: 2,
      );

      final updated = item.copyWith(price: 20000.0);
      expect(updated.price, equals(20000.0));
      expect(updated.calculatedSubtotal, equals(40000.0));
    });

    test('CartNotifier updates price of specific line item', () {
      final container = ProviderContainer();
      final notifier = container.read(cartProvider.notifier);

      final item1 = CartItem(
        id: 'item-1',
        productId: 'prod-1',
        inventoryItemId: 'inv-1',
        name: 'Item 1',
        price: 10000.0,
        qty: 1,
      );
      final item2 = CartItem(
        id: 'item-2',
        productId: 'prod-2',
        inventoryItemId: 'inv-2',
        name: 'Item 2',
        price: 25000.0,
        qty: 1,
      );

      notifier.addItem(item1);
      notifier.addItem(item2);

      notifier.updatePrice('item-1', 12000.0);

      final items = container.read(cartProvider);
      expect(items.firstWhere((i) => i.id == 'item-1').price, equals(12000.0));
      expect(items.firstWhere((i) => i.id == 'item-2').price, equals(25000.0));
    });
  });
}
