import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:provider/provider.dart';
import 'package:contextual_menu/contextual_menu.dart';
import '../providers/prompt_provider.dart';
import '../models/prompt.dart' as prompt_model;
import '../utils/export_utils.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final TextEditingController _searchController = TextEditingController();
  prompt_model.Prompt? _selectedPrompt;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PromptProvider>(
      builder: (context, promptProvider, child) {
        return Row(
          children: [
            Expanded(flex: 1, child: _buildPromptList(promptProvider)),
            const VerticalDivider(width: 1),
            Expanded(flex: 2, child: _buildPromptDetail()),
          ],
        );
      },
    );
  }

  Widget _buildPromptList(PromptProvider promptProvider) {
    return Column(
      children: [
        _buildSearchHeader(promptProvider),
        Expanded(
          child:
              promptProvider.isLoading
                  ? const Center(child: ProgressCircle())
                  : promptProvider.prompts.isEmpty
                  ? _buildEmptyList()
                  : _buildPromptListView(promptProvider),
        ),
      ],
    );
  }

  Widget _buildSearchHeader(PromptProvider promptProvider) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: MacosTheme.of(context).brightness == Brightness.dark
            ? MacosColors.controlBackgroundColor.darkColor
            : MacosColors.controlBackgroundColor.color,
        border: Border(bottom: BorderSide(color: MacosColors.separatorColor)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              '${promptProvider.prompts.length} prompts',
              style: MacosTheme.of(context).typography.headline.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          MacosIconButton(
            icon: MacosIcon(
              promptProvider.showFavoritesOnly
                  ? CupertinoIcons.bookmark_fill
                  : CupertinoIcons.bookmark,
              color: promptProvider.showFavoritesOnly
                  ? MacosColors.systemBlueColor
                  : MacosColors.secondaryLabelColor,
              ),
            onPressed: promptProvider.toggleFavoritesFilter,
            semanticLabel: 'Filter by bookmarks',
          ),
        ],
      ),
    );
  }
  
  // Show export options dialog
  void _showExportOptions(PromptProvider promptProvider) {
    showMacosAlertDialog(
      context: context,
      builder: (context) => MacosAlertDialog(
        appIcon: const Icon(Icons.file_download, size: 64),
        title: const Text('Export Prompts'),
        message: const Text('Choose an export option:'),
        primaryButton: PushButton(
          controlSize: ControlSize.large,
          onPressed: () {
            Navigator.of(context).pop();
            _exportAllPrompts(promptProvider.prompts);
          },
          child: const Text('Export All Prompts'),
        ),
        secondaryButton: PushButton(
          controlSize: ControlSize.large,
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
      ),
    );
  }
  
  // Export all prompts
  Future<void> _exportAllPrompts(List<prompt_model.Prompt> prompts) async {
    if (!mounted) return;
    
    final success = await ExportUtils.exportAllPrompts(context, prompts);
    if (success && mounted) {
      ExportUtils.showExportSuccess(context);
    }
  }

  Widget _buildEmptyList() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const MacosIcon(
            CupertinoIcons.doc_on_clipboard,
            size: 64,
            color: MacosColors.tertiaryLabelColor,
          ),
          const SizedBox(height: 16),
          Text(
            'No prompts found',
            style: MacosTheme.of(context).typography.headline.copyWith(
              color: MacosColors.secondaryLabelColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Create your first prompt to see it here',
            style: MacosTheme.of(
              context,
            ).typography.body.copyWith(color: MacosColors.tertiaryLabelColor),
          ),
        ],
      ),
    );
  }

  Widget _buildPromptListView(PromptProvider promptProvider) {
    return ListView.builder(
      itemCount: promptProvider.prompts.length,
      itemBuilder: (context, index) {
        final prompt = promptProvider.prompts[index];
        final isSelected = _selectedPrompt?.id == prompt.id;

        return _buildPromptListItem(prompt, isSelected, promptProvider);
      },
    );
  }

  Widget _buildPromptListItem(
    prompt_model.Prompt prompt,
    bool isSelected,
    PromptProvider promptProvider,
  ) {
    return GestureDetector(
      onTap: () => setState(() => _selectedPrompt = prompt),
      onSecondaryTapDown: (details) {
        popUpContextualMenu(
          Menu(
            items: [
              MenuItem(
                label:
                    prompt.isFavorite
                        ? 'Remove from favorites'
                        : 'Add to favorites',
                onClick:
                    (_) => _handlePromptAction(
                      'favorite',
                      prompt,
                      promptProvider,
                    ),
              ),
              MenuItem(
                label: 'Copy original',
                onClick:
                    (_) => _handlePromptAction('copy', prompt, promptProvider),
              ),
              MenuItem.submenu(
                label: 'Export',
                submenu: Menu(
                  items: [
                    MenuItem(
                      label: 'Export as JSON',
                      onClick: (_) => _handlePromptAction('export_json', prompt, promptProvider),
                    ),
                    MenuItem(
                      label: 'Export Professional Version',
                      onClick: (_) => _handlePromptAction('export_professional', prompt, promptProvider),
                    ),
                    MenuItem(
                      label: 'Export Creative Version',
                      onClick: (_) => _handlePromptAction('export_creative', prompt, promptProvider),
                    ),
                    MenuItem(
                      label: 'Export Technical Version',
                      onClick: (_) => _handlePromptAction('export_technical', prompt, promptProvider),
                    ),
                  ],
                ),
              ),
              MenuItem(
                label: 'Delete',
                onClick:
                    (_) => _handlePromptAction('delete', prompt, promptProvider),
              ),
            ],
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected
              ? MacosTheme.of(context).primaryColor.withOpacity(0.2)
              : MacosTheme.of(context).brightness == Brightness.dark
                  ? MacosColors.controlBackgroundColor.darkColor.withOpacity(0.5)
                  : MacosColors.controlBackgroundColor.color.withOpacity(0.5),
          borderRadius: BorderRadius.circular(6.0),
          border: isSelected
              ? Border.all(color: MacosTheme.of(context).primaryColor, width: 1.5)
              : Border.all(color: MacosColors.separatorColor.withOpacity(0.5)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    prompt.originalText,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: MacosTheme.of(context).typography.body,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatDate(prompt.createdAt),
                    style: MacosTheme.of(context).typography.caption1
                        .copyWith(color: MacosColors.secondaryLabelColor),
                  ),
                ],
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (prompt.isFavorite)
                  const MacosIcon(
                    CupertinoIcons.heart_fill,
                    color: MacosColors.systemRedColor,
                    size: 16,
                  ),
                GestureDetector(
                  onTapDown: (details) {
                    popUpContextualMenu(
                      Menu(
                        items: [
                          MenuItem(
                            label:
                                prompt.isFavorite
                                    ? 'Remove from favorites'
                                    : 'Add to favorites',
                            onClick:
                                (_) => _handlePromptAction(
                                  'favorite',
                                  prompt,
                                  promptProvider,
                                ),
                          ),
                          MenuItem(
                            label: 'Copy original',
                            onClick:
                                (_) => _handlePromptAction(
                                  'copy',
                                  prompt,
                                  promptProvider,
                                ),
                          ),
                          MenuItem(
                            label: 'Delete',
                            onClick:
                                (_) => _handlePromptAction(
                                  'delete',
                                  prompt,
                                  promptProvider,
                                ),
                          ),
                        ],
                      ),
                    );
                  },
                  child: const MacosIcon(CupertinoIcons.ellipsis),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPromptDetail() {
    if (_selectedPrompt == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const MacosIcon(
              CupertinoIcons.doc_text_search,
              size: 64,
              color: MacosColors.tertiaryLabelColor,
            ),
            const SizedBox(height: 16),
            Text(
              'Select a prompt to view details',
              style: MacosTheme.of(context).typography.headline.copyWith(
                color: MacosColors.secondaryLabelColor,
              ),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildPromptDetailHeader(),
          const SizedBox(height: 20),
          _buildOriginalPrompt(),
          const SizedBox(height: 20),
          _buildEnhancementTabs(),
        ],
      ),
    );
  }

  Widget _buildPromptDetailHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Prompt Details',
              style: MacosTheme.of(
                context,
              ).typography.largeTitle.copyWith(fontWeight: FontWeight.w700),
            ),
            Text(
              'Created ${_formatDate(_selectedPrompt!.createdAt)}',
              style: MacosTheme.of(context).typography.body.copyWith(
                color: MacosColors.secondaryLabelColor,
              ),
            ),
          ],
        ),
        Row(
          children: [
            Consumer<PromptProvider>(
              builder: (context, promptProvider, child) {
                return MacosIconButton(
                  icon: MacosIcon(
                    _selectedPrompt!.isFavorite
                        ? CupertinoIcons.heart_fill
                        : CupertinoIcons.heart,
                    color:
                        _selectedPrompt!.isFavorite
                            ? MacosColors.systemRedColor
                            : MacosColors.secondaryLabelColor,
                  ),
                  onPressed:
                      () => promptProvider.toggleFavorite(_selectedPrompt!.id),
                );
              },
            ),
            const SizedBox(width: 8),
            MacosIconButton(
              icon: MacosIcon(
                // Assuming a bookmarked property exists for _selectedPrompt
                false // Placeholder for _selectedPrompt!.isBookmarked
                    ? CupertinoIcons.bookmark_fill
                    : CupertinoIcons.bookmark,
                color: false // Placeholder for _selectedPrompt!.isBookmarked
                    ? MacosColors.systemBlueColor
                    : MacosColors.secondaryLabelColor,
              ),
              onPressed: () {
                // Handle bookmark toggle
                // promptProvider.toggleBookmark(_selectedPrompt!.id); // Uncomment when functionality is added
              },
              semanticLabel: 'Bookmark prompt',
            ),
            const SizedBox(width: 8),
            MacosIconButton(
              icon: const MacosIcon(CupertinoIcons.share),
              onPressed: () {
                // Handle share action
              },
              semanticLabel: 'Share prompt',
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildOriginalPrompt() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: MacosTheme.of(context).brightness == Brightness.dark
            ? MacosColors.controlBackgroundColor.darkColor
            : MacosColors.controlBackgroundColor.color,
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(color: MacosColors.separatorColor.withOpacity(0.7), width: 1.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Original Prompt',
            style: MacosTheme.of(
              context,
            ).typography.headline.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(
            _selectedPrompt!.originalText,
            style: MacosTheme.of(context).typography.body,
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancementTabs() {
    final enhancements = [
      (
        'Professional',
        _selectedPrompt!.professionalVersion,
        prompt_model.EnhancementStyle.professional,
      ),
      ('Creative', _selectedPrompt!.creativeVersion, prompt_model.EnhancementStyle.creative),
      ('Technical', _selectedPrompt!.technicalVersion, prompt_model.EnhancementStyle.technical),
    ];

    return Column(
      children:
          enhancements
              .map(
                (enhancement) => _buildEnhancementSection(
                  enhancement.$1,
                  enhancement.$2,
                  enhancement.$3,
                ),
              )
              .toList(),
    );
  }

  Widget _buildEnhancementSection(
    String title,
    String? content,
    prompt_model.EnhancementStyle style,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: MacosTheme.of(context).brightness == Brightness.dark
            ? MacosColors.controlBackgroundColor.darkColor
            : MacosColors.controlBackgroundColor.color,
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(color: MacosColors.separatorColor.withOpacity(0.7), width: 1.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _getStyleColor(style).withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
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
                    icon: const MacosIcon(CupertinoIcons.doc_on_doc),
                    onPressed: () => _copyToClipboard(content),
                    semanticLabel: 'Copy to clipboard',
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
    );
  }

  Color _getStyleColor(prompt_model.EnhancementStyle style) {
    switch (style) {
      case prompt_model.EnhancementStyle.professional:
        return MacosColors.systemBlueColor;
      case prompt_model.EnhancementStyle.creative:
        return MacosColors.systemPurpleColor;
      case prompt_model.EnhancementStyle.technical:
        return MacosColors.systemGreenColor;
    }
    return Colors.transparent;
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today ${_formatTime(date)}';
    } else if (difference.inDays == 1) {
      return 'Yesterday ${_formatTime(date)}';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  String _formatTime(DateTime date) {
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  void _handlePromptAction(
    String action,
    prompt_model.Prompt prompt,
    PromptProvider promptProvider,
  ) {
    switch (action) {
      case 'favorite':
        promptProvider.toggleFavorite(prompt.id);
        if (_selectedPrompt?.id == prompt.id) {
          setState(() {
            _selectedPrompt = prompt.copyWith(isFavorite: !prompt.isFavorite);
          });
        }
        break;
      case 'copy':
        Clipboard.setData(ClipboardData(text: prompt.originalText));
        break;
      case 'export_json': 
        ExportUtils.exportPrompt(context, prompt);
        break;
      case 'export_professional':
        ExportUtils.exportPromptAsText(context, prompt, prompt_model.EnhancementStyle.professional);
        break;
      case 'export_creative':
        ExportUtils.exportPromptAsText(context, prompt, prompt_model.EnhancementStyle.creative);
        break;
      case 'export_technical':
        ExportUtils.exportPromptAsText(context, prompt, prompt_model.EnhancementStyle.technical);
        break;
      case 'delete':
        promptProvider.deletePrompt(prompt.id);
        setState(() {
          _selectedPrompt = null;
        });
        break;
    }
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    // Show a brief success indicator
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Copied to clipboard!'),
          duration: const Duration(seconds: 1),
        ),
      );
    }
  }
}
