import 'package:flutter/material.dart';
import 'package:flutter_maps/core/colors_manager.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ThemeManager {
  static final ThemeData light = ThemeData(
    iconTheme: IconThemeData(color: ColorsManager.primaryGreen,size: 20.sp),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        textStyle: TextStyle(color: ColorsManager.white,fontSize: 14.sp,fontWeight: FontWeight.w400),
        foregroundColor: Colors.white,
        backgroundColor: ColorsManager.primaryGreen,
      ),

    ),
    appBarTheme: AppBarTheme(
      centerTitle: true,
      iconTheme: IconThemeData(color: Colors.white,size: 20.sp),
      titleTextStyle: TextStyle(
        fontSize: 18.sp,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
      backgroundColor: ColorsManager.primaryGreen,
      foregroundColor: Colors.white,
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        textStyle: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w400,
          fontSize: 16.sp,
          decoration: TextDecoration.underline,
          decorationColor: Colors.white,
        ),
      ),
    ),
    textTheme: TextTheme(
      labelMedium: TextStyle(
        color: Colors.white,
        fontSize: 12.sp,
        fontWeight: FontWeight.w400,
      ),
    ),
  );
}
