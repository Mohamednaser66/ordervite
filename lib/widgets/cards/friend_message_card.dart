import 'package:flutter_maps/models/message_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class FriendMessageCard extends StatelessWidget {
  final MessageModal? message;
  final String? imageUrl;
  const FriendMessageCard({Key? key, this.message, this.imageUrl})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    //  print(imageUrl);
    return Padding(
      padding: EdgeInsets.only(bottom: 1.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          CircleAvatar(
            backgroundImage: NetworkImage(
              imageUrl ??
                  'https://s3.amazonaws.com/37assets/svn/765-default-avatar.png',
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Container(
              width: 310.w,
              padding: EdgeInsets.all(21.r),
              decoration: BoxDecoration(
                /*gradient: LinearGradient(colors: [
                    Style.primaryColor,
                    Style.secondaryColor,
                    Style.secondaryColor,
                    Style.secondaryColor,
                  ], begin: Alignment.topCenter, end: Alignment.bottomCenter),*/
                color: Colors.grey,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(28.r),
                  topRight: Radius.circular(28.r),
                  bottomRight: Radius.circular(28.r),
                ),
              ),
              child: Row(
                children: <Widget>[Expanded(child: Text('${message?.body}'))],
              ),
            ),
          ),
        ],
      ),
    );
  }
}