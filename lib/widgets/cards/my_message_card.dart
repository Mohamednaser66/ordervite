import 'package:flutter_maps/models/message_model.dart';
import 'package:flutter/material.dart';
import '../style.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MyMessageCard extends StatelessWidget {
  final MessageModal? message;
  const MyMessageCard({
    Key? key,
    this.message,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 310.w,
      padding: EdgeInsets.all(21.r),
      margin: EdgeInsets.only(bottom: 1.h),
      decoration: BoxDecoration(
          color: Style.darkColor,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(28.r),
            topRight: Radius.circular(28.r),
            bottomLeft: Radius.circular(28.r),
          )),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Text(
              '${message?.body}',
            ),
          ),
        ],
      ),
    );
  }
}