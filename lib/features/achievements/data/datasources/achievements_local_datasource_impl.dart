import 'dart:convert';
import 'package:dartz/dartz.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/interfaces/datasources/i_achievements_local_datasource.dart';
import '../../../../core/errors/failures.dart';

class AchievementsLocalDataSourceImpl implements IAchievementsLocalDataSource {
  final SharedPreferences prefs;
  static const String _achievementsKey = 'achievements';

  AchievementsLocalDataSourceImpl({required this.prefs});

  @override
  Future<Either<Failure, List<Map<String, dynamic>>>> getAchievements() async {
    try {
      final jsonString = prefs.getString(_achievementsKey);
      if (jsonString == null) {
        return Left(CacheFailure(message: 'Нет сохранённых достижений'));
      }
      final List<dynamic> data = jsonDecode(jsonString);
      final achievements = data.map((e) => Map<String, dynamic>.from(e)).toList();
      return Right(achievements);
    } catch (e) {
      return Left(CacheFailure(message: 'Ошибка загрузки достижений: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> saveAchievements(
    List<Map<String, dynamic>> achievements,
  ) async {
    try {
      final jsonString = jsonEncode(achievements);
      await prefs.setString(_achievementsKey, jsonString);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(message: 'Ошибка сохранения достижений: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> updateAchievement(
    String id,
    Map<String, dynamic> data,
  ) async {
    try {
      final result = await getAchievements();
      return result.fold(
        (failure) => Left(failure),
        (achievements) async {
          final index = achievements.indexWhere((a) => a['id'] == id);
          if (index == -1) {
            return Left(NotFoundFailure(message: 'Достижение не найдено'));
          }
          achievements[index] = {...achievements[index], ...data};
          await saveAchievements(achievements);
          return const Right(null);
        },
      );
    } catch (e) {
      return Left(DatabaseFailure(message: 'Ошибка обновления достижения: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> initializeDefaultAchievements() async {
    try {
      final result = await getAchievements();
      return result.fold(
        (failure) async {
          if (failure is CacheFailure) {
            final defaultAchievements = _getDefaultAchievements();
            return await saveAchievements(defaultAchievements);
          }
          return Left(failure);
        },
        (_) => const Right(null),
      );
    } catch (e) {
      return Left(CacheFailure(message: 'Ошибка инициализации достижений: $e'));
    }
  }

  List<Map<String, dynamic>> _getDefaultAchievements() {
    return [
      {
        'id': 'first_task',
        'title': 'Первое задание',
        'description': 'Выполни своё первое задание',
        'icon': '🌟',
        'type': 'tasksCompleted',
        'requiredValue': 1,
        'currentProgress': 0,
        'isUnlocked': false,
        'unlockedAt': null,
      },
      {
        'id': 'task_master_10',
        'title': 'Мастер заданий',
        'description': 'Выполни 10 заданий',
        'icon': '🏅',
        'type': 'tasksCompleted',
        'requiredValue': 10,
        'currentProgress': 0,
        'isUnlocked': false,
        'unlockedAt': null,
      },
      {
        'id': 'task_master_50',
        'title': 'Легенда заданий',
        'description': 'Выполни 50 заданий',
        'icon': '👑',
        'type': 'tasksCompleted',
        'requiredValue': 50,
        'currentProgress': 0,
        'isUnlocked': false,
        'unlockedAt': null,
      },
      {
        'id': 'streak_7',
        'title': 'Неделя силы',
        'description': 'Выполняй задания 7 дней подряд',
        'icon': '🔥',
        'type': 'streak',
        'requiredValue': 7,
        'currentProgress': 0,
        'isUnlocked': false,
        'unlockedAt': null,
      },
      {
        'id': 'streak_30',
        'title': 'Месяц дисциплины',
        'description': 'Выполняй задания 30 дней подряд',
        'icon': '💪',
        'type': 'streak',
        'requiredValue': 30,
        'currentProgress': 0,
        'isUnlocked': false,
        'unlockedAt': null,
      },
      {
        'id': 'creativity_master',
        'title': 'Креативный гений',
        'description': 'Достигни 80% в креативности',
        'icon': '🎨',
        'type': 'skillMastery',
        'requiredValue': 80,
        'currentProgress': 0,
        'isUnlocked': false,
        'unlockedAt': null,
      },
      {
        'id': 'logic_master',
        'title': 'Логический ум',
        'description': 'Достигни 80% в логике',
        'icon': '🧠',
        'type': 'skillMastery',
        'requiredValue': 80,
        'currentProgress': 0,
        'isUnlocked': false,
        'unlockedAt': null,
      },
      {
        'id': 'points_100',
        'title': 'Сто очков',
        'description': 'Набери 100 очков',
        'icon': '⭐',
        'type': 'totalPoints',
        'requiredValue': 100,
        'currentProgress': 0,
        'isUnlocked': false,
        'unlockedAt': null,
      },
    ];
  }
}