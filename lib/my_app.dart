import 'package:flutter/material.dart';
import 'package:flutter_maps/Core/routes_manager.dart';
import 'package:flutter_maps/config/theme.dart';
import 'package:flutter_maps/lang.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: _getLanguage(),
      builder: (context, snapshot) {
        final language = snapshot.data ?? 'ar';

        return Lang(
          initialLang: language,
          child: ScreenUtilInit(
            designSize: const Size(360, 690),
            minTextAdapt: true,
            splitScreenMode: true,
            builder: (context, child) => MaterialApp(
              builder: (context, child) {
                return MediaQuery(
                  data: MediaQuery.of(context).copyWith(
                    textScaler: TextScaler.noScaling,
                  ),
                  child: child!,
                );
              },
              themeMode: ThemeMode.light,
              debugShowCheckedModeBanner: false,
              title: 'Flutter Maps',
              theme: ThemeManager.light,
              initialRoute: RoutesManager.landingPage,
              routes: RoutesManager.router,
            ),
          ),
        );
      },
    );
  }

  static Future<String> _getLanguage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('lang') ?? 'ar';
    } catch (_) {
      return 'ar';
    }
  }
}