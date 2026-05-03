import 'package:flutter/material.dart';
import 'package:flutter_maps/Core/routes_manager.dart';
import 'package:flutter_maps/core/firebase_service.dart';
import 'package:flutter_maps/core/widgets/custom_text_form_field.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class RegisterWithPhone extends StatefulWidget {
  const RegisterWithPhone({super.key});

  @override
  State<RegisterWithPhone> createState() => _RegisterWithPhoneState();
}

class _RegisterWithPhoneState extends State<RegisterWithPhone> {
  late TextEditingController _controller;
  late String arg;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
@override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
arg  = ModalRoute.of(context)?.settings.arguments as String;
  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _controller.dispose();
  }


  static String? validatePhoneNumber(String? val) {
    if (val == null) {
      return 'this field is required';
    } else if (int.tryParse(val.trim()) == null) {
      return 'enter numbers only';
    } else if (val
        .trim()
        .length != 11) {
      return 'enter value must equal 11 digit';
    } else {
      return null;
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Register by Phone Number'),
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
          key:formKey,
          child: Padding(
            padding:  REdgeInsets.all(16.0.r),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
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
                CustomTextFormField(controller: _controller,
                    icon: Icon(Icons.phone_android_outlined),
                    hintText: 'phone',
                    validation: validatePhoneNumber,
                    lable: 'Phone Number'),
                SizedBox(height: 12.h,),
                SizedBox(width: double.infinity,
                  child: ElevatedButton(onPressed: () {
                    if(!formKey.currentState!.validate())return;
                    FirebaseService.sendCode(_controller.text,arg,context);
                  }, child: Text('Get Code')),
                ),
              ],
            ),
          ),
        ),
      ),


    );
  }
}
