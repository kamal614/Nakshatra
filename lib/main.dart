import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'account.dart';
import 'app_bloc.dart';
import 'design.dart';
import 'explore.dart';
import 'sessions.dart';

void main() => runApp(const NakshatraApp());

class NakshatraApp extends StatelessWidget {
  const NakshatraApp({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: plum,
      primary: plum,
      secondary: rust,
      surface: canvas,
    );
    return BlocProvider(
      create: (_) => AppBloc(),
      child: MaterialApp(
        title: 'Nakshatra Astrology',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: colorScheme,
          fontFamily: 'DM Sans',
          primaryColor: plum,
          scaffoldBackgroundColor: canvas,
          textSelectionTheme: const TextSelectionThemeData(
            cursorColor: rust,
            selectionColor: Color(0xFFFFD7BE),
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: paper,
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(
              vertical: 15,
              horizontal: 14,
            ),
            hintStyle: body(14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: rust, width: 1.4),
            ),
          ),
          chipTheme: ChipThemeData(
            backgroundColor: paper,
            side: const BorderSide(color: border),
            selectedColor: rose,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            showCheckmark: false,
            labelStyle: body(13, color: ink, weight: FontWeight.w600),
          ),
          snackBarTheme: const SnackBarThemeData(
            behavior: SnackBarBehavior.floating,
            backgroundColor: plum,
          ),
          navigationBarTheme: NavigationBarThemeData(
            backgroundColor: paper,
            indicatorColor: rose,
            iconTheme: WidgetStateProperty.resolveWith(
              (states) => IconThemeData(
                color: states.contains(WidgetState.selected) ? rust : muted,
                size: 22,
              ),
            ),
            labelTextStyle: WidgetStateProperty.resolveWith(
              (states) => body(
                12,
                color: states.contains(WidgetState.selected) ? rust : muted,
                weight: FontWeight.w700,
              ),
            ),
          ),
        ),
        home: const _AppShell(),
      ),
    );
  }
}

extension on AppTab {
  String get label => switch (this) {
    AppTab.explore => 'Explore',
    AppTab.sessions => 'Sessions',
    AppTab.profile => 'Profile',
  };

  IconData get icon => switch (this) {
    AppTab.explore => Icons.explore_outlined,
    AppTab.sessions => Icons.history_rounded,
    AppTab.profile => Icons.person_outline_rounded,
  };

  IconData get selectedIcon => switch (this) {
    AppTab.explore => Icons.explore_rounded,
    AppTab.sessions => Icons.history_rounded,
    AppTab.profile => Icons.person_rounded,
  };
}

class _AppShell extends StatelessWidget {
  const _AppShell();

  void _setTab(BuildContext context, AppTab tab) {
    FocusManager.instance.primaryFocus?.unfocus();
    context.read<AppBloc>().add(TabChanged(tab));
  }

  void _openLogin(BuildContext context) {
    _setTab(context, AppTab.profile);
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder:
            (_) => AuthPage(
              signup: false,
              onVerified:
                  (phone) => context.read<AppBloc>().add(PhoneVerified(phone)),
              onProfile:
                  (profile) =>
                      context.read<AppBloc>().add(ProfileSaved(profile)),
            ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => BlocBuilder<AppBloc, AppState>(
    builder: (context, state) {
      // The desktop navigation needs enough room for the brand, three tabs and
      // account control. Use the compact navigation below this width.
      final wide = MediaQuery.sizeOf(context).width >= 960;
      return Scaffold(
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              DecoratedBox(
                decoration: const BoxDecoration(
                  color: canvas,
                  border: Border(bottom: BorderSide(color: border)),
                ),
                child: PageFrame(
                  child: SizedBox(
                    height: wide ? 72 : 63,
                    child: Row(
                      children: [
                        Semantics(
                          button: true,
                          label: 'Nakshatra home',
                          excludeSemantics: true,
                          child: InkWell(
                            onTap: () => _setTab(context, AppTab.explore),
                            borderRadius: BorderRadius.circular(8),
                            child: const Padding(
                              padding: EdgeInsets.symmetric(vertical: 6),
                              child: Brand(),
                            ),
                          ),
                        ),
                        const Spacer(),
                        if (wide)
                          for (final destination in AppTab.values)
                            Padding(
                              padding: const EdgeInsets.only(right: 6),
                              child: TextButton.icon(
                                onPressed: () => _setTab(context, destination),
                                icon: Icon(destination.icon, size: 17),
                                label: Text(destination.label),
                                style: TextButton.styleFrom(
                                  foregroundColor:
                                      state.tab == destination ? rust : muted,
                                  backgroundColor:
                                      state.tab == destination
                                          ? rose
                                          : Colors.transparent,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 10,
                                  ),
                                  textStyle: body(14, weight: FontWeight.w700),
                                ),
                              ),
                            ),
                        if (wide) const Spacer(),
                        if (state.phone == null)
                          TextButton(
                            onPressed: () => _openLogin(context),
                            style: TextButton.styleFrom(
                              foregroundColor: ink,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 15,
                                vertical: 9,
                              ),
                              backgroundColor: paper,
                              side: const BorderSide(color: border),
                              textStyle: body(13, weight: FontWeight.w700),
                            ),
                            child: const Text('Log in'),
                          )
                        else
                          IconButton.filledTonal(
                            onPressed: () => _setTab(context, AppTab.profile),
                            tooltip: 'Your profile',
                            style: IconButton.styleFrom(
                              backgroundColor: rose,
                              foregroundColor: rust,
                            ),
                            icon:
                                state.profile == null
                                    ? const Icon(
                                      Icons.person_outline_rounded,
                                      size: 19,
                                    )
                                    : Text(
                                      state.profile!.name.characters.first
                                          .toUpperCase(),
                                      style: body(
                                        16,
                                        color: rust,
                                        weight: FontWeight.w700,
                                      ),
                                    ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              // Keep each tab mounted so its scroll position and filters survive
              // navigation between Explore, Sessions and Profile.
              Expanded(
                child: IndexedStack(
                  index: state.tab.index,
                  children: [
                    ExplorePage(
                      onConsultation:
                          (session) => context.read<AppBloc>().add(
                            ConsultationCompleted(session),
                          ),
                    ),
                    HistoryPage(
                      state.history,
                      onExplore: () => _setTab(context, AppTab.explore),
                    ),
                    AccountPage(
                      profile: state.profile,
                      phone: state.phone,
                      onVerified:
                          (phone) =>
                              context.read<AppBloc>().add(PhoneVerified(phone)),
                      onProfile:
                          (profile) => context.read<AppBloc>().add(
                            ProfileSaved(profile),
                          ),
                      onSignOut:
                          () => context.read<AppBloc>().add(const SignedOut()),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar:
            wide
                ? null
                : NavigationBar(
                  height: 64,
                  selectedIndex: state.tab.index,
                  onDestinationSelected:
                      (index) => _setTab(context, AppTab.values[index]),
                  destinations: [
                    for (final destination in AppTab.values)
                      NavigationDestination(
                        label: destination.label,
                        icon: Icon(destination.icon),
                        selectedIcon: Icon(destination.selectedIcon),
                      ),
                  ],
                ),
      );
    },
  );
}
