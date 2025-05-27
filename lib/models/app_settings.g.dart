// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_settings.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AppSettings _$AppSettingsFromJson(Map<String, dynamic> json) => AppSettings(
  apiProvider: json['apiProvider'] as String? ?? 'openai',
  apiKey: json['apiKey'] as String? ?? '',
  selectedModel: json['selectedModel'] as String? ?? 'gpt-3.5-turbo',
  darkMode: json['darkMode'] as bool? ?? false,
  startMinimized: json['startMinimized'] as bool? ?? false,
  launchAtStartup: json['launchAtStartup'] as bool? ?? false,
  enableNotifications: json['enableNotifications'] as bool? ?? true,
  defaultCategory: json['defaultCategory'] as String? ?? 'general',
  customStyles:
      (json['customStyles'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, e as String),
      ) ??
      const {},
);

Map<String, dynamic> _$AppSettingsToJson(AppSettings instance) =>
    <String, dynamic>{
      'apiProvider': instance.apiProvider,
      'apiKey': instance.apiKey,
      'selectedModel': instance.selectedModel,
      'darkMode': instance.darkMode,
      'startMinimized': instance.startMinimized,
      'launchAtStartup': instance.launchAtStartup,
      'enableNotifications': instance.enableNotifications,
      'defaultCategory': instance.defaultCategory,
      'customStyles': instance.customStyles,
    };
