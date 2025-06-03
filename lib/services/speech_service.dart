import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:speech_to_text/speech_recognition_result.dart';

/// Service for handling speech-to-text functionality
class SpeechService {
  static SpeechService? _instance;
  final SpeechToText _speechToText = SpeechToText();
  bool _isInitialized = false;
  bool _isListening = false;
  String _lastRecognizedWords = '';
  
  // Stream controller for speech recognition results
  final StreamController<String> _resultController = StreamController<String>.broadcast();
  Stream<String> get resultStream => _resultController.stream;
  
  // Stream controller for speech recognition status
  final StreamController<bool> _statusController = StreamController<bool>.broadcast();
  Stream<bool> get statusStream => _statusController.stream;
  
  SpeechService._internal();
  
  static SpeechService get instance {
    _instance ??= SpeechService._internal();
    return _instance!;
  }
  
  /// Initialize the speech recognition service
  Future<bool> initialize() async {
    if (_isInitialized) return true;
    
    _isInitialized = await _speechToText.initialize(
      onError: (error) => debugPrint('Speech recognition error: $error'),
      onStatus: (status) {
        debugPrint('Speech recognition status: $status');
        if (status == 'done' || status == 'notListening') {
          _isListening = false;
          _statusController.add(false);
        }
      },
    );
    
    return _isInitialized;
  }
  
  /// Start listening for speech
  Future<bool> startListening() async {
    if (!_isInitialized) {
      final initialized = await initialize();
      if (!initialized) return false;
    }
    
    if (_isListening) return true;
    
    _lastRecognizedWords = '';
    
    final success = await _speechToText.listen(
      onResult: _onSpeechResult,
      listenFor: const Duration(seconds: 30),
      pauseFor: const Duration(seconds: 3),
      partialResults: true,
      localeId: 'en_US',
      cancelOnError: true,
    );
    
    _isListening = success;
    _statusController.add(success);
    return success;
  }
  
  /// Stop listening for speech
  Future<void> stopListening() async {
    if (_isListening) {
      await _speechToText.stop();
      _isListening = false;
      _statusController.add(false);
    }
  }
  
  /// Cancel speech recognition
  Future<void> cancelListening() async {
    if (_isListening) {
      await _speechToText.cancel();
      _isListening = false;
      _statusController.add(false);
      _lastRecognizedWords = '';
      _resultController.add('');
    }
  }
  
  /// Handle speech recognition results
  void _onSpeechResult(SpeechRecognitionResult result) {
    _lastRecognizedWords = result.recognizedWords;
    _resultController.add(_lastRecognizedWords);
  }
  
  /// Get the last recognized words
  String getLastRecognizedWords() {
    return _lastRecognizedWords;
  }
  
  /// Check if speech recognition is available
  Future<bool> isAvailable() async {
    if (!_isInitialized) {
      return await initialize();
    }
    return _isInitialized;
  }
  
  /// Check if currently listening
  bool isListening() {
    return _isListening;
  }
  
  /// Dispose the service
  void dispose() {
    _resultController.close();
    _statusController.close();
    _speechToText.cancel();
    _isListening = false;
    _isInitialized = false;
  }
}