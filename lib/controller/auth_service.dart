import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

/// A service that wraps Firebase Authentication and Google Sign-In,
/// providing methods and streams to sign in, sign out, and check the auth state.
class AuthService {
  /// FirebaseAuth singleton
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// The GoogleSignIn instance.
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Stream<User?> get userChanges => _auth.authStateChanges();

  /// The currently signed-in [User], or `null` if no user is signed in.
  User? get currentUser => _auth.currentUser;

  /// The UID of the currently signed-in user, or `null` if no user is signed in.
  String? get currentUserId => _auth.currentUser?.uid;

  /// Launches the Google Sign-In window, and signs the user into Firebase.
  /// Returns the authenticated [User] if login is successful, or `null` if the user
  /// cancels the Google sign-in dialog.
  Future<User?> signInWithGoogle() async {
    final googleUser = await _googleSignIn.signIn();
    if (googleUser == null) {
      return null;
    }

    final googleAuth = await googleUser.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken:     googleAuth.idToken,
    );

    final userCred = await _auth.signInWithCredential(credential);
    return userCred.user;
  }

  /// Signs out from both Firebase Authentication and GoogleSignIn.
  Future<void> signOut() async {
    await _auth.signOut();
    await _googleSignIn.signOut();
  }
}
