import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/prompt_provider.dart';
import '../providers/settings_provider.dart';

/// Class to manage keyboard shortcuts throughout the application
class KeyboardShortcuts {
  /// Register global keyboard shortcuts
  static Widget registerGlobalShortcuts(BuildContext context, Widget child) {
    // Define shortcuts based on platform
    final isMac = defaultTargetPlatform == TargetPlatform.macOS;
    
    // Create a focus node to capture keyboard events
    final FocusNode focusNode = FocusNode();
    focusNode.requestFocus();
    
    return Focus(
      focusNode: focusNode,
      autofocus: true,
      onKeyEvent: (node, event) {
        if (event is KeyDownEvent) {
          // Enhance prompt (Cmd+E on Mac, Ctrl+E elsewhere)
          if (event.logicalKey == LogicalKeyboardKey.keyE && 
              (isMac ? event.logicalKey == LogicalKeyboardKey.meta : event.logicalKey == LogicalKeyboardKey.control)) {
            _showQuickEnhanceDialog(context);
            return KeyEventResult.handled;
          }
          
          // Toggle favorites view (Cmd+F on Mac, Ctrl+F elsewhere)
          if (event.logicalKey == LogicalKeyboardKey.keyF && 
              (isMac ? event.logicalKey == LogicalKeyboardKey.meta : event.logicalKey == LogicalKeyboardKey.control)) {
            context.read<PromptProvider>().toggleFavoritesFilter();
            return KeyEventResult.handled;
          }
          
          // Toggle dark mode (Cmd+D on Mac, Ctrl+D elsewhere)
          if (event.logicalKey == LogicalKeyboardKey.keyD && 
              (isMac ? event.logicalKey == LogicalKeyboardKey.meta : event.logicalKey == LogicalKeyboardKey.control)) {
            final settingsProvider = context.read<SettingsProvider>();
            settingsProvider.updateDarkMode(!settingsProvider.settings.darkMode);
            return KeyEventResult.handled;
          }
          
          // Refresh prompts (Cmd+R on Mac, Ctrl+R elsewhere)
          if (event.logicalKey == LogicalKeyboardKey.keyR && 
              (isMac ? event.logicalKey == LogicalKeyboardKey.meta : event.logicalKey == LogicalKeyboardKey.control)) {
            context.read<PromptProvider>().loadPrompts();
            return KeyEventResult.handled;
          }
          
          // Show keyboard shortcuts help (Cmd+H on Mac, Ctrl+H elsewhere)
          if (event.logicalKey == LogicalKeyboardKey.keyH && 
              (isMac ? event.logicalKey == LogicalKeyboardKey.meta : event.logicalKey == LogicalKeyboardKey.control)) {
            _showShortcutsHelp(context);
            return KeyEventResult.handled;
          }
        }
        
        return KeyEventResult.ignored;
      },
      child: child,
    );
  }
  
  /// Show a quick enhance dialog
  static void _showQuickEnhanceDialog(BuildContext context) {
    final TextEditingController controller = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Quick Enhance'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Enter your prompt to enhance:'),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                hintText: 'Type your prompt here...',
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              controller.dispose();
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final prompt = controller.text.trim();
              if (prompt.isNotEmpty) {
                Navigator.of(context).pop();
                context.read<PromptProvider>().enhancePrompt(prompt);
              }
              controller.dispose();
            },
            child: const Text('Enhance'),
          ),
        ],
      ),
    );
  }
  
  /// Show keyboard shortcuts help dialog
  static void _showShortcutsHelp(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Keyboard Shortcuts'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: getShortcutsMap().entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        entry.key,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(child: Text(entry.value)),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
  
  /// Get a map of keyboard shortcuts for help/documentation
  static Map<String, String> getShortcutsMap() {
    final isMac = defaultTargetPlatform == TargetPlatform.macOS;
    final modKey = isMac ? '⌘' : 'Ctrl';
    
    return {
      '$modKey+E': 'Quick enhance prompt',
      '$modKey+F': 'Toggle favorites view',
      '$modKey+D': 'Toggle dark mode',
      '$modKey+R': 'Refresh prompts',
      '$modKey+,': 'Open settings',
      '$modKey+H': 'Show keyboard shortcuts',
      '$modKey+Q': 'Quit application',
    };
  }
}