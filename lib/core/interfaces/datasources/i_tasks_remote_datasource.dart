import 'package:dartz/dartz.dart';
import '../../errors/failures.dart';

abstract class ITasksRemoteDataSource {
  Future<Either<Failure, List<Map<String, dynamic>>>> fetchTasks();
  
  Future<Either<Failure, void>> submitResult(
    String taskId,
    Map<String, dynamic> answer,
  );
  
  Future<Either<Failure, List<Map<String, dynamic>>>> getUpdates(DateTime lastUpdate);
}