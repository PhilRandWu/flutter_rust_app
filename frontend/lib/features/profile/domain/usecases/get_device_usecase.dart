import 'package:dartz/dartz.dart';
import 'package:frontend/core/error/domain_error.dart';
import 'package:frontend/features/profile/domain/entities/device.dart';
import 'package:frontend/features/profile/domain/repositories/profile_repository.dart';

class GetDeviceUseCase {
  final ProfileRepository profileRepository;

  GetDeviceUseCase(this.profileRepository);

  Future<Either<DomainError, List<Device>>> call() async {
    return await profileRepository.getDevices();
  }
}
