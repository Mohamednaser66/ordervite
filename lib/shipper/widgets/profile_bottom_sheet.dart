import 'package:flutter/material.dart';
import 'package:flutter_maps/lang.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ProfileBottomSheet extends StatelessWidget {
  const ProfileBottomSheet({super.key, required this.onCameraClick, required this.onGalleryClick, required this.title});
final VoidCallback onCameraClick;
final VoidCallback onGalleryClick;
final String title;
  @override
  Widget build(BuildContext context) {
    Lang lang=Lang.of(context);

    return Container(
      height: 100.h,
      width: MediaQuery
          .of(context)
          .size
          .width,
      margin: EdgeInsets.symmetric(horizontal: 2.h.w, vertical: 2.h),
      child: Column(
        children: <Widget>[
          Expanded(
            child: Text(
            title,
              style: TextStyle(fontSize: 20.sp),
            ),
          ),
          SizedBox(height: 20.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              TextButton.icon(
                icon: Icon(Icons.camera),
                onPressed: onCameraClick,
                label: Text(lang.lang == "en" ? "Camera" : "كاميرا "),
              ),
              TextButton.icon(
                icon: Icon(Icons.image),
                label: Text(lang.lang == "en" ? "Gallery" : "معرض الصور "),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.blue,
                  padding: EdgeInsets.symmetric(horizontal: 1.w, vertical: 8.h),
                  textStyle: TextStyle(fontSize: 16.sp),
                ),
                onPressed:onGalleryClick,
              ),
            ],
          ),
        ],
      ),
    );
  }
}