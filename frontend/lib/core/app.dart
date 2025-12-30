import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/core/routes/app_routes.dart';
import 'package:frontend/core/ui/themes/dark.dart';
import 'package:frontend/core/ui/themes/light.dart';
import 'package:frontend/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:frontend/features/auth/presentation/bloc/auth_event.dart';
import 'package:frontend/features/profile/bloc/profile/profile_bloc.dart';
import 'package:frontend/features/profile/bloc/profile/profile_states.dart';
import 'package:frontend/l10n/app_localizations.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: _createBlocProviders(),
      child: BlocBuilder<ProfileBloc, ProfileState>(
        builder: (context, state) {
          Locale locale = ui.window.locale;
          final Brightness brightness = MediaQuery.of(
            context,
          ).platformBrightness;
          ThemeData themeData = brightness == Brightness.dark
              ? DarkAppTheme().themeData
              : LightAppTheme().themeData;

          if (state.profile != null) {
            locale = Locale(state.profile!.locale);
            themeData = state.profile!.theme == 'dark'
                ? DarkAppTheme().themeData
                : LightAppTheme().themeData;
          }
          return MaterialApp.router(
            debugShowCheckedModeBanner: true, // 隐藏 Debug 横幅
            locale: locale,
            theme: themeData,
            routerConfig: router,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
          );
        },
      ),
    );
  }

  List<BlocProvider> _createBlocProviders() {
    final authBloc = AuthBloc();
    final profileBloc = ProfileBloc();

    authBloc.add(AuthInitializeEvent());

    return [
      BlocProvider<AuthBloc>(create: (context) => authBloc),
      BlocProvider<ProfileBloc>(create: (context) => profileBloc),
    ];
  }
}
