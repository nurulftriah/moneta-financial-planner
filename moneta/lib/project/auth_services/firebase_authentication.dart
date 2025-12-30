import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:money_assistant_2608/project/classes/custom_toast.dart';

class FirebaseAuthentication {
  static Future<FirebaseApp> initializeFireBase() async {
    FirebaseApp firebaseApp = await Firebase.initializeApp();
    return firebaseApp;
  }

  static Future<User?> googleSignIn({required BuildContext context}) async {
    User? user;
    FirebaseAuth auth = FirebaseAuth.instance;
    final GoogleSignIn googleSignIn = GoogleSignIn();

    try {
      final GoogleSignInAccount? googleSignInAccount =
          await googleSignIn.signIn();
      if (googleSignInAccount != null) {
        final GoogleSignInAuthentication googleSignInAuthentication =
            await googleSignInAccount.authentication;
        final AuthCredential credential = GoogleAuthProvider.credential(
            accessToken: googleSignInAuthentication.accessToken,
            idToken: googleSignInAuthentication.idToken);

        final UserCredential userCredential =
            await auth.signInWithCredential(credential);
        user = userCredential.user;
      }
    } on FirebaseAuthException catch (e) {
      print(
          'FirebaseAuthException during Google Sign-In: ${e.code}, ${e.message}');
      if (e.code == 'account-exists-with-different-credential') {
        customToast(
            context, 'The account already exists with a different credential.');
      } else if (e.code == 'invalid-credential') {
        customToast(
            context, 'Error occurred while accessing credentials. Try again.');
      } else {
        customToast(context, 'Error: ${e.message}');
      }
    } catch (e) {
      print('Google Sign-In Error: $e');
      customToast(context, 'Error occurred using Google Sign-In. Try again.');
    }
    return user;
  }

  static Future<User?> signInWithEmailAndPassword({
    required String email,
    required String password,
    required BuildContext context,
  }) async {
    User? user;
    FirebaseAuth auth = FirebaseAuth.instance;
    try {
      UserCredential userCredential = await auth.signInWithEmailAndPassword(
          email: email, password: password);
      user = userCredential.user;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        customToast(context, 'No user found for that email.');
      } else if (e.code == 'wrong-password') {
        customToast(context, 'Wrong password provided for that user.');
      } else {
        customToast(context, 'Error: ${e.message}');
      }
    } catch (e) {
      customToast(context, 'Error signing in. Try again.');
    }
    return user;
  }

  static Future<User?> registerWithEmailAndPassword({
    required String email,
    required String password,
    required BuildContext context,
  }) async {
    User? user;
    FirebaseAuth auth = FirebaseAuth.instance;
    try {
      UserCredential userCredential = await auth.createUserWithEmailAndPassword(
          email: email, password: password);
      user = userCredential.user;
    } on FirebaseAuthException catch (e) {
      print(
          'FirebaseAuthException during Registration: ${e.code}, ${e.message}');
      if (e.code == 'weak-password') {
        customToast(context, 'The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        customToast(context, 'The account already exists for that email.');
      } else {
        customToast(context, 'Error: ${e.message}');
      }
    } catch (e) {
      print('Registration Error: $e');
      customToast(context, 'Error registering. Try again.');
    }
    return user;
  }

  static Future<void> signOut({required BuildContext context}) async {
    try {
      await FirebaseAuth.instance.signOut();

      try {
        await GoogleSignIn().signOut();
      } catch (e) {
        print('Google Sign Out Error: $e');
      }
    } catch (e) {
      print('Sign Out Error: $e');
      customToast(context, 'Error signing out. Try again.');
    }
  }

  static Future<void> resetPassword({
    required String email,
    required BuildContext context,
  }) async {
    FirebaseAuth auth = FirebaseAuth.instance;
    try {
      await auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      print('Reset Password Error: ${e.code}, ${e.message}');
      customToast(context, 'Error: ${e.message}');
      throw e;
    } catch (e) {
      print('Reset Password Error: $e');
      customToast(
          context, 'Error sending password reset email. Please try again.');
      throw e;
    }
  }
}
