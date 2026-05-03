import 'dart:convert';
import 'dart:io';
import 'package:flutter_maps/core/constant_manager.dart';
import 'package:path/path.dart';
import 'package:http/http.dart' as http;

class Api {
  static final Api _api = Api._internal();

  factory Api() => _api;

  Api._internal();

  String? token;
  String baseUrl = 'www.ordervite.com';
  String path = '/api';


  Future<http.Response> httpGet(String endPath, {Map<String, String>? query}) async {
    Uri uri = Uri.http(baseUrl, '$path/$endPath', query);
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
      final url = Uri.https(baseUrl, '$path/$endpoint');

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
    Uri uri = Uri.http(baseUrl, '$path/$endPath');
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
    var uri = Uri.parse("http://${baseUrl}${path}/$endPath");
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