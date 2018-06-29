import 'package:flutter/material.dart';
import 'dart:async';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// User for authenticaion purposes via Google
class User {
  static final googleSignIn = new GoogleSignIn();
  static String idToken;
  static final auth = FirebaseAuth.instance;

  /// Attempt to log the user in if they were previously logged in via Google
  static Future<Null> attemptPreviousLogin({VoidCallback callback}) async {
    GoogleSignInAccount user = googleSignIn.currentUser;
    if (user == null) {
      user = await googleSignIn.signInSilently();

      if (user == null) {
        print("User not signed in");
        return;
      }
      
      if (await auth.currentUser() == null) {
        GoogleSignInAuthentication credentials =
        await googleSignIn.currentUser.authentication;
        var u = await auth.signInWithGoogle(
          idToken: credentials.idToken,
          accessToken: credentials.accessToken,
        );
        User.idToken = u.uid;
        print("idToken: ${User.idToken}");
      }
      else {
        User.idToken = (await auth.currentUser()).uid;
        print("idToken: ${User.idToken}");
        var u = await user.authentication;
        print("USERS AUTHENTICATION: ${u.idToken}");
      }
      print("Attempt sign In: ${user != null ? 'success' : 'fail'}");
      if (callback != null)
        callback();
    }
  }

  /// Determines if the user is signed in. If not, the user is prompted to sign in, else if the user was previously signed in, they are silently signed in, else nothing. Executes callback after everything
  static Future<Null> ensureLoggedIn({VoidCallback callback}) async {
    print("Starting Google sign in process");
    GoogleSignInAccount user = googleSignIn.currentUser;
    if (user == null)
    {
      if (user == null) {
        user = await googleSignIn.signInSilently();
      }
      if (user == null) {
        user = await googleSignIn.signIn();
      }
    }
    if (await auth.currentUser() == null) {
      GoogleSignInAuthentication credentials =
      await googleSignIn.currentUser.authentication;
      var u = await auth.signInWithGoogle(
        idToken: credentials.idToken,
        accessToken: credentials.accessToken,
      );
      User.idToken = u.uid;
      print("idToken: ${User.idToken}");
    }
    else {
      User.idToken = (await auth.currentUser()).uid;
      print("idToken: ${User.idToken}");
      var prevAuth = await user.authentication;
      print("USERS AUTHENTICATION 2: ${prevAuth.idToken}");
    }
    print("Signed In");
    if (callback != null)
        callback();
  }

  /// Sign the current user out from Google authentication in the app
  /// 
  /// Asynchronous
  static Future<Null> signOut({VoidCallback callback}) async {
    print("Signed out");
    await googleSignIn.signOut();
    auth.signOut();
    if (callback != null)
        callback();
  }

  /// Determines if the user is currntly signed in via Google
  static bool isSignedIn() {
    return googleSignIn.currentUser != null;
  }
}