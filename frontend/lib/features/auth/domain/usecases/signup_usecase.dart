import 'package:dartz/dartz.dart';
import 'package:frontend/core/error/domain_error.dart';
import 'package:frontend/features/auth/domain/entities/user_token.dart';
import 'package:frontend/features/auth/domain/repositories/auth_repository.dart'
    show AuthRepository;

class SignupUseCase {
  final AuthRepository authRepository;

  SignupUseCase(this.authRepository);

  // Future<Either<Failure, UserEntity>> signup(String username, String password) async {
  //   try {
  //     final userModal = await authRepository.register(username: username, password: password);
  //
  //     return Right(UserEntity(
  //         id: userModal.id,
  //         username: userModal.username
  //     ));
  //   } catch (e) {
  //     return Left(ServerFailure(message: e.toString()));
  //   }
  // }

  Future<Either<DomainError, UserToken>> call(
    String username,
    String password,
    String locale,
    String theme,
  ) async {
    final result = await authRepository.signup(
      username: username,
      password: password,
      locale: locale,
      theme: theme,
    );

    await result.fold((_) async {}, (userToken) async {
      // TODO Store tokens securely after successful login
      // await TokenStorage().saveTokens(
      //   userToken.accessToken,
      //   userToken.refreshToken,
      // );
    });

    return result;
  }
}
