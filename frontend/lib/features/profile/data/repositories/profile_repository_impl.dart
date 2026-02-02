import 'package:dartz/dartz.dart';
import 'package:frontend/core/error/domain_error.dart';
import 'package:frontend/features/profile/data/sources/remote_data_sources.dart';
import 'package:frontend/features/profile/domain/entities/device.dart';
import 'package:frontend/features/profile/domain/entities/profile.dart';
import 'package:frontend/features/profile/domain/repositories/profile_repository.dart';
import 'package:logger/web.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource remoteDataSource;
  final logger = Logger();

  ProfileRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<DomainError, void>> deleteDevices(String deviceId) {
    // TODO: implement deleteDevices
    throw UnimplementedError();
  }

  @override
  Future<Either<DomainError, List<Device>>> getDevices() {
    // TODO: implement getDevices
    throw UnimplementedError();
  }

  @override
  Future<Either<DomainError, Profile>> getProfileInformation() {
    // TODO: implement getProfileInformation
    throw UnimplementedError();
  }

  @override
  Future<Either<DomainError, Profile>> postProfileInformation(Profile profile) {
    // TODO: implement postProfileInformation
    throw UnimplementedError();
  }

  @override
  Future<Either<DomainError, Profile>> setPassword(String newPassword) {
    // TODO: implement setPassword
    throw UnimplementedError();
  }

  @override
  Future<Either<DomainError, Profile>> updatePassword(
    String currentPassword,
    String newPassword,
  ) {
    // TODO: implement updatePassword
    throw UnimplementedError();
  }
}
