import 'package:flutter/material.dart';
import 'package:flutter_maps/core/routes_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_maps/classes.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class NamedIcon extends StatelessWidget {
  final IconData iconData;
  final String text;
  final int? notificationCount;
  final String? api_token, order_id, disLat, sorLat, disLong, sorlong;
  final bool? isConfirm, permission;
  final String? order_cost,
      order_price,
      order_pricecheck,
      order_state,
      order_shippier_id,
      order_supplier_id;

   NamedIcon({
    super.key,
    required this.text,
    required this.iconData,
    this.notificationCount,
    this.api_token,
    this.disLat,
    this.sorLat,
    this.disLong,
    this.sorlong,
    this.isConfirm,
    this.permission,
    this.order_cost,
    this.order_price,
    this.order_pricecheck,
    this.order_state,
    this.order_supplier_id,
    this.order_shippier_id,
    this.order_id,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        print('NamedIcon onTap called, order_id: $order_id');
        if (order_id != null && order_id!.isNotEmpty) {
          print('Condition passed, navigating to suChatScreen');
          final SharedPreferences preferences =
              await SharedPreferences.getInstance();

          if (!context.mounted) return;

          final String username = preferences.getString("username") ?? "مستخدم";
          final String id = preferences.getString("id") ?? "";

          final chat = Chat(
            order_id ?? '',
            id,
            null,
            username,
            null,
            "supplier",
            api_token ?? '',
            disLat ?? '',
            sorLat ?? '',
            disLong ?? '',
            sorlong ?? '',
            isConfirm ?? false,
            order_cost ?? '',
            order_price ?? '',
            order_pricecheck ?? '',
            order_state ?? '',
            order_supplier_id ?? '',
            order_shippier_id ?? '',
          );

          Navigator.pushNamed(
            context,
            RoutesManager.suChatScreen,
            arguments: chat,
          );
          print('Navigation to suChatScreen completed');
        } else {
          print('Condition failed, not navigating');
        }
      },
      child: Container(
        width: 72.w,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(iconData,size: 14.sp,),
                Text(
                  text,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 6.sp,color: Colors.white),
                ),
              ],
            ),
            if (notificationCount != null && notificationCount! > 0)
              Positioned(
                top: 4.h,
                right: 4.w,
                child: Container(
                  padding: EdgeInsets.all(4.r),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.red,
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 18,
                    minHeight: 18,
                  ),
                  child: Text(
                    '$notificationCount',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10.sp,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}