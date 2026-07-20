import 'dart:convert';
import 'dart:io';
import 'package:flutter_maps/core/constant_manager.dart';
import 'package:flutter_maps/shipper/models/ShipperOrdersList.dart';
import 'package:path/path.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../supplier/models/SuOrdersList.dart';

class Api {
  static final Api _api = Api._internal();

  factory Api() => _api;

  Api._internal();

  String? token;

  Future<SuOrdersList?> fetchUserOrderList(String supplierId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null || token.isEmpty) return null;

    try {
      final response = await http.get(
        Uri.parse(
          'https://www.ordervite.com/api/supplier/$supplierId/orders',
        ),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return SuOrdersList.fromJson(jsonDecode(response.body));
      } else {
        print(response.body);
      }
    } catch (e) {
      print('Error fetching user order list: $e');
    }

    return null;
  }
  Future<ShipperOrdersList?> fetchShipperOrderList(String shipperId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final url = 'https://www.ordervite.com/api/shippier/$shipperId/orders';
    print(url);
    if (token == null || token.isEmpty) return null;

    try {
      print(url);
      print("ID = $shipperId");
      print("Token = $token");
      print({
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      });
      final response = await http.get(
        Uri.parse(
            "https://www.ordervite.com/api/shippier/$shipperId/orders",
        ),

        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print("Status Code = ${response.statusCode}");
      print("Body = ${response.body}");

      if (response.statusCode == 200) {
        return ShipperOrdersList.fromJson(jsonDecode(response.body));
      } else {
        print(response.body);
      }
    } catch (e) {
      print('Error fetching user order list: $e');
    }

    return null;
  }
  Future<http.Response> httpGet(String endPath, {Map<String, String>? query}) async {
    Uri uri = Uri.http(ConstantManager.baseUrl, endPath, query);
    return await http.get(uri, headers: {
      'Authorization': 'Bearer ${token ?? ''}',
      'Accept': 'application/json',
    });
  }
  Future<bool> deleteSupplier(String token) {
    return delete(
      token: token,
      endpoint: ConstantManager.deleteSupplierEndpoint,
    );
  }

  Future<bool> deleteShipper(String token) {
    return delete(
      token: token,
      endpoint: ConstantManager.deleteShipperEndpoint,
    );
  }
  Future<bool> delete({
    required String token,
    required String endpoint,
  }) async {
    try {
      final url = Uri.https(ConstantManager.baseUrl, endpoint);

      print("DELETE URL: $url");

      final response = await http.delete(
        url,
        headers: {
          "Authorization": "Bearer $token",
          "Accept": "application/json",
        },
      );

      print("STATUS: ${response.statusCode}");
      print("BODY: ${response.body}");

      final data = jsonDecode(response.body);

      return data['success'] == true;
    } catch (e) {
      print("Error: $e");
      return false;
    }
  }

  Future<http.Response> httpPost(String endPath, Object body) async {
    Uri uri = Uri.http(ConstantManager.baseUrl, endPath);
    return await http.post(uri, body: body, headers: {
      'Authorization': 'Bearer ${token ?? ''}',
      'Accept': 'application/json',
    });
  }

  Future<http.Response> httpPostWithFile(String endPath, {required File file}) async {
    Map<String, String> headers = {
      'Authorization': 'Bearer ${token ?? ''}',
      'Accept': 'application/json',
    };
    var uri = Uri.parse("http://${ConstantManager.baseUrl}$endPath");
    var length = await file.length();
    var request = http.MultipartRequest('POST', uri)
      ..headers.addAll(headers)
      ..files.add(
        http.MultipartFile('file', file.openRead(), length,
            filename: basename(file.path)),
      );
    return await http.Response.fromStream(await request.send());
  }
}