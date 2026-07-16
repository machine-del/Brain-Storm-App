import 'package:dartz/dartz.dart';
import '../../domain/entities/user_entity.dart';
import '../../errors/failures.dart';

abstract class IUserRepository {
  Future<Either<Failure, UserEntity>> getUser();
  Future<Either<Failure, void>> updateUserName(String name);
  Future<Either<Failure, void>> updateLevel(int level);
  Future<Either<Failure, int>> getLevel();
  Future<Either<Failure, int>> getExperience();
  Future<Either<Failure, void>> addExperience(int amount);
}