import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_maps/Core/routes_manager.dart';
import 'package:flutter_maps/classes.dart';
import 'package:flutter_maps/core/app_validators.dart';
import 'package:flutter_maps/core/widgets/custom_text_form_field.dart';
import 'package:flutter_maps/lang.dart';
import 'package:flutter_maps/shipper/shipper_drawer.dart';
import 'package:flutter_maps/shipper/widgets/profile_bottom_sheet.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SHProfilePage extends StatefulWidget {
  SHProfilePage({Key? key}) : super(key: key);

  @override
  _CreatProfileState createState() => _CreatProfileState();
}

class _CreatProfileState extends State<SHProfilePage> {
  bool circular = false;
  XFile? _imageFile, _imageIdFile;
  final _globalkey = GlobalKey<FormState>();
  late TextEditingController _username;
  late TextEditingController _email;
  late TextEditingController _password;
  late TextEditingController _c_password;
  late TextEditingController _mobile1;
  late TextEditingController _mobile2;

  final GlobalKey<ScaffoldState> _scaffoldkey = new GlobalKey<ScaffoldState>();
  String? username;
  String? email;
  late String id;
  late String token;
  String? logo_src;
  String? id_image_src;
  String? verified;

  bool isSignIn = false;

  getPref() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();

    username = preferences.getString("username");

    email = preferences.getString("email");

    if (username != null && email != null) {
      setState(() {
        username = preferences.getString("username");
        email = preferences.getString("email");

        token = preferences.getString("token")!;
        id = preferences.getString("id")!;

        isSignIn = true;
      });
    }

    int myid = int.parse(id.toString(), radix: 10);

    String Url = "https://www.ordervite.com/api/shippier/show/$myid";
    var response = await http.get(
      Uri.parse(Url),

      headers: {'Authorization': 'Bearer  ' + this.token},
    );

    var reposnsebody = jsonDecode(response.body);
    if (reposnsebody["success"] == true) {}

    setState(() {
      _username = new TextEditingController(
        text: reposnsebody["data"]["name"]["name"].toString(),
      );
      _email = new TextEditingController(
        text: reposnsebody["data"]["name"]["email"].toString(),
      );
      _mobile1 = new TextEditingController(
        text: reposnsebody["data"]["name"]["mobile1"].toString(),
      );
      _mobile2 = new TextEditingController(
        text: reposnsebody["data"]["name"]["mobile1"].toString(),
      );
      logo_src = reposnsebody["data"]["logo"].toString();
      id_image_src = reposnsebody["data"]["id_image"].toString();
      verified = reposnsebody["data"]["name"]["verified"].toString();
    });
  }

  savePref(
    String username,
    String email,
    String token,
    String id,
    String type,
    String logo_src,
    String id_image_src,
  ) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.setString('username', username);
    preferences.setString('email', email);
    preferences.setString('token', token);
    preferences.setString('id', id);
    preferences.setString('type', type);
    preferences.setString('logo_src', logo_src);
    preferences.setString('id_image_src', id_image_src);
  }

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

  final ImagePicker _picker = ImagePicker();

  void takeIdPhoto(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);

    if (pickedFile != null) {
      setState(() {
        _imageIdFile = pickedFile;
      });
    } else {
      print("No ID image selected");
    }
  }

  takePhoto(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);

    if (pickedFile != null) {
      setState(() {
        _imageFile = pickedFile;
      });
    } else {
      print("No image selected");
    }
  }

  @override
  Widget build(BuildContext context) {
    Lang lang = Lang.of(context);
    return Directionality(
      textDirection: lang.lang == "en" ? TextDirection.ltr : TextDirection.rtl,

      child: Scaffold(
        key: _scaffoldkey,

        drawer: ShipperDrawer(
          username: username ?? '',
          email: email ?? '',
          lang: lang,
          isSignIn: isSignIn,
        ),

        appBar: AppBar(
          title: Text(
            username ?? '',
            style: TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.bold,
              fontStyle: FontStyle.normal,
              color: Colors.white,
            ),
          ),
        ),

        body: Form(
          key: _globalkey,
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
            children: <Widget>[
              this.verified.toString() == "0"
                  ? Row(
                      children: <Widget>[
                        Expanded(
                          child: Text(
                            lang.lang == "en"
                                ? "Your profile is incomplete, please fill the make sure you enter correct  data profile,please wait  we will  review  your data."
                                : "ملف بياناتك الشخصية غير مكتمل، يُرجى التأكد من إدخال ملف بيانات صحيح، يُرجى الانتظار حتى نراجع بياناتك. ",
                            style: TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                        ),
                      ],
                    )
                  : Row(
                      children: <Widget>[
                        Expanded(
                          child: Text(
                            " ",
                            style: TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                        ),
                      ],
                    ),

              this.verified.toString() == "2"
                  ? Row(
                      children: <Widget>[
                        Expanded(
                          child: Text(
                            lang.lang == "en"
                                ? "Your profile is blocked, please contact us to active your profile ."
                                : "الحساب مغلق من فضلك تواصل معنا لتفعيل حسابك ",
                            style: TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                        ),
                      ],
                    )
                  : Row(
                      children: <Widget>[
                        Expanded(
                          child: Text(
                            "",
                            style: TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
              SizedBox(height: 10),

              Center(
                child: Stack(
                  children: <Widget>[
                    CircleAvatar(
                      radius: 80.0,
                      backgroundImage: logo_src == null
                          ? AssetImage("assets/app_face.png")
                          : NetworkImage('https://www.ordervite.com/$logo_src'),
                    ),
                    Positioned(
                      bottom: 20.0,
                      right: 20.0,
                      child: InkWell(
                        onTap: () {
                          showModalBottomSheet(
                            context: context,
                            builder: ((builder) => ProfileBottomSheet(
                              onCameraClick: () =>
                                  takePhoto(ImageSource.camera),
                              onGalleryClick: () =>
                                  takePhoto(ImageSource.gallery),
                              title: lang.lang == 'en'
                                  ? 'Choose Profile Photo'
                                  : 'اختار الصوره الشخصيه',
                            )),
                          );
                        },
                        child: Icon(
                          Icons.camera_alt,
                          color: Colors.teal,
                          size: 28.0,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              CustomTextFormField(
                validation: AppValidators.validateFullName,
                controller: _username,
                icon: Icon(Icons.person, color: Colors.blue),
                hintText: lang.lang == 'en' ? 'User Name' : 'اسم المستخدم',
                lable: lang.lang == 'en' ? 'User Name' : 'اسم المستخدم',
              ),
              SizedBox(height: 20),
              CustomTextFormField(
                validation: AppValidators.validateEmail,
                controller: _email,
                icon: Icon(Icons.mail, color: Colors.blue),
                hintText: lang.lang == 'en' ? 'Email' : 'البريد الالكتروتى',
                lable: lang.lang == 'en' ? 'Email' : 'البريد الالكتروتى',
              ),
              SizedBox(height: 20),
              Text(
                lang.lang == "en"
                    ? "If you do not change password please password must be empty "
                    : "لو لم تريد تغيير كلمة السر يجب ترك الخانات فارغه ",
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
              SizedBox(height: 20),
              CustomTextFormField(
                validation: AppValidators.validateChangePassword,
                controller: _password,
                icon: Icon(Icons.key, color: Colors.blue),
                hintText: lang.lang == 'en'
                    ? 'Enter Password'
                    : 'ادخل كلمة السر',
                lable: lang.lang == 'en' ? 'Password' : 'كلمة السر',
                secure: true,
              ),
              SizedBox(height: 20),
              CustomTextFormField(
                validation: (val) =>
                    AppValidators.validateConfirmChangePassword(val, _password.text),

                secure: true,
                controller: _c_password,
                icon: Icon(Icons.key, color: Colors.blue),
                hintText: lang.lang == 'en'
                    ? 'Confirm Password'
                    : 'تاكيد كلمة السر',
                lable: lang.lang == 'en'
                    ? 'Confirm Password'
                    : 'تاكيد كلمة السر',
              ),
              SizedBox(height: 20),
              CustomTextFormField(
                validation: AppValidators.validatePhoneNumber,
                controller: _mobile1,
                icon: Icon(Icons.phone, color: Colors.blue),
                hintText: lang.lang == 'en'
                    ? 'Enter Mobile 1'
                    : 'ادخل رقم التليفون 1',
                lable: lang.lang == 'en' ? ' Mobile 1' : ' رقم التليفون 1',
              ),
              SizedBox(height: 20),
              CustomTextFormField(
                validation: AppValidators.validatePhoneNumber,
                controller: _mobile2,
                icon: Icon(Icons.phone, color: Colors.blue),
                hintText: lang.lang == 'en'
                    ? 'Enter Mobile 2'
                    : 'ادخل رقم التليفون 2',
                lable: lang.lang == 'en' ? ' Mobile 2' : ' رقم التليفون 2',
              ),
              SizedBox(height: 20),
              Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      lang.lang == "en"
                          ? "Please Choose  National ID photo"
                          : "أختر صورة البطاقة الشخصية",
                      style: TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                  ),
                  Center(
                    child: Stack(
                      children: <Widget>[
                        Container(
                          height: 100.0,
                          width: 100.0,

                          decoration: new BoxDecoration(
                            borderRadius: new BorderRadius.circular(15.0),

                            image: DecorationImage(
                              image: id_image_src == null
                                  ? AssetImage("assets/app_face.png")
                                  : NetworkImage(
                                      'https://www.ordervite.com/$id_image_src',
                                    ),
                              fit: BoxFit.fill,
                            ),
                          ),
                        ),

                        Positioned(
                          bottom: 20.0,
                          right: 20.0,
                          child: InkWell(
                            onTap: () {
                              showModalBottomSheet(
                                context: context,
                                builder: ((builder) => ProfileBottomSheet(
                                  onCameraClick:()=> takeIdPhoto(ImageSource.camera),
                                  onGalleryClick:()=> takeIdPhoto(
                                    ImageSource.gallery,
                                  ),
                                  title: lang.lang == 'en'
                                      ? 'Choose ID Photo'
                                      : 'اختار صورة البطاقه',
                                )),
                              );
                            },
                            child: Icon(
                              Icons.camera_alt,
                              color: Colors.teal,
                              size: 28.0,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              SizedBox(height: 20),
              InkWell(
                onTap: () async {
                  if(!_globalkey.currentState!.validate())return;
                  setState(() {
                    circular = true;
                  });

                  await SharedPreferences.getInstance();

                  try {
                    String Url =
                        "https://www.ordervite.com/api/shippier/logo_profile/$id";

                    var request = http.MultipartRequest('POST', Uri.parse(Url));
                    if (_imageFile != null) {
                      request.files.add(
                        await http.MultipartFile.fromPath(
                          "logo_src",
                          _imageFile!.path,
                        ),
                      );
                    }
                    if (_imageIdFile != null) {
                      request.files.add(
                        await http.MultipartFile.fromPath(
                          "id_image_src",
                          _imageIdFile!.path,
                        ),
                      );
                    }

                    request.fields['name'] = _username.text;
                    request.fields['email'] = _email.text;
                    request.fields['password'] = _password.text;
                    request.fields['c_password'] = _c_password.text;
                    request.fields['mobile1'] = _mobile1.text;
                    request.fields['mobile2'] = _mobile2.text;
                    request.headers.addAll({
                      "Content-type": "multipart/form-data",
                      "Authorization": "Bearer $token",
                    });
                    request.send();

                    setState(() {
                      circular = false;
                    });
                    getPref();
                    savePref(
                      _username.text,
                      _email.text,
                      this.token,
                      this.id,
                      'shipper',
                      this.logo_src ?? '',
                      this.id_image_src ?? '',
                    );
                    Message message = new Message(
                      lang.lang == "en"
                          ? "profile editing sucsses"
                          : "تم تحديث البيانات بنجاح ",
                    );
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      RoutesManager.shHome,
                      (route) => false,
                      arguments: message,
                    );
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
                          style: TextStyle(fontSize: 15, color: Colors.red),
                        ),
                      ),
                    );
                  }
                },
                child: Center(
                  child: Container(
                    width: 200,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.teal,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: circular
                          ? CircularProgressIndicator()
                          : Text(
                              lang.lang == "en" ? "Submit" : "حفظ",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
