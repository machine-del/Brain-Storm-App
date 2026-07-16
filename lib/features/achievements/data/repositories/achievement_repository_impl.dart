import 'package:dartz/dartz.dart';

import '../../../../core/interfaces/repositories/i_achievement_repository.dart';
import '../../../../core/interfaces/datasources/i_achievements_local_datasource.dart';
import '../../../../core/domain/entities/achievement_entity.dart';
import '../../../../core/domain/enums/achievement_type.dart';
import '../../../../core/errors/failures.dart';
import '../models/achievement_model.dart';

class AchievementRepositoryImpl implements IAchievementRepository {
  final IAchievementsLocalDataSource localDataSource;

  AchievementRepositoryImpl({required this.localDataSource});

  @override
  Future<Either<Failure, List<AchievementEntity>>> getAllAchievements() async {
    try {
      final result = await localDataSource.getAchievements();
      return result.fold(
        (failure) => Left(failure),
        (achievements) {
          final entities = achievements
              .map((a) => AchievementModel.fromJson(a).toEntity())
              .toList();
          return Right(entities);
        },
      );
    } catch (e) {
      return Left(UnknownFailure(message: 'Ошибка получения достижений: $e'));
    }
  }

  @override
  Future<Either<Failure, List<AchievementEntity>>> getUnlockedAchievements() async {
    final result = await getAllAchievements();
    return result.fold(
      (failure) => Left(failure),
      (achievements) {
        final unlocked = achievements.where((a) => a.isUnlocked).toList();
        return Right(unlocked);
      },
    );
  }

  @override
  Future<Either<Failure, List<AchievementEntity>>> getLockedAchievements() async {
    final result = await getAllAchievements();
    return result.fold(
      (failure) => Left(failure),
      (achievements) {
        final locked = achievements.where((a) => !a.isUnlocked).toList();
        return Right(locked);
      },
    );
  }

  @override
  Future<Either<Failure, AchievementEntity>> getAchievementById(String id) async {
    final result = await getAllAchievements();
    return result.fold(
      (failure) => Left(failure),
      (achievements) {
        try {
          final achievement = achievements.firstWhere((a) => a.id == id);
          return Right(achievement);
        } catch (_) {
          return Left(NotFoundFailure(message: 'Достижение не найдено'));
        }
      },
    );
  }

  @override
  Future<Either<Failure, void>> unlockAchievement(String id) async {
    try {
      await localDataSource.updateAchievement(id, {
        'isUnlocked': true,
        'unlockedAt': DateTime.now().toIso8601String(),
      });
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure(message: 'Ошибка разблокировки достижения: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> updateProgress(
    AchievementType type,
    int progress,
  ) async {
    try {
      final result = await getAllAchievements();
      return result.fold(
        (failure) => Left(failure),
        (achievements) async {
          for (var achievement in achievements) {
            if (achievement.type == type && !achievement.isUnlocked) {
              final newProgress = achievement.currentProgress + progress;
              await localDataSource.updateAchievement(achievement.id, {
                'currentProgress': newProgress,
                'isUnlocked': newProgress >= achievement.requiredValue,
                'unlockedAt': newProgress >= achievement.requiredValue
                    ? DateTime.now().toIso8601String()
                    : null,
              });
            }
          }
          return const Right(null);
        },
      );
    } catch (e) {
      return Left(DatabaseFailure(message: 'Ошибка обновления прогресса: $e'));
    }
  }

  @override
  Future<Either<Failure, int>> getTotalUnlockedCount() async {
    final result = await getUnlockedAchievements();
    return result.fold(
      (failure) => Left(failure),
      (achievements) => Right(achievements.length),
    );
  }
}