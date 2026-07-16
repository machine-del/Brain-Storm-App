part of 'tasks_bloc.dart';

abstract class TasksEvent extends Equatable {
  const TasksEvent();

  @override
  List<Object?> get props => [];
}

class LoadDailyTaskEvent extends TasksEvent {}

class LoadTaskByIdEvent extends TasksEvent {
  final String taskId;

  const LoadTaskByIdEvent({required this.taskId});

  @override
  List<Object?> get props => [taskId];
}

class LoadTasksBySkillEvent extends TasksEvent {
  final SkillType skillType;

  const LoadTasksBySkillEvent({required this.skillType});

  @override
  List<Object?> get props => [skillType];
}

class SubmitAnswerEvent extends TasksEvent {
  final AnswerEntity answer;

  const SubmitAnswerEvent({required this.answer});

  @override
  List<Object?> get props => [answer];
}

class LoadCompletedTasksEvent extends TasksEvent {}

class LoadPendingTasksEvent extends TasksEvent {}

class LoadAllTasksEvent extends TasksEvent {}

class ResetDailyTaskEvent extends TasksEvent {}