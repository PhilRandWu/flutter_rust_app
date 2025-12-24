import 'package:equatable/equatable.dart';
import 'package:frontend/features/profile/domain/entities/device.dart';
import 'package:frontend/features/profile/domain/entities/profile.dart';

abstract class ProfileState extends Equatable {
  final Profile? profile;

  const ProfileState({this.profile});

  @override
  List<Object?> get props => [profile];
}

class ProfileLoading extends ProfileState {
  const ProfileLoading({super.profile});
}

class ProfileAuthenticated extends ProfileState {
  @override
  Profile get profile => super.profile!;

  final List<Device> devices;

  const ProfileAuthenticated({required super.profile, required this.devices});

  @override
  List<Object?> get props => [profile, devices];
}
