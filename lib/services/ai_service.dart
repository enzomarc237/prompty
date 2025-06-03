import 'dart:convert';
import 'package:dio/dio.dart';
import '../models/prompt.dart';

class AIModel {
  final String id;
  final String name;
  final String provider;
  final bool available;

  const AIModel({
    required this.id,
    required this.name,
    required this.provider,
    this.available = true,
  });

  factory AIModel.fromJson(Map<String, dynamic> json, String provider) {
    switch (provider) {
      case 'openai':
        return AIModel(
          id: json['id'],
          name: json['id'],
          provider: provider,
          available: json['active'] ?? true,
        );
      case 'openrouter':
        return AIModel(
          id: json['id'],
          name: json['name'] ?? json['id'],
          provider: provider,
          available: true,
        );
      case 'gemini':
        return AIModel(
          id: json['name'],
          name: json['displayName'] ?? json['name'],
          provider: provider,
          available: true,
        );
      default:
        return AIModel(
          id: json['id'] ?? json['name'],
          name: json['name'] ?? json['id'],
          provider: provider,
        );
    }
  }
}

class AIService {
  static AIService? _instance;
  final Dio _dio;

  AIService._internal() : _dio = Dio();

  static AIService get instance {
    _instance ??= AIService._internal();
    return _instance!;
  }

  Future<List<AIModel>> getAvailableModels(String provider, String apiKey) async {
    try {
      switch (provider.toLowerCase()) {
        case 'openai':
          return await _getOpenAIModels(apiKey);
        case 'openrouter':
          return await _getOpenRouterModels(apiKey);
        case 'gemini':
          return await _getGeminiModels(apiKey);
        default:
          throw Exception('Unsupported AI provider: $provider');
      }
    } catch (e) {
      throw Exception('Failed to fetch models: $e');
    }
  }

  Future<Map<String, String>> enhancePrompt(String originalPrompt, String apiKey, {String provider = 'openai', String model = 'gpt-3.5-turbo', EnhancementStyle? style}) async {
    try {
      switch (provider.toLowerCase()) {
        case 'openai':
          return await _enhanceWithOpenAI(originalPrompt, apiKey, model, style);
        case 'openrouter':
          return await _enhanceWithOpenRouter(originalPrompt, apiKey, model, style);
        case 'gemini':
          return await _enhanceWithGemini(originalPrompt, apiKey, model, style);
        default:
          throw Exception('Unsupported AI provider: $provider');
      }
    } catch (e) {
      throw Exception('Failed to enhance prompt: $e');
    }
  }

  Future<List<AIModel>> _getOpenAIModels(String apiKey) async {
    const String baseUrl = 'https://api.openai.com/v1/models';
    
    final response = await _dio.get(
      baseUrl,
      options: Options(
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/json',
        },
      ),
    );

    if (response.statusCode == 200) {
      final data = response.data;
      final List<dynamic> models = data['data'];
      return models
          .where((model) => model['id'].toString().contains('gpt'))
          .map((model) => AIModel.fromJson(model, 'openai'))
          .toList();
    } else {
      throw Exception('OpenAI API error: ${response.statusCode}');
    }
  }

  Future<List<AIModel>> _getOpenRouterModels(String apiKey) async {
    const String baseUrl = 'https://openrouter.ai/api/v1/models';
    
    final response = await _dio.get(
      baseUrl,
      options: Options(
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/json',
        },
      ),
    );

    if (response.statusCode == 200) {
      final data = response.data;
      final List<dynamic> models = data['data'];
      return models
          .map((model) => AIModel.fromJson(model, 'openrouter'))
          .toList();
    } else {
      throw Exception('OpenRouter API error: ${response.statusCode}');
    }
  }

  Future<List<AIModel>> _getGeminiModels(String apiKey) async {
    const String baseUrl = 'https://generativelanguage.googleapis.com/v1/models';
    
    final response = await _dio.get(
      '$baseUrl?key=$apiKey',
      options: Options(
        headers: {
          'Content-Type': 'application/json',
        },
      ),
    );

    if (response.statusCode == 200) {
      final data = response.data;
      final List<dynamic> models = data['models'];
      print(models);

      return models
          .where((model) => model['name'].toString().contains('gemini'))
          .map((model) => AIModel.fromJson(model, 'gemini'))
          .toList();
    } else {
      throw Exception('Gemini API error: ${response.statusCode}');
    }
  }

  Future<Map<String, String>> _enhanceWithOpenAI(String originalPrompt, String apiKey, String model, EnhancementStyle? selectedStyle) async {
    const String baseUrl = 'https://api.openai.com/v1/chat/completions';
    
    final Map<String, String> enhancements = {};
    
    final stylesToEnhance = selectedStyle != null ? [selectedStyle] : EnhancementStyle.values;

    for (final style in stylesToEnhance) {
      final response = await _dio.post(
        baseUrl,
        options: Options(
          headers: {
            'Authorization': 'Bearer $apiKey',
            'Content-Type': 'application/json',
          },
        ),
        data: {
          'model': model,
          'messages': [
            {
              'role': 'system',
              'content': _getSystemPrompt(style),
            },
            {
              'role': 'user',
              'content': originalPrompt,
            },
          ],
          'max_tokens': 64000,
          'temperature': 0.7,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final enhancedPrompt = data['choices'][0]['message']['content'];
        enhancements[style.name] = enhancedPrompt.trim();
      } else {
        throw Exception('OpenAI API error: ${response.statusCode}');
      }
    }

    return enhancements;
  }

  Future<Map<String, String>> _enhanceWithOpenRouter(String originalPrompt, String apiKey, String model, EnhancementStyle? selectedStyle) async {
    const String baseUrl = 'https://openrouter.ai/api/v1/chat/completions';
    
    final Map<String, String> enhancements = {};
    
    final stylesToEnhance = selectedStyle != null ? [selectedStyle] : EnhancementStyle.values;

    for (final style in stylesToEnhance) {
      final response = await _dio.post(
        baseUrl,
        options: Options(
          headers: {
            'Authorization': 'Bearer $apiKey',
            'Content-Type': 'application/json',
            'HTTP-Referer': 'https://prompty.app',
            'X-Title': 'Prompty',
          },
        ),
        data: {
          'model': model,
          'messages': [
            {
              'role': 'system',
              'content': _getSystemPrompt(style),
            },
            {
              'role': 'user',
              'content': originalPrompt,
            },
          ],
          'max_tokens': 64000,
          'temperature': 0.7,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final enhancedPrompt = data['choices'][0]['message']['content'];
        enhancements[style.name] = enhancedPrompt.trim();
      } else {
        throw Exception('OpenRouter API error: ${response.statusCode}');
      }
    }

    return enhancements;
  }

  Future<Map<String, String>> _enhanceWithGemini(String originalPrompt, String apiKey, String model, EnhancementStyle? selectedStyle) async {
    final String baseUrl = 'https://generativelanguage.googleapis.com/v1/models/$model:generateContent';
    
    final Map<String, String> enhancements = {};
    
    final stylesToEnhance = selectedStyle != null ? [selectedStyle] : EnhancementStyle.values;

    for (final style in stylesToEnhance) {
      final response = await _dio.post(
        '$baseUrl?key=$apiKey',
        options: Options(
          headers: {
            'Content-Type': 'application/json',
          },
        ),
        data: {
          'contents': [
            {
              'parts': [
                {
                  'text': '${_getSystemPrompt(style)}\n\nOriginal prompt: $originalPrompt',
                },
              ],
            },
          ],
          'generationConfig': {
            'temperature': 0.7,
            'maxOutputTokens': 64000,
          },
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final enhancedPrompt = data['candidates'][0]['content']['parts'][0]['text'];
        enhancements[style.name] = enhancedPrompt.trim();
      } else {
        throw Exception('Gemini API error: ${response.statusCode}');
      }
    }

    return enhancements;
  }

  String _getSystemPrompt(EnhancementStyle style) {
    switch (style) {
      case EnhancementStyle.professional:
        return '''You are a professional prompt enhancer. Transform the given prompt to be more formal, clear, and business-oriented. Focus on:
- Clear objectives and deliverables
- Professional language and tone
- Structured approach
- Actionable outcomes
- Business value proposition

Return only the enhanced prompt without additional explanation.''';

      case EnhancementStyle.creative:
        return '''You are a creative prompt enhancer. Transform the given prompt to be more imaginative and inspiring. Focus on:
- Creative and innovative approaches
- Out-of-the-box thinking
- Brainstorming possibilities
- Multiple perspectives
- Imaginative scenarios

Return only the enhanced prompt without additional explanation.''';

      case EnhancementStyle.technical:
        return '''You are a technical prompt enhancer. Transform the given prompt to be more structured and precise. Focus on:
- Technical specifications
- Step-by-step procedures
- Detailed requirements
- Measurable criteria
- Implementation considerations

Return only the enhanced prompt without additional explanation.''';
    }
  }
}