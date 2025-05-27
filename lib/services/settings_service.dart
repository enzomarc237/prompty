import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/app_settings.dart';

class SettingsService {
  static SettingsService? _instance;
  static const String _settingsKey = 'app_settings';

  SettingsService._internal();

  static SettingsService get instance {
    _instance ??= SettingsService._internal();
    return _instance!;
  }

  Future<AppSettings> getSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final settingsJson = prefs.getString(_settingsKey);
    
    if (settingsJson != null) {
      try {
        final Map<String, dynamic> settingsMap = jsonDecode(settingsJson);
        return AppSettings.fromJson(settingsMap);
      } catch (e) {
        // If there's an error parsing, return default settings
        return const AppSettings();
      }
    }
    
    return const AppSettings();
  }

  Future<void> saveSettings(AppSettings settings) async {
    final prefs = await SharedPreferences.getInstance();
    final settingsJson = jsonEncode(settings.toJson());
    await prefs.setString(_settingsKey, settingsJson);
  }

  Future<void> updateApiKey(String apiKey) async {
    final currentSettings = await getSettings();
    final updatedSettings = currentSettings.copyWith(apiKey: apiKey);
    await saveSettings(updatedSettings);
  }

  Future<void> updateApiProvider(String provider) async {
    final currentSettings = await getSettings();
    final updatedSettings = currentSettings.copyWith(apiProvider: provider);
    await saveSettings(updatedSettings);
  }

  Future<void> updateDarkMode(bool darkMode) async {
    final currentSettings = await getSettings();
    final updatedSettings = currentSettings.copyWith(darkMode: darkMode);
    await saveSettings(updatedSettings);
  }

  Future<void> updateStartMinimized(bool startMinimized) async {
    final currentSettings = await getSettings();
    final updatedSettings = currentSettings.copyWith(startMinimized: startMinimized);
    await saveSettings(updatedSettings);
  }

  Future<void> updateLaunchAtStartup(bool launchAtStartup) async {
    final currentSettings = await getSettings();
    final updatedSettings = currentSettings.copyWith(launchAtStartup: launchAtStartup);
    await saveSettings(updatedSettings);
  }

  Future<void> resetSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_settingsKey);
  }
}