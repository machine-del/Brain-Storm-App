import 'package:dartz/dartz.dart';
import '../../domain/entities/task_entity.dart';
import '../../errors/failures.dart';

abstract class IGetDailyTask {
  Future<Either<Failure, TaskEntity>> call();
}