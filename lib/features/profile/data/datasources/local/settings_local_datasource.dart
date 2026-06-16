abstract class SettingsLocalDataSource {
  Future<bool> getDarkMode();
  Future<void> setDarkMode(bool value);
  Future<bool> getNotificationsEnabled();
  Future<void> setNotificationsEnabled(bool value);
}
