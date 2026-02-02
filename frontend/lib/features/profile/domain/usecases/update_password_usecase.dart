import 'package:dartz/dartz.dart';
import 'package:frontend/core/error/domain_error.dart';
import 'package:frontend/features/profile/domain/entities/profile.dart';
import 'package:frontend/features/profile/domain/repositories/profile_repository.dart';

class UpdatePasswordUseCase {
  final ProfileRepository profileRepository;

  UpdatePasswordUseCase(this.profileRepository);

  Future<Either<DomainError, Profile>> call({
    required String currentPassword,
    required String newPassword,
  }) async {
    return await profileRepository.updatePassword(currentPassword, newPassword);
  }
}
