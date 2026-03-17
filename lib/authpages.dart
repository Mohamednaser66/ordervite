import 'package:flutter/material.dart';
import 'package:flutter_maps/Core/routes_manager.dart';
import 'package:flutter_maps/lang.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthPages extends StatefulWidget {
  const AuthPages({Key? key}) : super(key: key);

  @override
  State<AuthPages> createState() => _AuthPagesState();
}

class _AuthPagesState extends State<AuthPages> {
  bool _languageSelected = false;

  @override
  Widget build(BuildContext context) {
    final lang = Lang.of(context);
    final isEnglish = lang.lang == 'en';
    final textDirection = isEnglish ? TextDirection.ltr : TextDirection.rtl;

    return Directionality(
      textDirection: textDirection,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF152A48),
                Color(0xFF0D1B2A)],
            ),
          ),
          child: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildLogo(),
                    const SizedBox(height: 16),
                    Text(
                      isEnglish ? 'JOIN NOW!' : 'أنضم الآن',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 30,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 24),
                    if (!_languageSelected) _buildLanguageSelection(lang),
                    if (_languageSelected) _buildAuthMenu(isEnglish),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return SizedBox(
      width: 270.w,
      height: 270.h,
      child: Image.asset('assets/auth_logo.png', fit: BoxFit.fill),
    );
  }

  Widget _buildLanguageSelection(Lang lang) {
    return Column(
      children: [
        _buildFullWidthButton(
          icon: Icons.language,
          label: 'اللغة / Language',
          color: Colors.blue,
          onTap: () {},
          horizontalPadding: 80,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildFullWidthButton(
                icon: Icons.flag,
                label: 'عربي',
                color: Colors.blue,
                onTap: () async {
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.setString('lang', 'ar');
                  setState(() {
                    lang.lang = 'ar';
                    _languageSelected = true;
                  });
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildFullWidthButton(
                icon: Icons.flag,
                label: 'English',
                color: Colors.blue,
                onTap: () async {
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.setString('lang', 'en');
                  setState(() {
                    lang.lang = 'en';
                    _languageSelected = true;
                  });
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAuthMenu(bool isEnglish) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildFullWidthButton(
          icon: Icons.home,
          label: isEnglish ? 'Supplier Panel' : 'إدارة حساب المورد',
          color: Colors.blue,
          onTap: () {},
          horizontalPadding: 20,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildFullWidthButton(
                icon: Icons.login,
                label: isEnglish ? 'Sign In' : 'دخول',
                color: Colors.green,
                onTap: () => Navigator.of(context).pushNamed(RoutesManager.login),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildFullWidthButton(
                icon: Icons.app_registration,
                label: isEnglish ? 'Sign Up' : 'تسجيل',
                color: Colors.red,
                onTap: () => Navigator.of(context).pushNamed(RoutesManager.register),
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        _buildFullWidthButton(
          icon: Icons.pedal_bike,
          label:
          isEnglish ? 'Shipper Panel' : 'إدارة حساب مسئول الشحن',
          color: Colors.blue,
          onTap: () {},
          horizontalPadding: 20.w,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildFullWidthButton(
                icon: Icons.login,
                label: isEnglish ? 'Sign In' : 'دخول',
                color: Colors.green,
                onTap: () => Navigator.of(context).pushNamed(RoutesManager.shLogin),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildFullWidthButton(
                icon: Icons.app_registration,
                label: isEnglish ? 'Sign Up' : 'تسجيل',
                color: Colors.red,
                onTap: () => Navigator.of(context).pushNamed(RoutesManager.shRegister),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

      ],
    );
  }

  Widget _buildFullWidthButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
    double horizontalPadding = 20,
  }) {
    return Padding(
      padding: EdgeInsets.only(
        left: horizontalPadding,
        right: horizontalPadding,
        top: 10,
      ),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 55.h,
          width: double.infinity,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              const SizedBox(width: 20),
              Icon(icon, size: 28, color: Colors.white),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}