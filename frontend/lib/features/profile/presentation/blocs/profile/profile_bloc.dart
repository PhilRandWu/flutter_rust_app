import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/features/profile/domain/entities/profile.dart';
import 'package:frontend/features/profile/presentation/blocs/profile/profile_events.dart';
import 'package:frontend/features/profile/presentation/blocs/profile/profile_states.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  ProfileBloc() : super(ProfileLoading()) {
    on<ProfileInitializeEvent>(_initialize);
    on<ProfileUpdateThemeEvent>(_updateTheme);
    on<ProfileUpdateLocaleEvent>(_updateLocale);
  }

  Future<void> _initialize(
    ProfileInitializeEvent event,
    Emitter<ProfileState> emit,
  ) async {
    await Future.delayed(const Duration(milliseconds: 100));
    final profile = Profile(theme: 'light', locale: 'zh');
    emit(ProfileAuthenticated(profile: profile, devices: []));
  }

  Future<void> _updateTheme(
    ProfileUpdateThemeEvent event,
    Emitter<ProfileState> emit,
  ) async {
    final currentState = state as ProfileAuthenticated;
    emit(ProfileLoading(profile: state.profile));

    Profile profile = currentState.profile;
    profile.theme = event.theme;

    emit(ProfileAuthenticated(profile: profile, devices: []));
  }

  Future<void> _updateLocale(
    ProfileUpdateLocaleEvent event,
    Emitter<ProfileState> emit,
  ) async {
    final currentState = state as ProfileAuthenticated;
    emit(ProfileLoading(profile: state.profile));

    Profile profile = currentState.profile;
    profile.locale = event.locale;
    emit(ProfileAuthenticated(profile: profile, devices: []));
  }
}
