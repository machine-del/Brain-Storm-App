import '../../../../core/domain/entities/answer_entity.dart';
import '../../../../core/domain/enums/skill_type.dart';

class AnswerModel {
  final String taskId;
  final String? selectedOption;
  final int? selectedIndex;
  final String? freeTextAnswer;
  final int timeSpentSeconds;
  final bool isCorrect;
  final String skillType;

  AnswerModel({
    required this.taskId,
    this.selectedOption,
    this.selectedIndex,
    this.freeTextAnswer,
    required this.timeSpentSeconds,
    required this.isCorrect,
    required this.skillType,
  });

  factory AnswerModel.fromJson(Map<String, dynamic> json) {
    return AnswerModel(
      taskId: json['taskId'] ?? '',
      selectedOption: json['selectedOption'],
      selectedIndex: json['selectedIndex'],
      freeTextAnswer: json['freeTextAnswer'],
      timeSpentSeconds: json['timeSpentSeconds'] ?? 0,
      isCorrect: json['isCorrect'] ?? false,
      skillType: json['skillType'] ?? 'creativity',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'taskId': taskId,
      'selectedOption': selectedOption,
      'selectedIndex': selectedIndex,
      'freeTextAnswer': freeTextAnswer,
      'timeSpentSeconds': timeSpentSeconds,
      'isCorrect': isCorrect,
      'skillType': skillType,
    };
  }

  AnswerEntity toEntity() {
    return AnswerEntity(
      taskId: taskId,
      selectedOption: selectedOption,
      selectedIndex: selectedIndex,
      freeTextAnswer: freeTextAnswer,
      timeSpentSeconds: timeSpentSeconds,
      isCorrect: isCorrect,
      skillType: SkillType.fromName(skillType),
    );
  }

  static AnswerModel fromEntity(AnswerEntity entity) {
    return AnswerModel(
      taskId: entity.taskId,
      selectedOption: entity.selectedOption,
      selectedIndex: entity.selectedIndex,
      freeTextAnswer: entity.freeTextAnswer,
      timeSpentSeconds: entity.timeSpentSeconds,
      isCorrect: entity.isCorrect,
      skillType: entity.skillType.name,
    );
  }
}