import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:tremental/services/user_service.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final UserService _userService = UserService();

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Stream of auth state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Sync user information to server after Firebase login
  /// POST /api/users - 토큰 기준으로 유저 생성(이미 있으면 email/name/picture 갱신)
  Future<void> _syncUserToServer(User user, String provider) async {
    try {
      // POST /api/users는 토큰 기준으로 유저 생성/갱신
      // 이미 있으면 email/name/picture 갱신
      await _userService.registerUser(
        uid: user.uid,
        email: user.email,
        displayName: user.displayName,
        photoUrl: user.photoURL,
        provider: provider,
      );
      debugPrint('User synced to server: ${user.uid}');
    } catch (e) {
      debugPrint('Error syncing user to server: $e');
      // Don't throw - Firebase login is successful even if server sync fails
      // Server sync can be retried later
    }
  }

  // Sign in with Google
  Future<UserCredential?> signInWithGoogle() async {
    try {
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        // User canceled the sign-in
        return null;
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google credential
      final userCredential = await _auth.signInWithCredential(credential);

      // Sync user to server after successful login
      if (userCredential.user != null) {
        await _syncUserToServer(userCredential.user!, 'google');
        // 유저 정보를 캐시에 로드
        await _userService.loadUser();
      }

      return userCredential;
    } catch (e) {
      debugPrint('Error signing in with Google: $e');
      rethrow;
    }
  }

  // Sign in with Apple
  Future<UserCredential?> signInWithApple() async {
    try {
      // Request credential from Apple
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      // Create an `OAuthCredential` from the credential returned by Apple
      final oauthCredential = OAuthProvider("apple.com").credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );

      // Sign in to Firebase with the Apple credential
      final userCredential = await _auth.signInWithCredential(oauthCredential);

      // Sync user to server after successful login
      if (userCredential.user != null) {
        await _syncUserToServer(userCredential.user!, 'apple');
        // 유저 정보를 캐시에 로드
        await _userService.loadUser();
      }

      return userCredential;
    } catch (e) {
      debugPrint('Error signing in with Apple: $e');
      rethrow;
    }
  }

  // Sign out
  Future<void> signOut() async {
    await Future.wait([_auth.signOut(), _googleSignIn.signOut()]);
    // 유저 정보 캐시 클리어
    _userService.clearCache();
  }
}
