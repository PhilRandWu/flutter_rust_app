import 'package:dartz/dartz.dart';
import 'package:frontend/features/auth/data/repositories/auth_reposeitory.dart';
import 'package:frontend/features/auth/domain/entities/user_entity.dart';
import 'package:frontend/features/auth/domain/errors/failures.dart';

class LoginUseCase {
  final AuthRepository authRepository;

  LoginUseCase(this.authRepository);

  Future<Either<Failure, UserEntity>> login(String username, String password) async {
    try {
      final userModal = await authRepository.login(username: username, password: password);

      return Right(UserEntity(
          id: userModal.id,
          username: username
      ));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}