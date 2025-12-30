import 'package:equatable/equatable.dart';
import 'package:frontend/core/message/message.dart';

abstract class AuthState extends Equatable {
  final Message? message;

  const AuthState({this.message});

  @override
  List<Object?> get props => [message];
}

class AuthUnauthenticatedState extends AuthState {
  const AuthUnauthenticatedState({super.message});

  @override
  List<Object?> get props => [message];
}

class AuthLoadingState extends AuthState {}

class AuthAuthenticatedState extends AuthState {
  const AuthAuthenticatedState({super.message});

  @override
  List<Object?> get props => [message];
}

class AuthAuthenticatedAfterRegistrationState extends AuthAuthenticatedState {
  final List<String>? recoveryCodes;
  final bool hasVerifiedOtp;

  const AuthAuthenticatedAfterRegistrationState({
    super.message,
    this.recoveryCodes,
    required this.hasVerifiedOtp,
  });

  @override
  List<Object?> get props => [message, recoveryCodes, hasVerifiedOtp];
}

class AuthAuthenticatedAfterLoginState extends AuthAuthenticatedState {
  final bool hasValidatedOtp;

  const AuthAuthenticatedAfterLoginState({
    super.message,
    required this.hasValidatedOtp,
  });

  @override
  List<Object?> get props => [message, hasValidatedOtp];
}

class AuthGenerateTwoFactorAuthenticationConfigState
    extends AuthAuthenticatedState {
  final String otpBase32;
  final String otpAuthUrl;

  const AuthGenerateTwoFactorAuthenticationConfigState({
    super.message,
    required this.otpBase32,
    required this.otpAuthUrl,
  });

  @override
  List<Object?> get props => [message, otpBase32, otpAuthUrl];
}

class AuthVerifyOneTimePasswordState
    extends AuthGenerateTwoFactorAuthenticationConfigState {
  const AuthVerifyOneTimePasswordState({
    super.message,
    required super.otpBase32,
    required super.otpAuthUrl,
  });
}

class AuthValidateOneTimePasswordState extends AuthState {
  final String userId;

  const AuthValidateOneTimePasswordState({super.message, required this.userId});

  @override
  List<Object?> get props => [message, userId];
}
