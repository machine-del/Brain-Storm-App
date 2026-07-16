import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import '../interfaces/repositories/i_tasks_repository.dart';
import '../interfaces/repositories/i_stats_repository.dart';
import '../interfaces/repositories/i_user_repository.dart';
import '../interfaces/repositories/i_achievement_repository.dart';
import '../interfaces/datasources/i_tasks_local_datasource.dart';
import '../interfaces/datasources/i_achievements_local_datasource.dart';
import '../interfaces/usecases/i_get_daily_task.dart';
import '../interfaces/usecases/i_submit_answer.dart';
import '../interfaces/usecases/i_get_stats.dart';
import '../interfaces/services/i_navigation_service.dart';
import '../domain/entities/task_entity.dart';
import '../domain/entities/user_entity.dart';
import '../domain/entities/stats_entity.dart';
import '../domain/entities/daily_progress_entity.dart';
import '../domain/entities/answer_entity.dart';
import '../domain/enums/skill_type.dart';
import '../errors/failures.dart';
import '../utils/date_formatter.dart';

import '../../features/tasks/data/datasources/tasks_local_datasource_impl.dart';
import '../../features/tasks/data/repositories/tasks_repository_impl.dart';
import '../../features/achievements/data/datasources/achievements_local_datasource_impl.dart';
import '../../features/achievements/data/repositories/achievement_repository_impl.dart';

import '../../features/tasks/presentation/bloc/tasks_bloc.dart';
import '../../features/statistics/presentation/bloc/stats_bloc.dart';
import '../../features/profile/presentation/bloc/profile_bloc.dart';
import '../../features/achievements/presentation/bloc/achievements_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {
  final prefs = await SharedPreferences.getInstance();
  sl.registerLazySingleton<SharedPreferences>(() => prefs);
  sl.registerLazySingleton<Connectivity>(() => Connectivity());

  sl.registerLazySingleton<INavigationService>(() => NavigationServiceImpl());

  sl.registerLazySingleton<ITasksLocalDataSource>(
    () => TasksLocalDataSourceImpl(prefs: sl()),
  );
  sl.registerLazySingleton<IAchievementsLocalDataSource>(
    () => AchievementsLocalDataSourceImpl(prefs: sl()),
  );

  final tasksDataSource = sl<ITasksLocalDataSource>() as TasksLocalDataSourceImpl;

  final updateResult = await tasksDataSource.checkAndUpdateTasks();
  await updateResult.fold(
    (failure) async {
      final loadResult = await tasksDataSource.loadTasksFromAssets();
      await loadResult.fold(
        (failure2) async {
          await tasksDataSource.initializeWithDefaultTasks();
          print('⚠️ Загружены дефолтные задания: ${failure2.message}');
        },
        (_) {
          print('✅ Задания успешно загружены из assets');
        },
      );
    },
    (_) {
      print('✅ Задания обновлены');
    },
  );

  sl.registerLazySingleton<ITasksRepository>(
    () => TasksRepositoryImpl(localDataSource: sl()),
  );
  sl.registerLazySingleton<IStatsRepository>(
    () => StatsRepositoryImpl(prefs: sl()),
  );
  sl.registerLazySingleton<IUserRepository>(
    () => UserRepositoryImpl(prefs: sl()),
  );
  sl.registerLazySingleton<IAchievementRepository>(
    () => AchievementRepositoryImpl(localDataSource: sl()),
  );

  sl.registerLazySingleton<IGetDailyTask>(() => GetDailyTask(sl()));
  sl.registerLazySingleton<ISubmitAnswer>(() => SubmitAnswer(sl()));
  sl.registerLazySingleton<IGetStats>(() => GetStats(sl()));

  sl.registerFactory(
    () => TasksBloc(
      getDailyTask: sl(),
      submitAnswer: sl(),
      tasksRepository: sl(),
    ),
  );
  sl.registerFactory(
    () => StatsBloc(
      getStats: sl(),
      statsRepository: sl(),
    ),
  );
  sl.registerFactory(
    () => ProfileBloc(
      userRepository: sl(),
      statsRepository: sl(),
    ),
  );
  sl.registerFactory(
    () => AchievementsBloc(
      achievementRepository: sl(),
    ),
  );
}

class NavigationServiceImpl implements INavigationService {
  @override
  void navigateTo(String routeName, {Map<String, dynamic>? arguments}) {}

  @override
  void navigateBack() {}

  @override
  void navigateReplace(String routeName, {Map<String, dynamic>? arguments}) {}

  @override
  void navigateToRoot() {}

  @override
  Future<T?> navigateToAndWait<T>(String routeName,
      {Map<String, dynamic>? arguments}) async {
    return null;
  }
}

class StatsRepositoryImpl implements IStatsRepository {
  final SharedPreferences prefs;

  StatsRepositoryImpl({required this.prefs});

  @override
  Future<Either<Failure, StatsEntity>> getOverallStats() async {
    try {
      final progressData = prefs.getString('user_progress');
      if (progressData == null) {
        return Right(StatsEntity(
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
      }

      final data = jsonDecode(progressData) as Map<String, dynamic>;
      final completed = (data['completed'] as List? ?? []).length;
      final points = data['totalPoints'] ?? 0;
      final streak = data['streak'] ?? 0;

      final skillProgress = <SkillType, double>{};
      final skillCompletedCount = <SkillType, int>{};
      final skillAccuracy = <SkillType, double>{};

      for (var skill in SkillType.values) {
        final value = (data['skillProgress']?[skill.name] ?? 0) as num;
        skillProgress[skill] = value.toDouble().clamp(0, 100);
        skillCompletedCount[skill] = (value ~/ 10).clamp(0, 100);
        skillAccuracy[skill] = 0.5 + (value / 200);
      }

      return Right(StatsEntity(
        totalTasksCompleted: completed,
        totalTasksAttempted: completed + 10,
        overallAccuracy: completed > 0 ? 0.75 : 0,
        skillProgress: skillProgress,
        skillCompletedCount: skillCompletedCount,
        skillAccuracy: skillAccuracy,
        currentStreak: streak,
        bestStreak: streak,
        totalPoints: points,
        lastUpdated: DateTime.now(),
      ));
    } catch (e) {
      return Left(UnknownFailure(message: 'Ошибка получения статистики: $e'));
    }
  }

  @override
  Future<Either<Failure, Map<SkillType, double>>> getSkillProgress() async {
    final result = await getOverallStats();
    return result.fold(
      (failure) => Left(failure),
      (stats) => Right(stats.skillProgress),
    );
  }

  @override
  Future<Either<Failure, List<DailyProgressEntity>>> getWeeklyProgress() async {
    try {
      final progressData = prefs.getString('user_progress');
      if (progressData == null) {
        return Right(_generateMockWeeklyData());
      }

      final data = jsonDecode(progressData) as Map<String, dynamic>;
      final completed = data['completed'] as List? ?? [];

      final weekData = <DailyProgressEntity>[];
      final now = DateTime.now();
      final skills = SkillType.values;

      for (int i = 6; i >= 0; i--) {
        final date = now.subtract(Duration(days: i));
        final dayName = DateFormatter.getShortDayName(date);
        final skillIndex = i % skills.length;
        final progress = 20 + (i * 10) + (completed.length % 20);
        weekData.add(DailyProgressEntity(
          date: date,
          dayName: dayName,
          progress: (progress % 100).toDouble(),
          skillType: skills[skillIndex],
          tasksCompleted: i % 3,
          tasksTotal: 5,
        ));
      }

      return Right(weekData);
    } catch (e) {
      return Left(UnknownFailure(
          message: 'Ошибка получения недельного прогресса: $e'));
    }
  }

  @override
  Future<Either<Failure, List<DailyProgressEntity>>> getMonthlyProgress() async {
    try {
      final weekResult = await getWeeklyProgress();
      return weekResult.fold(
        (failure) => Left(failure),
        (_) {
          final monthData = <DailyProgressEntity>[];
          for (int i = 0; i < 30; i++) {
            final date = DateTime.now().subtract(Duration(days: 29 - i));
            final dayName = DateFormatter.getShortDayName(date);
            final skillIndex = i % SkillType.values.length;
            monthData.add(DailyProgressEntity(
              date: date,
              dayName: dayName,
              progress: (20 + (i * 2) % 80).toDouble(),
              skillType: SkillType.values[skillIndex],
              tasksCompleted: i % 4,
              tasksTotal: 5,
            ));
          }
          return Right(monthData);
        },
      );
    } catch (e) {
      return Left(UnknownFailure(
          message: 'Ошибка получения месячного прогресса: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> saveStats(StatsEntity stats) async {
    try {
      final data = {
        'totalTasksCompleted': stats.totalTasksCompleted,
        'totalTasksAttempted': stats.totalTasksAttempted,
        'overallAccuracy': stats.overallAccuracy,
        'currentStreak': stats.currentStreak,
        'bestStreak': stats.bestStreak,
        'totalPoints': stats.totalPoints,
        'lastUpdated': DateTime.now().toIso8601String(),
      };
      await prefs.setString('stats', jsonEncode(data));
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(message: 'Ошибка сохранения статистики: $e'));
    }
  }

  @override
  Future<Either<Failure, int>> getStreak() async {
    final result = await getOverallStats();
    return result.fold(
      (failure) => Left(failure),
      (stats) => Right(stats.currentStreak),
    );
  }

  @override
  Future<Either<Failure, int>> getTotalPoints() async {
    final result = await getOverallStats();
    return result.fold(
      (failure) => Left(failure),
      (stats) => Right(stats.totalPoints),
    );
  }

  List<DailyProgressEntity> _generateMockWeeklyData() {
    final now = DateTime.now();
    final skills = SkillType.values;
    final result = <DailyProgressEntity>[];

    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final dayName = DateFormatter.getShortDayName(date);
      final skillIndex = i % skills.length;
      result.add(DailyProgressEntity(
        date: date,
        dayName: dayName,
        progress: (30 + (i * 8) % 70).toDouble(),
        skillType: skills[skillIndex],
        tasksCompleted: i % 3,
        tasksTotal: 5,
      ));
    }
    return result;
  }
}

class UserRepositoryImpl implements IUserRepository {
  final SharedPreferences prefs;

  UserRepositoryImpl({required this.prefs});

  @override
  Future<Either<Failure, UserEntity>> getUser() async {
    try {
      final name = prefs.getString('user_name') ?? 'Игрок';
      final level = prefs.getInt('user_level') ?? 1;
      final experience = prefs.getInt('user_experience') ?? 0;
      final points = prefs.getInt('user_points') ?? 0;
      final streak = prefs.getInt('user_streak') ?? 0;
      final completed = prefs.getInt('user_completed') ?? 0;

      return Right(UserEntity(
        id: 'user_001',
        name: name,
        level: level,
        experience: experience,
        nextLevelExperience: level * 100,
        totalPoints: points,
        streak: streak,
        completedTasks: completed,
        lastActivityDate: DateTime.now(),
      ));
    } catch (e) {
      return Left(UnknownFailure(message: 'Ошибка получения пользователя: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> updateUserName(String name) async {
    try {
      await prefs.setString('user_name', name);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(message: 'Ошибка обновления имени: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> updateLevel(int level) async {
    try {
      await prefs.setInt('user_level', level);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(message: 'Ошибка обновления уровня: $e'));
    }
  }

  @override
  Future<Either<Failure, int>> getLevel() async {
    try {
      final level = prefs.getInt('user_level') ?? 1;
      return Right(level);
    } catch (e) {
      return Left(CacheFailure(message: 'Ошибка получения уровня: $e'));
    }
  }

  @override
  Future<Either<Failure, int>> getExperience() async {
    try {
      final exp = prefs.getInt('user_experience') ?? 0;
      return Right(exp);
    } catch (e) {
      return Left(CacheFailure(message: 'Ошибка получения опыта: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> addExperience(int amount) async {
    try {
      final current = prefs.getInt('user_experience') ?? 0;
      final newExp = current + amount;
      await prefs.setInt('user_experience', newExp);

      final level = prefs.getInt('user_level') ?? 1;
      final needed = level * 100;
      if (newExp >= needed) {
        await prefs.setInt('user_level', level + 1);
        await prefs.setInt('user_experience', newExp - needed);
      }

      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(message: 'Ошибка добавления опыта: $e'));
    }
  }
}

class GetDailyTask implements IGetDailyTask {
  final ITasksRepository repository;

  GetDailyTask(this.repository);

  @override
  Future<Either<Failure, TaskEntity>> call() {
    return repository.getDailyTask();
  }
}

class SubmitAnswer implements ISubmitAnswer {
  final ITasksRepository repository;

  SubmitAnswer(this.repository);

  @override
  Future<Either<Failure, void>> call(AnswerEntity answer) {
    return repository.submitAnswer(answer);
  }
}

class GetStats implements IGetStats {
  final IStatsRepository repository;

  GetStats(this.repository);

  @override
  Future<Either<Failure, StatsEntity>> call() {
    return repository.getOverallStats();
  }
}