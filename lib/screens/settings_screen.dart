import 'package:flutter/material.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';
import '../utils/export_utils.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final TextEditingController _apiKeyController = TextEditingController();
  bool _isApiKeyVisible = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final settings = context.read<SettingsProvider>().settings;
      _apiKeyController.text = settings.apiKey;
    });
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settingsProvider, child) {
        if (settingsProvider.isLoading) {
          return const Center(child: ProgressCircle());
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeader(),
              const SizedBox(height: 20),
              _buildAPISection(settingsProvider),
              const SizedBox(height: 20),
              _buildAppearanceSection(settingsProvider),
              const SizedBox(height: 20),
              _buildBehaviorSection(settingsProvider),
              const SizedBox(height: 20),
              _buildAboutSection(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Settings',
          style: MacosTheme.of(
            context,
          ).typography.largeTitle.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          'Configure Prompty to suit your preferences',
          style: MacosTheme.of(
            context,
          ).typography.body.copyWith(color: MacosColors.secondaryLabelColor),
        ),
      ],
    );
  }

  Widget _buildAPISection(SettingsProvider settingsProvider) {
    return _buildSection(
      'AI Provider',
      'Configure your AI service for prompt enhancement',
      [
        _buildDropdown(
          'Provider',
          settingsProvider.settings.apiProvider,
          ['openai', 'openrouter', 'gemini'],
          (value) {
            settingsProvider.updateApiProvider(value!);
            // Load models for the new provider
            if (settingsProvider.settings.apiKey.isNotEmpty) {
              settingsProvider.loadAvailableModels();
            }
          },
          {
            'openai': 'OpenAI (GPT)',
            'openrouter': 'OpenRouter',
            'gemini': 'Google Gemini',
          },
        ),
        const SizedBox(height: 16),
        _buildAPIKeyField(settingsProvider),
        const SizedBox(height: 16),
        _buildModelSelection(settingsProvider),
        const SizedBox(height: 12),
        _buildHelpText('Get your API key from your provider\'s dashboard'),
      ],
    );
  }

  Widget _buildAPIKeyField(SettingsProvider settingsProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'API Key',
              style: MacosTheme.of(
                context,
              ).typography.body.copyWith(fontWeight: FontWeight.w500),
            ),
            MacosIconButton(
              icon: MacosIcon(
                _isApiKeyVisible ? Icons.visibility_off : Icons.visibility,
              ),
              onPressed:
                  () => setState(() => _isApiKeyVisible = !_isApiKeyVisible),
            ),
          ],
        ),
        const SizedBox(height: 8),
        MacosTextField(
          controller: _apiKeyController,
          placeholder: 'Enter your API key...',
          obscureText: !_isApiKeyVisible,
          onChanged: (value) {
            settingsProvider.updateApiKey(value);
            // Load models when API key changes
            if (value.isNotEmpty) {
              Future.delayed(const Duration(milliseconds: 500), () {
                settingsProvider.loadAvailableModels();
              });
            }
          },
          suffix:
              _apiKeyController.text.isNotEmpty
                  ? MacosIconButton(
                    icon: const MacosIcon(
                      Icons.check_circle,
                      color: MacosColors.systemGreenColor,
                    ),
                    onPressed: null,
                  )
                  : null,
        ),
      ],
    );
  }

  Widget _buildModelSelection(SettingsProvider settingsProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Model',
              style: MacosTheme.of(
                context,
              ).typography.body.copyWith(fontWeight: FontWeight.w500),
            ),
            if (settingsProvider.isLoadingModels)
              const SizedBox(
                width: 16,
                height: 16,
                child: ProgressCircle(value: null),
              )
            else if (settingsProvider.settings.apiKey.isNotEmpty)
              MacosIconButton(
                icon: const MacosIcon(Icons.refresh),
                onPressed: settingsProvider.loadAvailableModels,
              ),
          ],
        ),
        const SizedBox(height: 8),
        if (settingsProvider.availableModels.isEmpty &&
            !settingsProvider.isLoadingModels)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: MacosColors.systemGrayColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: MacosColors.separatorColor),
            ),
            child: Row(
              children: [
                const MacosIcon(Icons.info_outline, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    settingsProvider.settings.apiKey.isEmpty
                        ? 'Enter API key to load available models'
                        : 'Click refresh to load models',
                    style: MacosTheme.of(context).typography.caption1,
                  ),
                ),
              ],
            ),
          )
        else
          MacosPopupButton<String>(
            value:
                settingsProvider.availableModels.any(
                      (m) => m.id == settingsProvider.settings.selectedModel,
                    )
                    ? settingsProvider.settings.selectedModel
                    : settingsProvider.availableModels.isNotEmpty
                    ? settingsProvider.availableModels.first.id
                    : settingsProvider.settings.selectedModel,
            onChanged:
                settingsProvider.availableModels.isNotEmpty
                    ? (value) => settingsProvider.updateSelectedModel(value!)
                    : null,
            items:
                settingsProvider.availableModels.map((model) {
                  return MacosPopupMenuItem<String>(
                    value: model.id,
                    child: Text(model.name),
                  );
                }).toList(),
          ),
      ],
    );
  }

  Widget _buildAppearanceSection(SettingsProvider settingsProvider) {
    return _buildSection(
      'Appearance',
      'Customize the look and feel of the app',
      [
        _buildToggle(
          'Dark Mode',
          'Use dark theme throughout the app',
          settingsProvider.settings.darkMode,
          settingsProvider.updateDarkMode,
        ),
      ],
    );
  }

  Widget _buildBehaviorSection(SettingsProvider settingsProvider) {
    return _buildSection('Behavior', 'Configure how the app behaves', [
      _buildToggle(
        'Start Minimized',
        'Launch the app minimized to the system tray',
        settingsProvider.settings.startMinimized,
        settingsProvider.updateStartMinimized,
      ),
      const SizedBox(height: 16),
      _buildToggle(
        'Launch at Startup',
        'Automatically start Prompty when you log in',
        settingsProvider.settings.launchAtStartup,
        settingsProvider.updateLaunchAtStartup,
      ),
      const SizedBox(height: 16),
      _buildToggle(
        'Notifications',
        'Show notifications for completed enhancements',
        settingsProvider.settings.enableNotifications,
        settingsProvider.updateEnableNotifications,
      ),
    ]);
  }

  Widget _buildAboutSection() {
    return _buildSection('About', 'Information about Prompty', [
      _buildInfoRow('Version', '1.0.0'),
      const SizedBox(height: 12),
      _buildInfoRow('Build', '2024.1'),
      const SizedBox(height: 20),
      Row(
        children: [
          Expanded(
            child: PushButton(
              controlSize: ControlSize.large,
              onPressed: _resetSettings,
              child: const Text('Reset Settings'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: PushButton(
              controlSize: ControlSize.large,
              onPressed: _exportSettings,
              child: const Text('Export Settings'),
            ),
          ),
        ],
      ),
    ]);
  }

  Widget _buildSection(
    String title,
    String description,
    List<Widget> children,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: MacosTheme.of(context).canvasColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: MacosColors.separatorColor),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: MacosTheme.of(
                context,
              ).typography.headline.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            Text(
              description,
              style: MacosTheme.of(context).typography.caption1.copyWith(
                color: MacosColors.secondaryLabelColor,
              ),
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown<T>(
    String label,
    T value,
    List<T> items,
    ValueChanged<T?> onChanged,
    Map<T, String>? displayNames,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: MacosTheme.of(
            context,
          ).typography.body.copyWith(fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        MacosPopupButton<T>(
          value: value,
          onChanged: onChanged,
          items:
              items
                  .map(
                    (item) => MacosPopupMenuItem(
                      value: item,
                      child: Text(displayNames?[item] ?? item.toString()),
                    ),
                  )
                  .toList(),
        ),
      ],
    );
  }

  Widget _buildToggle(
    String title,
    String description,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: MacosTheme.of(
                  context,
                ).typography.body.copyWith(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 2),
              Text(
                description,
                style: MacosTheme.of(context).typography.caption1.copyWith(
                  color: MacosColors.secondaryLabelColor,
                ),
              ),
            ],
          ),
        ),
        MacosSwitch(value: value, onChanged: onChanged),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: MacosTheme.of(context).typography.body),
        Text(
          value,
          style: MacosTheme.of(
            context,
          ).typography.body.copyWith(color: MacosColors.secondaryLabelColor),
        ),
      ],
    );
  }

  Widget _buildHelpText(String text) {
    return Text(
      text,
      style: MacosTheme.of(
        context,
      ).typography.caption2.copyWith(color: MacosColors.tertiaryLabelColor),
    );
  }

  void _resetSettings() {
    showMacosAlertDialog(
      context: context,
      builder:
          (context) => MacosAlertDialog(
            appIcon: const MacosIcon(Icons.warning, size: 64),
            title: const Text('Reset Settings'),
            message: const Text(
              'Are you sure you want to reset all settings to their default values? This action cannot be undone.',
            ),
            primaryButton: PushButton(
              controlSize: ControlSize.large,
              onPressed: () {
                Navigator.of(context).pop();
                context.read<SettingsProvider>().resetSettings();
                _apiKeyController.clear();
              },
              child: const Text('Reset'),
            ),
            secondaryButton: PushButton(
              controlSize: ControlSize.large,
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
          ),
    );
  }

  Future<void> _exportSettings() async {
    final settingsProvider = context.read<SettingsProvider>();
    final settings = settingsProvider.settings;

    // Convert settings to a map
    final Map<String, dynamic> settingsMap = {
      'apiProvider': settings.apiProvider,
      'selectedModel': settings.selectedModel,
      'darkMode': settings.darkMode,
      'startMinimized': settings.startMinimized,
      'launchAtStartup': settings.launchAtStartup,
      'enableNotifications': settings.enableNotifications,
      'defaultCategory': settings.defaultCategory,
      'customStyles': settings.customStyles,
      // Don't include API key for security reasons
      'apiKey': '**********',
    };

    final success = await ExportUtils.exportSettings(context, settingsMap);
    if (success && mounted) {
      ExportUtils.showExportSuccess(context);
    }
  }
}
