import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/database/app_database.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/services/outlet_settings_service.dart';
import '../../pos/data/sync/delta_sync_service.dart';
import '../../pos/data/sync/initial_sync_service.dart';

class SyncRepository {
  final DioClient _dioClient;
  final AppDatabase _database;
  final OutletSettingsService _outletSettingsService;
  final SharedPreferences? _prefs;

  late final InitialSyncService _initialSyncService;
  late final DeltaSyncService _deltaSyncService;

  SyncRepository(
    this._dioClient,
    this._database,
    this._outletSettingsService, [
    this._prefs,
  ]) {
    _initialSyncService = InitialSyncService(
      _dioClient,
      _database,
      _outletSettingsService,
      _prefs,
    );
    _deltaSyncService = DeltaSyncService(
      _dioClient,
      _database,
      _prefs,
      _initialSyncService,
    );
  }

  InitialSyncService get initialSyncService => _initialSyncService;
  DeltaSyncService get deltaSyncService => _deltaSyncService;

  /// Melakukan full snapshot synchronization (Initial Sync)
  Future<void> syncMasterData() async {
    await _initialSyncService.syncInitialSnapshot();
  }

  /// Melakukan incremental synchronization (Delta Sync)
  Future<DateTime> syncDeltaData({DateTime? since}) async {
    return await _deltaSyncService.syncDeltaCatalog(since: since);
  }
}
