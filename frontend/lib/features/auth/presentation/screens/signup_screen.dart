import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/core/routes/app_routes.dart';
import 'package:frontend/core/widgets/global_snack_bar.dart';
import 'package:frontend/core/widgets/app_logo.dart';
import 'package:frontend/features/auth/presentation/blocs/auth_bloc.dart';
import 'package:frontend/features/auth/presentation/blocs/auth_event.dart';
import 'package:frontend/features/auth/presentation/blocs/auth_state.dart';
import 'package:frontend/features/auth/presentation/widgets/background.dart';
import 'package:frontend/core/widgets/custom_text_field.dart';
import 'package:frontend/features/auth/presentation/widgets/submit_button.dart';
import 'package:frontend/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:frontend/core/message/message.dart';

class SignupScreen extends StatelessWidget {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  SignupScreen({super.key});

  void _handleSignup(BuildContext context) {
    if (_usernameController.text.isEmpty || _passwordController.text.isEmpty) {
      GlobalSnackBar.show(context, ErrorMessage('请填写用户名和密码'));
      return;
    }
    
    BlocProvider.of<AuthBloc>(context).add(
      AuthSignupRequested(
        username: _usernameController.text,
        password: _passwordController.text,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Background(),
          SafeArea(
            child: SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: MediaQuery.of(context).size.height - 
                    MediaQuery.of(context).padding.top,
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: BlocListener<AuthBloc, AuthState>(
                    listener: (context, state) {
                      if (state is AuthAuthenticatedState) {
                        context.go(AppRoutes.home);
                      } else if (state.message != null) {
                        GlobalSnackBar.show(context, state.message);
                      }
                    },
                    child: BlocBuilder<AuthBloc, AuthState>(
                      builder: (context, state) {
                        if (state is AuthLoadingState) {
                          return Center(
                            child: CircularProgressIndicator(color: Colors.white),
                          );
                        }
                        return Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(height: 40),
                            AppLogo(size: 100),
                            SizedBox(height: 32),
                            Container(
                              width: double.infinity,
                              constraints: BoxConstraints(maxWidth: 420),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(24.0),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.08),
                                    blurRadius: 30,
                                    offset: Offset(0, 15),
                                    spreadRadius: 0,
                                  ),
                                ],
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(40.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    Text(
                                      AppLocalizations.of(context).signUp,
                                      style: TextStyle(
                                        fontSize: 28,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.black87,
                                        letterSpacing: -0.5,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      '创建新账户，开始您的旅程',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[600],
                                        height: 1.4,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    SizedBox(height: 32),
                                    CustomTextField(
                                      controller: _usernameController,
                                      label: AppLocalizations.of(context).username,
                                      keyboardType: TextInputType.text,
                                    ),
                                    SizedBox(height: 20),
                                    CustomTextField(
                                      controller: _passwordController,
                                      label: AppLocalizations.of(context).password,
                                      obscureText: true,
                                      onFieldSubmitted: (_) => _handleSignup(context),
                                    ),
                                    SizedBox(height: 32),
                                    SubmitButton(
                                      text: AppLocalizations.of(context).signUp,
                                      onPressed: () => _handleSignup(context),
                                      isLoading: state is AuthLoadingState,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(height: 32),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  '已有账户？',
                                  style: TextStyle(color: Colors.white70, fontSize: 14),
                                ),
                                SizedBox(width: 4),
                                TextButton(
                                  onPressed: () {
                                    context.go(AppRoutes.login);
                                  },
                                  style: TextButton.styleFrom(
                                    foregroundColor: Colors.white,
                                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  ),
                                  child: Text(
                                    '立即登录',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 16),
                            TextButton(
                              onPressed: () {
                                context.go(AppRoutes.unauthenticatedHome);
                              },
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.white60,
                                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.home, size: 14),
                                  SizedBox(width: 4),
                                  Text(AppLocalizations.of(context).comeBack),
                                ],
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
