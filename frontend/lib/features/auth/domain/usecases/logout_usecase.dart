import 'package:dartz/dartz.dart';
import 'package:frontend/core/error/domain_error.dart';
import 'package:frontend/features/auth/domain/repositories/auth_repository.dart';

class LogoutUseCase {
  final AuthRepository authRepository;

  LogoutUseCase(this.authRepository);

  Future<Either<DomainError, void>> call() async {
    final result = await authRepository.logout();
    return result;
  }
}