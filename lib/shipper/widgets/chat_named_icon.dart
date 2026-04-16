import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_maps/Core/routes_manager.dart';
import 'package:flutter_maps/classes.dart';
import 'package:rate_my_app/rate_my_app.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ChatNamedIcon extends StatelessWidget {
  final IconData iconData;
  final String text;
  final int? notificationCount;
  final String? api_token;
  final String? order_id;
  final String? disLat;
  final String? sorLat;
  final String? disLong;
  final String? sorlong;
  final bool isConfirm;
  final bool permission;
  final String? order_cost;
  final String? order_price;
  final String? order_pricecheck;
  final String? order_state;

  final String? order_shippier_id;

  final String? order_supplier_id;

  const ChatNamedIcon({
    Key? key,
    required this.text,
    required this.iconData,
    this.notificationCount,
    this.api_token,
    this.disLat,
    this.sorLat,
    this.disLong,
    this.sorlong,
    required this.isConfirm,
    required this.permission,
    this.order_cost,
    this.order_price,
    this.order_pricecheck,
    this.order_state,
    this.order_supplier_id,
    this.order_shippier_id,
    this.order_id,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        if (!permission) {
          print("permission false ❌");
          return;
        };

        SharedPreferences preferences = await SharedPreferences.getInstance();

        String username = preferences.getString("username") ?? "";
        String id = preferences.getString("id") ?? "";

        if (order_id == null || api_token == null) return;

        Chat chat = Chat(
          order_id!,
          null,
          id,
          null,
          username,
          "supplier",
          api_token!,
          disLat ?? "",
          sorLat ?? "",
          disLong ?? "",
          sorlong ?? "",
          isConfirm,
          order_cost ?? "",
          order_price ?? "",
          order_pricecheck ?? "",
          order_state ?? "",
          order_supplier_id ?? "",
          order_shippier_id ?? "",
        );

        Navigator.pushNamed(
          context,
          RoutesManager.shChatScreen,
          arguments: chat,
        );
      },
      child: Container(
        width: 72.w,
        padding: EdgeInsets.symmetric(horizontal: 8.w),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(iconData),
                Text(text, overflow: TextOverflow.ellipsis),
              ],
            ),

            if (notificationCount != null && notificationCount! > 0)
              Positioned(
                top: 0.h,
                right: 0.w,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.red,
                  ),
                  alignment: Alignment.center,
                  child: Text('${notificationCount ?? 0}'),
                ),
              ),
          ],
        ),
      ),
    );
  }
}