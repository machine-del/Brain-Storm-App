import 'package:dartz/dartz.dart';
import '../../domain/entities/answer_entity.dart';
import '../../errors/failures.dart';

abstract class ISubmitAnswer {
  Future<Either<Failure, void>> call(AnswerEntity answer);
}