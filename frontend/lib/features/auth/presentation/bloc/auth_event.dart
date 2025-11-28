import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object> get props => [];
}

class AuthLoginRequested extends AuthEvent {
  final String username;
  final String password;

  const AuthLoginRequested({
    required this.username,
    required this.password,
  });

  @override
  List<Object> get props => [username, password];
}

class AuthSignupRequested extends AuthEvent {
  final String username;
  final String password;

  const AuthSignupRequested({
    required this.username,
    required this.password,
  });

  @override
  List<Object> get props => [username, password];
}
