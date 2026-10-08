/// Centralized API Endpoints Configuration for Sollu POS Client
/// All endpoints are mapped to canonical versioned paths to avoid magic strings and leading slash Dio resolution bugs.
class ApiEndpoints {
  /// Current Active API Version
  static const String currentVersion = 'v1';

  /// Base Prefix for POS Module
  static const String posPrefix = '/$currentVersion/pos';

  // --- Device Management & Pairing ---
  static const String deviceConnect = '$posPrefix/device/connect';
  static const String deviceStatus = '$posPrefix/device/status';
  static const String deviceUnpair = '$posPrefix/device/unpair';

  // --- Master Data Synchronization ---
  static const String syncMaster = '$posPrefix/sync/master';
  static const String syncInitial = '$posPrefix/sync/initial';
  static const String syncDelta = '$posPrefix/sync/delta';

  // --- Employee Management ---
  static const String employees = '$posPrefix/employees';
  static const String employeesPin = '$posPrefix/employees/pin';

  // --- Transactions ---
  static const String transactions = '$posPrefix/transactions';

  // --- Shift Management ---
  static const String shiftsSync = '$posPrefix/shifts/sync';
  static const String shiftsOpen = '$posPrefix/shifts/open';
  static const String shiftsClose = '$posPrefix/shifts/close';
  static const String shiftsCashLog = '$posPrefix/shifts/cash-log';

  // --- Settings ---
  static const String settingsPrinter = '$posPrefix/settings/printer';

  // --- Error & Diagnostic Logs ---
  static const String logsError = '$posPrefix/logs/error';
}
