import 'dart:async';
import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_maps/Core/routes_manager.dart';
import 'package:flutter_maps/core/app_validators.dart';
import 'package:flutter_maps/core/firebase_service.dart';
import 'package:flutter_maps/core/widgets/custom_text_form_field.dart';
import 'package:flutter_maps/core/widgets/sign_in_with_google_widget.dart';
import 'package:flutter_maps/lang.dart';
import 'package:flutter_maps/services/auth.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;
import 'package:location/location.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Register extends StatefulWidget {
  const Register({Key? key}) : super(key: key);

  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {

  late TextEditingController username ;
  late TextEditingController email ;
  late TextEditingController password ;
  late TextEditingController cPassword ;
  late TextEditingController mobile1 ;
  late TextEditingController mobile2 ;

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final Location _locationTracker = Location();

  bool isLoading = false;

  final GlobalKey<FormState> formstatesignup = GlobalKey<FormState>();

  final GlobalKey<ScaffoldState> mykey2 = GlobalKey<ScaffoldState>();
  Future<void> loginWithGoogle(BuildContext context) async {
    try {
      await FirebaseService.signInWithGoogle();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('User logged in successfully'),
        ),
      );

      Navigator.pushReplacementNamed(
        context,
        RoutesManager.shHome,
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'invalid-credential') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Wrong email or password'),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.message ?? 'Login failed'),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    username = TextEditingController();
    email = TextEditingController();
    password = TextEditingController();
    cPassword = TextEditingController();
    mobile1 = TextEditingController();
    mobile2 = TextEditingController();

  }



  @override
  void dispose() {
    username.dispose();
    email.dispose();
    password.dispose();
    cPassword.dispose();
    mobile1.dispose();
    mobile2.dispose();
    super.dispose();
  }


  String? validusername(String? val) {
    if (val == null || val.isEmpty) {
      return 'Username address is required';
    }
    if (val.length < 3) {
      return 'Username is not valid';
    }
    return null;
  }

  String? validemail(String? val) {
    if (val == null || val.trim().isEmpty) {
      return 'Email address is required';
    }

    String pattern =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regex = RegExp(pattern);

    if (!regex.hasMatch(val)) {
      return 'Invalid email address';
    }

    if (val.length < 6) {
      return 'Email Is too short';
    }

    return null;
  }

  String? validepassword(String? val) {
    if (val == null || val.isEmpty) {
      return 'Password is required';
    }
    if (val.length < 6) {
      return 'Password is too short';
    }
    return null;
  }

  String? validecpassword(String? val) {
    if (val == null || val.isEmpty) {
      return 'Password is not Confirmed';
    }
    if (val != password.text) {
      return 'Password does not match';
    }
    if (val.length < 6) {
      return 'Password is too short';
    }
    return null;
  }

  String? validmobile1(String? val) {
    if (val == null || val.isEmpty) {
      return 'Mobile 1 is required';
    }
    if (val.length < 9) {
      return 'Mobile 1 is too short';
    }
    return null;
  }

  String? validmobile2(String? val) {
    if (val == null || val.isEmpty) {
      return 'Mobile 2 is required';
    }
    if (val.length < 9) {
      return 'Mobile 2 is too short';
    }
    return null;
  }

  Future<void> savePref(
    String username,
    String email,
    String token,
    String id,
    String type,
  ) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.setString('username', username);
    await preferences.setString('email', email);
    await preferences.setString('token', token);
    await preferences.setString('id', id);
    await preferences.setString('type', type);
  }

  @override
  Widget build(BuildContext context) {
    Lang lang = Lang.of(context);
    return Directionality(
      textDirection: lang.lang == "en" ? TextDirection.ltr : TextDirection.rtl,
      child: Scaffold(
        key: mykey2,
        backgroundColor: const Color.fromRGBO(21, 42, 72, 0.9),
        appBar: AppBar(
          title: Text(
            lang.lang == "en" ? 'Client Registration' : "تسجيل العميل",
          ),
        ),
        body: InkWell(
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: Container(
            height: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF152A48), Color(0xFF0D1B2A)],
              ),
            ),
            child: Form(
              key: formstatesignup,
              child: ListView(
                padding: EdgeInsets.all(20.r),
                children: [
                  SizedBox(
                    height: 70.h,
                    child: CircleAvatar(
                      backgroundColor: Colors.blue,
                      child: Padding(
                        padding: EdgeInsets.all(8.0.r),
                        child: Icon(Icons.person, size: 50.sp, color: Colors.white),
                      ),
                    ),
                  ),
                  SizedBox(height: 20.h),
                  CustomTextFormField(
                    validation: validusername,
                    icon: Icon(Icons.person, color: Colors.blue),
                    controller: username,
                    hintText: lang.lang == 'en' ? "User Name" : "اسم المستخدم",
                    lable: lang.lang == 'en' ? "User Name" : "اسم المستخدم",
                  ),
                  CustomTextFormField(
                    icon: Icon(Icons.email, color: Colors.blue),
                    validation: AppValidators.emailOrPhoneValidator,
                    controller: email,
                    hintText: lang.lang == 'en'
                        ? 'Email Address'
                        : 'عنوان البريد الالكترونى',
                    lable: lang.lang == 'en' ? 'email' : 'البريد الالكترونى ',
                  ),
                  CustomTextFormField(
                    icon: Icon(Icons.key, color: Colors.blue),
                    validation: validepassword,
                    secure: true,
                    controller: password,
                    hintText: lang.lang == 'en' ? 'Password' : 'كلمة المرور',
                    lable: lang.lang == 'en' ? 'Password' : 'كلمة المرور',
                  ),
                  CustomTextFormField(
                    secure: true,
                    controller: cPassword,
                    validation: validecpassword,
                    icon: Icon(Icons.key, color: Colors.blue),
                    hintText: lang.lang == 'en'
                        ? 'Re Password'
                        : 'تاكيد كلمة المرور',
                    lable: lang.lang == 'en'
                        ? 'Re Password'
                        : 'تاكيد كلمة المرور',
                  ),
                  CustomTextFormField(
                    validation: validmobile1,
                    controller: mobile1,
                    icon: Icon(Icons.phone_android_outlined, color: Colors.blue),
                    hintText: lang.lang == 'en' ? 'Mobile 1' : 'رقم التليفون 1 ',
                    lable: lang.lang == 'en' ? 'Mobile 1' : 'رقم التليفون 1 ',
                  ),
                  CustomTextFormField(
                    controller: mobile2,
                    validation: validmobile2,
                    icon: Icon(Icons.phone_android_outlined, color: Colors.blue),
                    hintText: lang.lang == 'en' ? 'Mobile 2' : 'رقم التليفون 2 ',
                    lable: lang.lang == 'en' ? 'Mobile 2' : 'رقم التليفون 2 ',
                  ),
                  SizedBox(height: 20.h),
                  SizedBox(
                    height: 40.h,
                    child: ElevatedButton.icon(
                      icon: Icon(Icons.app_registration,size: 22.sp,),
                      label: Text(lang.lang == "en" ? "Sign UP" : "تسجيل "),
                      onPressed: () async {
                        if (!formstatesignup.currentState!.validate()) return;

                        setState(() => isLoading = true);

                        try {
                          await _firebaseMessaging.requestPermission();

                          String? apiToken = await _firebaseMessaging.getToken();
                          LocationData location = await _locationTracker
                              .getLocation();

                          var data = {
                            "name": username.text,
                            "email": email.text,
                            "password": password.text,
                            "c_password": cPassword.text,
                            "mobile1": mobile1.text,
                            "mobile2": mobile2.text,
                            "reg_longitude": location.longitude.toString(),
                            "reg_latitude": location.latitude.toString(),
                            "cur_longitude": location.longitude.toString(),
                            "cur_latitude": location.latitude.toString(),
                            "api_token": apiToken ?? "",
                          };

                          var response = await http.post(
                            Uri.parse(
                              "https://www.ordervite.com/api/supplier/register",
                            ),
                            body: data,
                          );

                          var reposnsebody = jsonDecode(response.body);

                          setState(() => isLoading = false);
                          if (reposnsebody["success"] == true) {
                            await savePref(
                              reposnsebody["data"]["name"]["name"],
                              reposnsebody["data"]["name"]["email"],
                              reposnsebody["data"]["token"],
                              reposnsebody["data"]["name"]["id"].toString(),
                              "supplier",
                            );
                            AuthService.setToken(
                              reposnsebody["data"]["token"],
                              reposnsebody["data"]["token"],
                              "supplier",
                            );
                            Navigator.of(
                              context,
                            ).pushReplacementNamed(RoutesManager.suHome);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  lang.lang == "en"
                                      ? 'Invalid data'
                                      : 'البيانات غير صحيحة',
                                ),
                              ),
                            );
                          }
                        } catch (e) {
                          setState(() => isLoading = false);
                          showDialog(
                            context: context,
                            builder: (_) => AlertDialog(
                              title: Text(lang.lang == "en" ? 'Warning' : 'تحذير'),
                              content: Text(
                                lang.lang == "en"
                                    ? 'Please check your network'
                                    : 'يرجي التحقق من اتصال الشبكة',
                              ),
                            ),
                          );
                        }
                      },
                    )),
                  // SizedBox(height: 16.h,),
                  // InkWell(
                  //     onTap: (){
                  //       loginWithGoogle(context);
                  //     },
                  //     child: SignInWithGoogleWidget(tittle: lang.lang=='en'?'Login With Google':'سجل بحساب google')),
                    SizedBox(height: 10.h,),
                    Row(children: [
                      Text( lang.lang == "en"
                          ? "If you already have an account please"
                          : "اذا يوجد لديك حساب يمكنك الستجيل من هنا",style: TextStyle(color: Colors.white,fontSize: 12.sp),),
                      TextButton(
                        style: TextButton.styleFrom(padding: REdgeInsets.all(4)),
                        onPressed: (){
                          Navigator.pushReplacementNamed(context, RoutesManager.login);
                        },
                        child: Text(lang.lang=='en'?'Sign In':'تسجيل الدخول',style: TextStyle(color: Colors.blue,fontSize: 12.sp),),)
                    ],),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
