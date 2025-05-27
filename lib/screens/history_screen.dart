import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:provider/provider.dart';
import '../providers/prompt_provider.dart';
import '../models/prompt.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final TextEditingController _searchController = TextEditingController();
  Prompt? _selectedPrompt;

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
            Expanded(
              flex: 1,
              child: _buildPromptList(promptProvider),
            ),
            const VerticalDivider(width: 1),
            Expanded(
              flex: 2,
              child: _buildPromptDetail(),
            ),
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
          child: promptProvider.isLoading
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: MacosTheme.of(context).canvasColor,
        border: Border(
          bottom: BorderSide(color: MacosColors.separatorColor),
        ),
      ),
      child: Column(
        children: [
          MacosSearchField(
            controller: _searchController,
            placeholder: 'Search prompts...',
            onChanged: promptProvider.search,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Text(
                  '${promptProvider.prompts.length} prompts',
                  style: MacosTheme.of(context).typography.caption1.copyWith(
                    color: MacosColors.secondaryLabelColor,
                  ),
                ),
              ),
              MacosIconButton(
                icon: MacosIcon(
                  promptProvider.showFavoritesOnly
                      ? Icons.favorite
                      : Icons.favorite_border,
                  color: promptProvider.showFavoritesOnly
                      ? MacosColors.systemRedColor
                      : MacosColors.secondaryLabelColor,
                ),
                onPressed: promptProvider.toggleFavoritesFilter,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyList() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const MacosIcon(
            Icons.history,
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
            style: MacosTheme.of(context).typography.body.copyWith(
              color: MacosColors.tertiaryLabelColor,
            ),
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

  Widget _buildPromptListItem(Prompt prompt, bool isSelected, PromptProvider promptProvider) {
    return Container(
      decoration: BoxDecoration(
        color: isSelected
            ? MacosColors.controlAccentColor.withOpacity(0.1)
            : Colors.transparent,
        border: Border(
          bottom: BorderSide(
            color: MacosColors.separatorColor.withOpacity(0.5),
          ),
        ),
      ),
      child: GestureDetector(
        onTap: () => setState(() => _selectedPrompt = prompt),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                      style: MacosTheme.of(context).typography.caption1.copyWith(
                        color: MacosColors.secondaryLabelColor,
                      ),
                    ),
                    if (prompt.tags.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Wrap(
                        spacing: 4,
                        children: prompt.tags.take(2).map((tag) => Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: MacosColors.systemGrayColor.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            tag,
                            style: MacosTheme.of(context).typography.caption2,
                          ),
                        )).toList(),
                      ),
                    ],
                  ],
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (prompt.isFavorite)
                    const MacosIcon(
                      Icons.favorite,
                      color: MacosColors.systemRedColor,
                      size: 16,
                    ),
                  PopupMenuButton<String>(
                    icon: const MacosIcon(Icons.more_horiz),
                    onSelected: (value) => _handlePromptAction(value, prompt, promptProvider),
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'favorite',
                        child: Row(
                          children: [
                            MacosIcon(
                              prompt.isFavorite ? Icons.favorite_border : Icons.favorite,
                            ),
                            const SizedBox(width: 8),
                            Text(prompt.isFavorite ? 'Remove from favorites' : 'Add to favorites'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'copy',
                        child: Row(
                          children: [
                            MacosIcon(Icons.copy),
                            SizedBox(width: 8),
                            Text('Copy original'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            MacosIcon(Icons.delete, color: MacosColors.systemRedColor),
                            SizedBox(width: 8),
                            Text('Delete', style: TextStyle(color: MacosColors.systemRedColor)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
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
              Icons.select_all,
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
              style: MacosTheme.of(context).typography.largeTitle.copyWith(
                fontWeight: FontWeight.w700,
              ),
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
                    _selectedPrompt!.isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: _selectedPrompt!.isFavorite 
                        ? MacosColors.systemRedColor 
                        : MacosColors.secondaryLabelColor,
                  ),
                  onPressed: () => promptProvider.toggleFavorite(_selectedPrompt!.id),
                );
              },
            ),
            MacosIconButton(
              icon: const MacosIcon(Icons.copy),
              onPressed: () => _copyToClipboard(_selectedPrompt!.originalText),
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
        color: MacosTheme.of(context).canvasColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: MacosColors.separatorColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Original Prompt',
            style: MacosTheme.of(context).typography.headline.copyWith(
              fontWeight: FontWeight.w600,
            ),
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
      ('Professional', _selectedPrompt!.professionalVersion, EnhancementStyle.professional),
      ('Creative', _selectedPrompt!.creativeVersion, EnhancementStyle.creative),
      ('Technical', _selectedPrompt!.technicalVersion, EnhancementStyle.technical),
    ];

    return Column(
      children: enhancements.map((enhancement) => 
        _buildEnhancementSection(enhancement.$1, enhancement.$2, enhancement.$3)
      ).toList(),
    );
  }

  Widget _buildEnhancementSection(String title, String? content, EnhancementStyle style) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: MacosTheme.of(context).canvasColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: MacosColors.separatorColor),
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
                      style: MacosTheme.of(context).typography.headline.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      style.description,
                      style: MacosTheme.of(context).typography.caption1.copyWith(
                        color: MacosColors.secondaryLabelColor,
                      ),
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
          Padding(
            padding: const EdgeInsets.all(16),
            child: content != null
                ? Text(
                    content,
                    style: MacosTheme.of(context).typography.body,
                  )
                : Text(
                    'No ${title.toLowerCase()} enhancement available',
                    style: MacosTheme.of(context).typography.body.copyWith(
                      color: MacosColors.tertiaryLabelColor,
                    ),
                  ),
          ),
        ],
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

  void _handlePromptAction(String action, Prompt prompt, PromptProvider promptProvider) {
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
        _copyToClipboard(prompt.originalText);
        break;
      case 'delete':
        _showDeleteConfirmation(prompt, promptProvider);
        break;
    }
  }

  void _showDeleteConfirmation(Prompt prompt, PromptProvider promptProvider) {
    showMacosAlertDialog(
      context: context,
      builder: (context) => MacosAlertDialog(
        appIcon: const MacosIcon(Icons.warning, size: 64),
        title: const Text('Delete Prompt'),
        message: const Text('Are you sure you want to delete this prompt? This action cannot be undone.'),
        primaryButton: PushButton(
          controlSize: ControlSize.large,
          onPressed: () {
            Navigator.of(context).pop();
            promptProvider.deletePrompt(prompt.id);
            if (_selectedPrompt?.id == prompt.id) {
              setState(() => _selectedPrompt = null);
            }
          },
          child: const Text('Delete'),
        ),
        secondaryButton: PushButton(
          controlSize: ControlSize.large,
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
      ),
    );
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    // Show a brief success indicator using macOS native toast
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