import '../enums/skill_type.dart';

class StatsEntity {
  final int totalTasksCompleted;
  final int totalTasksAttempted;
  final double overallAccuracy;
  final Map<SkillType, double> skillProgress;
  final Map<SkillType, int> skillCompletedCount;
  final Map<SkillType, double> skillAccuracy;
  final int currentStreak;
  final int bestStreak;
  final int totalPoints;
  final DateTime? lastUpdated;

  const StatsEntity({
    required this.totalTasksCompleted,
    required this.totalTasksAttempted,
    required this.overallAccuracy,
    required this.skillProgress,
    required this.skillCompletedCount,
    required this.skillAccuracy,
    required this.currentStreak,
    required this.bestStreak,
    required this.totalPoints,
    this.lastUpdated,
  });

  double get completionRate => totalTasksAttempted > 0
      ? totalTasksCompleted / totalTasksAttempted
      : 0.0;

  StatsEntity copyWith({
    int? totalTasksCompleted,
    int? totalTasksAttempted,
    double? overallAccuracy,
    Map<SkillType, double>? skillProgress,
    Map<SkillType, int>? skillCompletedCount,
    Map<SkillType, double>? skillAccuracy,
    int? currentStreak,
    int? bestStreak,
    int? totalPoints,
    DateTime? lastUpdated,
  }) {
    return StatsEntity(
      totalTasksCompleted: totalTasksCompleted ?? this.totalTasksCompleted,
      totalTasksAttempted: totalTasksAttempted ?? this.totalTasksAttempted,
      overallAccuracy: overallAccuracy ?? this.overallAccuracy,
      skillProgress: skillProgress ?? this.skillProgress,
      skillCompletedCount: skillCompletedCount ?? this.skillCompletedCount,
      skillAccuracy: skillAccuracy ?? this.skillAccuracy,
      currentStreak: currentStreak ?? this.currentStreak,
      bestStreak: bestStreak ?? this.bestStreak,
      totalPoints: totalPoints ?? this.totalPoints,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}