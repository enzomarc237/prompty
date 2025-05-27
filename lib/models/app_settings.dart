import 'package:json_annotation/json_annotation.dart';

part 'app_settings.g.dart';

@JsonSerializable()
class AppSettings {
  final String apiProvider;
  final String apiKey;
  final String selectedModel;
  final bool darkMode;
  final bool startMinimized;
  final bool launchAtStartup;
  final bool enableNotifications;
  final String defaultCategory;
  final Map<String, String> customStyles;

  const AppSettings({
    this.apiProvider = 'openai',
    this.apiKey = '',
    this.selectedModel = 'gpt-3.5-turbo',
    this.darkMode = false,
    this.startMinimized = false,
    this.launchAtStartup = false,
    this.enableNotifications = true,
    this.defaultCategory = 'general',
    this.customStyles = const {},
  });

  factory AppSettings.fromJson(Map<String, dynamic> json) => _$AppSettingsFromJson(json);
  Map<String, dynamic> toJson() => _$AppSettingsToJson(this);

  AppSettings copyWith({
    String? apiProvider,
    String? apiKey,
    String? selectedModel,
    bool? darkMode,
    bool? startMinimized,
    bool? launchAtStartup,
    bool? enableNotifications,
    String? defaultCategory,
    Map<String, String>? customStyles,
  }) {
    return AppSettings(
      apiProvider: apiProvider ?? this.apiProvider,
      apiKey: apiKey ?? this.apiKey,
      selectedModel: selectedModel ?? this.selectedModel,
      darkMode: darkMode ?? this.darkMode,
      startMinimized: startMinimized ?? this.startMinimized,
      launchAtStartup: launchAtStartup ?? this.launchAtStartup,
      enableNotifications: enableNotifications ?? this.enableNotifications,
      defaultCategory: defaultCategory ?? this.defaultCategory,
      customStyles: customStyles ?? this.customStyles,
    );
  }
}