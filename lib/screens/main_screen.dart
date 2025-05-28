import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:provider/provider.dart';
import '../providers/prompt_provider.dart';
import '../providers/settings_provider.dart';
import '../models/prompt.dart';
import '../widgets/blurred_background.dart';
import 'settings_screen.dart';
import 'history_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final TextEditingController _promptController = TextEditingController();
  int _selectedTab = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PromptProvider>().loadPrompts();
      context.read<SettingsProvider>().loadSettings();
    });
  }

  @override
  void dispose() {
    _promptController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = MacosTheme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors:
              isDark
                  ? [const Color(0xFF282828), const Color(0xFF282828)]
                  : [const Color(0xFFF2F2F2), const Color(0xFFF2F2F2)],
        ),
      ),
      child: MacosWindow(
        sidebar: Sidebar(
          minWidth: 200,
          builder: (context, controller) {
            return SidebarItems(
              currentIndex: _selectedTab,
              onChanged: (index) => setState(() => _selectedTab = index),
              itemSize: SidebarItemSize.large,
              items: const [
                SidebarItem(
                  leading: MacosIcon(CupertinoIcons.sparkles),
                  label: Text('Enhance'),
                ),
                SidebarItem(
                  leading: MacosIcon(CupertinoIcons.time),
                  label: Text('History'),
                ),
                SidebarItem(
                  leading: MacosIcon(CupertinoIcons.gear),
                  label: Text('Settings'),
                ),
              ],
            );
          },
        ),
        child: MacosScaffold(
          toolBar: ToolBar(
            title: const Text(''),
            titleWidth: 0.0,
            actions: [
              CustomToolbarItem(
                inToolbarBuilder:
                    (context) => SizedBox(
                      width: 200,
                      child: MacosSearchField(
                        placeholder: 'Search prompts...',
                        onChanged: (value) {
                          // Handle search input changes
                        },
                      ),
                    ),
              ),
            ],
          ),
          children: [
            ContentArea(
              builder: (context, scrollController) {
                return IndexedStack(
                  index: _selectedTab,
                  children: [
                    _buildEnhanceTab(),
                    const HistoryScreen(),
                    const SettingsScreen(),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEnhanceTab() {
    return Consumer<PromptProvider>(
      builder: (context, promptProvider, child) {
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeader(),
              const SizedBox(height: 20),
              _buildPromptInput(promptProvider),
              const SizedBox(height: 20),
              if (promptProvider.isEnhancing) _buildLoadingIndicator(),
              if (promptProvider.error != null)
                _buildErrorMessage(promptProvider),
              const SizedBox(height: 20),
              Expanded(child: _buildEnhancementResults()),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return const SizedBox.shrink(); // Remove the old header as it's now in the toolbar
  }

  Widget _buildPromptInput(PromptProvider promptProvider) {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          MacosTextField(
            controller: _promptController,
            placeholder: '􀈃 Enter your prompt here...',
            maxLines: 4,
            style: MacosTheme.of(context).typography.body,
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${_promptController.text.length} characters',
                style: MacosTheme.of(context).typography.caption1.copyWith(
                  color: MacosColors.secondaryLabelColor,
                ),
              ),
              PushButton(
                controlSize: ControlSize.small,
                onPressed:
                    promptProvider.isEnhancing ||
                            _promptController.text.trim().isEmpty
                        ? null
                        : () => _enhancePrompt(promptProvider),
                child:
                    promptProvider.isEnhancing
                        ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: ProgressCircle(radius: 8),
                        )
                        : const Text('Enhance'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ProgressCircle(radius: 10),
          SizedBox(width: 12),
          Text('Enhancing your prompt...'),
        ],
      ),
    );
  }

  Widget _buildErrorMessage(PromptProvider promptProvider) {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          const MacosIcon(
            Icons.error_outline,
            color: MacosColors.systemRedColor,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              promptProvider.error!,
              style: MacosTheme.of(
                context,
              ).typography.body.copyWith(color: MacosColors.systemRedColor),
            ),
          ),
          MacosIconButton(
            icon: const MacosIcon(Icons.close),
            onPressed: promptProvider.clearError,
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancementResults() {
    return Consumer<PromptProvider>(
      builder: (context, promptProvider, child) {
        if (promptProvider.prompts.isEmpty) {
          return _buildEmptyState();
        }

        final latestPrompt = promptProvider.prompts.first;
        return _buildEnhancementCards(latestPrompt);
      },
    );
  }

  Widget _buildEmptyState() {
    return Container(
      decoration: BoxDecoration(
        color: MacosTheme.of(context).canvasColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: MacosColors.separatorColor),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const MacosIcon(
              Icons.lightbulb_outline,
              size: 64,
              color: MacosColors.tertiaryLabelColor,
            ),
            const SizedBox(height: 16),
            Text(
              'Your enhanced prompts will appear here',
              style: MacosTheme.of(context).typography.headline.copyWith(
                color: MacosColors.secondaryLabelColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Enter a prompt above and click "Enhance" to get started',
              style: MacosTheme.of(
                context,
              ).typography.body.copyWith(color: MacosColors.tertiaryLabelColor),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEnhancementCards(Prompt prompt) {
    final styles = [
      (
        'Professional',
        prompt.professionalVersion,
        EnhancementStyle.professional,
      ),
      ('Creative', prompt.creativeVersion, EnhancementStyle.creative),
      ('Technical', prompt.technicalVersion, EnhancementStyle.technical),
    ];

    return Row(
      children:
          styles.map((style) {
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: _buildEnhancementCard(style.$1, style.$2, style.$3),
              ),
            );
          }).toList(),
    );
  }

  Widget _buildEnhancementCard(
    String title,
    String? content,
    EnhancementStyle style,
  ) {
    return GlassCard(
      child: SizedBox(
        height: 300,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _getStyleColor(style).withValues(alpha: 0.1),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: MacosTheme.of(context).typography.headline
                            .copyWith(fontWeight: FontWeight.w600),
                      ),
                      Text(
                        style.description,
                        style: MacosTheme.of(context).typography.caption1
                            .copyWith(color: MacosColors.secondaryLabelColor),
                      ),
                    ],
                  ),
                  if (content != null)
                    MacosIconButton(
                      icon: const MacosIcon(Icons.copy),
                      onPressed: () => _copyToClipboard(content),
                    ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child:
                    content != null
                        ? SingleChildScrollView(
                          child: Text(
                            content,
                            style: MacosTheme.of(context).typography.body,
                          ),
                        )
                        : Center(
                          child: Text(
                            'Enhancement will appear here',
                            style: MacosTheme.of(
                              context,
                            ).typography.body.copyWith(
                              color: MacosColors.tertiaryLabelColor,
                            ),
                          ),
                        ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStyleColor(EnhancementStyle style) {
    switch (style) {
      case EnhancementStyle.professional:
        return MacosColors.systemBlueColor;
      case EnhancementStyle.creative:
        return MacosColors.systemPurpleColor;
      case EnhancementStyle.technical:
        return MacosColors.systemGreenColor;
    }
  }

  void _enhancePrompt(PromptProvider promptProvider) {
    final text = _promptController.text.trim();
    if (text.isNotEmpty) {
      promptProvider.enhancePrompt(text);
      _promptController.clear();
    }
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    // Show a brief success indicator
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Copied to clipboard!'),
          duration: Duration(seconds: 1),
        ),
      );
    }
  }
}
