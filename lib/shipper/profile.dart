import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_maps/Core/routes_manager.dart';
import 'package:flutter_maps/classes.dart';
import 'package:flutter_maps/lang.dart';
import 'package:flutter_maps/shipper/shipper_drawer.dart';
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
    _username.dispose;
    _email.dispose;
    _password.dispose;
    _c_password.dispose;
    _mobile1.dispose;
    _mobile2.dispose;
    super.dispose();
  }

  final ImagePicker _picker = ImagePicker();

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

              imageProfile(),
              SizedBox(height: 20),
              usernameTextField(),
              SizedBox(height: 20),
              emailTextField(),
              SizedBox(height: 20),

              Text(
                lang.lang == "en"
                    ? "If you do not change password please passord must be empty "
                    : "لو لم تريد تغيير كلمة السر يجب ترك الخانات فارغه ",
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
              SizedBox(height: 20),
              password(),
              SizedBox(height: 20),
              cpassword(),
              SizedBox(height: 20),
              mobile1TextField(),
              SizedBox(height: 20),
              mobile2TextField(),
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
                  imageIdProfile(),
                ],
              ),

              SizedBox(height: 20),
              InkWell(
                onTap: () async {
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
                    request.fields['c_passord'] = _c_password.text;
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
                      "supplier",
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

  Widget imageProfile() {
    return Center(
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
                  builder: ((builder) => bottomSheet()),
                );
              },
              child: Icon(Icons.camera_alt, color: Colors.teal, size: 28.0),
            ),
          ),
        ],
      ),
    );
  }

  Widget imageIdProfile() {
    return Center(
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
                    : NetworkImage('https://www.ordervite.com/$id_image_src'),
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
                  builder: ((builder) => bottomIdSheet()),
                );
              },
              child: Icon(Icons.camera_alt, color: Colors.teal, size: 28.0),
            ),
          ),
        ],
      ),
    );
  }

  Widget bottomSheet() {
    Lang lang = Lang.of(context);
    return Container(
      height: 100.0,
      width: MediaQuery.of(context).size.width,
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Column(
        children: <Widget>[
          Expanded(
            child: Text(
              lang.lang == "en"
                  ? "Choose Profile photo"
                  : "اختار صوره البروفايل ",
              style: TextStyle(fontSize: 20.0),
            ),
          ),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              ElevatedButton.icon(
                icon: Icon(Icons.camera),
                onPressed: () {
                  takePhoto(ImageSource.camera);
                },
                label: Text(lang.lang == "en" ? "Camera" : "كاميرا "),
              ),
              ElevatedButton.icon(
                icon: Icon(Icons.image),
                onPressed: () {
                  takePhoto(ImageSource.gallery);
                },
                label: Text(lang.lang == "en" ? "Gallery" : "معرض الصور "),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget bottomIdSheet() {
    Lang lang = Lang.of(context);
    return Container(
      height: 100.0,
      width: MediaQuery.of(context).size.width,
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Column(
        children: <Widget>[
          Expanded(
            child: Text(
              lang.lang == "en"
                  ? "Choose ID photo"
                  : "أختار صورة البطاقة الشخصية ",
              style: TextStyle(fontSize: 20.0),
            ),
          ),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              ElevatedButton.icon(
                icon: Icon(Icons.camera),
                onPressed: () {
                  takeIdPhoto(ImageSource.camera);
                },
                label: Text(lang.lang == "en" ? "Camera" : "كاميرا "),
              ),
              TextButton.icon(
                icon: Icon(Icons.image),
                label: Text(lang.lang == "en" ? "Gallery" : "معرض الصور "),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.blue,
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  textStyle: TextStyle(fontSize: 16),
                ),
                onPressed: () {
                  takeIdPhoto(ImageSource.gallery);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  void takePhoto(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);

    if (pickedFile != null) {
      setState(() {
        _imageFile = pickedFile;
      });
    } else {
      print("No image selected");
    }
  }

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

  Widget usernameTextField() {
    Lang lang = Lang.of(context);
    return TextFormField(
      controller: _username,
      validator: (value) {
        if (value!.isEmpty) return "Name can't be empty";

        return null;
      },
      decoration: InputDecoration(
        border: OutlineInputBorder(borderSide: BorderSide(color: Colors.black)),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.orange, width: 2),
        ),
        prefixIcon: Icon(Icons.person, color: Colors.green),
        labelText: lang.lang == "en" ? " Username" : "اسم المستخدم ",
        helperText: "Username can't be empty",
        hintText: lang.lang == "en" ? " Username" : "ادخل اسم المستخدم ",
      ),
    );
  }

  Widget emailTextField() {
    Lang lang = Lang.of(context);
    return TextFormField(
      controller: _email,
      keyboardType: TextInputType.emailAddress,
      validator: (value) {
        if (value!.isEmpty) return "Email can't be empty";
        String pattern =
            r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
        RegExp regex = new RegExp(pattern);
        if (!regex.hasMatch(value)) {
          return 'Invalid email address';
        }

        return null;
      },
      decoration: InputDecoration(
        border: OutlineInputBorder(borderSide: BorderSide(color: Colors.teal)),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.orange, width: 2),
        ),
        prefixIcon: Icon(Icons.email, color: Colors.green),
        labelText: lang.lang == "en"
            ? " Email Address"
            : "  عنوان  البريد الالكتروني ",
        helperText: "Email can't be empty",
        hintText: lang.lang == "en"
            ? "Enter Email Address"
            : " أدخل عنوان البريد الالكتروني  ",
      ),
    );
  }

  Widget password() {
    Lang lang = Lang.of(context);
    return TextFormField(
      controller: _password,
      obscureText: true,
      validator: (value) {
        return null;
      },
      decoration: InputDecoration(
        border: OutlineInputBorder(borderSide: BorderSide(color: Colors.teal)),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.orange, width: 2),
        ),
        prefixIcon: Icon(Icons.vpn_key, color: Colors.green),
        labelText: lang.lang == "en" ? " password" : " كلمة السر ",
        helperText: " Password",
        hintText: lang.lang == "en" ? "Enter password" : " أدخل كلمة السر ",
      ),
    );
  }

  Widget cpassword() {
    Lang lang = Lang.of(context);
    return TextFormField(
      controller: _c_password,
      obscureText: true,
      validator: (value) {
        if (value != _password.text) return 'Password does not match ';

        return null;
      },
      decoration: InputDecoration(
        border: OutlineInputBorder(borderSide: BorderSide(color: Colors.teal)),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.orange, width: 2),
        ),
        prefixIcon: Icon(Icons.vpn_key, color: Colors.green),
        labelText: lang.lang == "en" ? "Confirm password" : "تاكيد كلمة السر",
        helperText: " Confirm password",
        hintText: lang.lang == "en" ? "Confirm password" : "تاكيد كلمة السر",
      ),
    );
  }

  Widget mobile1TextField() {
    Lang lang = Lang.of(context);
    return TextFormField(
      controller: _mobile1,
      validator: (value) {
        if (value!.isEmpty) return "Mobile1 can't be empty";

        return null;
      },
      decoration: InputDecoration(
        border: OutlineInputBorder(borderSide: BorderSide(color: Colors.teal)),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.orange, width: 2),
        ),
        prefixIcon: Icon(Icons.mobile_friendly, color: Colors.green),
        labelText: lang.lang == "en" ? " Mobile1" : " رقم التليفون 1",
        helperText: "Mobile1 can't be empty",
        hintText: lang.lang == "en" ? "Enter Mobile1" : " ادخل رقم التليفون 1",
      ),
    );
  }

  Widget mobile2TextField() {
    Lang lang = Lang.of(context);
    return TextFormField(
      controller: _mobile2,
      validator: (value) {
        if (value!.isEmpty) return "Mobile2 can't be empty";

        return null;
      },
      decoration: InputDecoration(
        border: OutlineInputBorder(borderSide: BorderSide(color: Colors.teal)),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.orange, width: 2),
        ),
        prefixIcon: Icon(Icons.mobile_friendly, color: Colors.green),
        labelText: lang.lang == "en" ? " Mobile2" : " رقم التليفون 2",
        helperText: "Mobile1 can't be empty",
        hintText: lang.lang == "en" ? "Enter Mobile 2" : "ادخل رقم التليفون 2",
      ),
    );
  }
}
