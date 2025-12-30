import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/core/message/message.dart';
import 'package:frontend/features/auth/data/storage/token_storage.dart';
import 'package:frontend/features/auth/domain/usecases/login_usecase.dart';
import 'package:frontend/features/auth/domain/usecases/signup_usecase.dart';
import 'package:frontend/features/auth/presentation/blocs/auth_event.dart';
import 'package:frontend/features/auth/presentation/blocs/auth_state.dart';
import 'package:get_it/get_it.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase loginUseCase = GetIt.instance<LoginUseCase>();
  final SignupUseCase signupUseCase = GetIt.instance<SignupUseCase>();

  AuthBloc() : super(AuthLoadingState()) {
    on<AuthInitializeEvent>(_initialize);
    on<AuthLoginRequested>(_onLoginRequested);
    on<AuthLogoutRequested>(_onLogoutRequested);
    // on<AuthSignupRequested>(_onSignupRequested);
  }

  Future<void> _initialize(
      AuthInitializeEvent event,
      Emitter<AuthState> emit
      ) async {
    final result = await TokenStorage().getAccessToken();
    
    if (result == null) {
      emit(AuthUnauthenticatedState());
    } else {
      emit(AuthAuthenticatedAfterLoginState(hasValidatedOtp: false));
    }
  }

  Future<void> _onLoginRequested(AuthLoginRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoadingState());

    final result = await loginUseCase.call(event.username, event.password);

    result.fold(
      (error) => emit(
        AuthUnauthenticatedState(message: ErrorMessage(error.messageKey)),
      ),
      (userTokenOrUserId) {
        userTokenOrUserId.fold((userToken) {
          print('userToken $userToken');
          emit(
            AuthAuthenticatedAfterLoginState(
              hasValidatedOtp: false,
              message: SuccessMessage("loginSuccessful"),
            ),
          );
        }, (userId) => emit(AuthValidateOneTimePasswordState(userId: userId)));
      },
    );
  }

  void _onLogoutRequested(AuthLogoutRequested event, Emitter<AuthState> emit) {
    // emit(AuthUnauthenticated());
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
