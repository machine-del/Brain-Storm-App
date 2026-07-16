import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/domain/entities/user_entity.dart';
import '../../../../core/domain/entities/stats_entity.dart';
import '../../../../core/interfaces/repositories/i_user_repository.dart';
import '../../../../core/interfaces/repositories/i_stats_repository.dart';
import '../../../../core/errors/failures.dart';

part 'profile_event.dart';
part 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final IUserRepository userRepository;
  final IStatsRepository statsRepository;

  ProfileBloc({
    required this.userRepository,
    required this.statsRepository,
  }) : super(ProfileInitial()) {
    on<LoadProfileEvent>(_onLoadProfile);
    on<UpdateUserNameEvent>(_onUpdateUserName);
    on<RefreshProfileEvent>(_onRefreshProfile);
  }

  Future<void> _onLoadProfile(
    LoadProfileEvent event,
    Emitter<ProfileState> emit,
  ) async {
    emit(ProfileLoading());

    final userResult = await userRepository.getUser();
    final statsResult = await statsRepository.getOverallStats();

    if (userResult.isLeft() || statsResult.isLeft()) {
      final error = userResult.fold(
        (failure) => failure,
        (_) => statsResult.fold(
          (failure) => failure,
          (_) => UnknownFailure(message: 'Неизвестная ошибка'),
        ),
      );
      emit(ProfileError(message: _mapFailureToMessage(error)));
      return;
    }

    final user = userResult.getOrElse(() => UserEntity(
      id: 'user_001',
      name: 'Владислав',
      level: 1,
      experience: 0,
      nextLevelExperience: 100,
      totalPoints: 0,
      streak: 0,
      completedTasks: 0,
    ));

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

    emit(ProfileLoaded(user: user, stats: stats));
  }

  Future<void> _onUpdateUserName(
    UpdateUserNameEvent event,
    Emitter<ProfileState> emit,
  ) async {
    if (state is ProfileLoaded) {
      final currentState = state as ProfileLoaded;
      final result = await userRepository.updateUserName(event.name);
      result.fold(
        (failure) => emit(ProfileError(message: _mapFailureToMessage(failure))),
        (_) {
          final updatedUser = currentState.user.copyWith(name: event.name);
          emit(ProfileLoaded(
            user: updatedUser,
            stats: currentState.stats,
          ));
        },
      );
    }
  }

  Future<void> _onRefreshProfile(
    RefreshProfileEvent event,
    Emitter<ProfileState> emit,
  ) async {
    add(LoadProfileEvent());
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