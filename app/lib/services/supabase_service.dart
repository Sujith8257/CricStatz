import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static SupabaseClient get client => Supabase.instance.client;

  static User? get currentUser => client.auth.currentUser;

  static Stream<AuthState> get onAuthStateChange =>
      client.auth.onAuthStateChange;

  static Future<void> signInWithGoogle() async {
    await client.auth.signInWithOAuth(
      OAuthProvider.google,
      redirectTo: 'com.cricstatz.cricstatz://login-callback',
      authScreenLaunchMode: LaunchMode.externalApplication,
    );
  }

  static Future<void> signOut() async {
    await client.auth.signOut();
  }
}
