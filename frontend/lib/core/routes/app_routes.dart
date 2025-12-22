import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/core/presentation/root_screen.dart';
import 'package:frontend/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:frontend/features/auth/presentation/bloc/auth_state.dart';
import 'package:frontend/features/auth/presentation/screen/login_screen.dart';
import 'package:frontend/features/auth/presentation/screen/signup_screen.dart';
import 'package:frontend/features/auth/presentation/screen/unauthenticated_home_screen.dart';
import 'package:frontend/features/profile/screen/profile_screen.dart';
import 'package:go_router/go_router.dart';

class AppRoutes {
  static const String unauthenticatedHome = '/';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String recoveryCodes = '/recovery-codes';

  static const String home = '/home';
  static const String profile = '/profile';
}


final router = GoRouter(
  // initialLocation: AppRoutes.unauthenticatedHome,
  initialLocation: AppRoutes.home,
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