import 'package:flutter/material.dart';
import 'package:flutter_maps/Core/routes_manager.dart';
import 'package:flutter_maps/core/colors_manager.dart';
import 'package:flutter_maps/lang.dart';
import 'package:flutter_maps/services/auth.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// ignore: must_be_immutable
class ShipperDrawer extends StatefulWidget {
  ShipperDrawer({
    super.key,
    required this.username,
    this.logo_src,
    required this.email,
    required this.lang,
    required this.isSignIn, required this.id,
  });
  final String username;
  String? logo_src;
  final String email;
  final String id;
  final Lang lang;
  final bool isSignIn;

  @override
  State<ShipperDrawer> createState() => _ShipperDrawerState();
}

class _ShipperDrawerState extends State<ShipperDrawer> {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: 220.w,
      child: Container(
        decoration: BoxDecoration(
          color: ColorsManager.darkerGreen,
        ),

        child: ListView(
          children: <Widget>[
            SizedBox(
              height: 150.h,
              child: DrawerHeader(
                decoration: BoxDecoration(color: ColorsManager.primaryGreen),
                padding: EdgeInsets.all(10.r),

                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,

                  children: <Widget>[
                    Center(
                      child: CircleAvatar(
                        backgroundImage:
                            (widget.logo_src == null ||
                                widget.logo_src == "null")
                            ? const AssetImage("assets/app_face.png")
                            : NetworkImage(
                                    'https://www.ordervite.com/${widget.logo_src}',
                                  )
                                  as ImageProvider,
                      ),
                    ),
                    SizedBox(height: 10.h,),

                    widget.isSignIn
                        ? Expanded(
                          child: Text(
                              widget.username,
                              style: TextStyle(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                        )
                        : Text(""),

                    widget.isSignIn
                        ? Expanded(
                          child: Text(
                              widget.email,
                              style: TextStyle(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                        )
                        : Text(""),
                  ],
                ),
              ),
            ),

            ListTile(
              leading: Icon(Icons.home, color: ColorsManager.primaryGreen),

              title: Text(
                widget.lang.lang == "en" ? 'Home ' : 'الرئيسية ',
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),

              onTap: () {
                Navigator.of(context).pushNamedAndRemoveUntil(RoutesManager.shHome,(route) => false,);
              },
            ),
            ListTile(
              leading: Icon(Icons.card_travel, color: ColorsManager.primaryGreen),

              title: Text(
                widget.lang.lang == "en" ? 'Orders ' : ' الطلبات  ',
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),

              onTap: () {
                Navigator.of(context).pushNamedAndRemoveUntil(RoutesManager.shipperOrdersScreen,(route) => false,);
              },
            ),
            ListTile(
              leading: Icon(Icons.card_travel, color: ColorsManager.primaryGreen),
              title: Text(
                widget.lang.lang == "en" ? 'Orders History ' :  "سجل الطلبات" ,
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              onTap: () =>
                  Navigator.of(context).pushNamed(RoutesManager.shipperOrdersScreen,arguments: widget.id),

            ),
            ListTile(
              leading: Icon(Icons.card_travel, color: ColorsManager.primaryGreen),

              title: Text(
                widget.lang.lang == "en" ? 'Profile ' : ' الملف الشخصي ',
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),

              onTap: () {
                Navigator.pushNamedAndRemoveUntil(context, RoutesManager.shProfile,(route) => false,);
              },
            ),

            ListTile(
              leading: Icon(Icons.logout, color: ColorsManager.primaryGreen),

              title: Text(
                widget.lang.lang == "en" ? 'Log out ' : ' تسجيل خروج ',
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),

              onTap: () {
                AuthService.removeToken();
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  RoutesManager.authPage,
                  (route) => false,
                );
              },
            ),

            ListTile(
              leading: Icon(Icons.label_important_sharp, color: ColorsManager.primaryGreen),

              title: Text(
                widget.lang.lang == "en" ? ' عربي' : ' English ',
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),

              onTap: () {
                setState(() {
                  if (widget.lang.lang == "ar") {
                    widget.lang.lang = "en";
                  } else {
                    widget.lang.lang = "ar";
                  }
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}