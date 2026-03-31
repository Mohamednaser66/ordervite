import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_maps/Core/routes_manager.dart';
import 'package:flutter_maps/core/error/exception.dart';

class FirebaseService{
  static String? userRole;
  static String verificationId = "";

  static Future<void> sendCode(String phone, String role, BuildContext context,) async {

    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: "+2$phone",

      verificationCompleted: (credential) {},

      verificationFailed: (e) {
        print(e.message);
      },

      codeSent: (verificationId, resendToken) {
        Navigator.pushNamed(
          context,
          RoutesManager.otpScreen,
          arguments: {
            "verificationId": verificationId,
            "role": role,
          },
        );
      },

      codeAutoRetrievalTimeout: (verificationId) {},
    );
  }
 static Future<void> signInWithOTP(String verificationId, String smsCode) async {
   FirebaseAuth _auth =FirebaseAuth.instance;
   PhoneAuthCredential credential = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: smsCode,
    );

    UserCredential userCredential =
    await _auth.signInWithCredential(credential);
  }
}