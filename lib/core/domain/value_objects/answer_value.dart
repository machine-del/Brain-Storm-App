import 'package:equatable/equatable.dart';

class AnswerValue extends Equatable {
  final String taskId;
  final dynamic value;
  final int timeSpentSeconds;

  const AnswerValue({
    required this.taskId,
    required this.value,
    required this.timeSpentSeconds,
  });

  bool get isSelectedOption => value is int;
  bool get isFreeText => value is String;

  @override
  List<Object?> get props => [taskId, value, timeSpentSeconds];
}