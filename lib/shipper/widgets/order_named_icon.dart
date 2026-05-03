import 'package:flutter/material.dart';
import 'package:flutter_maps/Core/routes_manager.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';



class OrdersNamedIcon extends StatelessWidget {
  final IconData iconData;
  final String text;
  final int? notificationCount;
  final bool isVerified;

  const OrdersNamedIcon({
    Key? key,
    required this.text,
    required this.iconData,
    this.notificationCount,
    required this.isVerified,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        if (isVerified) {
          Navigator.pushNamed(context, RoutesManager.shOrders);
        }
      },
      child: Container(
        width: 50.w,
        padding: EdgeInsets.symmetric(horizontal: 4.w),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(iconData,size: 14.sp,),
                Text(text, overflow: TextOverflow.ellipsis,style: TextStyle(fontSize: 6.sp,color: Colors.white),),
              ],
            ),
            Positioned(
              top: 0.h,
              right: 0.w,
              child: (notificationCount != null && notificationCount! > 0)
                  ? Container(
                padding: EdgeInsets.all(4.r),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.red,
                ),
                child: Text(
                  '$notificationCount',
                  style: TextStyle(fontSize: 10.sp, color: Colors.white),
                ),
              )
                  : SizedBox(),
            ),
          ],
        ),
      ),
    );
  }
}