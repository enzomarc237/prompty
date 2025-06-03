import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:path_provider/path_provider.dart';
import 'package:file_selector/file_selector.dart';
import '../models/prompt.dart';

/// Utility class for exporting prompts and settings
class ExportUtils {
  /// Export a single prompt to a file
  static Future<bool> exportPrompt(BuildContext context, Prompt prompt) async {
    try {
      // Create the export data
      final Map<String, dynamic> exportData = {
        'original': prompt.originalText,
        'professional': prompt.professionalVersion,
        'creative': prompt.creativeVersion,
        'technical': prompt.technicalVersion,
        'created_at': prompt.createdAt.toIso8601String(),
        'is_favorite': prompt.isFavorite,
        'tags': prompt.tags,
        'category': prompt.category,
      };
      
      // Convert to JSON
      final String jsonData = jsonEncode(exportData);
      
      // Get suggested file name
      final String suggestedName = 'prompt_${prompt.id}.json';
      
      // Save the file
      final FileSaveLocation? result = await getSaveLocation(
        suggestedName: suggestedName,
        acceptedTypeGroups: [
          const XTypeGroup(
            label: 'JSON',
            extensions: ['json'],
          ),
        ],
      );
      
      if (result != null) {
        final File file = File(result.path);
        await file.writeAsString(jsonData);
        return true;
      }
      
      return false;
    } catch (e) {
      _showExportError(context, e.toString());
      return false;
    }
  }
  
  /// Export a prompt as plain text
  static Future<bool> exportPromptAsText(BuildContext context, Prompt prompt, EnhancementStyle style) async {
    try {
      // Get the content based on the style
      String content;
      switch (style) {
        case EnhancementStyle.professional:
          content = prompt.professionalVersion ?? prompt.originalText;
          break;
        case EnhancementStyle.creative:
          content = prompt.creativeVersion ?? prompt.originalText;
          break;
        case EnhancementStyle.technical:
          content = prompt.technicalVersion ?? prompt.originalText;
          break;
      }
      
      // Get suggested file name
      final String suggestedName = 'prompt_${style.name}_${prompt.id}.txt';
      
      // Save the file
      final FileSaveLocation? result = await getSaveLocation(
        suggestedName: suggestedName,
        acceptedTypeGroups: [
          const XTypeGroup(
            label: 'Text',
            extensions: ['txt'],
          ),
        ],
      );
      
      if (result != null) {
        final File file = File(result.path);
        await file.writeAsString(content);
        return true;
      }
      
      return false;
    } catch (e) {
      _showExportError(context, e.toString());
      return false;
    }
  }
  
  /// Export all prompts to a file
  static Future<bool> exportAllPrompts(BuildContext context, List<Prompt> prompts) async {
    try {
      // Create the export data
      final List<Map<String, dynamic>> exportData = prompts.map((prompt) => {
        'id': prompt.id,
        'original': prompt.originalText,
        'professional': prompt.professionalVersion,
        'creative': prompt.creativeVersion,
        'technical': prompt.technicalVersion,
        'created_at': prompt.createdAt.toIso8601String(),
        'updated_at': prompt.updatedAt?.toIso8601String(),
        'is_favorite': prompt.isFavorite,
        'tags': prompt.tags,
        'category': prompt.category,
      }).toList();
      
      // Convert to JSON
      final String jsonData = jsonEncode({
        'prompts': exportData,
        'exported_at': DateTime.now().toIso8601String(),
        'count': prompts.length,
      });
      
      // Get suggested file name
      final String suggestedName = 'prompty_export_${DateTime.now().millisecondsSinceEpoch}.json';
      
      // Save the file
      final FileSaveLocation? result = await getSaveLocation(
        suggestedName: suggestedName,
        acceptedTypeGroups: [
          const XTypeGroup(
            label: 'JSON',
            extensions: ['json'],
          ),
        ],
      );
      
      if (result != null) {
        final File file = File(result.path);
        await file.writeAsString(jsonData);
        return true;
      }
      
      return false;
    } catch (e) {
      _showExportError(context, e.toString());
      return false;
    }
  }
  
  /// Export settings to a file
  static Future<bool> exportSettings(BuildContext context, Map<String, dynamic> settings) async {
    try {
      // Convert to JSON
      final String jsonData = jsonEncode({
        'settings': settings,
        'exported_at': DateTime.now().toIso8601String(),
      });
      
      // Get suggested file name
      final String suggestedName = 'prompty_settings.json';
      
      // Save the file
      final FileSaveLocation? result = await getSaveLocation(
        suggestedName: suggestedName,
        acceptedTypeGroups: [
          const XTypeGroup(
            label: 'JSON',
            extensions: ['json'],
          ),
        ],
      );
      
      if (result != null) {
        final File file = File(result.path);
        await file.writeAsString(jsonData);
        return true;
      }
      
      return false;
    } catch (e) {
      _showExportError(context, e.toString());
      return false;
    }
  }
  
  /// Show export success dialog
  static void showExportSuccess(BuildContext context) {
    showMacosAlertDialog(
      context: context,
      builder: (context) => MacosAlertDialog(
        appIcon: const Icon(Icons.check_circle, size: 64, color: Colors.green),
        title: const Text('Export Successful'),
        message: const Text('Your data has been exported successfully.'),
        primaryButton: PushButton(
          controlSize: ControlSize.large,
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('OK'),
        ),
      ),
    );
  }
  
  /// Show export error dialog
  static void _showExportError(BuildContext context, String error) {
    showMacosAlertDialog(
      context: context,
      builder: (context) => MacosAlertDialog(
        appIcon: const Icon(Icons.error_outline, size: 64, color: Colors.red),
        title: const Text('Export Failed'),
        message: Text('An error occurred while exporting: $error'),
        primaryButton: PushButton(
          controlSize: ControlSize.large,
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('OK'),
        ),
      ),
    );
  }
}