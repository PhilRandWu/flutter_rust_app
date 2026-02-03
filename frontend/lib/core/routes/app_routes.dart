import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:frontend/core/presentation/root_screen.dart';
import 'package:frontend/features/auth/presentation/blocs/auth_bloc.dart';
import 'package:frontend/features/auth/presentation/blocs/auth_state.dart';
import 'package:frontend/features/auth/presentation/screens/login_screen.dart';
import 'package:frontend/features/auth/presentation/screens/signup_screen.dart';
import 'package:frontend/features/profile/presentation/screens/profile_screen.dart';
import 'package:frontend/features/auth/presentation/screens/unauthenticated_home_screen.dart';

class AppRoutes {
  static const String unauthenticatedHome = '/';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String recoveryCodes = '/recovery-codes';

  static const String home = '/home';
  static const String profile = '/profile';
}

GoRouter createRouter(BuildContext context) {
  final authBloc = context.read<AuthBloc>();

  return GoRouter(
    initialLocation: AppRoutes.unauthenticatedHome,
    // initialLocation: AppRoutes.home,
    routes: [
      ShellRoute(
        builder: (BuildContext context, GoRouterState state, Widget child) =>
            RootScreen(child: child),
        routes: [
          GoRoute(
            path: AppRoutes.home,
            builder: (context, state) =>
                const Scaffold(body: Center(child: Text('Home - Coming Soon'))),
          ),
            GoRoute(
              path: AppRoutes.profile,
              builder: (context, state) => ProfileScreen(),
            ),
        ],
        redirect: (context, state) {
          final authState = context.read<AuthBloc>().state;
          if (authState is AuthUnauthenticatedState) {
            return AppRoutes.login;
          }
          return null;
        },
      ),
      GoRoute(
        path: AppRoutes.unauthenticatedHome,
        builder: (context, state) => UnauthenticatedHomeScreen(),
        redirect: (context, state) {
          final authState = authBloc.state;
          if (authState is AuthAuthenticatedState) {
            return AppRoutes.home;
          }
          return null;
        },
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => LoginScreen(),
        redirect: (context, state) {
          final authState = context.read<AuthBloc>().state;
          if (authState is AuthAuthenticatedState) {
            return AppRoutes.home;
          }
          return null;
        },
      ),
      GoRoute(
        path: AppRoutes.signup,
        builder: (context, state) => SignupScreen(),
        redirect: (context, state) {
          final authState = context.read<AuthBloc>().state;
          if (authState is AuthAuthenticatedState) {
            return AppRoutes.recoveryCodes;
          }
          return null;
        },
      ),
      GoRoute(
        path: AppRoutes.recoveryCodes,
        builder: (context, state) => const Scaffold(
          body: Center(child: Text('Recovery Codes - Coming Soon')),
        ),
      ),
    ],
  );
}
