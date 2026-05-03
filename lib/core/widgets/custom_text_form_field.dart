import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// ignore: must_be_immutable
class CustomTextFormField extends StatelessWidget {
  CustomTextFormField({
    super.key,
    this.secure = false,
    required this.controller,
    required this.icon,
    this.validation,
    required this.hintText,
    required this.lable,
  });
  final TextEditingController controller;
  final String hintText;
  final String lable;
  bool secure;
  final Icon icon;
  String? Function(String?)? validation;
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      validator: validation,
      obscureText: secure,

      style: TextStyle(fontSize: 20.sp, color: Colors.black,),
      maxLength: 50,
      cursorColor: Colors.blue,
      onFieldSubmitted: (value) {
        FocusScope.of(context).unfocus();
      },
      decoration: InputDecoration(
                contentPadding: EdgeInsets.only(top: 1.h, bottom: 1.h),
        hintText: hintText,
          hoverColor: Colors.blue,
        fillColor: Colors.white,
        filled: true,
        prefixIcon: IconTheme(
      data: IconThemeData(size: 22.sp),
      child: icon,
    ),
        prefixStyle: TextStyle(fontSize: 50.sp, color: Colors.blue),
        labelText: lable,
        labelStyle: TextStyle(
          fontSize: 17.sp,
          color: Colors.black,
          fontWeight: FontWeight.bold,
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(20.r)),
        errorBorder:  OutlineInputBorder(borderRadius: BorderRadius.circular(20.r),borderSide: BorderSide(color: Colors.red)),
        focusedBorder: OutlineInputBorder(borderRadius:BorderRadius.circular(20.r),borderSide: BorderSide(color: Colors.blue) )
      ),
    );
  }
}