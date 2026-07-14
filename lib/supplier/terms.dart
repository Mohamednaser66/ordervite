import 'package:flutter/material.dart';
import 'package:flutter_maps/Core/routes_manager.dart';
import 'package:flutter_maps/supplier/home_page/widgets/home_drawer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter/services.dart';
import 'package:flutter_maps/lang.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class Terms extends StatefulWidget {
  const Terms({Key? key}) : super(key: key);

  final String title = "OrderVite";

  @override
  _TermsState createState() => _TermsState();
}

enum BestSize { small, medium, large }

class _TermsState extends State<Terms> {
  final GlobalKey<ScaffoldState> _scaffoldkey = GlobalKey<ScaffoldState>();

  String? username;
  String? email;
  String? id;
  String? token;
  String? logo_src;

  bool isSignIn = false;

  Future<void> getPref() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    username = preferences.getString("username");
    email = preferences.getString("email");

    if (username != null && email != null) {
      if (!mounted) return;
      setState(() {
        token = preferences.getString("token");
        id = preferences.getString("id");
        logo_src = preferences.getString("logo_src");
        isSignIn = true;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    checkTerms();
    getPref();
  }

  checkTerms() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? token = await preferences.getString('terms');
    if (token != null) {
      Navigator.pushReplacementNamed(context, RoutesManager.search);
    }
  }

  @override
  Widget build(BuildContext context) {
    Lang lang = Lang.of(context);

    return Directionality(
      textDirection: lang.lang == "en" ? TextDirection.ltr : TextDirection.rtl,
      child: Scaffold(
        key: _scaffoldkey,
        appBar: AppBar(
          title: Text(
            lang.lang == "en" ? 'Terms and policy ' : ' الشروط والأحكام ',
            style: TextStyle(
              fontSize: 25.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),

        drawer: SupplierDrawer(
          id: id??'',
          username: username ?? '',
          email: email ?? '',
          lang: lang,
          isSignIn: isSignIn,
        ),

        body: SingleChildScrollView(
          padding: EdgeInsets.all(16.r),
          child: Column(
            children: [
              SizedBox(height: 40.h),

              FutureBuilder(
                future: rootBundle.loadString(
                  lang.lang == 'en'
                      ? 'assets/ordervite_terms.md'
                      : 'assets/ordervite_terms_ar.md',
                ),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return MarkdownBody(data: snapshot.data as String);
                  }

                  return const Center(child: CircularProgressIndicator());
                },
              ),

              SizedBox(height: 30.h),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: ElevatedButton(
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.green,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                      ),
                      onPressed: () async {
                        SharedPreferences preferences =
                            await SharedPreferences.getInstance();
                        preferences.setString('terms', 'termsHasShown');
                        Navigator.of(context).pushNamed(RoutesManager.search);
                      },
                      child: Text(
                        lang.lang == "en" ? "Make an Order" : " طلب شحن ",
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),

                  SizedBox(width: 20.w),

                  Expanded(
                    child: ElevatedButton(
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.red,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(
                        lang.lang == "en" ? "Cancel" : "إلغاء",
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
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