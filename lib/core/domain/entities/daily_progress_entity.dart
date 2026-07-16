import '../enums/skill_type.dart';

class DailyProgressEntity {
  final DateTime date;
  final String dayName;
  final double progress; 
  final SkillType skillType;
  final int tasksCompleted;
  final int tasksTotal;

  const DailyProgressEntity({
    required this.date,
    required this.dayName,
    required this.progress,
    required this.skillType,
    required this.tasksCompleted,
    required this.tasksTotal,
  });
}