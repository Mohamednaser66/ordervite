import 'dart:convert';
import 'package:flutter_maps/shipper/models/route_model.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

class ShipperOrderRepository {
  Future<RouteModel> getRoute(
      LatLng source,
      LatLng destination,
      String apiKey,
      ) async {
    final url =
        "https://maps.googleapis.com/maps/api/directions/json?"
        "origin=${source.latitude},${source.longitude}"
        "&destination=${destination.latitude},${destination.longitude}"
        "&key=$apiKey";

    final response = await http
        .get(Uri.parse(url))
        .timeout(const Duration(seconds: 10));

    if (response.statusCode != 200) {
      throw Exception("Failed to fetch route");
    }

    final json = jsonDecode(response.body);

    if (json['routes'] == null || (json['routes'] as List).isEmpty) {
      throw Exception("No route found");
    }

    final route = json['routes'][0];

    return RouteModel(
      encodedPoints: route["overview_polyline"]["points"],
      distance: (route["legs"][0]["distance"]["value"] / 1000)
          .toStringAsFixed(2),
    );
  }
}