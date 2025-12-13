import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// GOOGLE SIGN-IN PACKAGE
import 'package:google_sign_in/google_sign_in.dart';

// FACEBOOK SIGN-IN PACKAGE
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';


// -----------------------------------------------------------------------------
//                           GOOGLE SIGN-IN INSTANCE
// -----------------------------------------------------------------------------
// We create a single GoogleSignIn object.
// "scopes: ['email']" means we only request the user's email from Google.
GoogleSignIn _googleSignIn = GoogleSignIn(
  scopes: ['email'],
);



class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;        // Firebase Auth instance
  final FirebaseFirestore _firestore = FirebaseFirestore.instance; // Firestore instance



  // =============================================================================
  //                             REGISTER NEW USER
  // =============================================================================
  Future<String?> registerUser({
    required String fullName,
    required String email,
    required String password,
  }) async {
    try {
      // 1️⃣ Create user in Firebase Authentication
      UserCredential userCredential =
      await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;

      // If Firebase didn't return user → something went wrong
      if (user == null) return "Failed to create user";

      // 2️⃣ Send email verification to user's Gmail
      //await user.sendEmailVerification();

      // 3️⃣ Store extra user data in Firestore
      await _firestore.collection('users').doc(user.uid).set({
        'fullName': fullName,
        'email': email,
        'createdAt': FieldValue.serverTimestamp(),
        'emailVerified': false,
      });

      return 'success';

    } on FirebaseAuthException catch (e) {
      // Handle Firebase-specific errors
      if (e.code == 'email-already-in-use') return 'This email is already registered.';
      if (e.code == 'invalid-email') return 'Invalid email address.';
      if (e.code == 'weak-password') return 'Password should be at least 6 characters.';
      return e.message;

    } catch (e) {
      // Any other unknown errors
      return e.toString();
    }
  }



  // =============================================================================
  //                               LOGIN USER
  // =============================================================================
  Future<String?> loginUser({
    required String email,
    required String password,
  }) async {
    try {
      // 1️⃣ Login user using Firebase Authentication
      UserCredential userCredential =
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;

      if (user == null) return "User not found";

      // 2️⃣ Block login if email is not verified
   /*   if (!user.emailVerified) {
        await _auth.signOut(); // logout again
        return 'Please verify your email before logging in.';
      }

      // 3️⃣ Update Firestore to mark user as verified
      await _firestore.collection('users').doc(user.uid).update({
        'emailVerified': true,
      });*/

      return 'success';

    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') return "User not found";
      if (e.code == 'wrong-password') return "Incorrect password";
      return e.message;
    } catch (e) {
      return e.toString();
    }
  }



  // =============================================================================
  //                          LOGIN WITH GOOGLE
  // =============================================================================
  Future<String> signInWithGoogle() async {
    try {
      await _googleSignIn.signOut();

      final GoogleSignInAccount? googleUser =
      await _googleSignIn.signIn();

      if (googleUser == null) return "Cancelled";

      final googleAuth = await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // 🔐 Firebase login
      UserCredential userCredential =
      await _auth.signInWithCredential(credential);

      final user = userCredential.user;
      if (user == null) return "Failed";

      // ✅ SAVE USER IN FIRESTORE
      await _firestore.collection("users").doc(user.uid).set({
        "fullName": user.displayName ?? "Google User",
        "email": user.email,
        "createdAt": FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      return "success";
    } catch (e) {
      return e.toString();
    }
  }



  // =============================================================================
  //                         LOGIN WITH FACEBOOK
  // =============================================================================
  Future<String> signInWithFacebook() async {
    try {
      final LoginResult result =
      await FacebookAuth.instance.login();

      if (result.status == LoginStatus.cancelled) return "Cancelled";
      if (result.status == LoginStatus.failed) {
        return "Failed: ${result.message}";
      }

      final accessToken = result.accessToken;
      if (accessToken == null) return "No access token";

      final OAuthCredential credential =
      FacebookAuthProvider.credential(accessToken.token);

      // 🔐 Firebase login
      UserCredential userCredential =
      await _auth.signInWithCredential(credential);

      final user = userCredential.user;
      if (user == null) return "Failed";

      // ✅ SAVE USER IN FIRESTORE
      await _firestore.collection("users").doc(user.uid).set({
        "fullName": user.displayName ?? "Facebook User",
        "email": user.email,
        "createdAt": FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      return "success";
    } catch (e) {
      return e.toString();
    }
  }




  // =============================================================================
  //                          SEND PASSWORD RESET EMAIL
  // =============================================================================
  Future<String?> sendPasswordReset({required String email}) async {
    try {
      // Firebase sends password reset email
      await _auth.sendPasswordResetEmail(email: email);
      return 'success';

    } on FirebaseAuthException catch (e) {
      return e.message;

    } catch (e) {
      return e.toString();
    }
  }



  // =============================================================================
  //                                SIGN OUT
  // =============================================================================
  Future<void> signOut() async {
    // 1️⃣ Firebase logout
    await _auth.signOut();

    // ------------------ GOOGLE LOGOUT ------------------
    try {
      // Check if Google account is logged in
      if (await _googleSignIn.isSignedIn()) {
        // Disconnect removes account from device (safe here)
        await _googleSignIn.disconnect();
      }
      await _googleSignIn.signOut();
    } catch (e) {
      print("Google sign-out error: $e");
    }

    // ------------------ FACEBOOK LOGOUT ------------------
    try {
      await FacebookAuth.instance.logOut();
    } catch (e) {
      print("Facebook sign-out error: $e");
    }
  }
}



// =============================================================================
//                          EMAIL VALIDATION FUNCTION
// =============================================================================
bool isValidEmail(String email) {
  // Simple regex to check valid email format
  return RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$").hasMatch(email);
}
