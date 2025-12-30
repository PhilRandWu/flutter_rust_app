import 'package:equatable/equatable.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => [];
}

class ProfileInitializeEvent extends ProfileEvent {}

class ProfileUpdateThemeEvent extends ProfileEvent {
  final String theme;

  const ProfileUpdateThemeEvent({required this.theme});

  @override
  List<Object?> get props => [theme];
}

class ProfileUpdateLocaleEvent extends ProfileEvent {
  final String locale;

  const ProfileUpdateLocaleEvent({required this.locale});

  @override
  List<Object> get props => [locale];
}
