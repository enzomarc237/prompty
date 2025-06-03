import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';
import 'package:tray_manager/tray_manager.dart';
import 'dart:io';

import 'models/prompt.dart';

import 'providers/prompt_provider.dart';
import 'providers/settings_provider.dart';
import 'screens/main_screen.dart';
import 'utils/keyboard_shortcuts.dart';
import 'utils/string_extensions.dart';

/// Configure macOS window utils for modern transparent effect
Future<void> _configureMacosWindowUtils() async {
  const config = MacosWindowUtilsConfig(
    toolbarStyle: NSWindowToolbarStyle.unified,
  );
  await config.apply();
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize window manager for desktop
  if (Platform.isMacOS || Platform.isWindows || Platform.isLinux) {
    await windowManager.ensureInitialized();
    // await trayManager.ensureInitialized();
    
    WindowOptions windowOptions = const WindowOptions(
      size: Size(1200, 800),
      minimumSize: Size(800, 600),
      center: true,
      backgroundColor: Colors.transparent,
      skipTaskbar: false,
      titleBarStyle: TitleBarStyle.hidden,
    );
    
    windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
      await _setupTray();
    });
  }

  // Configure macOS window utilities for modern look
  if (Platform.isMacOS) {
    await _configureMacosWindowUtils();
  }

  runApp(const PromptyApp());
}

/// Set up the system tray icon and menu
Future<void> _setupTray() async {
  // Set the tray icon
  await trayManager.setIcon(
    Platform.isWindows 
      ? 'assets/images/tray_icon.ico' 
      : 'assets/images/tray_icon.png'
  );
  
  // Create the tray menu
  final menu = Menu(
    items: [
      MenuItem(
        key: 'show_window',
        label: 'Open Prompty',
      ),
      MenuItem.separator(),
      MenuItem(
        key: 'enhance_prompt',
        label: 'Quick Enhance...',
      ),
      MenuItem.separator(),
      MenuItem(
        key: 'exit_app',
        label: 'Quit Prompty',
      ),
    ],
  );
  
  await trayManager.setContextMenu(menu);
}

class PromptyApp extends StatelessWidget {
  const PromptyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => PromptProvider()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
      ],
      child: Consumer<SettingsProvider>(
        builder: (context, settingsProvider, child) {
          return KeyboardShortcuts.registerGlobalShortcuts(
            context,
            MacosApp(
              title: 'Prompty',
              theme: MacosThemeData.light().copyWith(
                primaryColor: MacosColors.systemBlueColor,
              ),
              darkTheme: MacosThemeData.dark().copyWith(
                primaryColor: MacosColors.systemBlueColor,
              ),
              themeMode: settingsProvider.settings.darkMode
                  ? ThemeMode.dark
                  : ThemeMode.light,
              debugShowCheckedModeBanner: false,
              home: const PromptyWindow(),
            ),
          );
        },
      ),
    );
  }
}

class PromptyWindow extends StatefulWidget {
  const PromptyWindow({super.key});

  @override
  State<PromptyWindow> createState() => _PromptyWindowState();
}

class _PromptyWindowState extends State<PromptyWindow> with WindowListener, TrayListener {
  final TextEditingController _quickEnhanceController = TextEditingController();
  EnhancementStyle _selectedEnhancementStyle = EnhancementStyle.professional;
  
  @override
  void initState() {
    super.initState();
    if (Platform.isMacOS || Platform.isWindows || Platform.isLinux) {
      windowManager.addListener(this);
      trayManager.addListener(this);
    }
  }

  @override
  void dispose() {
    _quickEnhanceController.dispose();
    if (Platform.isMacOS || Platform.isWindows || Platform.isLinux) {
      windowManager.removeListener(this);
      trayManager.removeListener(this);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return const MainScreen();
  }

  // Window listener methods
  @override
  void onWindowClose() async {
    bool isPreventClose = await windowManager.isPreventClose();
    if (isPreventClose) {
      showMacosAlertDialog(
        context: context,
        builder: (context) => MacosAlertDialog(
          appIcon: const Icon(Icons.info, size: 64),
          title: const Text('Hide Prompty?'),
          message: const Text(
            'Prompty will continue running in the background. You can access it from the system tray.',
          ),
          primaryButton: PushButton(
            controlSize: ControlSize.large,
            onPressed: () {
              Navigator.of(context).pop();
              windowManager.hide();
            },
            child: const Text('Hide'),
          ),
          secondaryButton: PushButton(
            controlSize: ControlSize.large,
            onPressed: () {
              Navigator.of(context).pop();
              windowManager.destroy();
            },
            child: const Text('Quit'),
          ),
        ),
      );
    }
  }

  @override
  void onWindowFocus() {
    setState(() {});
  }

  // Position window as a popup under the menu bar
  Future<void> _positionWindowAsPopup() async {
    final screenSize = await windowManager.getBounds();
    final windowSize = await windowManager.getSize();
    
    // Position the window at the top center of the screen
    final x = (screenSize.size.width - windowSize.width) / 2;
    const y = 30.0; // Position below the menu bar
    
    await windowManager.setPosition(Offset(x, y));
  }

  // Tray listener methods
  @override
  void onTrayIconMouseDown() async {
    final isVisible = await windowManager.isVisible();
    
    if (isVisible) {
      await windowManager.hide();
    } else {
      await _positionWindowAsPopup();
      await windowManager.show();
      await windowManager.focus();
    }
  }

  @override
  void onTrayIconRightMouseDown() {
    trayManager.popUpContextMenu();
  }

  @override
  void onTrayMenuItemClick(MenuItem menuItem) async {
    switch (menuItem.key) {
      case 'show_window':
        await windowManager.show();
        await windowManager.focus();
        break;
      case 'enhance_prompt':
        _showQuickEnhanceDialog();
        break;
      case 'exit_app':
        await windowManager.destroy();
        break;
    }
  }
  
  // Show a quick enhance dialog from the tray
  void _showQuickEnhanceDialog() async {
    await windowManager.show();
    await windowManager.focus();
    
    if (!mounted) return;
    
    showMacosAlertDialog(
      context: context,
      builder: (context) => MacosAlertDialog(
        appIcon: const MacosIcon(CupertinoIcons.sparkles, size: 64),
        title: const Text('Quick Enhance'),
        message: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Enter your prompt to enhance:'),
            const SizedBox(height: 12),
            MacosTextField(
              controller: _quickEnhanceController,
              placeholder: 'Type your prompt here...',
              maxLines: 3,
            ),
            const SizedBox(height: 20),
            MacosPopupButton<EnhancementStyle>(
              value: _selectedEnhancementStyle,
              onChanged: (style) {
                if (style != null) {
                  setState(() {
                    _selectedEnhancementStyle = style;
                  });
                }
              },
              items: EnhancementStyle.values.map((style) {
                return MacosPopupMenuItem<EnhancementStyle>(
                  value: style,
                  child: Text(style.name.capitalize()),
                );
              }).toList(),
            ),
          ],
        ),
        primaryButton: PushButton(
          controlSize: ControlSize.large,
          onPressed: () {
            final prompt = _quickEnhanceController.text.trim();
            if (prompt.isNotEmpty) {
              Navigator.of(context).pop();
              _quickEnhanceController.clear();
              
              // Enhance the prompt
              context.read<PromptProvider>().enhancePrompt(prompt, style: _selectedEnhancementStyle);
            }
          },
          child: const Text('Enhance'),
        ),
        secondaryButton: PushButton(
          controlSize: ControlSize.large,
          onPressed: () {
            Navigator.of(context).pop();
            _quickEnhanceController.clear();
          },
          child: const Text('Cancel'),
        ),
      ),
    );
  }
}
