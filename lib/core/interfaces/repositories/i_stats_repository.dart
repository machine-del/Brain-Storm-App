import 'package:dartz/dartz.dart';
import '../../domain/entities/stats_entity.dart';
import '../../domain/entities/daily_progress_entity.dart';
import '../../domain/enums/skill_type.dart';
import '../../errors/failures.dart';

abstract class IStatsRepository {
  Future<Either<Failure, StatsEntity>> getOverallStats();
  Future<Either<Failure, Map<SkillType, double>>> getSkillProgress();
  Future<Either<Failure, List<DailyProgressEntity>>> getWeeklyProgress();
  Future<Either<Failure, List<DailyProgressEntity>>> getMonthlyProgress();
  Future<Either<Failure, void>> saveStats(StatsEntity stats);
  Future<Either<Failure, int>> getStreak();
  Future<Either<Failure, int>> getTotalPoints();
}