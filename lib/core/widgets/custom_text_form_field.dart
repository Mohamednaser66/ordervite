import 'package:flutter/material.dart';

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

      style: TextStyle(fontSize: 20, color: Colors.black),
      maxLength: 30,
      decoration: InputDecoration(
        contentPadding: EdgeInsets.only(top: 10, bottom: 10),
        hintText: hintText,

        fillColor: Colors.white,
        filled: true,
        prefixIcon: Padding(padding: EdgeInsets.only(left: 5), child: icon),

        prefixStyle: TextStyle(fontSize: 50, color: Colors.blue),
        labelText: lable,
        labelStyle: TextStyle(
          fontSize: 17,
          color: Colors.black,
          fontWeight: FontWeight.bold,
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );
  }
}
