import 'package:dartz/dartz.dart';
import 'package:frontend/core/error/domain_error.dart';
import 'package:frontend/features/profile/domain/repositories/profile_repository.dart';

class DeleteDeviceUseCase {
  final ProfileRepository profileRepository;

  DeleteDeviceUseCase(this.profileRepository);

  Future<Either<DomainError, void>> call(String deviceId) async {
    return await profileRepository.deleteDevices(deviceId);
  }
}
