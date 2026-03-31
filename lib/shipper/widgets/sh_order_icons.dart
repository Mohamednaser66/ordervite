import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ShOrderIcons extends StatelessWidget {
   ShOrderIcons({super.key,required this.isConfirm,required this.isDelviered,required this.isReceived});
  bool isConfirm;
  bool isReceived;
  bool isDelviered;

  @override
  Widget build(BuildContext context) {
    return  Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Expanded(
          child: Container(
            height: 30.0.h,
            width: 20.0.w,

            decoration:  BoxDecoration(
              borderRadius:  BorderRadius.circular(
                50.0.r,
              ),
              color: Color(0xFF18D191),
              image: DecorationImage(
                image: AssetImage(
                  'assets/icons_New order.png',
                ),
                fit: BoxFit.fill,
              ),
            ),
          ),
        ),

        SizedBox(width: 5),
        Expanded(
          child: Container(
            height: 30.0.h,
            width: 20.0.w,

            decoration:  BoxDecoration(
              borderRadius:  BorderRadius.circular(
                50.0,
              ),
              color: isConfirm
                  ? Color(0xFF18D191)
                  : Color(0xFFFC6A7F),
              image: DecorationImage(
                image: AssetImage(
                  'assets/icons_shipper confirm.png',
                ),
                fit: BoxFit.fill,
              ),
            ),
          ),
        ),

        SizedBox(width: 5),
        Expanded(
          child: Container(
            height: 30.0,
            width: 20.0,
            decoration: new BoxDecoration(
              borderRadius: new BorderRadius.circular(
                50.0,
              ),
              color: isReceived
                  ? Color(0xFF18D191)
                  : Color(0xFFFC6A7F),
              image: DecorationImage(
                image: AssetImage(
                  'assets/icons_shipper received.png',
                ),
                fit: BoxFit.fill,
              ),
            ),
          ),
        ),
        SizedBox(width: 5),
        Expanded(
          child: Container(
            height: 30.0,
            width: 20.0,
            decoration: new BoxDecoration(
              borderRadius: new BorderRadius.circular(
                50.0,
              ),
              color: isDelviered
                  ? Color(0xFF18D191)
                  : Color(0xFFFC6A7F),
              image: DecorationImage(
                image: AssetImage(
                  'assets/icons_package delivered.png',
                ),
                fit: BoxFit.fill,
              ),
            ),
          ),
        ),
        SizedBox(width: 5),
        Expanded(
          child: Container(
            height: 30.0,
            width: 20.0,
            decoration:  BoxDecoration(
              borderRadius:  BorderRadius.circular(
                50.0,
              ),
              color: Color(0xFFFC6A7F),
              image: DecorationImage(
                image: AssetImage(
                  'assets/icons_order complete.png',
                ),
                fit: BoxFit.fill,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
