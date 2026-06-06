import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import '../services/api_service.dart';

final apiServiceProvider = Provider((ref) => ApiService());

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.read(apiServiceProvider));
});

class AuthState {
  final bool isLoading;
  final String? error;
  final bool isSocialAuth;
  final bool isAuthSuccess;

  AuthState({
    this.isLoading = false,
    this.error,
    this.isSocialAuth = false,
    this.isAuthSuccess = false,
  });

  AuthState copyWith({
    bool? isLoading,
    String? error,
    bool? isSocialAuth,
    bool? isAuthSuccess,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      isSocialAuth: isSocialAuth ?? this.isSocialAuth,
      isAuthSuccess: isAuthSuccess ?? this.isAuthSuccess,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> with WidgetsBindingObserver {
  final ApiService _apiService;
  StreamSubscription<supabase.AuthState>? _authStateSubscription;
  Timer? _lifecycleTimer;

  AuthNotifier(this._apiService) : super(AuthState()) {
    WidgetsBinding.instance.addObserver(this);
    _initSupabaseListener();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState appState) {
    if (appState != AppLifecycleState.resumed) {
      _lifecycleTimer?.cancel();
      return;
    }

    if (appState == AppLifecycleState.resumed) {
      if (state.isLoading && state.isSocialAuth) {
        _lifecycleTimer?.cancel();
        
        _lifecycleTimer = Timer(const Duration(milliseconds: 500), () {
          if (!mounted) return;
          final session = supabase.Supabase.instance.client.auth.currentSession;
          
          if (session == null && state.isLoading && state.isSocialAuth && !state.isAuthSuccess) {
            state = state.copyWith(isLoading: false, isSocialAuth: false);
          }
        });
      }
    }
  }

  void _initSupabaseListener() {
    _authStateSubscription = supabase.Supabase.instance.client.auth.onAuthStateChange
        .listen((data) async {
      final event = data.event;
      final session = data.session;

      // Handle successful sign in from Supabase OAuth
      if (event == supabase.AuthChangeEvent.signedIn && session != null) {
        _lifecycleTimer?.cancel();

        final user = session.user;
        final provider = user.appMetadata['provider'] ?? 'unknown';

        // Check directly from provider instead of relying on memory state
        if (provider != 'google' && provider != 'facebook') return;

        if (!mounted) return;
        state = state.copyWith(isLoading: true, error: null, isAuthSuccess: false, isSocialAuth: true);
        try {
          final String email = (user.email != null && user.email!.isNotEmpty)
              ? user.email!
              : '${user.id}@$provider.social';
          final String fullName = user.userMetadata?['full_name'] ?? '';

          final nameParts = fullName.trim().split(' ');
          final firstName = nameParts.isNotEmpty ? nameParts.first : provider;
          final lastName = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : 'User';

          // Sync data to Spring Boot Backend
          await _apiService.socialLogin({
            'provider': provider,
            'email': email,
            'firstName': firstName,
            'lastName': lastName,
            'idToken': session.accessToken,
          });

          if (!mounted) return;
          state = state.copyWith(isLoading: false, isAuthSuccess: true, isSocialAuth: true);
        } catch (e) {
          if (!mounted) return;
          state = state.copyWith(
            isLoading: false,
            isSocialAuth: false,
            isAuthSuccess: false,
            error: e.toString().replaceAll('Exception: ', ''),
          );
        }
      }
    });
  }

  @override
  void dispose() {
    _lifecycleTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    _authStateSubscription?.cancel();
    super.dispose();
  }

  Future<bool> register(
    String firstName,
    String lastName,
    String email,
    String password,
  ) async {
    state = state.copyWith(isLoading: true, error: null, isSocialAuth: false, isAuthSuccess: false);
    try {
      await _apiService.register(firstName, lastName, email, password);
      if (!mounted) return false;
      state = state.copyWith(isLoading: false, isAuthSuccess: true, isSocialAuth: false);
      return true;
    } catch (e) {
      if (!mounted) return false;
      state = state.copyWith(
        isLoading: false,
        isAuthSuccess: false,
        error: e.toString().replaceAll('Exception: ', ''),
      );
      return false;
    }
  }

  Future<bool> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null, isSocialAuth: false, isAuthSuccess: false);
    try {
      await _apiService.login(email, password);
      if (!mounted) return false;
      state = state.copyWith(isLoading: false, isAuthSuccess: true, isSocialAuth: false);
      return true;
    } catch (e) {
      if (!mounted) return false;
      state = state.copyWith(
        isLoading: false,
        isAuthSuccess: false,
        error: e.toString().replaceAll('Exception: ', ''),
      );
      return false;
    }
  }

  Future<bool> socialLogin(String providerStr) async {
    state = state.copyWith(isLoading: true, error: null, isSocialAuth: true, isAuthSuccess: false);
    try {
      final client = supabase.Supabase.instance.client;
      
      if (providerStr == 'google') {
        const webClientId = '790202574296-9qsllsor2jv2n4qmg7d38fi1p3p6netv.apps.googleusercontent.com';
        const iosClientId = '790202574296-7fi2obusn34e5us92tpjhvif6bgfd3ea.apps.googleusercontent.com';
        
        final GoogleSignIn googleSignIn = GoogleSignIn(
          clientId: iosClientId,
          serverClientId: webClientId,
        );
        final googleUser = await googleSignIn.signIn();
        if (googleUser == null) {
           if (!mounted) return false;
           state = state.copyWith(isLoading: false);
           return false;
        }
        final googleAuth = await googleUser.authentication;
        final idToken = googleAuth.idToken;
        final accessToken = googleAuth.accessToken;
        
        if (idToken == null) {
           throw Exception('Google Sign In failed: Missing ID Token.');
        }
        
        await client.auth.signInWithIdToken(
          provider: supabase.OAuthProvider.google,
          idToken: idToken,
          accessToken: accessToken,
        );
      } else if (providerStr == 'facebook') {
        final result = await FacebookAuth.instance.login(
          permissions: ['public_profile', 'email'],
        );
        if (result.status != LoginStatus.success) {
           if (!mounted) return false;
           state = state.copyWith(isLoading: false);
           return false;
        }
        
        final accessToken = result.accessToken!.tokenString;
        
        await client.auth.signInWithIdToken(
          provider: supabase.OAuthProvider.facebook,
          idToken: accessToken,
        );
      } else {
        throw Exception('Unsupported social provider');
      }

      if (!mounted) return true;
      return true;
    } catch (e) {
      if (!mounted) return false;
      state = state.copyWith(
        isLoading: false,
        isAuthSuccess: false,
        error: e.toString().replaceAll('Exception: ', ''),
      );
      return false;
    }
  }

  Future<bool> forgotPassword(String email) async {
    state = state.copyWith(isLoading: true, error: null, isSocialAuth: false, isAuthSuccess: false);
    try {
      await _apiService.forgotPassword(email);
      if (!mounted) return false;
      state = state.copyWith(isLoading: false, isAuthSuccess: true, isSocialAuth: false);
      return true;
    } catch (e) {
      if (!mounted) return false;
      state = state.copyWith(
        isLoading: false,
        isAuthSuccess: false,
        error: e.toString().replaceAll('Exception: ', ''),
      );
      return false;
    }
  }
}