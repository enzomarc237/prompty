import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:macos_ui/macos_ui.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _promptController = TextEditingController();
  final List<TextEditingController> _resultControllers = List.generate(
    3,
    (_) => TextEditingController(),
  );
  bool _isLoading = false;

  @override
  void dispose() {
    _promptController.dispose();
    for (var controller in _resultControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _improvePrompt() async {
    if (_promptController.text.isEmpty) {
      showMacosAlertDialog(
        context: context,
        builder:
            (context) => MacosAlertDialog(
              appIcon: const MacosIcon(CupertinoIcons.exclamationmark_triangle),
              title: const Text('Erreur'),
              message: const Text(
                'Veuillez entrer un prompt avant de continuer.',
              ),
              primaryButton: PushButton(
                controlSize: ControlSize.large,
                child: const Text('OK'),
                onPressed: () => Navigator.pop(context),
              ),
            ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Simulation de l'appel API (à remplacer par l'appel réel)
      await Future.delayed(const Duration(seconds: 2));

      // Exemple de résultats (à remplacer par les résultats réels)
      final results = [
        'Version professionnelle du prompt...',
        'Version créative du prompt...',
        'Version technique du prompt...',
      ];

      for (var i = 0; i < _resultControllers.length; i++) {
        _resultControllers[i].text = results[i];
      }
    } catch (e) {
      showMacosAlertDialog(
        context: context,
        builder:
            (context) => MacosAlertDialog(
              appIcon: const MacosIcon(CupertinoIcons.exclamationmark_triangle),
              title: const Text('Erreur'),
              message: Text('Une erreur est survenue: $e'),
              primaryButton: PushButton(
                controlSize: ControlSize.large,
                child: const Text('OK'),
                onPressed: () => Navigator.pop(context),
              ),
            ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _copyToClipboard(String text) async {
    await Clipboard.setData(ClipboardData(text: text));
    if (!mounted) return;

    showMacosSheet(
      context: context,
      builder:
          (context) => MacosSheet(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const MacosIcon(
                    CupertinoIcons.check_mark_circled,
                    size: 32,
                    color: CupertinoColors.activeGreen,
                  ),
                  const SizedBox(height: 16),
                  const Text('Copié dans le presse-papiers'),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
    );
  }

  Widget _buildResultBox(
    String title,
    TextEditingController controller,
    IconData icon,
  ) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: MacosTheme.of(context).dividerColor.withOpacity(0.5),
          width: 1,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: MacosTheme.of(context).canvasColor.withOpacity(0.5),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(8),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    MacosIcon(
                      icon,
                      size: 16,
                      color: MacosTheme.of(context).primaryColor,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      title,
                      style: MacosTheme.of(
                        context,
                      ).typography.body.copyWith(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                MacosTooltip(
                  message: 'Copier',
                  child: MacosIconButton(
                    icon: MacosIcon(
                      CupertinoIcons.doc_on_doc,
                      size: 16,
                      color: MacosTheme.of(context).primaryColor,
                    ),
                    onPressed: () => _copyToClipboard(controller.text),
                    boxConstraints: const BoxConstraints(
                      minHeight: 20,
                      minWidth: 20,
                      maxHeight: 20,
                      maxWidth: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: MacosTextField(
                  controller: controller,
                  placeholder: 'Le résultat apparaîtra ici...',
                  maxLines: 4,
                  enabled: false,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6),
                    color: MacosColors.textBackgroundColor,
                  ),
                ),
              ),
              if (_isLoading)
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      color: MacosColors.textBackgroundColor.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Center(child: ProgressCircle(value: null)),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MacosScaffold(
      toolBar: ToolBar(
        title: const Text('Prompty'),
        titleWidth: 200.0,
        actions: [
          ToolBarIconButton(
            label: "Nouveau",
            icon: const MacosIcon(CupertinoIcons.add_circled),
            onPressed: () {
              _promptController.clear();
              for (var controller in _resultControllers) {
                controller.clear();
              }
            },
            showLabel: false,
          ),
          const ToolBarSpacer(),
          ToolBarIconButton(
            label: "Paramètres",
            icon: const MacosIcon(CupertinoIcons.settings),
            onPressed: () {},
            showLabel: false,
          ),
        ],
      ),
      children: [
        ContentArea(
          builder: (context, scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const MacosIcon(CupertinoIcons.text_cursor, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Prompt initial',
                        style: MacosTheme.of(context).typography.title3,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  MacosTextField(
                    controller: _promptController,
                    placeholder: 'Entrez votre prompt ici...',
                    maxLines: 5,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: MacosColors.textBackgroundColor,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: PushButton(
                      controlSize: ControlSize.large,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const MacosIcon(CupertinoIcons.wand_stars, size: 16),
                          const SizedBox(width: 8),
                          const Text('Améliorer le prompt'),
                        ],
                      ),
                      onPressed: _isLoading ? null : _improvePrompt,
                    ),
                  ),
                  const SizedBox(height: 32),
                  Row(
                    children: [
                      const MacosIcon(CupertinoIcons.sparkles, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Versions améliorées',
                        style: MacosTheme.of(context).typography.title3,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildResultBox(
                    'Style Professionnel',
                    _resultControllers[0],
                    CupertinoIcons.briefcase,
                  ),
                  const SizedBox(height: 16),
                  _buildResultBox(
                    'Style Créatif',
                    _resultControllers[1],
                    CupertinoIcons.lightbulb,
                  ),
                  const SizedBox(height: 16),
                  _buildResultBox(
                    'Style Technique',
                    _resultControllers[2],
                    CupertinoIcons.gear,
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}
