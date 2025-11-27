import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'core/presentation/root_screen.dart';

void main() {
  runApp(const MyApp());
}

final _router = GoRouter(
  initialLocation: '/',
  routes: [
    ShellRoute(
      builder: (BuildContext context, GoRouterState state, Widget child) =>
          RootScreen(),
      routes: [
        GoRoute(path: '/', builder: (context, state) => Text('12313'))
      ],
    ),
  ],
);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: true, // 隐藏 Debug 横幅
      routerConfig: _router,
    );
  }
}
