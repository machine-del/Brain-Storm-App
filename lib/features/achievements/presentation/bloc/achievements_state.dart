part of 'achievements_bloc.dart';

abstract class AchievementsState extends Equatable {
  const AchievementsState();

  @override
  List<Object?> get props => [];
}

class AchievementsInitial extends AchievementsState {}

class AchievementsLoading extends AchievementsState {}

class AchievementsLoaded extends AchievementsState {
  final List<AchievementEntity> achievements;
  final int unlockedCount;
  final int totalCount;

  const AchievementsLoaded({
    required this.achievements,
    required this.unlockedCount,
    required this.totalCount,
  });

  double get progressPercentage => totalCount > 0 ? unlockedCount / totalCount : 0;

  @override
  List<Object?> get props => [achievements, unlockedCount, totalCount];
}

class AchievementsError extends AchievementsState {
  final String message;

  const AchievementsError({required this.message});

  @override
  List<Object?> get props => [message];
}