import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/core/routes/app_routes.dart';
import 'package:frontend/core/widgets/app_logo.dart';
import 'package:frontend/core/widgets/custom_container.dart';
import 'package:frontend/core/widgets/global_snack_bar.dart';
import 'package:frontend/features/auth/presentation/blocs/auth_bloc.dart';
import 'package:frontend/features/auth/presentation/blocs/auth_event.dart';
import 'package:frontend/features/auth/presentation/blocs/auth_state.dart';
import 'package:frontend/features/auth/presentation/widgets/background.dart';
import 'package:frontend/core/widgets/custom_text_field.dart';
import 'package:frontend/features/auth/presentation/widgets/submit_button.dart';
import 'package:frontend/features/auth/presentation/widgets/successful_login_animation.dart';
import 'package:frontend/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:frontend/core/message/message.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<StatefulWidget> createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isAuthenticated = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authMessage = context.select((AuthBloc bloc) => bloc.state.message);

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Background(),
          if (!_isAuthenticated) _buildLoginContent(authMessage),
          SuccessfulLoginAnimation(
            isVisible: _isAuthenticated,
            onAnimationComplete: () {
              if (authMessage != null) {
                GlobalSnackBar.show(context, authMessage);
              }
              context.go(AppRoutes.home);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLoginContent(dynamic authMessage) {
    return SingleChildScrollView(
      physics: const ClampingScrollPhysics(),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: MediaQuery.of(context).size.height,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              AppLogo(),
              SizedBox(height: 40),
              CustomContainer(
                child: BlocConsumer<AuthBloc, AuthState>(
                  listener: (context, state) {
                    if (state is AuthAuthenticatedState) {
                      setState(() {
                        _isAuthenticated = true;
                      });
                    } else if (state.message != null &&
                        state is! AuthLoadingState) {
                      GlobalSnackBar.show(context, state.message);
                    }
                  },
                  builder: (context, state) {
                    if (state is AuthLoadingState) {
                      return _buildLoadingScreen();
                    } else {
                      return _buildLoginViewScreen(context);
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingScreen() {
    return Column(children: [CircularProgressIndicator()]);
  }

  Widget _buildLoginViewScreen(BuildContext context) {
    void triggerLogin() {
      if (_usernameController.text.isEmpty || _passwordController.text.isEmpty) {
        GlobalSnackBar.show(context, ErrorMessage('请填写用户名和密码'));
        return;
      }
      
      BlocProvider.of<AuthBloc>(context).add(
        AuthLoginRequested(
          username: _usernameController.text,
          password: _passwordController.text,
        ),
      );
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
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
                  AppLocalizations.of(context).logIn,
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
                  '欢迎回来，请登录您的账户',
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
                  onFieldSubmitted: (_) => triggerLogin(),
                ),
                SizedBox(height: 32),
                BlocBuilder<AuthBloc, AuthState>(
                  builder: (context, state) {
                    return SubmitButton(
                      text: AppLocalizations.of(context).logIn,
                      onPressed: triggerLogin,
                      isLoading: state is AuthLoadingState,
                    );
                  },
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
              '还没有账户？',
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),
            SizedBox(width: 4),
            TextButton(
              onPressed: () {
                context.go(AppRoutes.signup);
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              ),
              child: Text(
                '立即注册',
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
            children: [
              Icon(Icons.arrow_back_ios, size: 14),
              SizedBox(width: 4),
              Text(AppLocalizations.of(context).comeBack),
            ],
          ),
        ),
      ],
    );
  }
}
