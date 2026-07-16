part of 'stats_bloc.dart';

abstract class StatsState extends Equatable {
  const StatsState();

  @override
  List<Object?> get props => [];
}

class StatsInitial extends StatsState {}

class StatsLoading extends StatsState {}

class StatsLoaded extends StatsState {
  final StatsEntity stats;
  final List<DailyProgressEntity> weeklyProgress;
  final List<DailyProgressEntity> monthlyProgress;

  const StatsLoaded({
    required this.stats,
    required this.weeklyProgress,
    required this.monthlyProgress,
  });

  @override
  List<Object?> get props => [stats, weeklyProgress, monthlyProgress];
}

class StatsError extends StatsState {
  final String message;

  const StatsError({required this.message});

  @override
  List<Object?> get props => [message];
}