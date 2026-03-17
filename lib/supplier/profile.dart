import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:flutter_maps/classes.dart';
import 'dart:convert';
import 'package:flutter_maps/lang.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class SUProfilePage extends StatefulWidget {
  const SUProfilePage({Key? key}) : super(key: key);

  @override
  _CreatProfileState createState() => _CreatProfileState();
}

class _CreatProfileState extends State<SUProfilePage> {
  bool circular = false;

  XFile? _imageFile;

  final _globalkey = GlobalKey<FormState>();

  late TextEditingController _username ;
  late TextEditingController _email ;
  late TextEditingController _password ;
  late TextEditingController _c_password ;
  late TextEditingController _mobile1 ;
  late TextEditingController _mobile2 ;

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
      request.fields['c_passord'] = _c_password.text;
      request.fields['mobile1'] = _mobile1.text;
      request.fields['mobile2'] = _mobile2.text;

      request.headers.addAll({"Authorization": "Bearer $token"});

      await request.send();

      setState(() => circular = false);

      Message message = Message("profile editing sucsses");

      Navigator.pushNamedAndRemoveUntil(
        context,
        "suhome",
        (route) => false,
        arguments: message,
      );
    } catch (e) {
      setState(() => circular = false);

      showDialog(
        context: context,
        builder: (c) => const AlertDialog(
          title: Text('Warning', style: TextStyle(color: Colors.red)),
          content: Text(
            'Please check your network',
            style: TextStyle(fontSize: 15, color: Colors.red),
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
        key: _scaffoldkey,
        appBar: AppBar(title: Text(username ?? "")),
        body: Form(
          key: _globalkey,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Center(
                child: CircleAvatar(
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
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _username,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Name can't be empty";
                  }
                  return null;
                },
                decoration: const InputDecoration(labelText: "Username"),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _email,
                decoration: const InputDecoration(labelText: "Email"),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _password,
                obscureText: true,
                decoration: const InputDecoration(labelText: "Password"),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _c_password,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: "Confirm Password",
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _mobile1,
                decoration: const InputDecoration(labelText: "Mobile1"),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _mobile2,
                decoration: const InputDecoration(labelText: "Mobile2"),
              ),
              const SizedBox(height: 30),
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
