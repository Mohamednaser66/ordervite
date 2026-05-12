import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_maps/core/firebase_service.dart';
import 'package:flutter_maps/core/images_manager.dart';
import 'package:flutter_maps/core/routes_manager.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SignInWithGoogleWidget extends StatelessWidget {
  const SignInWithGoogleWidget({
    super.key,
    required this.tittle,
  });

  final String tittle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: REdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: Colors.blue,
          width: 1.w,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            ImagesManager.google,
            height: 26.h,
            width: 26.w,
          ),

          SizedBox(width: 10.w),

          Text(tittle,style: TextStyle(color: Colors.blue,fontSize: 14.sp),),
        ],
      ),
    );
  }
}