import 'package:dartz/dartz.dart';
import 'package:frontend/core/error/domain_error.dart';
import 'package:frontend/features/profile/domain/entities/profile.dart';
import 'package:frontend/features/profile/domain/repositories/profile_repository.dart';

class GetProfileUseCase {
  final ProfileRepository profileRepository;

  GetProfileUseCase(this.profileRepository);

  Future<Either<DomainError, Profile>> call() async {
    return await profileRepository.getProfileInformation();
  }
}
