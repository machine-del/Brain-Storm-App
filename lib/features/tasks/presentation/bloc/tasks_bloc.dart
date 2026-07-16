import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/domain/entities/task_entity.dart';
import '../../../../core/domain/entities/answer_entity.dart';
import '../../../../core/domain/enums/skill_type.dart';
import '../../../../core/interfaces/usecases/i_get_daily_task.dart';
import '../../../../core/interfaces/usecases/i_submit_answer.dart';
import '../../../../core/interfaces/repositories/i_tasks_repository.dart';
import '../../../../core/errors/failures.dart';

part 'tasks_event.dart';
part 'tasks_state.dart';

class TasksBloc extends Bloc<TasksEvent, TasksState> {
  final IGetDailyTask getDailyTask;
  final ISubmitAnswer submitAnswer;
  final ITasksRepository tasksRepository;

  TasksBloc({
    required this.getDailyTask,
    required this.submitAnswer,
    required this.tasksRepository,
  }) : super(TasksInitial()) {
    on<LoadDailyTaskEvent>(_onLoadDailyTask);
    on<LoadTaskByIdEvent>(_onLoadTaskById);
    on<LoadTasksBySkillEvent>(_onLoadTasksBySkill);
    on<SubmitAnswerEvent>(_onSubmitAnswer);
    on<LoadCompletedTasksEvent>(_onLoadCompletedTasks);
    on<LoadPendingTasksEvent>(_onLoadPendingTasks);
    on<ResetDailyTaskEvent>(_onResetDailyTask);
    on<LoadAllTasksEvent>(_onLoadAllTasks);
  }

  Future<void> _onLoadDailyTask(
    LoadDailyTaskEvent event,
    Emitter<TasksState> emit,
  ) async {
    emit(TasksLoading());
    final result = await getDailyTask();
    result.fold(
      (failure) => emit(TasksError(message: _mapFailureToMessage(failure))),
      (task) => emit(DailyTaskLoaded(task: task)),
    );
  }

  Future<void> _onLoadTaskById(
    LoadTaskByIdEvent event,
    Emitter<TasksState> emit,
  ) async {
    emit(TasksLoading());
    final result = await tasksRepository.getTaskById(event.taskId);
    result.fold(
      (failure) => emit(TasksError(message: _mapFailureToMessage(failure))),
      (task) => emit(DailyTaskLoaded(task: task)),
    );
  }

  Future<void> _onLoadTasksBySkill(
    LoadTasksBySkillEvent event,
    Emitter<TasksState> emit,
  ) async {
    emit(TasksLoading());
    final result = await tasksRepository.getTasksBySkill(event.skillType);
    result.fold(
      (failure) => emit(TasksError(message: _mapFailureToMessage(failure))),
      (tasks) => emit(TasksBySkillLoaded(tasks: tasks, skillType: event.skillType)),
    );
  }

  Future<void> _onSubmitAnswer(
    SubmitAnswerEvent event,
    Emitter<TasksState> emit,
  ) async {
    emit(AnswerSubmitting());
    final result = await submitAnswer(event.answer);
    result.fold(
      (failure) => emit(TasksError(message: _mapFailureToMessage(failure))),
      (_) {
        final points = event.answer.isCorrect ? 10 : 0;
        emit(AnswerSubmitted(
          isCorrect: event.answer.isCorrect,
          pointsEarned: points,
        ));
        add(LoadDailyTaskEvent());
      },
    );
  }

  Future<void> _onLoadCompletedTasks(
    LoadCompletedTasksEvent event,
    Emitter<TasksState> emit,
  ) async {
    emit(TasksLoading());
    final result = await tasksRepository.getCompletedTasks();
    result.fold(
      (failure) => emit(TasksError(message: _mapFailureToMessage(failure))),
      (tasks) => emit(CompletedTasksLoaded(tasks: tasks)),
    );
  }

  Future<void> _onLoadPendingTasks(
    LoadPendingTasksEvent event,
    Emitter<TasksState> emit,
  ) async {
    emit(TasksLoading());
    final result = await tasksRepository.getPendingTasks();
    result.fold(
      (failure) => emit(TasksError(message: _mapFailureToMessage(failure))),
      (tasks) => emit(PendingTasksLoaded(tasks: tasks)),
    );
  }

  Future<void> _onResetDailyTask(
    ResetDailyTaskEvent event,
    Emitter<TasksState> emit,
  ) async {
    await tasksRepository.getDailyTask();
    add(LoadDailyTaskEvent());
  }

  Future<void> _onLoadAllTasks(
    LoadAllTasksEvent event,
    Emitter<TasksState> emit,
  ) async {
    emit(TasksLoading());
    final result = await tasksRepository.getPendingTasks();
    result.fold(
      (failure) => emit(TasksError(message: _mapFailureToMessage(failure))),
      (tasks) => emit(PendingTasksLoaded(tasks: tasks)),
    );
  }

  String _mapFailureToMessage(Failure failure) {
    if (failure is NetworkFailure) {
      return 'Нет подключения к интернету';
    } else if (failure is CacheFailure) {
      return 'Ошибка кэша: ${failure.message}';
    } else if (failure is NotFoundFailure) {
      return failure.message;
    } else if (failure is DatabaseFailure) {
      return 'Ошибка базы данных: ${failure.message}';
    } else if (failure is UnknownFailure) {
      return failure.message;
    } else {
      return 'Произошла неизвестная ошибка';
    }
  }
}