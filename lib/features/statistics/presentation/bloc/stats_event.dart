part of 'stats_bloc.dart';

abstract class StatsEvent extends Equatable {
  const StatsEvent();

  @override
  List<Object?> get props => [];
}

class LoadStatsEvent extends StatsEvent {}

class LoadWeeklyProgressEvent extends StatsEvent {}

class LoadMonthlyProgressEvent extends StatsEvent {}

class RefreshStatsEvent extends StatsEvent {}