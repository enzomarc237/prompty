import 'package:flutter/material.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';
import 'package:tray_manager/tray_manager.dart';
import 'dart:io';

import 'providers/prompt_provider.dart';
import 'providers/settings_provider.dart';
import 'screens/main_screen.dart';

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
    
    WindowOptions windowOptions = const WindowOptions(
      size: Size(1200, 800),
      minimumSize: Size(800, 600),
      center: true,
      backgroundColor: Colors.transparent,
      // skipTaskbar: false,
    );
    
    windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
    });
  }

  // Configure macOS window utilities for modern look
  if (Platform.isMacOS) {
    await _configureMacosWindowUtils();
  }

  runApp(const PromptyApp());
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
          return MacosApp(
            title: 'Prompty',
            theme: MacosThemeData.light(),
            darkTheme: MacosThemeData.dark(),
            themeMode: settingsProvider.settings.darkMode 
                ? ThemeMode.dark 
                : ThemeMode.light,
            debugShowCheckedModeBanner: false,
            home: const PromptyWindow(),
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
  @override
  void initState() {
    super.initState();
    if (Platform.isMacOS || Platform.isWindows || Platform.isLinux) {
      windowManager.addListener(this);
    }
  }

  @override
  void dispose() {
    if (Platform.isMacOS || Platform.isWindows || Platform.isLinux) {
      windowManager.removeListener(this);
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

  // Tray listener methods
  @override
  void onTrayIconMouseDown() {
    windowManager.show();
    windowManager.focus();
  }

  @override
  void onTrayIconRightMouseDown() {
    trayManager.popUpContextMenu();
  }

  @override
  void onTrayMenuItemClick(MenuItem menuItem) {
    switch (menuItem.key) {
      case 'show_window':
        windowManager.show();
        windowManager.focus();
        break;
      case 'exit_app':
        windowManager.destroy();
        break;
    }
  }
}
