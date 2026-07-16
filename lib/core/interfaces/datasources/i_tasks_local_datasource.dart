import 'package:dartz/dartz.dart';
import '../../errors/failures.dart';

abstract class ITasksLocalDataSource {
  Future<Either<Failure, List<Map<String, dynamic>>>> getTasks();
  Future<Either<Failure, Map<String, dynamic>>> getTaskById(String id);
  Future<Either<Failure, void>> cacheTasks(List<Map<String, dynamic>> tasks);
  Future<Either<Failure, void>> markTaskCompleted(
    String taskId,
    Map<String, dynamic> answer,
  );
  
  Future<Either<Failure, Map<String, dynamic>>> getProgress();
  Future<Either<Failure, void>> saveProgress(Map<String, dynamic> progress);
  Future<Either<Failure, String?>> getTodayTaskId();
  Future<Either<Failure, void>> saveTodayTaskId(String taskId);
}