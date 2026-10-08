import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class OutletSettingsService {
  final SharedPreferences _prefs;

  OutletSettingsService(this._prefs);

  static const _outletProfileKey = 'outlet_profile';
  static const _outletSettingsKey = 'outlet_settings';

  Future<void> saveOutletProfile(Map<String, dynamic> profile) async {
    await _prefs.setString(_outletProfileKey, jsonEncode(profile));
  }

  Map<String, dynamic>? getOutletProfile() {
    final data = _prefs.getString(_outletProfileKey);
    if (data != null) {
      return jsonDecode(data) as Map<String, dynamic>;
    }
    return null;
  }

  Future<void> saveOutletSettings(Map<String, dynamic> settings) async {
    await _prefs.setString(_outletSettingsKey, jsonEncode(settings));
  }

  Map<String, dynamic>? getOutletSettings() {
    final data = _prefs.getString(_outletSettingsKey);
    if (data != null) {
      return jsonDecode(data) as Map<String, dynamic>;
    }
    return null;
  }

  static const _autoPrintKey = 'pos_auto_print';

  Future<void> saveAutoPrint(bool autoPrint) async {
    await _prefs.setBool(_autoPrintKey, autoPrint);
  }

  bool getAutoPrint() {
    return _prefs.getBool(_autoPrintKey) ?? true;
  }

  Future<void> clearAll() async {
    await _prefs.remove(_outletProfileKey);
    await _prefs.remove(_outletSettingsKey);
    await _prefs.remove(_autoPrintKey);
  }
}
