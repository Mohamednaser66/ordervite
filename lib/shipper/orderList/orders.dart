// import 'dart:async';
// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:flutter_maps/lang.dart';
// import 'package:flutter_maps/shipper/shipper_drawer.dart';
// import 'package:flutter_maps/supplier/order.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:http/http.dart' as http;
// import 'package:location/location.dart';
// import 'package:shared_preferences/shared_preferences.dart';
//
// String GoogleApiKEY = "AIzaSyDl8LFLQn24CbaZyQ0F4wnzoF9NY3_gMWY";
//
// const oneSec = const Duration(seconds: 1);
// const interval = const Duration(minutes: 1);
// const iconCancel = Icons.cancel;
// const iconStart = Icons.alarm;
//
// class ShListOrders extends StatefulWidget {
//   ShListOrders({Key? key}) : super(key: key);
//
//   final String title = "OrderVite";
//
//   @override
//   _ShListOrdersState createState() => _ShListOrdersState();
// }
//
// enum BestSize { small, medium, large }
//
// enum BestPrice { transfer, cash }
//
// class _ShListOrdersState extends State<ShListOrders> {
//   final Set<Marker> _markers = Set();
//
//   LatLng sourceLatLong = LatLng(30.059445, 31.1933067);
//   LatLng destinationLatLong = LatLng(30.060671, 31.204131);
//   final GlobalKey<ScaffoldState> _scaffoldkey = new GlobalKey<ScaffoldState>();
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
//   int order_num = 0;
//
//   bool isOrderDate = false;
//   bool isConfirm = false;
//
//   bool isSignIn = false;
//
//   GlobalKey<FormState> formstatesorder = new GlobalKey<FormState>();
//   late StreamController _orderController;
//
//   TextEditingController size = new TextEditingController();
//   TextEditingController price = new TextEditingController();
//   late BuildContext mainContext;
//   dynamic order_id_session;
//   dynamic order_data_session;
//
//   late Map<String, dynamic> formData;
//   Timer? timer;
//   String data = "";
//
//   String? validprice(String? val) {
//     if (val!.trim().isEmpty) {
//       return 'package price  Is Required';
//     }
//
//     return null;
//   }
//
//   getPref() async {
//     SharedPreferences preferences = await SharedPreferences.getInstance();
//
//     order_id_session = await preferences.get("order_id_session");
//     order_data_session = await preferences.get('order_data $order_id_session');
//
//     username = preferences.getString("username");
//     email = preferences.getString("email");
//
//     if (username != null && email != null) {
//       setState(() {
//         username = preferences.getString("username");
//         email = preferences.getString("email");
//
//         token = preferences.getString("token");
//         logo_src = preferences.getString("logo_src");
//         id = preferences.getString("id");
//         //     print(id);
//
//         isSignIn = true;
//       });
//     }
//     Location _locationTracker = Location();
//     var location = await _locationTracker.getLocation();
//
//     setState(() {
//       sourceLatLong = LatLng(location.latitude ?? 0, location.longitude ?? 0);
//     });
//
//     _markers.add(
//       Marker(
//         markerId: MarkerId("1"),
//         position: sourceLatLong,
//         infoWindow: InfoWindow(title: this.username),
//         icon: BitmapDescriptor.defaultMarker,
//         visible: true,
//       ),
//     );
//   }
//
//   changeMainContext(BuildContext context) {
//     mainContext = context;
//   }
//
//   Future<List<Map<String, dynamic>>> getdailyOrders() async {
//     SharedPreferences preferences = await SharedPreferences.getInstance();
//     token = preferences.getString("token");
//
//     if (id != null) {
//       try {
//         int userId = int.parse(id!);
//         String url = "https://www.ordervite.com/api/shippier/$userId/orders";
//         var response = await http.get(
//           Uri.parse(url),
//           headers: {
//             'Content-Type': 'application/json',
//             'Accept': 'application/json',
//             'Authorization': 'Bearer $token',
//           },
//         );
//
//         var responseBody = jsonDecode(response.body);
//
//         if (responseBody["data"] != null) {
//           if (responseBody["data"].length > order_num) {
//             setState(() {
//               data = responseBody.toString();
//               isOrderDate = true;
//               order_num = responseBody["data"].length;
//             });
//           }
//           return List<Map<String, dynamic>>.from(responseBody["data"]);
//         }
//       } catch (e) {
//         print(e);
//       }
//     }
//
//     return [];
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
//   void dispose() {
//     timer?.cancel;
//     _orderController.close();
//     super.dispose();
//   }
//
//   void initState() {
//     getPref();
//     _orderController = StreamController();
//     loaddailyOrders();
//
//     super.initState();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     Lang lang = Lang.of(context);
//
//     return Directionality(
//       textDirection: lang.lang == "en" ? TextDirection.ltr : TextDirection.rtl,
//
//       child: Scaffold(
//         key: _scaffoldkey,
//         drawer: ShipperDrawer(
//           username: username ?? '',
//           email: email ?? '',
//           lang: lang,
//           isSignIn: isSignIn,
//         ),
//         appBar: AppBar(
//           title: Text(
//             'Orders',
//             style: TextStyle(
//               fontSize: 25,
//               fontWeight: FontWeight.bold,
//               fontStyle: FontStyle.normal,
//               color: Colors.white,
//             ),
//           ),
//         ),
//         body: Stack(
//           children: <Widget>[
//             Positioned(
//               child: FutureBuilder(
//                 future: getdailyOrders(),
//                 builder: (context, snapshot) {
//                   if (snapshot.hasData) {
//                     return ListView.builder(
//                       itemCount: snapshot.data?.length,
//                       itemBuilder: (context, index) {
//                         return ListTile(
//                           title: Text(
//                             (lang.lang == "en" ? "id : " : "الكود:") +
//                                 snapshot.data![index]["id"].toString() +
//                                 (lang.lang == "en"
//                                     ? ("Size : " +
//                                           snapshot.data![index]["size"]
//                                               .toString())
//                                     : ("Size: " +
//                                                   snapshot.data![index]["size"]
//                                                       .toString() ==
//                                               "small"
//                                           ? " الحجم : صغير"
//                                           : ("Size: " +
//                                                         snapshot
//                                                             .data![index]["size"]
//                                                             .toString() ==
//                                                     "medium"
//                                                 ? " الحجم :   كبير  "
//                                                 : " الحجم :   متوسط "))) +
//                                 "      ",
//                           ),
//                           subtitle: Text(
//                             (lang.lang == "en" ? "cost " : "التكلفة ") +
//                                 snapshot.data![index]["cost"].toString() +
//                                 (lang.lang == "en" ? " EGP " : " جم ") +
//                                 (lang.lang == "en"
//                                     ? ("Order State: " +
//                                           snapshot.data![index]["order_state"]
//                                               .toString())
//                                     : ("Order State: " +
//                                                   snapshot
//                                                       .data![index]["order_state"]
//                                                       .toString() ==
//                                               "new"
//                                           ? "حالة الطلب : جديد"
//                                           : ("Order State: " +
//                                                         snapshot
//                                                             .data![index]["order_state"]
//                                                             .toString() ==
//                                                     "shipper confirmed"
//                                                 ? "حالة الطلب : تاكيد مسئول الشحن  "
//                                                 : ("Order State: " +
//                                                               snapshot
//                                                                   .data![index]["order_state"]
//                                                                   .toString() ==
//                                                           "order received"
//                                                       ? "حالة الطلب :   استلام الشحنة   "
//                                                       : (snapshot.data![index]["order_state"]
//                                                                     .toString() ==
//                                                                 "order delivered"
//                                                             ? "حالة الطلب :      اكتمال الطلب    "
//                                                             : "حالة الطلب :   توصيل الشحنة  الشحنة   "))))),
//                           ),
//                           onTap: () {
//                             ShOrderData shorderData = new ShOrderData(
//                               snapshot.data![index]["dist_latitude"].toString(),
//                               snapshot.data![index]["so_latitude"].toString(),
//                               snapshot.data![index]["dist_longitude"]
//                                   .toString(),
//                               snapshot.data![index]["so_longitude"].toString(),
//                               snapshot.data![index]["id"].toString(),
//                               snapshot.data![index]["cost"].toString(),
//                               snapshot.data![index]["price"].toString(),
//                               snapshot.data![index]["pricecheck"].toString(),
//                               snapshot.data![index]["order_state"].toString(),
//                               snapshot.data![index]["supplier_id"].toString(),
//                               snapshot.data![index]["rating"].toString(),
//                             );
//                             Navigator.pushNamed(
//                               context,
//                               "shlistorder",
//                               arguments: shorderData,
//                             );
//                           },
//                           leading: CircleAvatar(
//                             child: Icon(
//                               Icons.card_travel_rounded,
//                               size: 20,
//                               color: Colors.white,
//                             ),
//                           ),
//                         );
//                       },
//                     );
//                   } else {
//                     return Center(child: CircularProgressIndicator());
//                   }
//                 },
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   List<Steps> parseSteps(final responseBody) {
//     var list = responseBody
//         .map<Steps>((json) => new Steps.fromJson(json))
//         .toList();
//     return list;
//   }
// }
//
// class NamedIcon extends StatelessWidget {
//   final IconData iconData;
//   final String text;
//   final VoidCallback onTap;
//   final int? notificationCount;
//
//   const NamedIcon({
//     required Key key,
//     required this.onTap,
//     required this.text,
//     required this.iconData,
//     this.notificationCount,
//   }) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return InkWell(
//       onTap: () {
//         Navigator.pushNamed(context, "shorders");
//       },
//       child: Container(
//         width: 72,
//         padding: const EdgeInsets.symmetric(horizontal: 8),
//         child: Stack(
//           alignment: Alignment.center,
//           children: [
//             Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: <Widget>[
//                 Icon(iconData),
//                 Text(text, overflow: TextOverflow.ellipsis),
//               ],
//             ),
//             Positioned(
//               top: 0,
//               right: 0,
//               child: Container(
//                 padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
//                 decoration: BoxDecoration(
//                   shape: BoxShape.circle,
//                   color: Colors.red,
//                 ),
//                 alignment: Alignment.center,
//                 child: Text('$notificationCount'),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// class ShOrderData {
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
//   ShOrderData(
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
