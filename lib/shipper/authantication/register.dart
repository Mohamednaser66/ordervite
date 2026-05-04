import 'dart:async';
import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_maps/Core/routes_manager.dart';
import 'package:flutter_maps/core/app_validators.dart';
import 'package:flutter_maps/core/constant_manager.dart';
import 'package:flutter_maps/core/widgets/custom_text_form_field.dart';
import 'package:flutter_maps/lang.dart';
import 'package:flutter_maps/services/auth.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:location/location.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RegisterSH extends StatefulWidget {
  RegisterSH({Key? key}) : super(key: key);

  @override
  _RegisterSHState createState() => _RegisterSHState();
}

showdialog(context) {
  return showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(title: Text("Loading...."));
    },
  );
}

class _RegisterSHState extends State<RegisterSH> {

 late TextEditingController username ;
 late TextEditingController email ;
 late TextEditingController password ;
 late TextEditingController cpassword ;
 late TextEditingController mobile1 ;
 late TextEditingController mobile2 ;

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  Location _locationTracker = Location();
  late Marker marker;
  late Circle circle;
  bool isLoading = false;

  GlobalKey<FormState> formstatesignup = new GlobalKey<FormState>();

  final mykey2 = GlobalKey<ScaffoldState>();

  Future<Uint8List> getMarker() async {
    ByteData byteData = await DefaultAssetBundle.of(
      context,
    ).load("assets/mark.png");
    return byteData.buffer.asUint8List();
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
  savePref(
    String username,
    String email,
    String token,
    String id,
    String type,
  ) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.setString('username', username);
    preferences.setString('email', email);
    preferences.setString('token', token);
    preferences.setString('id', id);
    preferences.setString('type', type);
  }
  @override
  void dispose() {
    username.dispose();
    email.dispose();
    password.dispose();
    cpassword.dispose();
    mobile1.dispose();
    mobile2.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    username =  TextEditingController();
    email =  TextEditingController();
    password =  TextEditingController();
    cpassword =  TextEditingController();
    mobile1 =  TextEditingController();
    mobile2 =  TextEditingController();
  }

String roles = ConstantManager.shipper;
  Widget build(BuildContext context) {
    Lang lang = Lang.of(context);

    return Directionality(
      textDirection: lang.lang == "en" ? TextDirection.ltr : TextDirection.rtl,
      child: Scaffold(
        key: mykey2,
        backgroundColor: Color.fromRGBO(21, 42, 72, 0.9),
        appBar: AppBar(
          title: Text(
            lang.lang == "en" ? 'Shipper Registration ' : 'تسجيل مسئول شحن ',
            style: TextStyle(
              fontSize: 25.sp,
              fontWeight: FontWeight.bold,
              fontStyle: FontStyle.normal,
              color: Colors.white,
            ),
          ),
        ),
        body: InkWell(onTap: () {
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
              child: SingleChildScrollView(
                child: Padding(
                  padding: REdgeInsets.all(12.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    //   mainAxisSize: MainAxisSize.max,
                    children: <Widget>[
                      Padding(padding: EdgeInsets.only(top: 2.h)),
                      Container(
                        margin: REdgeInsets.symmetric(vertical: 30.h),
                        width: 70.w,
                        height: 70.h,
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.circular(100.r),
                        ),
                        child: Icon(Icons.person, size: 50.sp, color: Colors.white),
                      ),
                      SizedBox(height: 20.h),
                      CustomTextFormField(
                        icon: Icon(Icons.person, color: Colors.blue),
                        validation: AppValidators.validateUsername,
                        controller: username,
                        hintText: lang.lang == 'en'
                            ? "User Name"
                            : "اسم المستخدم",
                        lable: lang.lang == 'en' ? "User Name" : "اسم المستخدم",
                      ),
                      CustomTextFormField(
                        icon: Icon(Icons.email, color: Colors.blue),
                        controller: email,
                        validation: AppValidators.validateEmail,
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
                        controller: cpassword,
                        validation:validecpassword,
                        icon: Icon(Icons.key, color: Colors.blue),
                        hintText: lang.lang == 'en'
                            ? 'Re Password'
                            : 'تاكيد كلمة المرور',
                        lable: lang.lang == 'en'
                            ? 'Re Password'
                            : 'تاكيد كلمة المرور',
                      ),
                      CustomTextFormField(
                        controller: mobile1,
                        validation: AppValidators.validatePhoneNumber,
                        icon: Icon(
                          Icons.phone_android_outlined,
                          color: Colors.blue,
                        ),
                        hintText: lang.lang == 'en'
                            ? 'Mobile 1'
                            : 'رقم التليفون 1 ',
                        lable: lang.lang == 'en' ? 'Mobile 1' : 'رقم التليفون 1 ',
                      ),
                      CustomTextFormField(
                        validation: AppValidators.validatePhoneNumber,
                        controller: mobile2,
                        icon: Icon(
                          Icons.phone_android_outlined,
                          color: Colors.blue,
                        ),
                        hintText: lang.lang == 'en'
                            ? 'Mobile 2'
                            : 'رقم التليفون 2 ',
                        lable: lang.lang == 'en' ? 'Mobile 2' : 'رقم التليفون 2 ',
                      ),
                      SizedBox(height: 20.h),
                      SizedBox(
                        height: 40.h,
                        width: 140.w,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue, // instead of color
                            foregroundColor: Colors.white, // instead of textColor
                            splashFactory: InkRipple.splashFactory,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(Radius.circular(15.r)),
                              // side: BorderSide(color: Colors.red, width: 2.w),
                            ),
                          ),
                          label: Text(
                            lang.lang == "en" ? 'Sign UP' : 'تسجيل كمسئول شحن ',
                          ),

                          onPressed: () async {
                            FocusScope.of(context).unfocus();
                            formstatesignup.currentState!.save();

                            setState(() {
                              isLoading = true;
                            });

                            try {
                              await _firebaseMessaging.requestPermission();

                              String? api_token = await _firebaseMessaging.getToken();

                              print("FCM TOKEN: $api_token");

                              var location = await _locationTracker.getLocation();

                              var data = {
                                "name": username.text,
                                "email": email.text,
                                "password": password.text,
                                "c_password": cpassword.text,
                                "mobile1": mobile1.text,
                                "mobile2": mobile2.text,
                                "reg_longitude": location.longitude.toString(),
                                "reg_latitude": location.latitude.toString(),
                                "cur_longitude": location.longitude.toString(),
                                "cur_latitude": location.latitude.toString(),
                                "api_token": api_token.toString(),
                              };
                              var url =
                                  "https://www.ordervite.com/api/shippier/register";
                              var response = await http.post(
                                Uri.parse(url),
                                body: data,
                              );
                              var reposnsebody = jsonDecode(response.body);

                              if (formstatesignup.currentState!.validate()) {
                                if (reposnsebody["success"] == true) {
                                  setState(() {
                                    isLoading = false;
                                  });
                                  savePref(
                                    reposnsebody["data"]["name"]["name"],
                                    reposnsebody["data"]["name"]["email"],
                                    reposnsebody["data"]["token"],
                                    reposnsebody["data"]["name"]["id"].toString(),
                                    "shipper",
                                  );

                                  AuthService.setToken(
                                    reposnsebody["data"]["token"],
                                    reposnsebody["data"]["token"],
                                    "shipper",
                                  );
                                  Navigator.of(
                                    context,
                                  ).pushNamed(RoutesManager.shProfile);
                                } else {
                                  setState(() {
                                    isLoading = false;
                                  });
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Invlid data Please Insert Correct Data',
                                        style: TextStyle(
                                          fontSize: 15.sp,
                                          color: Colors.red,
                                        ),
                                      ),
                                    ),
                                  );
                                }
                              }
                            } catch (e) {
                              showDialog<bool>(
                                context: context,
                                builder: (c) => AlertDialog(
                                  title: Text(
                                    lang.lang == "en" ? 'Warning' : 'تحذير',
                                    style: TextStyle(color: Colors.red),
                                  ),
                                  content: Text(
                                    lang.lang == "en"
                                        ? 'Please check your network  '
                                        : '  يرجي التحقق من اتصال الشبكة الخاص بك   ',
                                    style: TextStyle(
                                      fontSize: 15.sp,
                                      color: Colors.red,
                                    ),
                                  ),
                                ),
                              );
                            }
                          },
                        ),
                      ),
                      SizedBox(height: 10.h,),
                       Row(children: [
                         Text( lang.lang == "en"
                             ? "If you already have an account please"
                             : "اذا يوجد لديك حساب يمكنك الستجيل من هنا",style: TextStyle(color: Colors.white,fontSize: 14.sp),),
                         TextButton(
                           onPressed: (){
                             Navigator.pushReplacementNamed(context, RoutesManager.shLogin);
                           },
                           child: Text(lang.lang=='en'?'Sign In':'تسجيل الدخول',style: TextStyle(color: Colors.white,fontSize: 14.sp),),)
                       ],),
                      SizedBox(height: 10.h,),
                      // TextButton(onPressed: (){
                      //   Navigator.pushNamed(context, RoutesManager.registerWithPhone,arguments: roles);
                      // }, child: Text(lang.lang=='en'?'Register by Phone Number':'سجل برقم الهاتف',style: TextStyle(color: Colors.white ),))
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
