import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:drift/native.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:sollu_pos_client/core/database/app_database.dart';
import 'package:sollu_pos_client/core/network/dio_client.dart';
import 'package:sollu_pos_client/core/services/device_info_service.dart';
import 'package:sollu_pos_client/core/services/secure_storage_service.dart';
import 'package:sollu_pos_client/features/auth/data/auth_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;
  late SharedPreferences prefs;
  late AuthRepository authRepository;

  setUp(() async {
    FlutterSecureStorage.setMockInitialValues({});
    dotenv.testLoad(mergeWith: {
      'API_BASE_URL': 'http://api.sollu.test',
      'APP_NAME': 'Sollu POS',
    });
    SharedPreferences.setMockInitialValues({
      'last_sync_at': '2026-10-08T10:00:00.000Z',
      'last_synced_at': '2026-10-08T10:00:00.000Z',
      'pos_display_mode': 'variant',
    });
    prefs = await SharedPreferences.getInstance();
    db = AppDatabase.forTesting(NativeDatabase.memory());

    final secureStorage = SecureStorageService();
    final dioClient = DioClient(secureStorage);
    final deviceInfoService = DeviceInfoService(secureStorage);

    authRepository = AuthRepository(
      dioClient,
      deviceInfoService,
      secureStorage,
      db,
      prefs,
    );
  });

  tearDown(() async {
    await db.close();
  });

  test('disconnect purges last_sync_at and last_synced_at from SharedPreferences', () async {
    expect(prefs.getString('last_sync_at'), isNotNull);
    expect(prefs.getString('last_synced_at'), isNotNull);

    await authRepository.disconnect();

    expect(prefs.getString('last_sync_at'), isNull);
    expect(prefs.getString('last_synced_at'), isNull);
    // Other unrelated preferences remain intact
    expect(prefs.getString('pos_display_mode'), equals('variant'));
  });
}
