import 'package:dartz/dartz.dart';
import 'package:frontend/core/error/domain_error.dart';
import 'package:frontend/features/auth/domain/entities/user_token.dart';
import 'package:frontend/features/auth/domain/errors/failures.dart';
import 'package:frontend/features/auth/domain/repositories/auth_repository.dart';

class LoginUseCase {
  final AuthRepository authRepository;

  LoginUseCase(this.authRepository);

  // Future<Either<UserTokenEntity, Failure>> login(
  //   String username,
  //   String password,
  // ) async {
  //   try {
  //     final result = await authRepository.login(
  //       username: username,
  //       password: password,
  //     );
  //
  //     return Left(
  //       UserTokenEntity(
  //         accessToken: result.accessToken,
  //         refreshToken: result.refreshToken,
  //         expiresIn: result.expiresIn,
  //       ),
  //     );
  //   } catch (e) {
  //     return Right(ServerFailure(message: e.toString()));
  //   }
  // }

  Future<Either<DomainError, Either<UserToken, String>>> call(String username, String password) async {
    final result = await authRepository.login(username: username, password: password);
    await result.fold((_) async {}, (userTokenOrUserId) async {
      await userTokenOrUserId.fold((userToken) async {
        // TODO Store token securely after successFul login
      }, (r) async {});
    });
    return result;
  }
}
