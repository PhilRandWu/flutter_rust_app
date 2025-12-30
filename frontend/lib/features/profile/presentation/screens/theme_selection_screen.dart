import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/features/profile/presentation/blocs/profile/profile_bloc.dart';
import 'package:frontend/features/profile/presentation/blocs/profile/profile_events.dart';
import 'package:frontend/features/profile/presentation/blocs/profile/profile_states.dart';
import 'package:frontend/l10n/app_localizations.dart';

class ThemeSelectionScreen extends StatelessWidget {
  const ThemeSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final profileBloc = BlocProvider.of<ProfileBloc>(context);
      if (profileBloc.state is ProfileLoading) {
        profileBloc.add(ProfileInitializeEvent());
      }
    });

    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context).selectTheme)),
      body: BlocBuilder<ProfileBloc, ProfileState>(
        builder: (context, state) {
          if (state is ProfileLoading) {
            return Center(child: CircularProgressIndicator());
          } else if (state is ProfileAuthenticated) {
            return _buildThemeSelectionView(context, state);
          } else {
            return Center(
              child: Text(AppLocalizations.of(context).failedToLoadProfile),
            );
          }
        },
      ),
    );
  }

  Widget _buildThemeSelectionView(
    BuildContext context,
    ProfileAuthenticated state,
  ) {
    final List<Map<String, String>> themes = [
      {'code': 'light', 'name': AppLocalizations.of(context).light},
      {'code': 'dark', 'name': AppLocalizations.of(context).dark},
    ];
    return RadioGroup<String>(
      groupValue: state.profile.theme,
      onChanged: (String? value) {
        if (value != null) {
          BlocProvider.of<ProfileBloc>(
            context,
          ).add(ProfileUpdateThemeEvent(theme: value));
        }
      },
      child: Column(
        children: themes.map((theme) {
          return RadioListTile<String>(
            title: Text(theme['name']!),
            value: theme['code']!,
            contentPadding: EdgeInsets.zero,
          );
        }).toList(),
      ),
    );
  }
}
