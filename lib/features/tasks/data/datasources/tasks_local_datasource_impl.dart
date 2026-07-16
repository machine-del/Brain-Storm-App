import 'dart:convert';
import 'package:dartz/dartz.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';

import '../../../../core/interfaces/datasources/i_tasks_local_datasource.dart';
import '../../../../core/errors/failures.dart';

class TasksLocalDataSourceImpl implements ITasksLocalDataSource {
  final SharedPreferences prefs;
  static const String _tasksKey = 'cached_tasks';
  static const String _progressKey = 'user_progress';
  static const String _todayTaskKey = 'today_task_';
  static const String _dataVersionKey = 'data_version';
  static const String _currentVersion = '1.0';

  TasksLocalDataSourceImpl({required this.prefs});

  @override
  Future<Either<Failure, List<Map<String, dynamic>>>> getTasks() async {
    try {
      final jsonString = prefs.getString(_tasksKey);
      if (jsonString == null) {
        return Left(CacheFailure(message: 'Нет сохранённых заданий'));
      }
      final List<dynamic> data = jsonDecode(jsonString);
      final tasks = data.map((e) => Map<String, dynamic>.from(e)).toList();
      return Right(tasks);
    } catch (e) {
      return Left(CacheFailure(message: 'Ошибка загрузки заданий: $e'));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getTaskById(String id) async {
    try {
      final tasksResult = await getTasks();
      return tasksResult.fold(
        (failure) => Left(failure),
        (tasks) {
          final task = tasks.firstWhere(
            (t) => t['id'] == id,
            orElse: () => throw Exception('Задание не найдено'),
          );
          return Right(task);
        },
      );
    } catch (e) {
      return Left(NotFoundFailure(message: 'Задание с ID $id не найдено'));
    }
  }

  @override
  Future<Either<Failure, void>> cacheTasks(List<Map<String, dynamic>> tasks) async {
    try {
      final jsonString = jsonEncode(tasks);
      await prefs.setString(_tasksKey, jsonString);
      await prefs.setString(_dataVersionKey, _currentVersion);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(message: 'Ошибка сохранения заданий: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> markTaskCompleted(
    String taskId,
    Map<String, dynamic> answer,
  ) async {
    try {
      final progressResult = await getProgress();
      return progressResult.fold(
        (failure) => Left(failure),
        (data) async {
          final completed = List<Map<String, dynamic>>.from(data['completed'] ?? []);
          completed.add({
            'taskId': taskId,
            'answer': answer,
            'completedAt': DateTime.now().toIso8601String(),
          });
          data['completed'] = completed;
          await saveProgress(data);
          return const Right(null);
        },
      );
    } catch (e) {
      return Left(DatabaseFailure(message: 'Ошибка отметки задания: $e'));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getProgress() async {
    try {
      final jsonString = prefs.getString(_progressKey);
      if (jsonString == null) {
        return Right({
          'completed': [],
          'totalPoints': 0,
          'streak': 0,
          'lastActivity': null,
          'skillProgress': {
            'creativity': 0,
            'logic': 0,
            'socialIntelligence': 0,
            'speed': 0,
          },
        });
      }
      final data = jsonDecode(jsonString) as Map<String, dynamic>;
      return Right(data);
    } catch (e) {
      return Left(CacheFailure(message: 'Ошибка загрузки прогресса: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> saveProgress(Map<String, dynamic> progress) async {
    try {
      final jsonString = jsonEncode(progress);
      await prefs.setString(_progressKey, jsonString);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(message: 'Ошибка сохранения прогресса: $e'));
    }
  }

  @override
  Future<Either<Failure, String?>> getTodayTaskId() async {
    try {
      final today = DateTime.now().toIso8601String().substring(0, 10);
      final key = '${_todayTaskKey}$today';
      final taskId = prefs.getString(key);
      return Right(taskId);
    } catch (e) {
      return Left(CacheFailure(message: 'Ошибка получения сегодняшнего задания: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> saveTodayTaskId(String taskId) async {
    try {
      final today = DateTime.now().toIso8601String().substring(0, 10);
      final key = '${_todayTaskKey}$today';
      await prefs.setString(key, taskId);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(message: 'Ошибка сохранения сегодняшнего задания: $e'));
    }
  }

  Future<Either<Failure, void>> initializeWithDefaultTasks() async {
    try {
      final tasksResult = await getTasks();
      return tasksResult.fold(
        (failure) async {
          if (failure is CacheFailure) {
            final defaultTasks = _getDefaultTasks();
            return await cacheTasks(defaultTasks);
          }
          return Left(failure);
        },
        (_) => const Right(null),
      );
    } catch (e) {
      return Left(CacheFailure(message: 'Ошибка инициализации: $e'));
    }
  }

  Future<Either<Failure, void>> loadTasksFromAssets() async {
    try {
      final jsonString = await rootBundle.loadString('assets/data/tasks.json');
      final List<dynamic> data = jsonDecode(jsonString);
      final tasks = data.map((e) => Map<String, dynamic>.from(e)).toList();
      return await cacheTasks(tasks);
    } catch (e) {
      return Left(CacheFailure(message: 'Ошибка загрузки заданий из assets: $e'));
    }
  }

  Future<Either<Failure, void>> checkAndUpdateTasks() async {
    try {
      final savedVersion = prefs.getString(_dataVersionKey);
      if (savedVersion != _currentVersion) {
        final result = await loadTasksFromAssets();
        if (result.isRight()) {
          await prefs.setString(_dataVersionKey, _currentVersion);
        }
        return result;
      }
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(message: 'Ошибка проверки обновлений: $e'));
    }
  }

  List<Map<String, dynamic>> _getDefaultTasks() {
    return [
      {
        'id': 'creative_001',
        'title': '10 применений для старого ноутбука',
        'description': 'У тебя есть старый ноутбук, который больше не включается. Найди 10 креативных способов его использования.',
        'instruction': 'Напиши список из 10 пунктов. Чем необычнее, тем лучше.',
        'hint': 'Подумай не только о техническом использовании, но и о декоре, мебели, подарках...',
        'explanation': 'Креативность оценивается по количеству и оригинальности идей.',
        'skillType': 'creativity',
        'difficulty': 'medium',
        'estimatedMinutes': 5,
        'isFreeText': true,
        'options': [],
        'correctAnswerIndex': -1,
        'createdAt': DateTime.now().toIso8601String(),
      },
      {
        'id': 'logic_001',
        'title': 'Найди следующее число',
        'description': '2, 6, 12, 20, 30, ? Какое следующее число?',
        'instruction': 'Выбери правильный вариант.',
        'hint': 'Разница между числами увеличивается на 2: 4, 6, 8, 10, 12...',
        'explanation': 'Правильный ответ: 42. Разница увеличивается на 2: 2+4=6, 6+6=12, 12+8=20, 20+10=30, 30+12=42.',
        'skillType': 'logic',
        'difficulty': 'easy',
        'estimatedMinutes': 2,
        'isFreeText': false,
        'options': ['38', '40', '42', '44'],
        'correctAnswerIndex': 2,
        'createdAt': DateTime.now().toIso8601String(),
      },
      {
        'id': 'social_001',
        'title': 'Коллега ошибся в коде',
        'description': 'Ваш коллега совершил серьёзную ошибку в продакшене, из-за чего сайт упал на 2 часа. Он сильно переживает.',
        'instruction': 'Что ты ему скажешь? Выбери лучший вариант.',
        'hint': 'Учитывай его эмоциональное состояние.',
        'explanation': 'Лучший вариант: поддержать и помочь исправить ошибку. Это укрепляет доверие.',
        'skillType': 'socialIntelligence',
        'difficulty': 'medium',
        'estimatedMinutes': 3,
        'isFreeText': false,
        'options': [
          'Как ты мог допустить такую ошибку?',
          'Не переживай, мы все ошибаемся. Давай разберёмся вместе.',
          'Ты должен был проверить перед деплоем.',
          'Я скажу начальнику, что это была моя ошибка.'
        ],
        'correctAnswerIndex': 1,
        'createdAt': DateTime.now().toIso8601String(),
      },
      {
        'id': 'speed_001',
        'title': 'Быстрый счёт',
        'description': 'Сколько будет 36 × 47?',
        'instruction': 'У тебя 10 секунд. Просто введи ответ.',
        'hint': 'Округляй: 40 × 47 = 1880, минус 4 × 47 = 188, получается 1692.',
        'explanation': 'Правильный ответ: 1692. Тренирует скорость вычислений.',
        'skillType': 'speed',
        'difficulty': 'medium',
        'estimatedMinutes': 1,
        'isFreeText': false,
        'options': ['1632', '1692', '1722', '1652'],
        'correctAnswerIndex': 1,
        'createdAt': DateTime.now().toIso8601String(),
      },
    ];
  }
}