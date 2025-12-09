import 'package:dartz/dartz.dart';
import 'package:frontend/features/auth/data/repositories/auth_repository.dart';
import 'package:frontend/features/auth/domain/entities/user_entity.dart';
import 'package:frontend/features/auth/domain/entities/user_token_entity.dart';
import 'package:frontend/features/auth/domain/errors/failures.dart';

class LoginUseCase {
  final AuthRepository authRepository;

  LoginUseCase(this.authRepository);

  Future<Either<UserTokenEntity, Failure>> login(
    String username,
    String password,
  ) async {
    try {
      final result = await authRepository.login(
        username: username,
        password: password,
      );

      return Left(
        UserTokenEntity(
          accessToken: result.accessToken,
          refreshToken: result.refreshToken,
          expiresIn: result.expiresIn,
        ),
      );
    } catch (e) {
      return Right(ServerFailure(message: e.toString()));
    }
  }
}
