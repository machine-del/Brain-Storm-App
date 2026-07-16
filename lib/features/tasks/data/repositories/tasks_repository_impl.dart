import 'package:dartz/dartz.dart';

import '../../../../core/interfaces/repositories/i_tasks_repository.dart';
import '../../../../core/interfaces/datasources/i_tasks_local_datasource.dart';
import '../../../../core/domain/entities/task_entity.dart';
import '../../../../core/domain/entities/answer_entity.dart';
import '../../../../core/domain/enums/skill_type.dart';
import '../../../../core/domain/enums/difficulty_level.dart';
import '../../../../core/errors/failures.dart';
import '../models/task_model.dart';

class TasksRepositoryImpl implements ITasksRepository {
  final ITasksLocalDataSource localDataSource;

  TasksRepositoryImpl({
    required this.localDataSource,
  });

  @override
  Future<Either<Failure, TaskEntity>> getDailyTask() async {
    try {
      final todayResult = await localDataSource.getTodayTaskId();
      return todayResult.fold(
        (failure) => Left(failure),
        (taskId) async {
          if (taskId != null) {
            final taskResult = await localDataSource.getTaskById(taskId);
            return taskResult.fold(
              (failure) => Left(failure),
              (taskData) => Right(TaskModel.fromJson(taskData).toEntity()),
            );
          }
          final allTasksResult = await localDataSource.getTasks();
          return allTasksResult.fold(
            (failure) => Left(failure),
            (tasks) async {
              if (tasks.isEmpty) {
                return Left(NotFoundFailure(message: 'Нет доступных заданий'));
              }

              final progressResult = await localDataSource.getProgress();
              return progressResult.fold(
                (failure) => Left(failure),
                (progress) async {
                  final completedIds = (progress['completed'] as List? ?? [])
                      .map((e) => e['taskId'] as String)
                      .toList();

                  final pending = tasks.where((t) => !completedIds.contains(t['id'])).toList();

                  if (pending.isEmpty) {
                    return Left(NotFoundFailure(message: 'Все задания выполнены!'));
                  }

                  final random = DateTime.now().millisecondsSinceEpoch % pending.length;
                  final selected = pending[random];

                  await localDataSource.saveTodayTaskId(selected['id']);

                  return Right(TaskModel.fromJson(selected).toEntity());
                },
              );
            },
          );
        },
      );
    } catch (e) {
      return Left(UnknownFailure(message: 'Ошибка получения задания: $e'));
    }
  }

  @override
  Future<Either<Failure, List<TaskEntity>>> getTasksBySkill(SkillType skill) async {
    try {
      final result = await localDataSource.getTasks();
      return result.fold(
        (failure) => Left(failure),
        (tasks) {
          final filtered = tasks
              .where((t) => t['skillType'] == skill.name)
              .map((t) => TaskModel.fromJson(t).toEntity())
              .toList();
          return Right(filtered);
        },
      );
    } catch (e) {
      return Left(UnknownFailure(message: 'Ошибка получения заданий по навыку: $e'));
    }
  }

  @override
  Future<Either<Failure, TaskEntity>> getTaskById(String id) async {
    try {
      final result = await localDataSource.getTaskById(id);
      return result.fold(
        (failure) => Left(failure),
        (taskData) => Right(TaskModel.fromJson(taskData).toEntity()),
      );
    } catch (e) {
      return Left(UnknownFailure(message: 'Ошибка получения задания: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> submitAnswer(AnswerEntity answer) async {
    try {
      final taskResult = await getTaskById(answer.taskId);
      return taskResult.fold(
        (failure) => Left(failure),
        (task) async {
          final isCorrect = _checkAnswer(task, answer);
          final updatedAnswer = answer.copyWith(isCorrect: isCorrect);

          final result = await localDataSource.markTaskCompleted(
            answer.taskId,
            updatedAnswer.toJson(),
          );

          return result.fold(
            (failure) => Left(failure),
            (_) async {
              await _updateProgress(updatedAnswer);
              return const Right(null);
            },
          );
        },
      );
    } catch (e) {
      return Left(UnknownFailure(message: 'Ошибка отправки ответа: $e'));
    }
  }

  @override
  Future<Either<Failure, List<TaskEntity>>> getCompletedTasks() async {
    try {
      final progressResult = await localDataSource.getProgress();
      return progressResult.fold(
        (failure) => Left(failure),
        (progress) async {
          final completedIds = (progress['completed'] as List? ?? [])
              .map((e) => e['taskId'] as String)
              .toList();

          final allTasksResult = await localDataSource.getTasks();
          return allTasksResult.fold(
            (failure) => Left(failure),
            (tasks) {
              final completed = tasks
                  .where((t) => completedIds.contains(t['id']))
                  .map((t) => TaskModel.fromJson(t).toEntity())
                  .toList();
              return Right(completed);
            },
          );
        },
      );
    } catch (e) {
      return Left(UnknownFailure(message: 'Ошибка получения выполненных заданий: $e'));
    }
  }

  @override
  Future<Either<Failure, List<TaskEntity>>> getPendingTasks() async {
    try {
      final completedResult = await getCompletedTasks();
      return completedResult.fold(
        (failure) => Left(failure),
        (completed) async {
          final allTasksResult = await localDataSource.getTasks();
          return allTasksResult.fold(
            (failure) => Left(failure),
            (tasks) {
              final completedIds = completed.map((t) => t.id).toList();
              final pending = tasks
                  .where((t) => !completedIds.contains(t['id']))
                  .map((t) => TaskModel.fromJson(t).toEntity())
                  .toList();
              return Right(pending);
            },
          );
        },
      );
    } catch (e) {
      return Left(UnknownFailure(message: 'Ошибка получения невыполненных заданий: $e'));
    }
  }

  @override
  Future<Either<Failure, int>> getTotalTasksCount() async {
    try {
      final result = await localDataSource.getTasks();
      return result.fold(
        (failure) => Left(failure),
        (tasks) => Right(tasks.length),
      );
    } catch (e) {
      return Left(UnknownFailure(message: 'Ошибка получения количества заданий: $e'));
    }
  }

  @override
  Future<Either<Failure, List<TaskEntity>>> getTasksByDifficulty(DifficultyLevel difficulty) async {
    try {
      final result = await localDataSource.getTasks();
      return result.fold(
        (failure) => Left(failure),
        (tasks) {
          final filtered = tasks
              .where((t) => t['difficulty'] == difficulty.name)
              .map((t) => TaskModel.fromJson(t).toEntity())
              .toList();
          return Right(filtered);
        },
      );
    } catch (e) {
      return Left(UnknownFailure(message: 'Ошибка получения заданий по сложности: $e'));
    }
  }

  bool _checkAnswer(TaskEntity task, AnswerEntity answer) {
    if (task.isFreeText) {
      return answer.freeTextAnswer != null && answer.freeTextAnswer!.trim().length > 3;
    } else {
      return answer.selectedIndex == task.correctAnswerIndex;
    }
  }

  Future<void> _updateProgress(AnswerEntity answer) async {
    final progressResult = await localDataSource.getProgress();
    progressResult.fold(
      (failure) => null,
      (progress) async {
        int points = answer.isCorrect ? 10 : 0;
        progress['totalPoints'] = (progress['totalPoints'] ?? 0) + points;

        final skillKey = answer.skillType.name;
        if (progress['skillProgress'] == null) {
          progress['skillProgress'] = {};
        }
        final current = progress['skillProgress'][skillKey] ?? 0;
        progress['skillProgress'][skillKey] = current + (answer.isCorrect ? 5 : 1);

        final lastActivity = progress['lastActivity'];
        if (lastActivity != null) {
          final lastDate = DateTime.parse(lastActivity);
          final today = DateTime.now();
          if (today.difference(lastDate).inDays <= 1) {
            progress['streak'] = (progress['streak'] ?? 0) + 1;
          } else {
            progress['streak'] = 1;
          }
        } else {
          progress['streak'] = 1;
        }

        progress['lastActivity'] = DateTime.now().toIso8601String();

        await localDataSource.saveProgress(progress);
      },
    );
  }
}