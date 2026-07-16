import 'package:dartz/dartz.dart';
import '../../errors/failures.dart';

abstract class IAchievementsLocalDataSource {
  Future<Either<Failure, List<Map<String, dynamic>>>> getAchievements();
  Future<Either<Failure, void>> saveAchievements(
    List<Map<String, dynamic>> achievements,
  );
  Future<Either<Failure, void>> updateAchievement(
    String id,
    Map<String, dynamic> data,
  );
  Future<Either<Failure, void>> initializeDefaultAchievements();
}