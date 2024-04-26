import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthService extends ChangeNotifier {
  // instance of auth
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  //sign in
  Future<UserCredential> signInWithEmailandPassword(
      String email, String password) async {
    try {
      //sign in
      UserCredential userCredential = await _firebaseAuth
          .signInWithEmailAndPassword(email: email, password: password);

      return userCredential;
    }
    // catch any errors
    on FirebaseAuthException catch (e) {
      throw Exception(e.code);
    }
  }

  // create new user
  Future<void> signUpWithEmailandPassword(String email, String password) async {
    try {
      UserCredential userCredential =
          await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? user = userCredential.user;

      // Store user details in Firestore
      if (user != null) {
        await _firestore.collection('users').doc(user.uid).set({
          'uid': user.uid,
          'email': email,
          'username': email.split('@')[0],
          'bio': 'Empty bio...',
        });
      }
    } catch (e) {
      throw Exception(e);
    }
  }

  // sign out
  Future<void> signOut() async {
    return await FirebaseAuth.instance.signOut();
  }
}
