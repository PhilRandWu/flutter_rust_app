import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/core/routes/app_routes.dart';
import 'package:frontend/core/ui/extensions.dart';
import 'package:frontend/core/widgets/app_logo.dart';
import 'package:frontend/core/widgets/global_snack_bar.dart'
    show GlobalSnackBar;
import 'package:frontend/features/auth/presentation/blocs/auth_bloc.dart';
import 'package:frontend/features/auth/presentation/blocs/auth_state.dart';
import 'package:frontend/features/auth/presentation/widgets/background.dart';
import 'package:frontend/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';

class UnauthenticatedHomeScreen extends StatelessWidget {
  const UnauthenticatedHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        GlobalSnackBar.show(context, state.message);
        if (state is AuthAuthenticatedState) {
          context.go(AppRoutes.home);
        }
      },
      child: Scaffold(
        body: Stack(
          children: [
            Background(),
            Center(
              child: SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: MediaQuery.of(context).size.height,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(30.0),
                    child: BlocBuilder<AuthBloc, AuthState>(
                      builder: (context, state) {
                        if (state is AuthLoadingState) {
                          return _buildLoadingScreen(context, state);
                        } else {
                          return _buildUnauthenticatedHomeScreen(context, state);
                        }
                      },
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingScreen(BuildContext context, AuthState state) {
    return Center(child: CircularProgressIndicator());
  }

  Widget _buildUnauthenticatedHomeScreen(
    BuildContext context,
    AuthState state,
  ) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        AppLogo(size: 120),
        SizedBox(height: 48),
        Text(
          AppLocalizations.of(context).welcome,
          textAlign: TextAlign.center,
          style: context.typographies.headingLarge.copyWith(
            color: context.colors.textOnPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 32,
            letterSpacing: -0.5,
          ),
        ),
        SizedBox(height: 20),
        Container(
          constraints: BoxConstraints(maxWidth: 320),
          child: Text(
            AppLocalizations.of(context).pleaseLoginOrSignUp,
            style: TextStyle(
              fontSize: 16,
              color: context.colors.hint.withValues(alpha: 0.8),
              letterSpacing: 0.3,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
          ),
        ),
        SizedBox(height: 64),
        Container(
          width: double.infinity,
          constraints: BoxConstraints(maxWidth: 320),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 登录按钮
              SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    context.push(AppRoutes.login);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: context.colors.primary,
                    elevation: 0,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ).copyWith(
                    overlayColor: WidgetStateProperty.resolveWith((states) {
                      if (states.contains(WidgetState.pressed)) {
                        return Colors.grey.withValues(alpha: 0.1);
                      }
                      return null;
                    }),
                  ),
                  child: Text(
                    AppLocalizations.of(context).logIn,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 16),
              // 注册按钮
              SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    context.push(AppRoutes.signup);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: context.colors.secondary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ).copyWith(
                    overlayColor: WidgetStateProperty.resolveWith((states) {
                      if (states.contains(WidgetState.pressed)) {
                        return Colors.white.withValues(alpha: 0.1);
                      }
                      return null;
                    }),
                  ),
                  child: Text(
                    AppLocalizations.of(context).signUp,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 32),
              // 底部说明文字
              Text(
                '开始使用我们的服务',
                style: TextStyle(
                  fontSize: 14,
                  color: context.colors.hint.withValues(alpha: 0.6),
                  letterSpacing: 0.3,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
