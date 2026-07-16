import '../enums/skill_type.dart';
import '../enums/difficulty_level.dart';

class TaskEntity {
  final String id;
  final String title;
  final String description;
  final String instruction;
  final String? hint;
  final String explanation;
  final SkillType skillType;
  final DifficultyLevel difficulty;
  final int estimatedMinutes;
  final bool isFreeText;
  final List<String> options;
  final int correctAnswerIndex;
  final DateTime? createdAt;
  final bool isCompleted;
  final int? userAnswerIndex;
  final String? userFreeTextAnswer;

  const TaskEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.instruction,
    this.hint,
    required this.explanation,
    required this.skillType,
    required this.difficulty,
    required this.estimatedMinutes,
    required this.isFreeText,
    required this.options,
    required this.correctAnswerIndex,
    this.createdAt,
    this.isCompleted = false,
    this.userAnswerIndex,
    this.userFreeTextAnswer,
  });

  TaskEntity copyWith({
    String? id,
    String? title,
    String? description,
    String? instruction,
    String? hint,
    String? explanation,
    SkillType? skillType,
    DifficultyLevel? difficulty,
    int? estimatedMinutes,
    bool? isFreeText,
    List<String>? options,
    int? correctAnswerIndex,
    DateTime? createdAt,
    bool? isCompleted,
    int? userAnswerIndex,
    String? userFreeTextAnswer,
  }) {
    return TaskEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      instruction: instruction ?? this.instruction,
      hint: hint ?? this.hint,
      explanation: explanation ?? this.explanation,
      skillType: skillType ?? this.skillType,
      difficulty: difficulty ?? this.difficulty,
      estimatedMinutes: estimatedMinutes ?? this.estimatedMinutes,
      isFreeText: isFreeText ?? this.isFreeText,
      options: options ?? this.options,
      correctAnswerIndex: correctAnswerIndex ?? this.correctAnswerIndex,
      createdAt: createdAt ?? this.createdAt,
      isCompleted: isCompleted ?? this.isCompleted,
      userAnswerIndex: userAnswerIndex ?? this.userAnswerIndex,
      userFreeTextAnswer: userFreeTextAnswer ?? this.userFreeTextAnswer,
    );
  }
}