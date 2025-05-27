import 'package:flutter/foundation.dart';
import '../models/prompt.dart';
import '../services/database_service.dart';
import '../services/ai_service.dart';
import '../services/settings_service.dart';

class PromptProvider extends ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService.instance;
  final AIService _aiService = AIService.instance;
  final SettingsService _settingsService = SettingsService.instance;

  List<Prompt> _prompts = [];
  List<Prompt> _filteredPrompts = [];
  bool _isLoading = false;
  bool _isEnhancing = false;
  String? _error;
  String _searchQuery = '';
  bool _showFavoritesOnly = false;

  List<Prompt> get prompts => _filteredPrompts;
  bool get isLoading => _isLoading;
  bool get isEnhancing => _isEnhancing;
  String? get error => _error;
  String get searchQuery => _searchQuery;
  bool get showFavoritesOnly => _showFavoritesOnly;

  Future<void> loadPrompts() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _prompts = await _databaseService.getAllPrompts();
      _applyFilters();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> enhancePrompt(String originalText) async {
    _isEnhancing = true;
    _error = null;
    notifyListeners();

    try {
      final settings = await _settingsService.getSettings();
      
      if (settings.apiKey.isEmpty) {
        throw Exception('API key not configured. Please set your API key in settings.');
      }

      final enhancements = await _aiService.enhancePrompt(
        originalText,
        settings.apiKey,
        provider: settings.apiProvider,
        model: settings.selectedModel,
      );

      final prompt = Prompt(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        originalText: originalText,
        professionalVersion: enhancements['professional'],
        creativeVersion: enhancements['creative'],
        technicalVersion: enhancements['technical'],
        createdAt: DateTime.now(),
      );

      await _databaseService.insertPrompt(prompt);
      await loadPrompts();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isEnhancing = false;
      notifyListeners();
    }
  }

  Future<void> toggleFavorite(String promptId) async {
    try {
      final promptIndex = _prompts.indexWhere((p) => p.id == promptId);
      if (promptIndex != -1) {
        final updatedPrompt = _prompts[promptIndex].copyWith(
          isFavorite: !_prompts[promptIndex].isFavorite,
        );
        
        await _databaseService.updatePrompt(updatedPrompt);
        await loadPrompts();
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> deletePrompt(String promptId) async {
    try {
      await _databaseService.deletePrompt(promptId);
      await loadPrompts();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  void search(String query) {
    _searchQuery = query;
    _applyFilters();
    notifyListeners();
  }

  void toggleFavoritesFilter() {
    _showFavoritesOnly = !_showFavoritesOnly;
    _applyFilters();
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void _applyFilters() {
    _filteredPrompts = List.from(_prompts);

    if (_showFavoritesOnly) {
      _filteredPrompts = _filteredPrompts.where((p) => p.isFavorite).toList();
    }

    if (_searchQuery.isNotEmpty) {
      _filteredPrompts = _filteredPrompts.where((p) =>
        p.originalText.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        (p.professionalVersion?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false) ||
        (p.creativeVersion?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false) ||
        (p.technicalVersion?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false)
      ).toList();
    }
  }
}