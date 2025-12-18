import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:frontend/core/routes/app_routes.dart';
import 'package:frontend/features/auth/domain/usecases/login_usecase.dart';
import 'package:frontend/features/auth/domain/usecases/signup_usecase.dart';
import 'package:go_router/go_router.dart';

import 'core/presentation/root_screen.dart';
import 'features/auth/data/repositories/auth_repository.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/bloc/auth_state.dart';
import 'features/auth/presentation/screen/login_screen.dart';
import 'features/auth/presentation/screen/signup_screen.dart';
import 'features/auth/presentation/screen/unauthenticated_home_screen.dart';
import 'features/profile/profile_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();
  runApp(const MyApp());
}

final _router = GoRouter(
  initialLocation: AppRoutes.unauthenticatedHome,
  routes: [
    GoRoute(
      path: AppRoutes.unauthenticatedHome,
      builder: (context, state) => UnauthenticatedHomeScreen(),
      redirect: (context, state) {
        if (state is AuthAuthenticated) {
          return AppRoutes.home;
        }
        return null;
      },
    ),
    GoRoute(
      path: AppRoutes.login,
      builder: (context, state) => LoginScreen(),
      redirect: (context, state) {
        if (state is AuthAuthenticated) {
          return AppRoutes.home;
        }
        return null;
      },
    ),
    GoRoute(
      path: AppRoutes.signup,
      builder: (context, state) => SignupScreen(),
      redirect: (context, state) {
        if (state is AuthAuthenticated) {
          return AppRoutes.recoveryCodes;
        }
        return null;
      },
    ),
    GoRoute(
      path: AppRoutes.recoveryCodes,
      builder: (context, state) => const Text('12313'),
    ),

    ShellRoute(
      builder: (BuildContext context, GoRouterState state, Widget child) =>
          RootScreen(child: child),
      routes: [
        GoRoute(
          path: AppRoutes.home,
          builder: (context, state) => Text('12313'),
        ),
        GoRoute(
          path: AppRoutes.profile,
          builder: (context, state) => ProfileScreen(),
        ),
      ],
      redirect: (context, state) {
        final authState = context.read<AuthBloc>().state;
        final isGoingHome = state.fullPath != '/';
        if (authState is AuthAuthenticated) {
          return null;
        } else {
          return isGoingHome ? null : '/';
        }
      },
    ),
  ],
);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    String apiUrl = dotenv.env['API_BASE_URL'] ?? 'http://0.0.0.0:3009';
    final authRepository = AuthRepository(baseUrl: apiUrl);

    final Brightness brightness = MediaQuery.of(context).platformBrightness;

    ThemeData themeData = brightness == Brightness.dark ? DarkAppTheme().themeData : LightAppTheme().themeData;

    return BlocProvider(
      create: (_) => AuthBloc(
        loginUseCase: LoginUseCase(authRepository),
        signupUseCase: SignupUseCase(authRepository),
      ),
      child: MaterialApp.router(
        debugShowCheckedModeBanner: true, // 隐藏 Debug 横幅
        theme: themeData,
        routerConfig: _router,
      ),
    );
  }
}
