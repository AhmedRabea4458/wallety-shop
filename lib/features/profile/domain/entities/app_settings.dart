class AppSettings {
  final bool isDarkMode;
  final bool isNotificationsEnabled;

  const AppSettings({
    required this.isDarkMode,
    required this.isNotificationsEnabled,
  });

  AppSettings.empty()
      : isDarkMode = true,
        isNotificationsEnabled = true;
}
