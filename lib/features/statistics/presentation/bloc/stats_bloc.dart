import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/domain/entities/stats_entity.dart';
import '../../../../core/domain/entities/daily_progress_entity.dart';
import '../../../../core/interfaces/usecases/i_get_stats.dart';
import '../../../../core/interfaces/repositories/i_stats_repository.dart';
import '../../../../core/errors/failures.dart';

part 'stats_event.dart';
part 'stats_state.dart';

class StatsBloc extends Bloc<StatsEvent, StatsState> {
  final IGetStats getStats;
  final IStatsRepository statsRepository;

  StatsBloc({
    required this.getStats,
    required this.statsRepository,
  }) : super(StatsInitial()) {
    on<LoadStatsEvent>(_onLoadStats);
    on<LoadWeeklyProgressEvent>(_onLoadWeeklyProgress);
    on<LoadMonthlyProgressEvent>(_onLoadMonthlyProgress);
    on<RefreshStatsEvent>(_onRefreshStats);
  }

  Future<void> _onLoadStats(
    LoadStatsEvent event,
    Emitter<StatsState> emit,
  ) async {
    emit(StatsLoading());
    
    final statsResult = await getStats();
    final weeklyResult = await statsRepository.getWeeklyProgress();
    final monthlyResult = await statsRepository.getMonthlyProgress();

    if (statsResult.isLeft() || weeklyResult.isLeft() || monthlyResult.isLeft()) {
      final error = statsResult.fold(
        (failure) => failure,
        (_) => weeklyResult.fold(
          (failure) => failure,
          (_) => monthlyResult.fold(
            (failure) => failure,
            (_) => UnknownFailure(message: 'Неизвестная ошибка'),
          ),
        ),
      );
      emit(StatsError(message: _mapFailureToMessage(error)));
      return;
    }

    final stats = statsResult.getOrElse(() => StatsEntity(
      totalTasksCompleted: 0,
      totalTasksAttempted: 0,
      overallAccuracy: 0,
      skillProgress: {},
      skillCompletedCount: {},
      skillAccuracy: {},
      currentStreak: 0,
      bestStreak: 0,
      totalPoints: 0,
    ));

    final weekly = weeklyResult.getOrElse(() => []);
    final monthly = monthlyResult.getOrElse(() => []);

    emit(StatsLoaded(
      stats: stats,
      weeklyProgress: weekly,
      monthlyProgress: monthly,
    ));
  }

  Future<void> _onLoadWeeklyProgress(
    LoadWeeklyProgressEvent event,
    Emitter<StatsState> emit,
  ) async {
    if (state is StatsLoaded) {
      final currentState = state as StatsLoaded;
      final result = await statsRepository.getWeeklyProgress();
      result.fold(
        (failure) => emit(StatsError(message: _mapFailureToMessage(failure))),
        (weekly) => emit(StatsLoaded(
          stats: currentState.stats,
          weeklyProgress: weekly,
          monthlyProgress: currentState.monthlyProgress,
        )),
      );
    }
  }

  Future<void> _onLoadMonthlyProgress(
    LoadMonthlyProgressEvent event,
    Emitter<StatsState> emit,
  ) async {
    if (state is StatsLoaded) {
      final currentState = state as StatsLoaded;
      final result = await statsRepository.getMonthlyProgress();
      result.fold(
        (failure) => emit(StatsError(message: _mapFailureToMessage(failure))),
        (monthly) => emit(StatsLoaded(
          stats: currentState.stats,
          weeklyProgress: currentState.weeklyProgress,
          monthlyProgress: monthly,
        )),
      );
    }
  }

  Future<void> _onRefreshStats(
    RefreshStatsEvent event,
    Emitter<StatsState> emit,
  ) async {
    add(LoadStatsEvent());
  }

  String _mapFailureToMessage(Failure failure) {
    if (failure is NetworkFailure) {
      return 'Нет подключения к интернету';
    } else if (failure is CacheFailure) {
      return 'Ошибка кэша: ${failure.message}';
    } else if (failure is NotFoundFailure) {
      return failure.message;
    } else if (failure is DatabaseFailure) {
      return 'Ошибка базы данных: ${failure.message}';
    } else {
      return failure.message;
    }
  }
}