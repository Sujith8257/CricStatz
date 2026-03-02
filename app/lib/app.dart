import 'package:cricstatz/config/routes.dart';
import 'package:cricstatz/config/theme.dart';
import 'package:cricstatz/providers/auth_provider.dart';
import 'package:cricstatz/providers/match_provider.dart';
import 'package:cricstatz/providers/scoring_provider.dart';
import 'package:cricstatz/providers/team_provider.dart';
import 'package:cricstatz/screens/auth/login_screen.dart';
import 'package:cricstatz/screens/auth/profile_setup_screen.dart';
import 'package:cricstatz/screens/home/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CricStatzApp extends StatelessWidget {
  const CricStatzApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => TeamProvider()),
        ChangeNotifierProvider(create: (_) => MatchProvider()),
        ChangeNotifierProvider(create: (_) => ScoringProvider()),
      ],
      child: Consumer<AuthProvider>(
        builder: (context, auth, _) {
          return MaterialApp(
            title: 'CricStatz',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            routes: AppRoutes.routeTable,
            home: _buildHome(auth),
          );
        },
      ),
    );
  }

  Widget _buildHome(AuthProvider auth) {
    if (auth.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    if (!auth.isSignedIn) {
      return const LoginScreen();
    }
    if (!auth.isProfileComplete) {
      return const ProfileSetupScreen();
    }
    return const HomeScreen();
  }
}
