import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_expense/features/profile/data/datasources/local/settings_local_datasource.dart';

class SettingsLocalDataSourceImpl implements SettingsLocalDataSource {
  final SharedPreferences _prefs;

  static const String _darkModeKey = 'is_dark_mode';
  static const String _notificationsKey = 'is_notifications_enabled';

  SettingsLocalDataSourceImpl(this._prefs);

  @override
  Future<bool> getDarkMode() async {
    return _prefs.getBool(_darkModeKey) ?? true;
  }

  @override
  Future<void> setDarkMode(bool value) async {
    await _prefs.setBool(_darkModeKey, value);
  }

  @override
  Future<bool> getNotificationsEnabled() async {
    return _prefs.getBool(_notificationsKey) ?? true;
  }

  @override
  Future<void> setNotificationsEnabled(bool value) async {
    await _prefs.setBool(_notificationsKey, value);
  }
}
