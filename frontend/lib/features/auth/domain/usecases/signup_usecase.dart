import 'package:dartz/dartz.dart';
import 'package:frontend/features/auth/data/repositories/auth_reposeitory.dart';
import 'package:frontend/features/auth/domain/entities/user_entity.dart';
import 'package:frontend/features/auth/domain/errors/failures.dart';

class SignupUseCase {
  final AuthRepository authRepository;

  SignupUseCase(this.authRepository);

  Future<Either<Failure, UserEntity>> signup(String username, String password) async {
    try {
      final userModal = await authRepository.register(username: username, password: password);

      return Right(UserEntity(
          id: userModal.id,
          username: userModal.username
      ));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}