import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:frontend/core/network/auth_interceptor.dart';
import 'package:frontend/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:frontend/features/auth/data/services/auth_service.dart';
import 'package:frontend/features/auth/data/sources/remote_data_sources.dart';
import 'package:frontend/features/auth/data/storage/token_storage.dart';
import 'package:frontend/features/auth/domain/repositories/auth_repository.dart';
import 'package:frontend/features/auth/domain/usecases/login_usecase.dart';
import 'package:frontend/features/auth/domain/usecases/logout_usecase.dart';
import 'package:frontend/features/auth/domain/usecases/signup_usecase.dart';
import 'package:get_it/get_it.dart';
import 'package:http_interceptor/http/intercepted_client.dart';

import 'network/expired_token_retry_policy.dart';

final sl = GetIt.instance;

void setupServiceLocator() {
  final baseUrl = '${dotenv.env['API_BASE_URL'] ?? 'http://0.0.0.0:3009'} ';
  final tokenStorage = TokenStorage();
  final authService = AuthService(baseUrl: baseUrl, tokenStorage: tokenStorage);
  final apiClient = InterceptedClient.build(
    interceptors: [AuthInterceptor(baseUrl: baseUrl, tokenStorage: tokenStorage)],
    requestTimeout: Duration(seconds: 15),
    retryPolicy: ExpiredTokenRetryPolicy(authService: authService),
  );
  sl.registerSingleton<AuthRemoteDataSource>(
    AuthRemoteDataSource(baseUrl: baseUrl, apiClient: apiClient),
  );

  sl.registerSingleton<AuthRepository>(
    AuthRepositoryImpl(sl<AuthRemoteDataSource>()),
  );

  sl.registerSingleton<LoginUseCase>(LoginUseCase(sl<AuthRepository>()));
  sl.registerSingleton<SignupUseCase>(SignupUseCase(sl<AuthRepository>()));
  sl.registerSingleton<LogoutUseCase>(LogoutUseCase(sl<AuthRepository>()));
}
