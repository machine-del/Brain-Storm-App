import '../enums/skill_type.dart';

class AnswerEntity {
  final String taskId;
  final String? selectedOption;
  final int? selectedIndex;
  final String? freeTextAnswer;
  final int timeSpentSeconds;
  final bool isCorrect;
  final SkillType skillType;

  const AnswerEntity({
    required this.taskId,
    this.selectedOption,
    this.selectedIndex,
    this.freeTextAnswer,
    required this.timeSpentSeconds,
    required this.isCorrect,
    required this.skillType,
  });

  Map<String, dynamic> toJson() => {
    'taskId': taskId,
    'selectedOption': selectedOption,
    'selectedIndex': selectedIndex,
    'freeTextAnswer': freeTextAnswer,
    'timeSpentSeconds': timeSpentSeconds,
    'isCorrect': isCorrect,
    'skillType': skillType.name,
  };

  AnswerEntity copyWith({
    String? taskId,
    String? selectedOption,
    int? selectedIndex,
    String? freeTextAnswer,
    int? timeSpentSeconds,
    bool? isCorrect,
    SkillType? skillType,
  }) {
    return AnswerEntity(
      taskId: taskId ?? this.taskId,
      selectedOption: selectedOption ?? this.selectedOption,
      selectedIndex: selectedIndex ?? this.selectedIndex,
      freeTextAnswer: freeTextAnswer ?? this.freeTextAnswer,
      timeSpentSeconds: timeSpentSeconds ?? this.timeSpentSeconds,
      isCorrect: isCorrect ?? this.isCorrect,
      skillType: skillType ?? this.skillType,
    );
  }
}