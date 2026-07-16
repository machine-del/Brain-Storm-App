import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/domain/entities/achievement_entity.dart';
import '../../../../core/domain/enums/skill_type.dart';
import '../../../../core/domain/enums/achievement_type.dart';
import '../../../../core/interfaces/repositories/i_achievement_repository.dart';
import '../../../../core/errors/failures.dart';

part 'achievements_event.dart';
part 'achievements_state.dart';

class AchievementsBloc extends Bloc<AchievementsEvent, AchievementsState> {
  final IAchievementRepository achievementRepository;

  AchievementsBloc({
    required this.achievementRepository,
  }) : super(AchievementsInitial()) {
    on<LoadAchievementsEvent>(_onLoadAchievements);
    on<RefreshAchievementsEvent>(_onRefreshAchievements);
    on<CheckAchievementsProgressEvent>(_onCheckAchievementsProgress);
  }

  Future<void> _onLoadAchievements(
    LoadAchievementsEvent event,
    Emitter<AchievementsState> emit,
  ) async {
    emit(AchievementsLoading());
    final result = await achievementRepository.getAllAchievements();
    result.fold(
      (failure) => emit(AchievementsError(message: _mapFailureToMessage(failure))),
      (achievements) {
        final unlocked = achievements.where((a) => a.isUnlocked).length;
        emit(AchievementsLoaded(
          achievements: achievements,
          unlockedCount: unlocked,
          totalCount: achievements.length,
        ));
      },
    );
  }

  Future<void> _onRefreshAchievements(
    RefreshAchievementsEvent event,
    Emitter<AchievementsState> emit,
  ) async {
    add(LoadAchievementsEvent());
  }

  Future<void> _onCheckAchievementsProgress(
    CheckAchievementsProgressEvent event,
    Emitter<AchievementsState> emit,
  ) async {
    await achievementRepository.updateProgress(
      AchievementType.tasksCompleted,
      event.tasksCompleted,
    );
    
    await achievementRepository.updateProgress(
      AchievementType.streak,
      event.streak,
    );
    
    await achievementRepository.updateProgress(
      AchievementType.totalPoints,
      event.totalPoints,
    );

    for (var entry in event.skillProgress.entries) {
      final progress = entry.value;
      if (progress >= 80) {
        await achievementRepository.updateProgress(
          AchievementType.skillMastery,
          progress.toInt(),
        );
      }
    }

    add(LoadAchievementsEvent());
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