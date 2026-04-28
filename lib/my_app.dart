import 'package:flutter/material.dart';
import 'package:flutter_maps/Core/routes_manager.dart';
import 'package:flutter_maps/config/theme.dart';
import 'package:flutter_maps/landing_page.dart';
import 'package:flutter_maps/lang.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:rate_my_app/rate_my_app.dart';

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _languageLoaded = false;
  String _language = 'ar';

  @override
  void initState() {
    super.initState();
    _loadLanguage();
  }

  Future<void> _loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final lang = prefs.getString('lang') ?? 'ar';
    if (!mounted) return;

    setState(() {
      _language = lang;
      _languageLoaded = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_languageLoaded) {
      return const MaterialApp(
        home: Scaffold(body: Center(child: CircularProgressIndicator())),
      );
    }

    return Lang(
      initialLang: _language,
      child: ScreenUtilInit(
        designSize: const Size(360, 690),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: _buildApp,
      ),
    );
  }

  static Widget _buildApp(BuildContext context, Widget? child) {
    return MaterialApp(
      themeMode: ThemeMode.light,
      debugShowCheckedModeBanner: false,
      title: 'Flutter Maps',
      theme: ThemeManager.light,
      initialRoute: RoutesManager.landingPage,
      routes: RoutesManager.router,
    );
  }
}