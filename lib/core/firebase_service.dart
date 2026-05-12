import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_maps/Core/routes_manager.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';


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
  static Future<void> signInWithGoogle() async {
    final GoogleSignInAccount? googleUser =
    await GoogleSignIn().signIn();


    if (googleUser == null) return;


    final GoogleSignInAuthentication googleAuth =
    await googleUser.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    UserCredential userCredential =
    await FirebaseAuth.instance.signInWithCredential(credential);

    User? user = userCredential.user;
    String? name = user?.displayName ;
    String? email = user?.email;
    String? photo = user?.photoURL;
    String? token = await user?.getIdToken();
    String? googleAccessToken = googleAuth.accessToken;
    SharedPreferences preferences =await SharedPreferences.getInstance();
    await preferences.setString("gmailName", name!);
    await preferences.setString("gmailEmail", email!);
    await preferences.setString("gmailToken", token!);
    print("Name: $name");
    print("Email: $email");
    print("Photo: $photo");
    print("Firebase Token: $token");
    print("Google Access Token: $googleAccessToken");
  }}