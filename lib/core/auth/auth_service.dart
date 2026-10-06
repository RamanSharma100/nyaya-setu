import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hive_flutter/hive_flutter.dart';

class UserProfile {
  final String displayName;
  final String email;
  final String photoUrl;
  final String targetState;
  final bool isLoggedIn;

  UserProfile({
    required this.displayName,
    required this.email,
    required this.photoUrl,
    required this.targetState,
    required this.isLoggedIn,
  });

  factory UserProfile.guest() {
    return UserProfile(
      displayName: 'Guest User',
      email: '',
      photoUrl: '',
      targetState: 'DJS',
      isLoggedIn: false,
    );
  }
}

class AuthService {
  static const String authBoxName = 'user_auth_box';
  static final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
    serverClientId: '964695528281-sc3l8edm98l75f0pupd6dcmkd3hijp9e.apps.googleusercontent.com',
  );

  static Future<void> initAuthBox() async {
    if (!Hive.isBoxOpen(authBoxName)) {
      await Hive.openBox(authBoxName);
    }
    final box = Hive.box(authBoxName);
    final name = box.get('user_name', defaultValue: '') as String;
    // Purge any legacy static test profiles from disk storage
    if (name.toLowerCase().contains('sharma') || name.toLowerCase().contains('advocate')) {
      await box.clear();
      await box.put('is_logged_in', false);
    }
  }

  static UserProfile getUserProfile() {
    if (!Hive.isBoxOpen(authBoxName)) {
      return UserProfile.guest();
    }
    try {
      final box = Hive.box(authBoxName);
      final isLoggedIn = box.get('is_logged_in', defaultValue: false) as bool;
      final name = box.get('user_name', defaultValue: '') as String;
      final email = box.get('user_email', defaultValue: '') as String;
      final photo = box.get('user_photo', defaultValue: '') as String;
      final targetState = box.get('target_state', defaultValue: 'DJS') as String;

      if (!isLoggedIn || name.isEmpty) {
        return UserProfile.guest();
      }

      return UserProfile(
        displayName: name,
        email: email,
        photoUrl: photo,
        targetState: targetState,
        isLoggedIn: true,
      );
    } catch (_) {
      return UserProfile.guest();
    }
  }

  static Future<bool> signInWithGoogle() async {
    if (!Hive.isBoxOpen(authBoxName)) {
      await Hive.openBox(authBoxName);
    }
    try {
      final GoogleSignInAccount? account = await _googleSignIn.signIn();
      if (account != null) {
        final box = Hive.box(authBoxName);
        await box.put('is_logged_in', true);
        await box.put('user_name', account.displayName ?? account.email.split('@')[0]);
        await box.put('user_email', account.email);
        await box.put('user_photo', account.photoUrl ?? '');
        return true;
      }
    } catch (e) {
      return false;
    }
    return false;
  }

  static Future<void> signOut() async {
    if (!Hive.isBoxOpen(authBoxName)) {
      await Hive.openBox(authBoxName);
    }
    try {
      await _googleSignIn.signOut();
    } catch (_) {}
    final box = Hive.box(authBoxName);
    await box.clear();
    await box.put('is_logged_in', false);
  }
}

final userProfileProvider = StateNotifierProvider<UserAuthNotifier, UserProfile>((ref) {
  return UserAuthNotifier();
});

class UserAuthNotifier extends StateNotifier<UserProfile> {
  UserAuthNotifier() : super(AuthService.getUserProfile());

  Future<bool> loginWithGoogle() async {
    final success = await AuthService.signInWithGoogle();
    state = AuthService.getUserProfile();
    return success;
  }

  Future<void> logout() async {
    await AuthService.signOut();
    state = AuthService.getUserProfile();
  }

  void updateTargetState(String stateCode) {
    state = UserProfile(
      displayName: state.displayName,
      email: state.email,
      photoUrl: state.photoUrl,
      targetState: stateCode,
      isLoggedIn: state.isLoggedIn,
    );
  }
}
