import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:frontend/features/auth/presentation/bloc/auth_state.dart';
import 'package:go_router/go_router.dart';

class UnauthenticatedHomeScreen extends StatelessWidget {
  const UnauthenticatedHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Unauthenticated Home Screen')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: BlocListener<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is AuthFailure) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(state.message)));
            }
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  context.go('/login');
                },
                child: Text("Login"),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  context.go('/signup');
                },
                child: Text("Sign Up"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
