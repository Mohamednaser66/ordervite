import 'dart:io';
import 'package:path/path.dart';
import 'package:http/http.dart' as http;

class Api {
  static final Api _api = Api._internal();

  factory Api() => _api;

  Api._internal();

  String? token; // ممكن تكون null قبل تسجيل الدخول
  String baseUrl = 'www.ordervite.com';
  String path = '/api';

  Future<http.Response> httpGet(String endPath, {Map<String, String>? query}) async {
    Uri uri = Uri.http(baseUrl, '$path/$endPath', query);
    return await http.get(uri, headers: {
      'Authorization': 'Bearer ${token ?? ''}',
      'Accept': 'application/json',
    });
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