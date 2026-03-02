import 'dart:async';
import 'package:cricstatz/models/profile.dart';
import 'package:cricstatz/services/profile_service.dart';
import 'package:cricstatz/services/supabase_service.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthProvider extends ChangeNotifier {
  Profile? _profile;
  bool _isLoading = true;
  StreamSubscription<AuthState>? _authSub;

  AuthProvider() {
    _init();
  }

  Profile? get profile => _profile;
  bool get isLoading => _isLoading;
  bool get isSignedIn => SupabaseService.currentUser != null;
  bool get isProfileComplete => _profile != null;

  void _init() {
    _authSub = SupabaseService.onAuthStateChange.listen((authState) async {
      final event = authState.event;
      if (event == AuthChangeEvent.signedIn ||
          event == AuthChangeEvent.tokenRefreshed) {
        await _loadProfile();
      } else if (event == AuthChangeEvent.signedOut) {
        _profile = null;
        _isLoading = false;
        notifyListeners();
      }
    });

    // Check if already signed in
    if (SupabaseService.currentUser != null) {
      _loadProfile();
    } else {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _loadProfile() async {
    _isLoading = true;
    notifyListeners();

    final user = SupabaseService.currentUser;
    if (user != null) {
      _profile = await ProfileService.getProfile(user.id);
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> signInWithGoogle() async {
    await SupabaseService.signInWithGoogle();
  }

  Future<void> signOut() async {
    await SupabaseService.signOut();
    _profile = null;
    notifyListeners();
  }

  Future<void> createProfile({
    required String username,
    required String displayName,
    String? avatarUrl,
    required String role,
  }) async {
    final user = SupabaseService.currentUser;
    if (user == null) return;

    _profile = await ProfileService.createProfile(
      userId: user.id,
      username: username,
      displayName: displayName,
      avatarUrl: avatarUrl,
      role: role,
    );
    notifyListeners();
  }

  Future<void> refreshProfile() async {
    await _loadProfile();
  }

  @override
  void dispose() {
    _authSub?.cancel();
    super.dispose();
  }
}
