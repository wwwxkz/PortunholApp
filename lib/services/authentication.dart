import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

abstract class BaseAuth {
  Future<String> signIn(String email, String password);

  Future<String> signUp(String email, String password);

  Future<String> signUpWithName(String email, String password, String name, String number);

  Future<FirebaseUser> getCurrentUser();

  Future<void> sendEmailVerification();

  Future<void> signOut();

  Future<bool> isEmailVerified();
}

class Auth implements BaseAuth {
  final FirebaseDatabase _database = FirebaseDatabase.instance;
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  Future<String> signIn(String email, String password) async {
    FirebaseUser user = (await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: email, password: password)).user;
    return user.uid;
  }

  Future<String> signUpWithName(String email, String password, String name, String number) async {
    FirebaseUser user = (await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: email, password: password)).user;

    _database.reference().child('users/'+user.uid).set({
      'name': name,
      'email': email,
      'uid': user.uid,
      'number': number,
      'points': 0,
    });

    return user.uid;
  }

  Future<String> signUp(String email, String password) async {
    FirebaseUser user = (await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: email, password: password)).user;
    return user.uid;
  }

  Future<FirebaseUser> getCurrentUser() async {
    FirebaseUser user = await _firebaseAuth.currentUser();
    return user;
  }

  Future<void> signOut() async {
    return _firebaseAuth.signOut();
  }

  Future<void> sendEmailVerification() async {
    FirebaseUser user = await _firebaseAuth.currentUser();
    user.sendEmailVerification();
  }

  Future<bool> isEmailVerified() async {
    FirebaseUser user = await _firebaseAuth.currentUser();
    return user.isEmailVerified;
  }

}