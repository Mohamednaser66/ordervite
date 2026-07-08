import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_maps/core/app_validators.dart';
import 'package:flutter_maps/core/colors_manager.dart';
import 'package:flutter_maps/core/firebase_service.dart';
import 'package:flutter_maps/core/routes_manager.dart';
import 'package:flutter_maps/core/widgets/custom_text_form_field.dart';
import 'package:flutter_maps/core/widgets/sign_in_with_google_widget.dart';
import 'package:flutter_maps/services/auth.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_maps/lang.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class LogIn extends StatefulWidget {
  const LogIn({Key? key}) : super(key: key);

  @override
  _LogInState createState() => _LogInState();
}

showdialog(context) {
  return showDialog(
    context: context,
    builder: (context) {
      return  AlertDialog(
        title: Text('Warning', style: TextStyle(color: Colors.red)),
        content: Text(
          'is there some problem with network app please wait few mintute and retry',
          style: TextStyle(fontSize: 15.sp, color: Colors.red),
        ),
      );
    },
  );
}

class _LogInState extends State<LogIn> {
  late TapGestureRecognizer _changesign;

  final TextEditingController email = TextEditingController();
  final TextEditingController password = TextEditingController();

  bool isLoading = false;

  final GlobalKey<FormState> formstatesignin = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> mykey = GlobalKey<ScaffoldState>();

  String? validemail(String? val) {
    if (val == null || val.trim().isEmpty) {
      return 'Email address is Required';
    }

    String pattern =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regex = RegExp(pattern);

    if (!regex.hasMatch(val)) {
      return 'Email address is not valid';
    }

    if (val.length < 6) {
      return 'Email is too short';
    }

    return null;
  }

  String? validepassword(String? val) {
    if (val == null || val.trim().isEmpty) {
      return 'Password is Required';
    }

    if (val.length < 6) {
      return 'Password is too short';
    }

    return null;
  }

  Future<void> savePref(
    String username,
    String email,
    String token,
    String id,
    String type,
    String logo_src,
  ) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.setString('username', username);
    await preferences.setString('email', email);
    await preferences.setString('token', token);
    await preferences.setString('id', id);
    await preferences.setString('type', type);
    await preferences.setString('logo_src', logo_src);
  }
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
        RoutesManager.suHome,
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
    _changesign = TapGestureRecognizer()
      ..onTap = () {
        Navigator.of(context).pushNamed("register");
      };
  }

  @override
  void dispose() {
    _changesign.dispose();
    email.dispose();
    password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    Lang lang = Lang.of(context);

    return Directionality(
      textDirection: lang.lang == "en" ? TextDirection.ltr : TextDirection.rtl,
      child: Scaffold(
        key: mykey,
        backgroundColor: const Color.fromRGBO(21, 42, 72, 0.9),
        appBar: AppBar(
          title: Text(lang.lang == "en" ? 'Client Login' : ' دخول العميل '),
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
                colors: [ColorsManager.darkerGreen, ColorsManager.darkerGreen],
              ),
            ),
            child: Padding(
              padding: EdgeInsets.all(16.0.r),
              child: Form(
                key: formstatesignin,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Padding(padding: EdgeInsets.only(top: 2.h)),
                      Container(
                        margin: REdgeInsets.symmetric(vertical: 30.h),
                        width: 70.w,
                        height: 70.h,
                        decoration: BoxDecoration(
                          color: Color.fromRGBO(244, 67, 54, 0.9),
                          borderRadius: BorderRadius.circular(100.r),
                        ),
                        child: Icon(Icons.person, size: 50.sp, color: Colors.white),
                      ),
                      CustomTextFormField(
                        validation: AppValidators.emailOrPhoneValidator,
                        controller: email,
                        icon: Icon(Icons.email, color: ColorsManager.primaryGreen),
                        hintText: lang.lang == 'en'
                            ? 'Email Address'
                            : 'عنوان البريد الالكترونى',
                        lable: lang.lang == 'en' ? 'email' : 'البريد الالكترونى ',
                      ),
                      SizedBox(height: 12.h),
                      CustomTextFormField(
                        secure: true,
                        validation: validepassword,
                        controller: password,
                        icon: Icon(Icons.key, color: ColorsManager.primaryGreen),
                        hintText: lang.lang == 'en' ? 'Password' : 'كلمة السر',
                        lable: lang.lang == 'en' ? 'Password' : 'كلمة السر',
                      ),
                      SizedBox(
                        height: 40.h,
                        child: ElevatedButton.icon(
                          icon: Icon(Icons.login,size: 22.sp,),
                          label: Text(lang.lang == "en" ? 'Sign In' : ' دخول '),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: ColorsManager.primaryGreen,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15.r),
                            ),
                          ),
                          onPressed: () async {
                            if (!formstatesignin.currentState!.validate()) return;
                            setState(() => isLoading = true);
                            try {
                              var data = {
                                "email": email.text,
                                "password": password.text,
                              };
                              var url =
                                  "https://www.ordervite.com/api/supplier/login";

                              var response = await http.post(
                                Uri.parse(url),
                                body: data,
                              );

                              var reposnsebody = jsonDecode(response.body);

                              if (reposnsebody["success"] == true) {
                                setState(() => isLoading = false);

                                await savePref(
                                  reposnsebody["data"]["name"]["name"],
                                  reposnsebody["data"]["name"]["email"],
                                  reposnsebody["data"]["token"],
                                  reposnsebody["data"]["name"]["id"].toString(),
                                  "supplier",
                                  reposnsebody["data"]["logo"].toString(),
                                );

                                AuthService.setToken(
                                  reposnsebody["data"]["token"],
                                  reposnsebody["data"]["token"],
                                  "supplier",
                                );

                                Navigator.of(
                                  context,
                                ).pushNamed(RoutesManager.suHome);

                              } else {
                                setState(() => isLoading = false);

                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      lang.lang == "en"
                                          ? 'these cerditional does not match any account please sign up '
                                          : ' هذه البيانات لا توافق اي بيانات حساب لدينا من فضلك قم بتسجيل بياناتك ',
                                    ),
                                  ),
                                );
                              }
                            } catch (e) {
                              setState(() => isLoading = false);

                              showDialog(
                                context: context,
                                builder: (c) => AlertDialog(
                                  title: Text(
                                    lang.lang == "en" ? 'Warning' : 'تحذير',
                                  ),
                                  content: Text(
                                    lang.lang == "en"
                                        ? 'Please check your network'
                                        : 'يرجي التحقق من اتصال الشبكة الخاص بك',
                                  ),
                                ),
                              );
                            }
                          },
                        ),
                      ),
                      // SizedBox(height: 16.h,),
                      // InkWell(
                      //     onTap: (){
                      //   loginWithGoogle(context);
                      // },
                      //     child: SignInWithGoogleWidget(tittle: lang.lang=='en'?'Login With Google':'سجل بحساب google')),
                      SizedBox(height: 16.h),
                      Row(
                        children: [
                          Text(
                            lang.lang == "en"
                                ? "If You don`t have an Email Please"
                                : "اذا كنت لاتملك حساب من فضلك",
                            style: Theme.of(context).textTheme.labelMedium,
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pushReplacementNamed(
                                context,
                                RoutesManager.register,
                              );
                            },
                            child: Text(
                              lang.lang == "en" ? "SignUp" : "قم بالاشتراك",
                              style: TextStyle(color: ColorsManager.white,fontSize: 12.sp),
                            ),
                          ),
                        ],
                      ),
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
