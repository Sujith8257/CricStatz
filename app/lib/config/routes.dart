import 'package:cricstatz/screens/auth/login_screen.dart';
import 'package:cricstatz/screens/auth/profile_setup_screen.dart';
import 'package:cricstatz/screens/home/home_screen.dart';
import 'package:cricstatz/screens/match/info.dart';
import 'package:cricstatz/screens/match/live.dart';
import 'package:cricstatz/screens/match/players.dart';
import 'package:cricstatz/screens/match/scoreboard.dart';
import 'package:cricstatz/screens/match/toss_screen.dart';
import 'package:cricstatz/screens/match/upcoming_fixtures_screen.dart';
import 'package:cricstatz/screens/stats/results_screen.dart';
import 'package:flutter/material.dart';

class AppRoutes {
  static const String login = '/login';
  static const String profileSetup = '/profile-setup';
  static const String home = '/';
  static const String toss = '/matches/toss';
  static const String upcoming = '/matches/upcoming';
  static const String info = '/matches/info';
  static const String live = '/matches/live';
  static const String scoreboard = '/matches/scoreboard';
  static const String players = '/matches/players';
  static const String results = '/results';

  static Map<String, WidgetBuilder> get routeTable => {
<<<<<<< HEAD
        home: (_) => const HomeScreen(),
=======
        login: (_) => const LoginScreen(),
        profileSetup: (_) => const ProfileSetupScreen(),
        teams: (_) => const TeamListScreen(),
        createTeam: (_) => const CreateTeamScreen(),
        matches: (_) => const MatchListScreen(),
        createMatch: (_) => const CreateMatchScreen(),
>>>>>>> a98afb1878d115ca26211b59e9a79d3d1d6bfc6e
        toss: (_) => const TossScreen(),
        upcoming: (_) => const UpcomingFixturesScreen(),
        info: (_) => const MatchInfoScreen(),
        live: (_) => const MatchLiveScreen(),
        scoreboard: (_) => const MatchScoreboardScreen(),
        players: (_) => const MatchPlayersScreen(),
        results: (_) => const ResultsScreen(),
      };

  /// Smooth transition to ResultsScreen (fade + slight slide).
  static Route<void> buildResultsRoute() {
    return PageRouteBuilder<void>(
      settings: const RouteSettings(name: results),
      pageBuilder: (context, animation, secondaryAnimation) =>
          const ResultsScreen(),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const curve = Curves.easeOutCubic;
        final curved = CurvedAnimation(parent: animation, curve: curve);
        return FadeTransition(
          opacity: curved,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.04, 0),
              end: Offset.zero,
            ).animate(curved),
            child: child,
          ),
        );
      },
      transitionDuration: const Duration(milliseconds: 280),
    );
  }

  /// Smooth transition to UpcomingFixturesScreen (fade + slight slide).
  static Route<void> buildUpcomingRoute() {
    return PageRouteBuilder<void>(
      settings: const RouteSettings(name: upcoming),
      pageBuilder: (context, animation, secondaryAnimation) =>
          const UpcomingFixturesScreen(),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const curve = Curves.easeOutCubic;
        final curved = CurvedAnimation(parent: animation, curve: curve);
        return FadeTransition(
          opacity: curved,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.04, 0),
              end: Offset.zero,
            ).animate(curved),
            child: child,
          ),
        );
      },
      transitionDuration: const Duration(milliseconds: 280),
    );
  }

  const AppRoutes._();
}
