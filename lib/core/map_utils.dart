import 'package:google_maps_flutter/google_maps_flutter.dart';

/// Decodes an encoded polyline string into a list of [LatLng] points.
/// This is a direct extraction from the original `order.dart` files.
List<LatLng> decodePolyline(String poly) {
  var list = poly.codeUnits;
  var lList = <double>[];
  int index = 0;
  int len = poly.length;
  int c = 0;

  do {
    var shift = 0;
    int result = 0;
    do {
      c = list[index++] - 63;
      result |= (c & 0x1f) << shift;
      shift += 5;
    } while (c >= 32);
    if (result & 1 == 1) {
      result = ~result;
    }
    var result1 = (result >> 1) * 0.00001;
    lList.add(result1);
  } while (index < len);

  for (var i = 2; i < lList.length; i++) {
    lList[i] += lList[i - 2];
  }

  List<LatLng> res = [];
  for (var i = 0; i < lList.length; i += 2) {
    res.add(LatLng(lList[i], lList[i + 1]));
  }
  return res;
}


LatLngBounds getBounds(LatLng start, LatLng end) {
  return LatLngBounds(
    southwest: LatLng(
      start.latitude < end.latitude ? start.latitude : end.latitude,
      start.longitude < end.longitude ? start.longitude : end.longitude,
    ),
    northeast: LatLng(
      start.latitude > end.latitude ? start.latitude : end.latitude,
      start.longitude > end.longitude ? start.longitude : end.longitude,
    ),
  );
}

class Steps {
  final LatLng startLocation;
  final LatLng endLocation;

  Steps({required this.startLocation, required this.endLocation});

  factory Steps.fromJson(Map<String, dynamic> json) {
    return Steps(
      startLocation: LatLng(
        json["start_location"]["lat"],
        json["start_location"]["lng"],
      ),
      endLocation: LatLng(
        json["end_location"]["lat"],
        json["end_location"]["lng"],
      ),
    );
  }
}
List<Steps> parseSteps(List<dynamic> responseBody) {
  return responseBody.map<Steps>((json) => Steps.fromJson(json)).toList();
}
