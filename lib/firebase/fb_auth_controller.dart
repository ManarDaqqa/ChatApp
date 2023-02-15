
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import '../utils/helpers.dart';
import 'fb_firestore_controller.dart';

class FbAuthController with Helpers{
  final FirebaseAuth _firebaseAuth =FirebaseAuth.instance;


  Future<bool> signUp(
      BuildContext context, {required String username ,required String email,required String password,required File image}) async{
    try {
      UserCredential userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
          email: email,
          password: password,
      );
      await userCredential.user!.updateDisplayName(username);
      print(userCredential.user!.displayName);
      final ref = FirebaseStorage.instance.ref().child('user_image').child('${userCredential.user?.uid}.jpg');
      await ref.putFile(image);
      final url = await ref.getDownloadURL();

      FbFirestoreController().instance.collection('users').add({
        'username': username,
        'email': email,
        'password': password,
        'image_url': url
      });

      await userCredential.user?.sendEmailVerification();
      await _firebaseAuth.signOut();
      showSnackBar(context, message: 'Registered successfully, verify your email');
      return true;
    } on FirebaseAuthException catch (exception) {
      controlAuthException(context, authException: exception);
    } catch (e) {
      print('Error: $e');
    }
    return false;
  }

  Future<bool> signIn(
      BuildContext context, {required String email,required String password}) async {
    try {
      UserCredential userCredential = await _firebaseAuth.signInWithEmailAndPassword(
          email: email,
          password: password
      );
      if (userCredential.user != null ){
        if(userCredential.user!.emailVerified){
          return true;
        }
        showSnackBar(context, message: 'Email must be verified!',error: true);
        await _firebaseAuth.signOut();
      }
      return false;
    } on FirebaseAuthException catch (exception) {
      controlAuthException(context, authException: exception);
    } catch (e) {
      print('Error: $e');
    }
    return false;
  }

  Future<bool> forgetPassword(
      BuildContext context,{required String email}) async{
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
      return true;
    } on FirebaseAuthException catch (exception) {
      controlAuthException(context, authException: exception);
    } catch (e) {
      print('Error: $e');
    }
    return false;
  }

  Future<void> signOut() async{
    await _firebaseAuth.signOut();
  }


  void controlAuthException(BuildContext context,{required FirebaseAuthException authException}){
    showSnackBar(context, message: authException.message ?? '',error: true);
    switch (authException.code){
      case "email-already-in-use":
        break;
      case "invalid-email":
        break;
      case "operation-not-allowed":
        break;
      case "weak-password":
        break;
      case "user-disabled":
        break;
      case "user-not-found":
        break;
      case "wrong-password":
        break;

    }
  }
}