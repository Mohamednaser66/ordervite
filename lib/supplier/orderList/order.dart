// import 'dart:async';
// import 'dart:convert';
//
// import 'package:http/http.dart' as http;
// import 'package:flutter/foundation.dart';
// import 'package:flutter_maps/lang.dart';
// import 'package:flutter/material.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:flutter_maps/supplier/orderList/orders.dart';
//
// String GoogleApiKEY = "AIzaSyDl8LFLQn24CbaZyQ0F4wnzoF9NY3_gMWY";
//
// class SuListOrder extends StatefulWidget {
//   const SuListOrder({Key? key}) : super(key: key);
//
//   final String title = "OrderVite";
//
//   @override
//   _SuListOrderState createState() => _SuListOrderState();
// }
//
// enum BestSize { small, medium, large }
//
// enum BestPrice { transfer, cash }
//
// class _SuListOrderState extends State<SuListOrder> {
//   CameraPosition _initialCamera = const CameraPosition(
//     target: LatLng(30.059445, 31.1933067),
//     zoom: 14.0000,
//   );
//
//   final Completer<GoogleMapController> _mapController = Completer();
//   final Set<Marker> _markers = {};
//   final Set<Polyline> _polyline = {};
//   final GlobalKey<ScaffoldState> _scaffoldkey = GlobalKey<ScaffoldState>();
//
//   LatLng sourceLatLong = const LatLng(30.059445, 31.1933067);
//   LatLng destinationLatLong = const LatLng(30.060671, 31.204131);
//
//   String? username;
//   String? email;
//   String? id;
//   String? token;
//   String? logo_src;
//   String? disLat;
//   String? sorLat;
//   String? disLong;
//   String? sorlong;
//   String? order_id;
//   String? order_cost;
//   String? order_size;
//   String? order_pricecheck;
//   String? rating;
//   String? order_supplier_id;
//   String? order_price;
//   String? order_state;
//
//   bool isConfirm = false;
//
//   bool isSignIn = false;
//
//   @override
//   void initState() {
//     super.initState();
//     getPref();
//   }
//
//   Future<void> getPref() async {
//     SharedPreferences preferences = await SharedPreferences.getInstance();
//
//     final suorderData =
//         ModalRoute.of(context)!.settings.arguments as SuOrderData;
//
//     username = preferences.getString("username");
//     email = preferences.getString("email");
//
//     if (username != null && email != null) {
//       setState(() {
//         token = preferences.getString("token");
//         logo_src = preferences.getString("logo_src");
//         id = preferences.getString("id");
//         isSignIn = true;
//       });
//     }
//
//     setState(() {
//       disLat = suorderData.disLat.toString();
//       disLong = suorderData.disLong.toString();
//       sorLat = suorderData.sorLat.toString();
//       sorlong = suorderData.sorlong.toString();
//       order_id = suorderData.order_id.toString();
//       order_cost = suorderData.order_cost;
//       order_price = suorderData.order_price;
//       order_pricecheck = suorderData.order_pricecheck;
//       order_supplier_id = suorderData.order_supplier_id;
//       order_state = suorderData.order_state;
//       rating = suorderData.rating;
//
//       _initialCamera = CameraPosition(
//         target: LatLng(double.parse(sorLat!), double.parse(sorlong!)),
//         zoom: 14.0000,
//       );
//
//       sourceLatLong = LatLng(double.parse(sorLat!), double.parse(sorlong!));
//       destinationLatLong = LatLng(
//         double.parse(disLat!),
//         double.parse(disLong!),
//       );
//     });
//
//     _markers.add(
//       Marker(
//         markerId: const MarkerId("1"),
//         position: sourceLatLong,
//         infoWindow: const InfoWindow(title: "source"),
//       ),
//     );
//
//     _markers.add(
//       Marker(
//         markerId: const MarkerId("2"),
//         position: destinationLatLong,
//         infoWindow: const InfoWindow(title: "destination"),
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     Lang lang = Lang.of(context);
//
//     return Directionality(
//       textDirection: lang.lang == "en" ? TextDirection.ltr : TextDirection.rtl,
//       child: Scaffold(
//         key: _scaffoldkey,
//         appBar: AppBar(
//           title: Text(
//             lang.lang == "en" ? 'Order $order_id' : ' طلب شحن  $order_id',
//           ),
//         ),
//         body: Stack(
//           children: [
//             GoogleMap(
//               mapType: MapType.normal,
//               polylines: _polyline,
//               myLocationEnabled: true,
//               initialCameraPosition: _initialCamera,
//               onMapCreated: (GoogleMapController controller) {
//                 _mapController.complete(controller);
//                 _getPoliLine();
//               },
//               markers: _markers,
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Future<dynamic> _getPoliLine() async {
//     final BASE_URL =
//         "https://maps.googleapis.com/maps/api/directions/json?"
//         "origin=${sourceLatLong.latitude},${sourceLatLong.longitude}"
//         "&destination=${destinationLatLong.latitude},${destinationLatLong.longitude}"
//         "&key=$GoogleApiKEY";
//
//     final response = await http.get(Uri.parse(BASE_URL));
//
//     if (response.statusCode != 200) {
//       throw Exception("Error loading polyline");
//     }
//
//     final decoded = jsonDecode(response.body);
//
//     try {
//       String _distance = decoded["routes"][0]["legs"][0]["distance"]["text"];
//
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           backgroundColor: Colors.redAccent,
//           content: Text(
//             'Distance: $_distance',
//             style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
//           ),
//         ),
//       );
//     } catch (_) {}
//
//     List<Steps> steps = parseSteps(decoded["routes"][0]["legs"][0]["steps"]);
//
//     List<LatLng> _listOfLatLongs = [];
//
//     for (final i in steps) {
//       _listOfLatLongs.add(i.startLocation);
//       _listOfLatLongs.add(i.endLocation);
//     }
//
//     setState(() {
//       _polyline.add(
//         Polyline(
//           polylineId: const PolylineId("2"),
//           visible: true,
//           width: 8,
//           points: _listOfLatLongs,
//           color: Colors.blue,
//         ),
//       );
//     });
//
//     return steps;
//   }
//
//   List<Steps> parseSteps(final responseBody) {
//     return responseBody.map<Steps>((json) => Steps.fromJson(json)).toList();
//   }
// }
//
// class Steps {
//   final LatLng startLocation;
//   final LatLng endLocation;
//
//   Steps({required this.startLocation, required this.endLocation});
//
//   factory Steps.fromJson(Map<String, dynamic> json) {
//     return Steps(
//       startLocation: LatLng(
//         json["start_location"]["lat"],
//         json["start_location"]["lng"],
//       ),
//       endLocation: LatLng(
//         json["end_location"]["lat"],
//         json["end_location"]["lng"],
//       ),
//     );
//   }
// }
//
// class OrderDist2 {
//   final String disLat;
//   final String sorLat;
//   final String disLong;
//   final String sorlong;
//   final String order_id;
//
//   OrderDist2(
//     this.disLat,
//     this.sorLat,
//     this.disLong,
//     this.sorlong,
//     this.order_id,
//   );
// }
