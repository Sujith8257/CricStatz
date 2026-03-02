import 'package:cricstatz/screens/auth/login_screen.dart';
import 'package:cricstatz/screens/auth/profile_setup_screen.dart';
import 'package:cricstatz/screens/home/home_screen.dart';
import 'package:cricstatz/screens/match/create_match_screen.dart';
import 'package:cricstatz/screens/match/match_list_screen.dart';
import 'package:cricstatz/screens/match/toss_screen.dart';
import 'package:cricstatz/screens/scoring/scoring_screen.dart';
import 'package:cricstatz/screens/stats/match_stats_screen.dart';
import 'package:cricstatz/screens/stats/player_stats_screen.dart';
import 'package:cricstatz/screens/teams/create_team_screen.dart';
import 'package:cricstatz/screens/teams/team_list_screen.dart';
import 'package:flutter/material.dart';

class AppRoutes {
  static const String login = '/login';
  static const String profileSetup = '/profile-setup';
  static const String home = '/';
  static const String teams = '/teams';
  static const String createTeam = '/teams/create';
  static const String matches = '/matches';
  static const String createMatch = '/matches/create';
  static const String toss = '/matches/toss';
  static const String scoring = '/scoring';
  static const String playerStats = '/stats/player';
  static const String matchStats = '/stats/match';

  static Map<String, WidgetBuilder> get routeTable => {
        login: (_) => const LoginScreen(),
        profileSetup: (_) => const ProfileSetupScreen(),
        teams: (_) => const TeamListScreen(),
        createTeam: (_) => const CreateTeamScreen(),
        matches: (_) => const MatchListScreen(),
        createMatch: (_) => const CreateMatchScreen(),
        toss: (_) => const TossScreen(),
        scoring: (_) => const ScoringScreen(),
        playerStats: (_) => const PlayerStatsScreen(),
        matchStats: (_) => const MatchStatsScreen(),
      };

  const AppRoutes._();
}
