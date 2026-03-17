import 'package:flutter/material.dart';

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
                 width: 270,
            height: 270,
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
