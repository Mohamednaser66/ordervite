// import 'dart:async';
// import 'dart:convert';
//
//
// import 'package:flutter/material.dart';
// import 'package:flutter_maps/lang.dart';
// import 'package:flutter_maps/services/auth.dart';
// import 'package:flutter_maps/shipper/orderList/orders.dart';
// import 'package:flutter_maps/shipper/shipper_drawer.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:http/http.dart' as http;
// import 'package:shared_preferences/shared_preferences.dart';
//
// String GoogleApiKEY = "AIzaSyDl8LFLQn24CbaZyQ0F4wnzoF9NY3_gMWY";
//
// class ShListOrder extends StatefulWidget {
//   ShListOrder({ Key? key}) : super(key: key);
//
//   final String title = "OrderVite";
//
//   @override
//   _ShListOrderState createState() => _ShListOrderState();
// }
//
// enum BestSize { small, medium, large }
//
// enum BestPrice { transfer, cash }
//
// class _ShListOrderState extends State<ShListOrder> {
//   CameraPosition _initialCamera = CameraPosition(
//     target: LatLng(30.059445, 31.1933067),
//     zoom: 14.0000,
//   );
//
//   Completer<GoogleMapController> _mapController = Completer();
//   final Set<Marker> _markers = Set();
//
//   LatLng sourceLatLong = LatLng(30.059445, 31.1933067);
//   LatLng destinationLatLong = LatLng(30.060671, 31.204131);
//   final Set<Polyline> _polyline = {};
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
//
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
//   BestSize _sizegl = BestSize.small;
//   BestPrice _pricegl = BestPrice.transfer;
//
//   GlobalKey<FormState> formstatesorder = new GlobalKey<FormState>();
//
//   String _size = 'default';
//   String _price = 'default';
//
//   String _priceCheck = 'default';
//
//   TextEditingController size = new TextEditingController();
//   TextEditingController price = new TextEditingController();
//   late BuildContext mainContext;
//
//   late Map<String, dynamic> formData;
//
//   _saveForm() {
//     var form = formstatesorder.currentState;
//     if (form!.validate()) {
//       form.save();
//     }
//   }
//
//   getPref() async {
//     SharedPreferences preferences = await SharedPreferences.getInstance();
//
//     ShOrderData shorderData =
//         ModalRoute.of(context)?.settings.arguments as ShOrderData;
//
//     username = preferences.getString("username")??'';
//     email = preferences.getString("email")??'';
//
//     if (username != null && email != null) {
//       setState(() {
//         username = preferences.getString("username");
//         email = preferences.getString("email");
//
//         token = preferences.getString("token")??'';
//         logo_src = preferences.getString("logo_src")??'';
//         id = preferences.getString("id")??"";
//         //  print(id);
//
//         isSignIn = true;
//       });
//     }
//     setState(() {
//       disLat = shorderData.disLat.toString();
//       disLong = shorderData.disLong.toString();
//       sorLat = shorderData.sorLat.toString();
//       sorlong = shorderData.sorlong.toString();
//       order_id = shorderData.order_id.toString();
//
//       order_cost = shorderData.order_cost;
//       order_price = shorderData.order_price;
//       order_pricecheck = shorderData.order_pricecheck;
//       rating = shorderData.rating;
//       order_supplier_id = shorderData.order_supplier_id;
//       order_state = shorderData.order_state;
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
//         markerId: MarkerId("1"),
//         position: sourceLatLong,
//         infoWindow: InfoWindow(title: "source"),
//         icon: BitmapDescriptor.defaultMarker,
//         visible: true,
//       ),
//     );
//
//     _markers.add(
//       Marker(
//         markerId: MarkerId("2"),
//         position: destinationLatLong,
//         infoWindow: InfoWindow(title: "destination"),
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
//   int _currentRating = 0;
//
//   Widget _buildRatingStar(int index) {
//     if (index < _currentRating) {
//       return Icon(Icons.star, color: Colors.orange);
//     } else {
//       return Icon(Icons.star_border_outlined);
//     }
//   }
//
//   @override
//   void initState() {
//     getPref();
//
//     super.initState();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     Lang lang = Lang.of(context);
//     ShOrderData shorderData =
//         ModalRoute.of(context)?.settings.arguments as ShOrderData;
//     return Directionality(
//       textDirection: lang.lang == "en" ? TextDirection.ltr : TextDirection.rtl,
//
//       child: Scaffold(
//         key: _scaffoldkey,
//         drawer:ShipperDrawer(username: username??'', email: email??'', lang: lang, isSignIn: isSignIn),
//         appBar: AppBar(
//           title: Text(
//             lang.lang == "en" ? 'Order $order_id' : ' طلب شحن  $order_id',
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
//               child: GoogleMap(
//                 mapType: MapType.normal,
//                 polylines: _polyline,
//                 myLocationEnabled: true,
//                 onCameraIdle: () {
//                   // print('camera stop');
//                 },
//                 initialCameraPosition: _initialCamera,
//                 onMapCreated: (GoogleMapController controller) {
//                   _mapController.complete(controller);
//                   _getPolyline();
//                 },
//                 markers: _markers,
//               ),
//             ),
//
//             Positioned(
//               left: 0.0,
//               right: 0.0,
//               bottom: 0.0,
//               child: Container(
//                 height: 250.0,
//                 decoration: BoxDecoration(
//                   gradient: LinearGradient(
//                     begin: Alignment.topRight,
//                     end: Alignment.topLeft,
//                     colors: [
//                       Color.fromRGBO(21, 42, 72, 1),
//                       Color.fromRGBO(7, 15, 33, 1),
//                     ],
//                   ),
//
//                   color: Color.fromRGBO(7, 15, 33, 0.9),
//                   borderRadius: BorderRadius.only(
//                     topLeft: Radius.circular(18.0),
//                     topRight: Radius.circular(18.0),
//                   ),
//                 ),
//
//                 child: Padding(
//                   padding: const EdgeInsets.symmetric(
//                     horizontal: 24.0,
//                     vertical: 18.0,
//                   ),
//                   child: SingleChildScrollView(
//                     child: Container(
//                       decoration: BoxDecoration(
//                         color: Colors.white.withOpacity(0.2),
//                         borderRadius: BorderRadius.all(Radius.circular(18.0)),
//                       ),
//                       child: Padding(
//                         padding: EdgeInsets.all(15.0),
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: <Widget>[
//                             Row(
//                               children: <Widget>[
//                                 Expanded(
//                                   child: Text(
//                                     lang.lang == "en"
//                                         ? "Order State: $order_state"
//                                         : (order_state == "new"
//                                               ? "حالة الطلب : جديد"
//                                               : (order_state ==
//                                                         "shipper confirmed"
//                                                     ? "حالة الطلب : تاكيد مسئول الشحن  "
//                                                     : (order_state ==
//                                                               "order received"
//                                                           ? "حالة الطلب :   استلام الشحنة   "
//                                                           : (order_state ==
//                                                                     "order delivered"
//                                                                 ? "حالة الطلب :      اكتمال الطلب    "
//                                                                 : "حالة الطلب :   توصيل الشحنة  الشحنة   ")))),
//                                     style: TextStyle(
//                                       fontSize: 15,
//                                       fontWeight: FontWeight.bold,
//                                       fontStyle: FontStyle.normal,
//                                       color: Colors.white,
//                                     ),
//                                   ),
//                                 ),
//                               ],
//                             ),
//
//                             SizedBox(height: 20),
//
//                             Row(
//                               crossAxisAlignment: CrossAxisAlignment.center,
//                               children: <Widget>[
//                                 Expanded(
//                                   child: Container(
//                                     height: 30.0,
//                                     width: 20.0,
//
//                                     decoration: new BoxDecoration(
//                                       borderRadius: new BorderRadius.circular(
//                                         50.0,
//                                       ),
//                                       color: Color(0xFF18D191),
//                                       image: DecorationImage(
//                                         image: AssetImage(
//                                           'assets/icons_New order.png',
//                                         ),
//                                         fit: BoxFit.fill,
//                                       ),
//                                     ),
//                                   ),
//                                 ),
//
//                                 SizedBox(width: 5),
//                                 Expanded(
//                                   child: Container(
//                                     height: 30.0,
//                                     width: 20.0,
//
//                                     decoration: new BoxDecoration(
//                                       borderRadius: new BorderRadius.circular(
//                                         50.0,
//                                       ),
//                                       color:
//                                           shorderData.order_state.toString() ==
//                                                   "shipper confirmed" ||
//                                               shorderData.order_state
//                                                       .toString() ==
//                                                   "order received" ||
//                                               shorderData.order_state
//                                                       .toString() ==
//                                                   "order delivered" ||
//                                               shorderData.order_state
//                                                       .toString() ==
//                                                   "order complete"
//                                           ? Color(0xFF18D191)
//                                           : Color(0xFFFC6A7F),
//                                       image: DecorationImage(
//                                         image: AssetImage(
//                                           'assets/icons_shipper confirm.png',
//                                         ),
//                                         fit: BoxFit.fill,
//                                       ),
//                                     ),
//                                   ),
//                                 ),
//
//                                 SizedBox(width: 5),
//                                 Expanded(
//                                   child: Container(
//                                     height: 30.0,
//                                     width: 20.0,
//                                     decoration: new BoxDecoration(
//                                       borderRadius: new BorderRadius.circular(
//                                         50.0,
//                                       ),
//                                       color:
//                                           shorderData.order_state.toString() ==
//                                                   "order received" ||
//                                               shorderData.order_state
//                                                       .toString() ==
//                                                   "order delivered" ||
//                                               shorderData.order_state
//                                                       .toString() ==
//                                                   "order complete"
//                                           ? Color(0xFF18D191)
//                                           : Color(0xFFFC6A7F),
//                                       image: DecorationImage(
//                                         image: AssetImage(
//                                           'assets/icons_shipper received.png',
//                                         ),
//                                         fit: BoxFit.fill,
//                                       ),
//                                     )
//                                   ),
//                                 ),
//                                 SizedBox(width: 5),
//                                 Expanded(
//                                   child: Container(
//                                     height: 30.0,
//                                     width: 20.0,
//                                     decoration: new BoxDecoration(
//                                       borderRadius: new BorderRadius.circular(
//                                         50.0,
//                                       ),
//                                       color:
//                                           shorderData.order_state.toString() ==
//                                                   "order delivered" ||
//                                               shorderData.order_state
//                                                       .toString() ==
//                                                   "order complete"
//                                           ? Color(0xFF18D191)
//                                           : Color(0xFFFC6A7F),
//                                       image: DecorationImage(
//                                         image: AssetImage(
//                                           'assets/icons_package delivered.png',
//                                         ),
//                                         fit: BoxFit.fill,
//                                       ),
//                                     ),
//                                   ),
//                                 ),
//                                 SizedBox(width: 5),
//                                 Expanded(
//                                   child: Container(
//                                     height: 30.0,
//                                     width: 20.0,
//                                     decoration: new BoxDecoration(
//                                       borderRadius: new BorderRadius.circular(
//                                         50.0,
//                                       ),
//                                       color:
//                                           shorderData.order_state.toString() ==
//                                               "order complete"
//                                           ? Color(0xFF18D191)
//                                           : Color(0xFFFC6A7F),
//                                       image: DecorationImage(
//                                         image: AssetImage(
//                                           'assets/icons_order complete.png',
//                                         ),
//                                         fit: BoxFit.fill,
//                                       ),
//                                     ),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                             SizedBox(height: 15),
//
//                             Row(
//                               children: <Widget>[
//                                 Expanded(
//                                   child: Text(
//                                     lang.lang == "en"
//                                         ? "Order ID: $order_id"
//                                         : "كود الطلب : $order_id",
//                                     style: TextStyle(
//                                       fontSize: 15,
//                                       fontWeight: FontWeight.bold,
//                                       fontStyle: FontStyle.normal,
//                                       color: Colors.white,
//                                     ),
//                                   ),
//                                 ),
//
//                                 SizedBox(width: 20.0),
//
//                                 Expanded(
//                                   child: Text(
//                                     lang.lang == "en"
//                                         ? " supplier Id:   $order_supplier_id "
//                                         : "كود المورد:   $order_supplier_id ",
//                                     style: TextStyle(
//                                       fontSize: 15,
//                                       fontWeight: FontWeight.bold,
//                                       fontStyle: FontStyle.normal,
//                                       color: Colors.white,
//                                     ),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                             SizedBox(height: 10),
//
//                             Row(
//                               children: <Widget>[
//                                 Expanded(
//                                   child: Text(
//                                     lang.lang == "en"
//                                         ? "Shipping Cost:"
//                                         : "تكلفة الطلب :",
//                                     style: TextStyle(
//                                       fontSize: 15,
//                                       fontWeight: FontWeight.bold,
//                                       fontStyle: FontStyle.normal,
//                                       color: Colors.white,
//                                     ),
//                                   ),
//                                 ),
//
//                                 SizedBox(width: 20),
//                                 Expanded(
//                                   child: Text(
//                                     lang.lang == "en"
//                                         ? "Package Price:"
//                                         : "سعر الشحنة ",
//                                     style: TextStyle(
//                                       fontSize: 15,
//                                       fontWeight: FontWeight.bold,
//                                       fontStyle: FontStyle.normal,
//                                       color: Colors.white,
//                                     ),
//                                   ),
//                                 ),
//                               ],
//                             ),
//
//                             SizedBox(height: 5),
//
//                             Row(
//                               children: <Widget>[
//                                 Expanded(
//                                   child: Text(
//                                     lang.lang == "en"
//                                         ? " $order_cost L.E."
//                                         : "$order_cost جم",
//                                     style: TextStyle(
//                                       fontSize: 15,
//                                       fontWeight: FontWeight.bold,
//                                       fontStyle: FontStyle.normal,
//                                       color: Colors.white,
//                                     ),
//                                   ),
//                                 ),
//
//                                 SizedBox(width: 20),
//                                 Expanded(
//                                   child: Text(
//                                     lang.lang == "en"
//                                         ? " $order_price L.E."
//                                         : "$order_price جم",
//                                     style: TextStyle(
//                                       fontSize: 15,
//                                       fontWeight: FontWeight.bold,
//                                       fontStyle: FontStyle.normal,
//                                       color: Colors.white,
//                                     ),
//                                   ),
//                                 ),
//                               ],
//                             ),
//
//                             SizedBox(height: 20.0),
//
//                             Row(
//                               children: <Widget>[
//                                 Expanded(
//                                   child: Text(
//                                     lang.lang == "en"
//                                         ? "Payment Method : $order_pricecheck"
//                                         : (order_pricecheck == "cash"
//                                               ? "نظام الدفع  : كاش"
//                                               : "نظام الدفع  : تحويل"),
//                                     style: TextStyle(
//                                       fontSize: 15,
//                                       fontWeight: FontWeight.bold,
//                                       fontStyle: FontStyle.normal,
//                                       color: Colors.white,
//                                     ),
//                                   ),
//                                 ),
//                               ],
//                             ),
//
//                             SizedBox(height: 10),
//                             Row(
//                               children: <Widget>[
//                                 Expanded(
//                                   child: Text(
//                                     lang.lang == "en"
//                                         ? "Rating : $rating"
//                                         : "تقييم : $rating",
//                                     style: TextStyle(
//                                       fontSize: 15,
//                                       fontWeight: FontWeight.bold,
//                                       fontStyle: FontStyle.normal,
//                                       color: Colors.white,
//                                     ),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Future<List<Steps>> _getPolyline() async {
//     final BASE_URL = "https://maps.googleapis.com/maps/api/directions/json?"
//         "origin=${sourceLatLong.latitude},${sourceLatLong.longitude}"
//         "&destination=${destinationLatLong.latitude},${destinationLatLong.longitude}"
//         "&key=$GoogleApiKEY";
//
//     final response = await http.get(Uri.parse(BASE_URL));
//
//     if (response.statusCode != 200) {
//       throw Exception('Failed to load directions');
//     }
//
//     final data = json.decode(response.body);
//
//     List<Steps> steps = parseSteps(data["routes"][0]["legs"][0]["steps"]);
//
//     List<LatLng> polyPoints = [];
//     for (final step in steps) {
//       polyPoints.add(step.startLocation);
//       polyPoints.add(step.endLocation);
//     }
//
//     setState(() {
//       _polyline.add(Polyline(
//         polylineId: PolylineId("2"),
//         visible: true,
//         width: 8,
//         points: polyPoints,
//         color: Colors.blue,
//       ));
//     });
//
//     return steps;
//   }
//   List<Steps> parseSteps(final responseBody) {
//     var list = responseBody
//         .map<Steps>((json) => new Steps.fromJson(json))
//         .toList();
//     return list;
//   }
// }
//
// class Steps {
//   LatLng startLocation;
//   LatLng endLocation;
//
//   Steps({ required this.startLocation,required this.endLocation});
//
//   factory Steps.fromJson(Map<String, dynamic> json) {
//     return new Steps(
//       startLocation: new LatLng(
//         json["start_location"]["lat"],
//         json["start_location"]["lng"],
//       ),
//       endLocation: new LatLng(
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
