import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'data.dart';

enum AppTab { explore, sessions, profile }

sealed class AppEvent {
  const AppEvent();
}

final class TabChanged extends AppEvent {
  const TabChanged(this.tab);
  final AppTab tab;
}

final class PhoneVerified extends AppEvent {
  const PhoneVerified(this.phone);
  final String phone;
}

final class ProfileSaved extends AppEvent {
  const ProfileSaved(this.profile);
  final ConsumerProfile profile;
}

final class ConsultationCompleted extends AppEvent {
  const ConsultationCompleted(this.session);
  final SessionRecord session;
}

final class SignedOut extends AppEvent {
  const SignedOut();
}

@immutable
/// In-memory app state. Profiles and histories are scoped to a phone number;
/// a null history key represents consultations started as a guest.
class AppState {
  const AppState({
    this.tab = AppTab.explore,
    this.phone,
    this.profiles = const {},
    this.histories = const {},
  });

  final AppTab tab;
  final String? phone;
  final Map<String, ConsumerProfile> profiles;
  final Map<String?, List<SessionRecord>> histories;

  ConsumerProfile? get profile => phone == null ? null : profiles[phone];
  List<SessionRecord> get history => histories[phone] ?? const [];

  AppState copyWith({
    AppTab? tab,
    String? phone,
    bool clearPhone = false,
    Map<String, ConsumerProfile>? profiles,
    Map<String?, List<SessionRecord>>? histories,
  }) => AppState(
    tab: tab ?? this.tab,
    phone: clearPhone ? null : (phone ?? this.phone),
    profiles: profiles ?? this.profiles,
    histories: histories ?? this.histories,
  );
}

/// Owns the consumer data shared by Explore, Sessions and Profile.
class AppBloc extends Bloc<AppEvent, AppState> {
  AppBloc() : super(const AppState()) {
    on<TabChanged>((event, emit) => emit(state.copyWith(tab: event.tab)));
    on<PhoneVerified>(_onPhoneVerified);
    on<ProfileSaved>(_onProfileSaved);
    on<ConsultationCompleted>(_onConsultationCompleted);
    on<SignedOut>((event, emit) => emit(state.copyWith(clearPhone: true)));
  }

  void _onPhoneVerified(PhoneVerified event, Emitter<AppState> emit) {
    final histories = Map<String?, List<SessionRecord>>.from(state.histories);
    // Preserve guest consultations when the guest signs in, newest first.
    final guestHistory = histories.remove(null);
    if (guestHistory != null) {
      histories[event.phone] = [...guestHistory, ...?histories[event.phone]];
    }
    emit(state.copyWith(phone: event.phone, histories: histories));
  }

  void _onProfileSaved(ProfileSaved event, Emitter<AppState> emit) {
    final phone = state.phone;
    if (phone == null) return;
    emit(state.copyWith(profiles: {...state.profiles, phone: event.profile}));
  }

  void _onConsultationCompleted(
    ConsultationCompleted event,
    Emitter<AppState> emit,
  ) {
    // Copy the map and list so each emitted state has its own collection.
    final histories = Map<String?, List<SessionRecord>>.from(state.histories);
    histories[state.phone] = [event.session, ...?histories[state.phone]];
    emit(state.copyWith(histories: histories));
  }
}
