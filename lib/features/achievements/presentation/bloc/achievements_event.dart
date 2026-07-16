part of 'achievements_bloc.dart';

abstract class AchievementsEvent extends Equatable {
  const AchievementsEvent();

  @override
  List<Object?> get props => [];
}

class LoadAchievementsEvent extends AchievementsEvent {}

class RefreshAchievementsEvent extends AchievementsEvent {}

class CheckAchievementsProgressEvent extends AchievementsEvent {
  final int tasksCompleted;
  final int streak;
  final int totalPoints;
  final Map<SkillType, double> skillProgress;

  const CheckAchievementsProgressEvent({
    required this.tasksCompleted,
    required this.streak,
    required this.totalPoints,
    required this.skillProgress,
  });

  @override
  List<Object?> get props => [tasksCompleted, streak, totalPoints, skillProgress];
}