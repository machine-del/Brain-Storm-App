part of 'tasks_bloc.dart';

abstract class TasksState extends Equatable {
  const TasksState();

  @override
  List<Object?> get props => [];
}

class TasksInitial extends TasksState {}

class TasksLoading extends TasksState {}

class DailyTaskLoaded extends TasksState {
  final TaskEntity task;

  const DailyTaskLoaded({required this.task});

  @override
  List<Object?> get props => [task];
}

class TasksBySkillLoaded extends TasksState {
  final List<TaskEntity> tasks;
  final SkillType skillType;

  const TasksBySkillLoaded({required this.tasks, required this.skillType});

  @override
  List<Object?> get props => [tasks, skillType];
}

class CompletedTasksLoaded extends TasksState {
  final List<TaskEntity> tasks;

  const CompletedTasksLoaded({required this.tasks});

  @override
  List<Object?> get props => [tasks];
}

class PendingTasksLoaded extends TasksState {
  final List<TaskEntity> tasks;

  const PendingTasksLoaded({required this.tasks});

  @override
  List<Object?> get props => [tasks];
}

class AnswerSubmitting extends TasksState {}

class AnswerSubmitted extends TasksState {
  final bool isCorrect;
  final int pointsEarned;

  const AnswerSubmitted({required this.isCorrect, required this.pointsEarned});

  @override
  List<Object?> get props => [isCorrect, pointsEarned];
}

class TasksError extends TasksState {
  final String message;

  const TasksError({required this.message});

  @override
  List<Object?> get props => [message];
}