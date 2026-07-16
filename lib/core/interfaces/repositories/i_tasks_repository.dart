import 'package:dartz/dartz.dart';
import '../../domain/entities/task_entity.dart';
import '../../domain/entities/answer_entity.dart';
import '../../domain/enums/skill_type.dart';
import '../../domain/enums/difficulty_level.dart';
import '../../errors/failures.dart';

abstract class ITasksRepository {
  Future<Either<Failure, List<TaskEntity>>> getTasksBySkill(SkillType skill);
  Future<Either<Failure, TaskEntity>> getDailyTask();
  Future<Either<Failure, TaskEntity>> getTaskById(String id);
  Future<Either<Failure, void>> submitAnswer(AnswerEntity answer);
  Future<Either<Failure, List<TaskEntity>>> getCompletedTasks();
  Future<Either<Failure, List<TaskEntity>>> getPendingTasks();
  Future<Either<Failure, int>> getTotalTasksCount();
  Future<Either<Failure, List<TaskEntity>>> getTasksByDifficulty(DifficultyLevel difficulty);
}