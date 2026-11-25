// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:nakshatra_ui/app_bloc.dart';
import 'package:nakshatra_ui/data.dart';
import 'package:nakshatra_ui/main.dart';

void main() {
  testWidgets('shows the astrology discovery experience', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const NakshatraApp());

    expect(find.text('Explore astrologers'), findsOneWidget);
    expect(find.text('Meera Sharma'), findsOneWidget);
    expect(find.text('Search by name or specialty'), findsOneWidget);
  });

  test('keeps profile and session state in AppBloc', () async {
    final bloc = AppBloc();
    addTearDown(bloc.close);

    final verified = bloc.stream.firstWhere(
      (state) => state.phone == '9876543210',
    );
    bloc.add(const PhoneVerified('9876543210'));
    await verified;

    final profile = ConsumerProfile(
      name: 'Aditi Shah',
      birthDate: DateTime(1995),
      birthTime: TimeOfDay(hour: 12, minute: 0),
      birthplace: 'Pune, India',
    );
    final profileStored = bloc.stream.firstWhere(
      (state) => state.profile?.name == profile.name,
    );
    bloc.add(ProfileSaved(profile));
    await profileStored;

    final session = SessionRecord(
      astrologer: astrologers.first,
      method: Method.chat,
      duration: const Duration(minutes: 4),
      date: DateTime(2026, 11, 25),
    );
    final sessionStored = bloc.stream.firstWhere(
      (state) => state.history.singleOrNull == session,
    );
    bloc.add(ConsultationCompleted(session));
    await sessionStored;

    expect(bloc.state.profile?.birthplace, 'Pune, India');
    expect(bloc.state.history.single, session);
  });
}
