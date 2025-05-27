import 'package:json_annotation/json_annotation.dart';

part 'prompt.g.dart';

@JsonSerializable()
class Prompt {
  final String id;
  final String originalText;
  final String? professionalVersion;
  final String? creativeVersion;
  final String? technicalVersion;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool isFavorite;
  final List<String> tags;
  final String? category;

  const Prompt({
    required this.id,
    required this.originalText,
    this.professionalVersion,
    this.creativeVersion,
    this.technicalVersion,
    required this.createdAt,
    this.updatedAt,
    this.isFavorite = false,
    this.tags = const [],
    this.category,
  });

  factory Prompt.fromJson(Map<String, dynamic> json) => _$PromptFromJson(json);
  Map<String, dynamic> toJson() => _$PromptToJson(this);

  Prompt copyWith({
    String? id,
    String? originalText,
    String? professionalVersion,
    String? creativeVersion,
    String? technicalVersion,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isFavorite,
    List<String>? tags,
    String? category,
  }) {
    return Prompt(
      id: id ?? this.id,
      originalText: originalText ?? this.originalText,
      professionalVersion: professionalVersion ?? this.professionalVersion,
      creativeVersion: creativeVersion ?? this.creativeVersion,
      technicalVersion: technicalVersion ?? this.technicalVersion,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isFavorite: isFavorite ?? this.isFavorite,
      tags: tags ?? this.tags,
      category: category ?? this.category,
    );
  }
}

enum EnhancementStyle {
  professional,
  creative,
  technical,
}

extension EnhancementStyleExtension on EnhancementStyle {
  String get displayName {
    switch (this) {
      case EnhancementStyle.professional:
        return 'Professional';
      case EnhancementStyle.creative:
        return 'Creative';
      case EnhancementStyle.technical:
        return 'Technical';
    }
  }

  String get description {
    switch (this) {
      case EnhancementStyle.professional:
        return 'Formal, clear, and business-oriented';
      case EnhancementStyle.creative:
        return 'Imaginative, brainstorming-focused';
      case EnhancementStyle.technical:
        return 'Structured, precise, and detailed';
    }
  }
}