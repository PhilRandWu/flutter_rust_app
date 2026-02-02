import 'package:dartz/dartz.dart';
import 'package:frontend/core/error/domain_error.dart';
import 'package:frontend/features/auth/domain/entities/user_token.dart';

abstract class AuthRepository {
  Future<Either<DomainError, UserToken>> signup({
    required String username,
    required String password,
    required String locale,
    required String theme,
  });
  Future<Either<DomainError, Either<UserToken, String>>> login({
    required String username,
    required String password,
  });
  Future<Either<DomainError, void>> logout();
}
