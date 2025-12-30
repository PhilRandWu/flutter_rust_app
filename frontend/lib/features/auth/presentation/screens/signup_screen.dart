import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/core/routes/app_routes.dart';
import 'package:frontend/core/widgets/global_snack_bar.dart';
import 'package:frontend/features/auth/presentation/blocs/auth_bloc.dart';
import 'package:frontend/features/auth/presentation/blocs/auth_event.dart';
import 'package:frontend/features/auth/presentation/blocs/auth_state.dart';
import 'package:frontend/features/auth/presentation/widgets/background.dart';
import 'package:frontend/core/widgets/custom_text_field.dart';
import 'package:frontend/features/auth/presentation/widgets/submit_button.dart';
import 'package:frontend/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';

class SignupScreen extends StatelessWidget {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  SignupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Background(),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: BlocListener<AuthBloc, AuthState>(
              listener: (context, state) {
                if (state is AuthAuthenticatedState) {
                  context.go(AppRoutes.home);
                } else {
                  GlobalSnackBar.show(context, state.message);
                }
              },
              child: BlocBuilder<AuthBloc, AuthState>(
                builder: (context, state) {
                  if (state is AuthLoadingState) {
                    return CircularProgressIndicator(color: Colors.white);
                  }
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(height: 100, width: 100, child: Placeholder()),
                      SizedBox(height: 40),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(
                            width: 1.0,
                            color: Colors.blue.shade200,
                          ),
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
                              ),
                              SizedBox(height: 24),
                              SubmitButton(
                                text: AppLocalizations.of(context).signUp,
                                onPressed: () {
                                  BlocProvider.of<AuthBloc>(context).add(
                                    AuthSignupRequested(
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
                        child: Text(AppLocalizations.of(context).comeBack),
                      ),
                      SizedBox(height: 16),
                      TextButton(
                        onPressed: () {
                          context.go(AppRoutes.login);
                        },
                        child: Text(
                          AppLocalizations.of(context).alreadyAnAccountLogin,
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
