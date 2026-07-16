import '../../../../core/domain/entities/task_entity.dart';
import '../../../../core/domain/enums/skill_type.dart';
import '../../../../core/domain/enums/difficulty_level.dart';

class TaskModel {
  final String id;
  final String title;
  final String description;
  final String instruction;
  final String? hint;
  final String explanation;
  final String skillType;
  final String difficulty;
  final int estimatedMinutes;
  final bool isFreeText;
  final List<String> options;
  final int correctAnswerIndex;
  final DateTime? createdAt;
  final bool isCompleted;
  final int? userAnswerIndex;
  final String? userFreeTextAnswer;

  TaskModel({
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

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      instruction: json['instruction'] ?? '',
      hint: json['hint'],
      explanation: json['explanation'] ?? '',
      skillType: json['skillType'] ?? 'creativity',
      difficulty: json['difficulty'] ?? 'medium',
      estimatedMinutes: json['estimatedMinutes'] ?? 5,
      isFreeText: json['isFreeText'] ?? false,
      options: List<String>.from(json['options'] ?? []),
      correctAnswerIndex: json['correctAnswerIndex'] ?? -1,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      isCompleted: json['isCompleted'] ?? false,
      userAnswerIndex: json['userAnswerIndex'],
      userFreeTextAnswer: json['userFreeTextAnswer'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'instruction': instruction,
      'hint': hint,
      'explanation': explanation,
      'skillType': skillType,
      'difficulty': difficulty,
      'estimatedMinutes': estimatedMinutes,
      'isFreeText': isFreeText,
      'options': options,
      'correctAnswerIndex': correctAnswerIndex,
      'createdAt': createdAt?.toIso8601String(),
      'isCompleted': isCompleted,
      'userAnswerIndex': userAnswerIndex,
      'userFreeTextAnswer': userFreeTextAnswer,
    };
  }

  TaskEntity toEntity() {
    return TaskEntity(
      id: id,
      title: title,
      description: description,
      instruction: instruction,
      hint: hint,
      explanation: explanation,
      skillType: SkillType.fromName(skillType),
      difficulty: DifficultyLevel.fromName(difficulty),
      estimatedMinutes: estimatedMinutes,
      isFreeText: isFreeText,
      options: options,
      correctAnswerIndex: correctAnswerIndex,
      createdAt: createdAt,
      isCompleted: isCompleted,
      userAnswerIndex: userAnswerIndex,
      userFreeTextAnswer: userFreeTextAnswer,
    );
  }

  static TaskModel fromEntity(TaskEntity entity) {
    return TaskModel(
      id: entity.id,
      title: entity.title,
      description: entity.description,
      instruction: entity.instruction,
      hint: entity.hint,
      explanation: entity.explanation,
      skillType: entity.skillType.name,
      difficulty: entity.difficulty.name,
      estimatedMinutes: entity.estimatedMinutes,
      isFreeText: entity.isFreeText,
      options: entity.options,
      correctAnswerIndex: entity.correctAnswerIndex,
      createdAt: entity.createdAt,
      isCompleted: entity.isCompleted,
      userAnswerIndex: entity.userAnswerIndex,
      userFreeTextAnswer: entity.userFreeTextAnswer,
    );
  }
}