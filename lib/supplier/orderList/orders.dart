// import 'dart:async';
// import 'dart:convert';
//
// import 'package:http/http.dart' as http;
// import 'package:flutter/material.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:flutter_maps/lang.dart';
// import 'package:location/location.dart';
//
// String GoogleApiKEY = "AIzaSyDl8LFLQn24CbaZyQ0F4wnzoF9NY3_gMWY";
//
// class SuListOrders extends StatefulWidget {
//   const SuListOrders({Key? key}) : super(key: key);
//
//   final String title = "OrderVite";
//
//   @override
//   _SuListOrdersState createState() => _SuListOrdersState();
// }
//
// class _SuListOrdersState extends State<SuListOrders> {
//   final Set<Marker> _markers = {};
//   final GlobalKey<ScaffoldState> _scaffoldkey = GlobalKey<ScaffoldState>();
//
//   LatLng sourceLatLong = const LatLng(30.059445, 31.1933067);
//
//   String? username;
//   String? email;
//   String? id;
//   String? token;
//   String? logo_src;
//
//   int order_num = 0;
//   bool isSignIn = false;
//
//   late StreamController<dynamic> _orderController;
//   Timer? timer;
//
//   @override
//   void initState() {
//     super.initState();
//     _orderController = StreamController<dynamic>();
//     getPref();
//     loaddailyOrders();
//   }
//
//   @override
//   void dispose() {
//     timer?.cancel();
//     _orderController.close();
//     super.dispose();
//   }
//
//   Future<void> getPref() async {
//     SharedPreferences preferences = await SharedPreferences.getInstance();
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
//     Location locationTracker = Location();
//     var location = await locationTracker.getLocation();
//
//     setState(() {
//       sourceLatLong = LatLng(
//         location.latitude ?? 30.0,
//         location.longitude ?? 31.0,
//       );
//     });
//
//     _markers.add(
//       Marker(
//         markerId: const MarkerId("1"),
//         position: sourceLatLong,
//         infoWindow: InfoWindow(title: username ?? ""),
//       ),
//     );
//   }
//
//   Future<dynamic> getdailyOrders() async {
//     SharedPreferences preferences = await SharedPreferences.getInstance();
//
//     token = preferences.getString("token");
//
//     try {
//       if (id != null) {
//         int supplierId = int.parse(id!);
//
//         String Url =
//             "https://www.ordervite.com/api/supplier/$supplierId/orders";
//
//         var response = await http.get(
//           Uri.parse(Url),
//           headers: {
//             'Content-Type': 'application/json',
//             'Accept': 'application/json',
//             'Authorization': 'Bearer $token',
//           },
//         );
//
//         var reposnsebody = jsonDecode(response.body);
//
//         if (reposnsebody["data"] != null) {
//           if (reposnsebody["data"].length > order_num) {
//             setState(() {
//               order_num = reposnsebody["data"].length;
//             });
//           }
//         }
//
//         return reposnsebody["data"];
//       }
//     } catch (_) {}
//
//     return null;
//   }
//
//   loaddailyOrders() async {
//     getdailyOrders().then((res) async {
//       _orderController.add(res);
//       return res;
//     });
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
//             lang.lang == "en" ? 'Orders' : 'الطلبات ',
//             style: const TextStyle(
//               fontSize: 25,
//               fontWeight: FontWeight.bold,
//               color: Colors.white,
//             ),
//           ),
//         ),
//         body: FutureBuilder(
//           future: getdailyOrders(),
//           builder: (context, snapshot) {
//             if (snapshot.hasData) {
//               return ListView.builder(
//                 itemCount: snapshot.data.length,
//                 itemBuilder: (context, index) {
//                   var item = snapshot.data[index];
//
//                   return ListTile(
//                     leading: const CircleAvatar(
//                       child: Icon(
//                         Icons.card_travel_rounded,
//                         size: 20,
//                         color: Colors.white,
//                       ),
//                     ),
//                     title: Text(
//                       (lang.lang == "en" ? "id : " : "الكود:") +
//                           item["id"].toString(),
//                     ),
//                     subtitle: Text(
//                       (lang.lang == "en" ? "cost " : "التكلفة ") +
//                           item["cost"].toString(),
//                     ),
//                     onTap: () {
//                       SuOrderData suorderData = SuOrderData(
//                         item["dist_latitude"].toString(),
//                         item["so_latitude"].toString(),
//                         item["dist_longitude"].toString(),
//                         item["so_longitude"].toString(),
//                         item["id"].toString(),
//                         item["cost"].toString(),
//                         item["price"].toString(),
//                         item["pricecheck"].toString(),
//                         item["order_state"].toString(),
//                         item["supplier_id"].toString(),
//                         item["rating"].toString(),
//                       );
//
//                       Navigator.pushNamed(
//                         context,
//                         "sulistorder",
//                         arguments: suorderData,
//                       );
//                     },
//                   );
//                 },
//               );
//             } else {
//               return const Center(child: CircularProgressIndicator());
//             }
//           },
//         ),
//       ),
//     );
//   }
// }
//
// class SuOrderData {
//   final String disLat;
//   final String sorLat;
//   final String disLong;
//   final String sorlong;
//   final String order_id;
//   final String order_cost;
//   final String order_price;
//   final String order_pricecheck;
//   final String order_state;
//   final String order_supplier_id;
//   final String rating;
//
//   SuOrderData(
//     this.disLat,
//     this.sorLat,
//     this.disLong,
//     this.sorlong,
//     this.order_id,
//     this.order_cost,
//     this.order_price,
//     this.order_pricecheck,
//     this.order_state,
//     this.order_supplier_id,
//     this.rating,
//   );
// }
