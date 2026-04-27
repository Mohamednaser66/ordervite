import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_maps/Core/routes_manager.dart';
import 'package:flutter_maps/authpages.dart';
import 'package:flutter_maps/classes.dart';
import 'package:flutter_maps/services/auth.dart';
import 'package:flutter_maps/shipper/home.dart';
import 'package:flutter_maps/supplier/home_page/home_page.dart';
import 'package:http/http.dart' as http;
import 'package:rate_my_app/rate_my_app.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

const _apiBase = 'https://www.ordervite.com/api';

class LandingPage extends StatefulWidget {
  const LandingPage({Key? key}) : super(key: key);

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  bool _loading = true;
  String _language = 'ar';

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    await _loadLanguage();

    final tokenInfo = await AuthService.getToken();
    if (tokenInfo == null) {
      _pushReplacement(const AuthPages());
      return;
    }

    final type = tokenInfo['type'] as String?;

    if (type == 'supplier') {
      await _handleSupplier();
      _pushReplacement(MyHomePage(title: 'OrderVite'));
    } else if (type == 'shipper') {
      await _handleShipper();
      _pushReplacement(SHHomePage());
    } else {
      _pushReplacement(MyHomePage(title: 'OrderVite'));
    }
  }

  Future<void> _loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final language = prefs.getString('lang') ?? 'ar';
    if (!mounted) return;
    setState(() {
      _language = language;
      _loading = false;
    });
  }

  void _pushReplacement(Widget page) {
    if (!mounted) return;

    Future.microtask(() {
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => page),
          (route) => false,
        );
      }
    });
  }

  Future<void> _handleSupplier() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final id = prefs.getString('id');
    if (token == null || id == null) return;

    final uri = Uri.parse('$_apiBase/supplier/current_order/cancel/$id');
    final response = await _getJson(uri, token);
    if (response == null) return;

    final data = response['data'];
    if (data == null) return;

    final orderState = data['order_state']?.toString();
    final orderCancel = data['order_cancel'];
    if (orderState != null &&
        orderState != 'order delivered' &&
        orderCancel == null) {
      final orderDist = OrderDist(
        data['dist_latitude']?.toString() ?? '',
        data['so_latitude']?.toString() ?? '',
        data['dist_longitude']?.toString() ?? '',
        data['so_longitude']?.toString() ?? '',
        true,
        data['id']?.toString() ?? '',
        data['cost']?.toString() ?? '',
        data['price']?.toString() ?? '',
        data['pricecheck']?.toString() ?? '',
        orderState,
        data['shippier_id']?.toString() ?? '',
      );

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        Navigator.of(
          context,
        ).pushNamed(RoutesManager.orderPage, arguments: orderDist);
      });
    }
  }

  Future<void> _handleShipper() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final id = prefs.getString('id');
    if (token == null || id == null) return;

    await _checkShipperVerified(token, id);
    await _checkShipperCurrentOrder(token, id);
  }

  Future<void> _checkShipperVerified(String token, String id) async {
    final uri = Uri.parse('$_apiBase/shippier/show/$id');
    final response = await _getJson(uri, token);
    if (response == null) return;

    final data = response['data'];
    final verified = data?['name']?['verified']?.toString();
    if (verified == '0' || verified == '2') {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        Navigator.pushNamed(context, RoutesManager.shProfile);
      });
    }
  }

  Future<void> _checkShipperCurrentOrder(String token, String id) async {
    final uri = Uri.parse('$_apiBase/shippier/current_order/cancel/$id');
    final response = await _getJson(uri, token);
    if (response == null) return;

    final data = response['data'];
    final orderState = data?['order_state']?.toString();
    final orderCancel = data?['order_cancel'];
    if (orderState != null &&
        orderState != 'order delivered' &&
        orderCancel == null) {
      final orderData = OrderData(
        data['dist_latitude']?.toString() ?? '',
        data['so_latitude']?.toString() ?? '',
        data['dist_longitude']?.toString() ?? '',
        data['so_longitude']?.toString() ?? '',
        data['id']?.toString() ?? '',
        true,
        data['cost']?.toString() ?? '',
        data['price']?.toString() ?? '',
        data['pricecheck']?.toString() ?? '',
        orderState,
        data['supplier_id']?.toString() ?? '',
      );

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        Navigator.of(
          context,
        ).pushNamed(RoutesManager.shOrder, arguments: orderData);
      });
    }
  }

  Future<Map<String, dynamic>?> _getJson(Uri uri, String token) async {
    try {
      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      return jsonDecode(response.body) as Map<String, dynamic>?;
    } catch (e) {
      _showNetworkError();
      return null;
    }
  }

  void _showNetworkError() {
    if (!mounted) return;

    showDialog<void>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Warning', style: TextStyle(color: Colors.red)),
        content:  Text(
          'Please check your network',
          style: TextStyle(fontSize: 15.sp, color: Colors.red),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: Color(0xFF0D1B2A),
      body: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _language == 'ar' ? 'جارٍ التحميل... ' : 'Loading... ',
              style: TextStyle(fontSize: 20.sp, color: Colors.white),
            ),
            CircularProgressIndicator(color: Colors.white),
          ],
        ),
      ),
    );
  }
}