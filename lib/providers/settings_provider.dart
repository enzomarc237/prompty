import 'package:flutter/foundation.dart';
import '../models/app_settings.dart';
import '../services/settings_service.dart';
import '../services/ai_service.dart';

class SettingsProvider extends ChangeNotifier {
  final SettingsService _settingsService = SettingsService.instance;
  final AIService _aiService = AIService.instance;
  
  AppSettings _settings = const AppSettings();
  bool _isLoading = false;
  bool _isLoadingModels = false;
  List<AIModel> _availableModels = [];

  AppSettings get settings => _settings;
  bool get isLoading => _isLoading;
  bool get isLoadingModels => _isLoadingModels;
  List<AIModel> get availableModels => _availableModels;

  Future<void> loadSettings() async {
    _isLoading = true;
    notifyListeners();

    try {
      _settings = await _settingsService.getSettings();
    } catch (e) {
      debugPrint('Error loading settings: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateApiKey(String apiKey) async {
    _settings = _settings.copyWith(apiKey: apiKey);
    await _settingsService.saveSettings(_settings);
    notifyListeners();
  }

  Future<void> updateApiProvider(String provider) async {
    _settings = _settings.copyWith(apiProvider: provider);
    await _settingsService.saveSettings(_settings);
    notifyListeners();
  }

  Future<void> updateDarkMode(bool darkMode) async {
    _settings = _settings.copyWith(darkMode: darkMode);
    await _settingsService.saveSettings(_settings);
    notifyListeners();
  }

  Future<void> updateStartMinimized(bool startMinimized) async {
    _settings = _settings.copyWith(startMinimized: startMinimized);
    await _settingsService.saveSettings(_settings);
    notifyListeners();
  }

  Future<void> updateLaunchAtStartup(bool launchAtStartup) async {
    _settings = _settings.copyWith(launchAtStartup: launchAtStartup);
    await _settingsService.saveSettings(_settings);
    notifyListeners();
  }

  Future<void> updateEnableNotifications(bool enableNotifications) async {
    _settings = _settings.copyWith(enableNotifications: enableNotifications);
    await _settingsService.saveSettings(_settings);
    notifyListeners();
  }

  Future<void> updateSelectedModel(String model) async {
    _settings = _settings.copyWith(selectedModel: model);
    await _settingsService.saveSettings(_settings);
    notifyListeners();
  }

  Future<void> loadAvailableModels() async {
    if (_settings.apiKey.isEmpty) return;
    
    _isLoadingModels = true;
    notifyListeners();

    try {
      _availableModels = await _aiService.getAvailableModels(_settings.apiProvider, _settings.apiKey);
    } catch (e) {
      debugPrint('Error loading models: $e');
      _availableModels = [];
    } finally {
      _isLoadingModels = false;
      notifyListeners();
    }
  }

  Future<void> updateDefaultCategory(String category) async {
    _settings = _settings.copyWith(defaultCategory: category);
    await _settingsService.saveSettings(_settings);
    notifyListeners();
  }

  Future<void> resetSettings() async {
    await _settingsService.resetSettings();
    _settings = const AppSettings();
    _availableModels = [];
    notifyListeners();
  }
}