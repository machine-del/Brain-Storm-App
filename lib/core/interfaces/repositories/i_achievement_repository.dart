import 'package:dartz/dartz.dart';
import '../../domain/entities/achievement_entity.dart';
import '../../domain/enums/achievement_type.dart';
import '../../errors/failures.dart';

abstract class IAchievementRepository {
  Future<Either<Failure, List<AchievementEntity>>> getAllAchievements();
  Future<Either<Failure, List<AchievementEntity>>> getUnlockedAchievements();
  Future<Either<Failure, List<AchievementEntity>>> getLockedAchievements();
  Future<Either<Failure, AchievementEntity>> getAchievementById(String id);
  Future<Either<Failure, void>> unlockAchievement(String id);
  Future<Either<Failure, void>> updateProgress(
    AchievementType type,
    int progress,
  );
  Future<Either<Failure, int>> getTotalUnlockedCount();
}