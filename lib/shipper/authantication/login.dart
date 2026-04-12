import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_maps/Core/routes_manager.dart';
import 'package:flutter_maps/core/app_validators.dart';
import 'package:flutter_maps/core/constant_manager.dart';
import 'package:flutter_maps/core/widgets/custom_text_form_field.dart';
import 'package:flutter_maps/lang.dart';
import 'package:flutter_maps/services/auth.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

//import 'package:flutter_maps/supplier/register.dart';

class LogInSH extends StatefulWidget {
  LogInSH({Key? key}) : super(key: key);

  @override
  _LogInSHState createState() => _LogInSHState();
}

showdialog(context) {
  return showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(content: CircularProgressIndicator());
    },
  );
}

class _LogInSHState extends State<LogInSH> {
  late TextEditingController email ;
 late  TextEditingController password ;

  bool isLoading = false;

  GlobalKey<FormState> formstatesignin = new GlobalKey<FormState>();

  final mykey = GlobalKey<ScaffoldState>();



  savePref(
    String username,
    String email,
    String token,
    String id,
    String type,
    String logo_src,
  ) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.setString('username', username);
    preferences.setString('email', email);
    preferences.setString('token', token);
    preferences.setString('id', id);
    preferences.setString('type', type);
    preferences.setString('logo_src', logo_src);
  }

  @override
  void dispose() {
    email.dispose();
    password.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
     email =  TextEditingController();
 password =  TextEditingController();

  }

  String roles = ConstantManager.shipper;

  Widget build(BuildContext context) {
    Lang lang = Lang.of(context);

    return Directionality(
      textDirection: lang.lang == "en" ? TextDirection.ltr : TextDirection.rtl,

      child: Scaffold(
        key: mykey,
        backgroundColor: Colors.transparent,

        appBar: AppBar(
          title: Text(
            lang.lang == "en" ? 'Shipper Login ' : 'دخول مسئول الشحن ',
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
            child: SingleChildScrollView(
              child: Form(
                key: formstatesignin,

                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Padding(padding: EdgeInsets.only(top: 20)),
                      Container(
                        margin: REdgeInsets.symmetric(vertical: 30),
                        width: 70.w,
                        height: 70.h,
                        decoration: BoxDecoration(
                          color: Color.fromRGBO(244, 67, 54, 0.9),
                          borderRadius: BorderRadius.circular(100),
                          //  boxShadow: [BoxShadow(color: Colors.blue,blurRadius:30,spreadRadius: 5) ],
                        ),
                        child: Icon(
                          Icons.person,
                          size: 50,
                          color: Colors.white,
                        ),
                      ),
                      CustomTextFormField(
                        controller: email,
                        validation: AppValidators.validateEmail,
                        icon: Icon(Icons.email, color: Colors.blue),
                        hintText: lang.lang == 'en'
                            ? 'Email Address'
                            : 'عنوان البريد الالكترونى',
                        lable: lang.lang == 'en'
                            ? 'email'
                            : 'البريد الالكترونى ',
                      ),
                      SizedBox(height: 10.h),
                      CustomTextFormField(
                        secure: true,
                        controller: password,
                        validation: AppValidators.validepassword,
                        icon: Icon(Icons.key, color: Colors.blue),
                        hintText: lang.lang == 'en' ? 'Password' : 'كلمة السر',
                        lable: lang.lang == 'en' ? 'Password' : 'كلمة السر',
                      ),

                      ElevatedButton.icon(
                        onPressed: () async {
                          formstatesignin.currentState?.save();
                          setState(() {
                            isLoading = true;
                          });
                          try {
                            var data = {
                              "email": email.text,
                              "password": password.text,
                            };
                            var url =
                                "https://www.ordervite.com/api/shippier/login";
                            var response = await http.post(
                              Uri.parse(url),
                              body: data,
                            );
                            var reposnsebody = jsonDecode(response.body);

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
                                reposnsebody["data"]["logo"].toString(),
                              );
                              AuthService.setToken(
                                reposnsebody["data"]["token"],
                                reposnsebody["data"]["token"],
                                "shipper",
                              );
                              Navigator.of(
                                context,
                              ).pushNamed(RoutesManager.shHome);

                            } else {
                              setState(() {
                                isLoading = false;
                              });
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    lang.lang == 'en'
                                        ? 'these cerditional does not match any account please sign up '
                                        : ' هذه البيانات لا توافق اي بيانات حساب لدينا من فضلك قم بتسجيل بياناتك ',
                                    style: TextStyle(
                                      fontSize: 15,
                                      color: Colors.red,
                                    ),
                                  ),
                                ),
                              );
                            }
                          } catch (e) {
                            print(e.toString());

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
                        icon: Icon(Icons.login),
                        label: Text(lang.lang == "en" ? 'Sign In' : 'دخول'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                      ),
                      SizedBox(height: 10.h),
                      Row(
                        children: [
                          Text(
                            lang.lang == "en"
                                ? "If You do not have an Email Please"
                                : "اذا كنت لاتملك حساب من فضلك",
                            style: Theme.of(context).textTheme.labelMedium,
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pushReplacementNamed(
                                context,
                                RoutesManager.shRegister,
                              );
                            },
                            child: Text(
                              lang.lang == "en" ? "SignUp" : "قم بالاشتراك",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),

                        ],
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
      ),
    );
  }
}
