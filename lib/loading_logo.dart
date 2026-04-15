import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class LoadingLogo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
       debugShowCheckedModeBanner:false, 
      home:Scaffold(
        backgroundColor: Color.fromRGBO(21, 42, 72, 0.9) ,
      body: Center(
        child: Column(
      //    mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            new Stack(
              alignment: Alignment.center,
              children: <Widget>[



                 Container(
                 width: 270.w,
            height: 270.h,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/auth_logo.png'),
                fit: BoxFit.fill,
              ),
            ),
         ),




              ],
            ),
           
        
          ],
        ),
      ),
    ),
    );
  }
}