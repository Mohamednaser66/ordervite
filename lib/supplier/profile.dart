import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_maps/Core/routes_manager.dart';
import 'package:flutter_maps/classes.dart';
import 'package:flutter_maps/core/app_validators.dart';
import 'package:flutter_maps/core/widgets/custom_text_form_field.dart';
import 'package:flutter_maps/lang.dart';
import 'package:flutter_maps/shipper/widgets/profile_bottom_sheet.dart';
import 'package:flutter_maps/supplier/home_page/widgets/home_drawer.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SUProfilePage extends StatefulWidget {
  const SUProfilePage({Key? key}) : super(key: key);

  @override
  _CreatProfileState createState() => _CreatProfileState();
}

class _CreatProfileState extends State<SUProfilePage> {
  bool circular = false;

  XFile? _imageFile;

  final _globalkey = GlobalKey<FormState>();

  late TextEditingController _username;

  late TextEditingController _email;

  late TextEditingController _password;

  late TextEditingController _c_password;

  late TextEditingController _mobile1;

  late TextEditingController _mobile2;

  final GlobalKey<ScaffoldState> _scaffoldkey = GlobalKey<ScaffoldState>();

  String? username;
  String? email;
  String? id;
  String? token;
  String? logo_src;

  bool isSignIn = false;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    getPref();
    _username = TextEditingController();
    _email = TextEditingController();
    _password = TextEditingController();
    _c_password = TextEditingController();
    _mobile1 = TextEditingController();
    _mobile2 = TextEditingController();
  }

  @override
  void dispose() {
    _username.dispose();
    _email.dispose();
    _password.dispose();
    _c_password.dispose();
    _mobile1.dispose();
    _mobile2.dispose();
    super.dispose();
  }

  Future<void> getPref() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();

    username = preferences.getString("username");
    email = preferences.getString("email");
    token = preferences.getString("token");
    id = preferences.getString("id");

    if (username != null && email != null) {
      setState(() {
        isSignIn = true;
      });
    }

    if (id == null || token == null) return;

    int myid = int.parse(id!);

    String url = "https://www.ordervite.com/api/supplier/show/$myid";

    var response = await http.get(
      Uri.parse(url),
      headers: {"Authorization": "Bearer $token"},
    );

    var reposnsebody = jsonDecode(response.body);

    if (reposnsebody["success"] == true) {
      setState(() {
        _username.text = reposnsebody["data"]["name"]["name"].toString();
        _email.text = reposnsebody["data"]["name"]["email"].toString();
        _mobile1.text = reposnsebody["data"]["name"]["mobile1"].toString();
        _mobile2.text = reposnsebody["data"]["name"]["mobile2"].toString();
        logo_src = reposnsebody["data"]["logo"].toString();
      });
    }
  }

  Future<void> takePhoto(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);
    setState(() {
      _imageFile = pickedFile;
    });
  }

  Future<void> updateProfile() async {
    if (id == null || token == null) return;

    setState(() => circular = true);

    try {
      String url = "https://www.ordervite.com/api/supplier/logo_profile/$id";

      var request = http.MultipartRequest('POST', Uri.parse(url));

      if (_imageFile != null) {
        request.files.add(
          await http.MultipartFile.fromPath("logo_src", _imageFile!.path),
        );
      }

      request.fields['name'] = _username.text;
      request.fields['email'] = _email.text;
      request.fields['password'] = _password.text;
      request.fields['c_password'] = _c_password.text;
      request.fields['mobile1'] = _mobile1.text;
      request.fields['mobile2'] = _mobile2.text;

      request.headers.addAll({"Authorization": "Bearer $token"});

      await request.send();

      setState(() => circular = false);

      Message message = Message("profile editing sucsses");

      Navigator.pushNamedAndRemoveUntil(
        context,
        RoutesManager.suHome,
            (route) => false,
        arguments: message,
      );
    } catch (e) {
      setState(() => circular = false);

      showDialog(
        context: context,
        builder: (c) =>
         AlertDialog(
          title: Text('Warning', style: TextStyle(color: Colors.red)),
          content: Text(
            'Please check your network',
            style: TextStyle(fontSize: 15.sp, color: Colors.red),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    Lang lang = Lang.of(context);

    return Directionality(
      textDirection: lang.lang == "en" ? TextDirection.ltr : TextDirection.rtl,
      child: Scaffold(
        drawer: SupplierDrawer(username: username??'', email: email??'', lang: lang, isSignIn: isSignIn),
        key: _scaffoldkey,
        appBar: AppBar(title: Text(username ?? "")),
        body: Form(
          key: _globalkey,
          child: ListView(
            padding: REdgeInsets.all(20.r),
            children: [
              Center(
                child: Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    CircleAvatar(
                      radius: 80,
                      backgroundImage: _imageFile != null
                          ? FileImage(File(_imageFile!.path))
                          : (logo_src == null
                          ? const AssetImage("assets/app_face.png")
                      as ImageProvider
                          : NetworkImage(
                        'https://www.ordervite.com/$logo_src',
                      )),
                    ),
                    IconButton(
                      onPressed: () {
                        showModalBottomSheet(
                            context: context, builder:(_)=> ProfileBottomSheet(
                          onCameraClick: () => takePhoto(ImageSource.camera),
                          onGalleryClick: () => takePhoto(ImageSource.gallery),
                          title: lang.lang == 'en'
                              ? 'Choose Profile Photo'
                              : 'اختار الصوره الشخصيه',
                        )
                        );
                      },
                      icon: Icon(Icons.camera_alt, color: Colors.blue,),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20.h),
              CustomTextFormField(
                validation: AppValidators.validateUsername,
                controller: _username,
                icon: Icon(Icons.person_rounded),
                hintText: lang.lang == 'en' ? 'User Name' : 'اسم المستخدم',
                lable: lang.lang == 'en' ? 'User Name' : 'اسم المستخدم',
              ),
              SizedBox(height: 20.h),
              CustomTextFormField(
                validation: AppValidators.validateEmail,
                controller: _email,
                icon: Icon(Icons.email, color: Colors.blue,),
                hintText: lang.lang == 'en'
                    ? 'Enter Email'
                    : 'ادخل البريد الالكترونى',
                lable: lang.lang == 'en'
                    ? 'Enter Email'
                    : 'ادخل البريد الالكترونى',
              ),
              SizedBox(height: 20.h),
              CustomTextFormField(
                controller: _password,
                icon: Icon(Icons.key, color: Colors.blue,),
                validation: AppValidators.validateChangePassword,
                secure: true,
                hintText: lang.lang == 'en' ? 'Password' : 'كلمة المرور',
                lable: lang.lang == 'en' ? 'Password' : 'كلمة المرور',
              ),
              SizedBox(height: 20.h),
              CustomTextFormField(
                controller: _c_password,
                icon: Icon(Icons.key, color: Colors.blue,),
                hintText: lang.lang == 'en'
                    ? 'Confirm Password'
                    : 'تاكيد كلمة المرور',
                lable: lang.lang == 'en'
                    ? 'Confirm Password'
                    : 'تاكيد كلمة المرور',
                secure: true,
                validation: (val) =>
                    AppValidators.validateConfirmChangePassword(
                      val,
                      _password.text,
                    ),
              ),
              SizedBox(height: 20.h),
              CustomTextFormField(
                controller: _mobile1,
                icon: Icon(Icons.phone, color: Colors.blue,),
                validation: AppValidators.validatePhoneNumber,
                hintText: lang.lang == 'en' ? 'Mobile 1' : 'رقم الهاتف 1',
                lable: lang.lang == 'en' ? 'Mobile 1' : 'رقم الهاتف 1',
              ),
              SizedBox(height: 20.h),
              CustomTextFormField(
                controller: _mobile2,
                icon: Icon(Icons.phone, color: Colors.blue,),
                validation: AppValidators.validatePhoneNumber,
                hintText: lang.lang == 'en' ? 'Mobile 2' : 'رقم الهاتف 2',
                lable: lang.lang == 'en' ? 'Mobile 2' : 'رقم الهاتف 2',
              ),
              SizedBox(height: 30.h),
              ElevatedButton(
                onPressed: updateProfile,
                child: circular
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(lang.lang == "en" ? "Submit" : "حفظ"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
