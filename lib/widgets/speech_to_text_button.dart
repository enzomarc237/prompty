import 'package:flutter/material.dart';
import 'package:macos_ui/macos_ui.dart';
import '../services/speech_service.dart';

/// A button that activates speech-to-text functionality
class SpeechToTextButton extends StatefulWidget {
  /// Callback when speech is recognized
  final Function(String) onSpeechResult;
  
  /// Button size
  final double size;
  
  /// Button color
  final Color? color;
  
  /// Button tooltip
  final String? tooltip;

  const SpeechToTextButton({
    super.key,
    required this.onSpeechResult,
    this.size = 24.0,
    this.color,
    this.tooltip,
  });

  @override
  State<SpeechToTextButton> createState() => _SpeechToTextButtonState();
}

class _SpeechToTextButtonState extends State<SpeechToTextButton> with SingleTickerProviderStateMixin {
  final SpeechService _speechService = SpeechService.instance;
  bool _isListening = false;
  bool _isAvailable = false;
  String _recognizedText = '';
  
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    
    // Initialize animation
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    
    _animation = Tween<double>(begin: 1.0, end: 1.3)
      .animate(CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ));
    
    // Check if speech recognition is available
    _checkAvailability();
    
    // Listen for speech recognition results
    _speechService.resultStream.listen((result) {
      setState(() {
        _recognizedText = result;
      });
      widget.onSpeechResult(result);
    });
    
    // Listen for speech recognition status changes
    _speechService.statusStream.listen((isListening) {
      setState(() {
        _isListening = isListening;
      });
      
      if (isListening) {
        _animationController.repeat(reverse: true);
      } else {
        _animationController.stop();
        _animationController.reset();
      }
    });
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
  
  /// Check if speech recognition is available
  Future<void> _checkAvailability() async {
    final available = await _speechService.isAvailable();
    if (mounted) {
      setState(() {
        _isAvailable = available;
      });
    }
  }
  
  /// Toggle speech recognition
  Future<void> _toggleListening() async {
    if (_isListening) {
      await _speechService.stopListening();
    } else {
      if (!_isAvailable) {
        final available = await _speechService.isAvailable();
        if (!available) {
          _showSpeechNotAvailableDialog();
          return;
        }
      }
      
      await _speechService.startListening();
    }
  }
  
  /// Show dialog when speech recognition is not available
  void _showSpeechNotAvailableDialog() {
    showMacosAlertDialog(
      context: context,
      builder: (context) => MacosAlertDialog(
        appIcon: const Icon(Icons.mic_off, size: 64, color: Colors.red),
        title: const Text('Speech Recognition Unavailable'),
        message: const Text(
          'Speech recognition is not available on this device. Please check your microphone permissions and try again.',
        ),
        primaryButton: PushButton(
          controlSize: ControlSize.large,
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('OK'),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final buttonColor = widget.color ?? 
        (_isListening 
            ? MacosColors.systemRedColor 
            : MacosTheme.of(context).brightness == Brightness.dark
                ? MacosColors.controlAccentColor
                : MacosColors.controlAccentColor);
    
    return Tooltip(
      message: widget.tooltip ?? 'Speech to text',
      child: ScaleTransition(
        scale: _animation,
        child: MacosIconButton(
          icon: Icon(
            _isListening ? Icons.mic : Icons.mic_none,
            color: buttonColor,
            size: widget.size,
          ),
          onPressed: _toggleListening,
          boxConstraints: BoxConstraints.tightFor(
            width: widget.size * 1.5,
            height: widget.size * 1.5,
          ),
        ),
      ),
    );
  }
}