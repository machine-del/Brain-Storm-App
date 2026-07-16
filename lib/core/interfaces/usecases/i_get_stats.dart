import 'package:dartz/dartz.dart';
import '../../domain/entities/stats_entity.dart';
import '../../errors/failures.dart';

abstract class IGetStats {
  Future<Either<Failure, StatsEntity>> call();
}