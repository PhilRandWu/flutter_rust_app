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

class LoginScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isAuthenticated = false;

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
        SizedBox(height: 100, width: 100, child: Placeholder()),
        SizedBox(height: 40),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(width: 1.0, color: Colors.blue.shade200),
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Padding(
            padding: const EdgeInsets.all(30.0),
            child: Column(
              children: [
                CustomTextField(
                  controller: _usernameController,
                  label: AppLocalizations.of(context).username,
                ),
                SizedBox(height: 16),
                CustomTextField(
                  controller: _passwordController,
                  label: AppLocalizations.of(context).password,
                  obscureText: true,
                  onFieldSubmitted: (_) => triggerLogin(),
                ),
                SizedBox(height: 24),
                SubmitButton(
                  text: AppLocalizations.of(context).logIn,
                  onPressed: () {
                    BlocProvider.of<AuthBloc>(context).add(
                      AuthLoginRequested(
                        username: _usernameController.text,
                        password: _passwordController.text,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: 16),
        ElevatedButton(
          onPressed: () {
            context.go(AppRoutes.unauthenticatedHome);
          },
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
          child: Text(AppLocalizations.of(context).comeBack),
        ),
        SizedBox(height: 16),
        TextButton(
          onPressed: () {
            context.go(AppRoutes.signup);
          },
          child: Text(
            AppLocalizations.of(context).noAccountCreateOne,
            style: TextStyle(color: Colors.white),
          ),
        ),
      ],
    );
  }
}
