import 'package:flutter_riverpod/flutter_riverpod.dart';
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
      displayName: 'Judicial Aspirant',
      email: 'aspirant@nyayasetu.in',
      photoUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150',
      targetState: 'DJS',
      isLoggedIn: false,
    );
  }
}

class AuthService {
  static const String authBoxName = 'user_auth_box';

  static Future<void> initAuthBox() async {
    if (!Hive.isBoxOpen(authBoxName)) {
      await Hive.openBox(authBoxName);
    }
  }

  static UserProfile getUserProfile() {
    if (!Hive.isBoxOpen(authBoxName)) {
      return UserProfile.guest();
    }
    try {
      final box = Hive.box(authBoxName);
      final isLoggedIn = box.get('is_logged_in', defaultValue: false) as bool;
      final name = box.get('user_name', defaultValue: 'Aspirant Advocate') as String;
      final email = box.get('user_email', defaultValue: 'advocate@judiciary.in') as String;
      final photo = box.get('user_photo', defaultValue: '') as String;
      final targetState = box.get('target_state', defaultValue: 'DJS') as String;

      return UserProfile(
        displayName: name,
        email: email,
        photoUrl: photo,
        targetState: targetState,
        isLoggedIn: isLoggedIn,
      );
    } catch (_) {
      return UserProfile.guest();
    }
  }

  static Future<void> signInWithGoogle() async {
    if (!Hive.isBoxOpen(authBoxName)) {
      await Hive.openBox(authBoxName);
    }
    final box = Hive.box(authBoxName);
    await box.put('is_logged_in', true);
    await box.put('user_name', 'Judge Aspirant Sharma');
    await box.put('user_email', 'sharma.pcsj@gmail.com');
    await box.put('user_photo', 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150');
  }

  static Future<void> signOut() async {
    if (!Hive.isBoxOpen(authBoxName)) {
      await Hive.openBox(authBoxName);
    }
    final box = Hive.box(authBoxName);
    await box.put('is_logged_in', false);
  }
}

final userProfileProvider = StateNotifierProvider<UserAuthNotifier, UserProfile>((ref) {
  return UserAuthNotifier();
});

class UserAuthNotifier extends StateNotifier<UserProfile> {
  UserAuthNotifier() : super(AuthService.getUserProfile());

  Future<void> loginWithGoogle() async {
    await AuthService.signInWithGoogle();
    state = AuthService.getUserProfile();
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
