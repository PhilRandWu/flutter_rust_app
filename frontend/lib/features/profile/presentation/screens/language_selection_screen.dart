import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/features/profile/presentation/blocs/profile/profile_bloc.dart';
import 'package:frontend/features/profile/presentation/blocs/profile/profile_events.dart';
import 'package:frontend/features/profile/presentation/blocs/profile/profile_states.dart';
import 'package:frontend/l10n/app_localizations.dart';

class LocaleSelectionScreen extends StatelessWidget {
  const LocaleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final profileBloc = BlocProvider.of<ProfileBloc>(context);
      if (profileBloc.state is ProfileLoading) {
        profileBloc.add(ProfileInitializeEvent());
      }
    });
    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context).selectLanguage)),
      body: BlocBuilder<ProfileBloc, ProfileState>(
        builder: (context, state) {
          if (state is ProfileLoading) {
            return Center(child: CircularProgressIndicator());
          } else if (state is ProfileAuthenticated) {
            return _buildLocaleSelectionView(context, state);
          } else {
            return Center(
              child: Text(AppLocalizations.of(context).failedToLoadProfile),
            );
          }
        },
      ),
    );
  }

  Widget _buildLocaleSelectionView(
    BuildContext context,
    ProfileAuthenticated state,
  ) {
    final List<Map<String, String>> locales = [
      {'code': 'en', 'name': 'English'},
      {'code': 'zh', 'name': '简体中文'},
    ];

    return RadioGroup<String>(
      groupValue: state.profile.locale,
      onChanged: (String? value) {
        if (value != null) {
          BlocProvider.of<ProfileBloc>(
            context,
          ).add(ProfileUpdateLocaleEvent(locale: value));
        }
      },
      child: Column(
        children: locales.map((locale) {
          return RadioListTile<String>(
            title: Text(locale['name']!),
            value: locale['code']!,
            contentPadding: EdgeInsets.zero,
          );
        }).toList(),
      ),
    );
  }
}
