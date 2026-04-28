import 'package:flutter/material.dart';
import 'package:flutter_maps/Core/routes_manager.dart';
import 'package:flutter_maps/lang.dart';
import 'package:flutter_maps/services/auth.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// ignore: must_be_immutable
class SupplierDrawer extends StatefulWidget {
  SupplierDrawer({
    super.key,
    required this.username,
    required this.email,
    required this.lang,
    this.logo_src,
    required this.isSignIn,
  });
  String? logo_src;
  final bool isSignIn;
  final String username;
  final String email;
  Lang lang;

  @override
  State<SupplierDrawer> createState() => _SupplierDrawerState();
}

class _SupplierDrawerState extends State<SupplierDrawer> {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: 200.w,
      child: Container(
        decoration: BoxDecoration(
          color: Color.fromRGBO(7, 15, 33, 0.9),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(18.0.r),
            topRight: Radius.circular(18.0.r),
          ),
        ),
        child: Column(
          children: [
            SizedBox(
            height:   150.h,
              child: DrawerHeader(
                decoration: BoxDecoration(color: Colors.blue),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Center(
                      child: CircleAvatar(
                        backgroundImage: widget.logo_src == null
                            ? AssetImage("assets/app_face.png")
                            : NetworkImage(
                                    'https://www.ordervite.com/${widget.logo_src}',
                                  )
                                  as ImageProvider,
                      ),
                    ),
                    SizedBox(height: 16.h,),
                    if (widget.isSignIn)
                      Expanded(
                        child: Text(
                          widget.username,
                          style: TextStyle(
                            fontSize: 10.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    if (widget.isSignIn)
                      Expanded(
                        child: Text(
                          widget.email,
                          style: TextStyle(
                            fontSize: 10.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.home, color: Colors.blue),
              title: Text(
                widget.lang.lang == "en" ? 'Home ' : 'الرئيسية ',
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              onTap: () =>
                  Navigator.of(context).pushNamedAndRemoveUntil(RoutesManager.suHome,(route) => false,),
            ),
            // ListTile(
            //   leading: Icon(Icons.card_travel, color: Colors.blue),
            //   title: Text(
            //     widget.lang.lang == "en" ? 'Orders ' : ' الطلبات  ',
            //     style: TextStyle(
            //       fontSize: 15.sp,
            //       fontWeight: FontWeight.bold,
            //       color: Colors.white,
            //     ),
            //   ),
            //   onTap: () =>
            //       Navigator.of(context).pushNamed(RoutesManager.suListOrders),
            // ),
            ListTile(
              leading: Icon(Icons.card_travel, color: Colors.blue),
              title: Text(
                widget.lang.lang == "en" ? 'Profile ' : ' الملف الشخصي ',
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              onTap: () =>
                  Navigator.pushNamedAndRemoveUntil(context, RoutesManager.suProfile,(route) => false,),
            ),
            ListTile(
              leading: Icon(Icons.logout, color: Colors.blue),
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
                Navigator.of(context).pushNamedAndRemoveUntil(
                  RoutesManager.authPage,
                  (route) => false,
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.label_important_sharp, color: Colors.blue),
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
                  widget.lang.lang = widget.lang.lang == "ar" ? "en" : "ar";
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}