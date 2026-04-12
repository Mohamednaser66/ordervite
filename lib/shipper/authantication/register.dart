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
  late TapGestureRecognizer _changesign;

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
    _changesign =  TapGestureRecognizer()
      ..onTap = () {
        Navigator.of(context).pushNamed(RoutesManager.shLogin);
      };
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
              fontSize: 25,
              fontWeight: FontWeight.bold,
              fontStyle: FontStyle.normal,
              color: Colors.white,
            ),
          ),
        ),
        body: Container(
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
                padding: REdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  //   mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    Padding(padding: EdgeInsets.only(top: 20)),
                    Container(
                      margin: REdgeInsets.symmetric(vertical: 30),
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: Icon(Icons.person, size: 50, color: Colors.white),
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
                      validation: AppValidators.validepassword,
                      secure: true,
                      controller: password,
                      hintText: lang.lang == 'en' ? 'Password' : 'كلمة السر',
                      lable: lang.lang == 'en' ? 'Password' : 'كلمة السر',
                    ),
                    CustomTextFormField(
                      secure: true,
                      controller: cpassword,
                      validation:(val) => AppValidators.validecpassword(val, password.text),
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
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue, // instead of color
                        foregroundColor: Colors.white, // instead of textColor
                        splashFactory: InkRipple.splashFactory,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(15)),
                          // side: BorderSide(color: Colors.red, width: 2),
                        ),
                      ),
                      label: Text(
                        lang.lang == "en" ? 'Sign UP' : 'تسجيل كمسئول شحن ',
                      ),

                      onPressed: () async {
                        formstatesignup.currentState!.save();

                        setState(() {
                          isLoading = true;
                        });

                        try {
                          String? api_token;

                          _firebaseMessaging.getToken().then((token) async {
                            setState(() {
                              api_token = token.toString();
                            });
                          });

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
                                      fontSize: 15,
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
                                  fontSize: 15,
                                  color: Colors.red,
                                ),
                              ),
                            ),
                          );
                        }
                      },
                    ),
                    SizedBox(height: 10.h,),
                    Container(
                      margin: EdgeInsets.only(left: 5),
                      child: RichText(
                        text: TextSpan(
                          children: <TextSpan>[
                            TextSpan(
                              text: lang.lang == "en"
                                  ? " If you already have an account please    "
                                  : " اذا يوجد لديك حساب يمكنك الستجيل من هنا ",
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.white,
                              ),
                            ),
                            TextSpan(
                              recognizer: _changesign,
                              text: lang.lang == "en"
                                  ? "Sign in"
                                  : "تسجيل دخول ",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
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
    );
  }
}
