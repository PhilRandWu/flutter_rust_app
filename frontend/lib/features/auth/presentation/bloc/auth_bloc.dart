import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/features/auth/domain/usecases/login_usecase.dart';
import 'package:frontend/features/auth/domain/usecases/signup_usecase.dart';
import 'package:frontend/features/auth/presentation/bloc/auth_event.dart';
import 'package:frontend/features/auth/presentation/bloc/auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase loginUseCase;
  final SignupUseCase signupUseCase;

  AuthBloc({required this.loginUseCase, required this.signupUseCase})
    : super(AuthUnauthenticated()) {
    on<AuthLoginRequested>(_onLoginRequested);
    on<AuthLogoutRequested>(_onLogoutRequested);
    // on<AuthSignupRequested>(_onSignupRequested);
  }

  void _onLoginRequested(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final result = await loginUseCase.login(event.username, event.password);
    result.fold((userTokenEntity) {
      emit(
        AuthAuthenticated(
          accessToken: userTokenEntity.accessToken,
          refreshToken: userTokenEntity.refreshToken,
          expiresIn: userTokenEntity.expiresIn,
        ),
      );
    }, (failure) => emit(AuthFailure(message: failure.message)));
  }

  void _onLogoutRequested(
      AuthLogoutRequested event,
      Emitter<AuthState> emit
      ) {
    emit(AuthUnauthenticated());
  }

  // void _onSignupRequested(
  //   AuthSignupRequested event,
  //   Emitter<AuthState> emit,
  // ) async {
  //   emit(AuthLoading());
  //   final result = await signupUseCase.signup(event.username, event.password);
  //   result.fold(
  //     (failure) => emit(AuthFailure(message: failure.message)),
  //     (user) => emit(AuthAuthenticated(user: user)),
  //   );
  // }
}
