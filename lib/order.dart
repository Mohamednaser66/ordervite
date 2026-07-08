import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_maps/Core/routes_manager.dart';
import 'package:flutter_maps/classes.dart';
import 'package:flutter_maps/core/colors_manager.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:location/location.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

const String _googleApiKey = "AIzaSyDl8LFLQn24CbaZyQ0F4wnzoF9NY3_gMWY";
const String _mapsBaseUrl =
    "https://maps.googleapis.com/maps/api/directions/json";

class Order extends StatefulWidget {
  Order({Key? key}) : super(key: key);

  final String title = "OrderVite";

  @override
  _OrderState createState() => _OrderState();
}

enum BestSize { small, medium, large }

enum BestPrice { transfer, cash }

class _OrderState extends State<Order> {
  CameraPosition _initialCamera = CameraPosition(
    target: LatLng(30.059445, 31.1933067),
    zoom: 14.0000,
  );

  Completer<GoogleMapController> _mapController = Completer();
  final Set<Marker> _markers = Set();

  LatLng sourceLatLong = LatLng(30.059445, 31.1933067);
  LatLng destinationLatLong = LatLng(30.060671, 31.204131);
  final Set<Polyline> _polyline = {};
  final GlobalKey<ScaffoldState> _scaffoldkey = new GlobalKey<ScaffoldState>();
  String username = '';
  String email = '';
  String? id;
  String? token;
  String? type;
  String? disLat = "30.035957023060657";
  String? sorLat = "30.059445";
  String? disLong = "31.19988958191512";
  String? sorlong = "31.1933067";
  String? distance = "2";
  String? order_id;
  String? cost;

  String? order_cost;
  String? order_size;
  String? order_pricecheck;
  String? order_supplier_id;
  String? order_shippier_id;
  String? order_price;
  String? order_state;

  Timer? timer;

  late StreamController _orderController;

  bool isConfirm = false;

  bool isConfirmSupplier = false;

  bool isConfirmOrder = false;

  bool isConfrimSupplier = false;

  bool isReceived = false;
  bool isDelviered = false;
  bool isComplete = false;
  bool isCnacel = false;
  bool isCnacelSupplier = false;

  bool isSignIn = false;

  BestSize _sizegl = BestSize.small;
  BestPrice _pricegl = BestPrice.transfer;

  String _size = 'default';
  String _priceCheck = 'default';

  TextEditingController price = TextEditingController();

  String? validprice(String? val) {
    if (val!.trim().isEmpty) {
      return 'package price  Is Required';
    }

    return null;
  }

  getPref() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();

    final args = ModalRoute.of(context)?.settings.arguments;
    final OrderData? orderData = args is OrderData ? args : null;
    final OrderDist? orderDist = args is OrderDist ? args : null;

    username = preferences.getString("username") ?? '';
    email = preferences.getString("email") ?? '';

    setState(() {
      token = preferences.getString("token") ?? '';
      id = preferences.getString("id") ?? '';
      type = preferences.getString("type") ?? '';
      isSignIn = username.isNotEmpty && email.isNotEmpty;
    });
    setState(() {
      if (orderDist is OrderDist) {
        disLat = orderDist.disLat.toString();
        disLong = orderDist.disLong.toString();
        sorLat = orderDist.sorLat.toString();
        sorlong = orderDist.sorlong.toString();
        isConfirm = orderDist.isConfirm;
        order_id = orderDist.order_id ?? '';

        order_cost = orderDist.order_cost ?? "";
        order_price = orderDist.order_price ?? '';
        order_pricecheck = orderDist.order_pricecheck ?? '';
        order_shippier_id = orderDist.order_shippier_id ?? '';
        order_state = orderDist.order_state ?? '';
      }

      if (orderData is OrderData) {
        disLat = orderData.disLat.toString();
        disLong = orderData.disLong.toString();
        sorLat = orderData.sorLat.toString();
        sorlong = orderData.sorlong.toString();
        order_id = orderData.order_id.toString();
        isConfirm = orderData.isConfirm;
        order_cost = orderData.order_cost;
        order_price = orderData.order_price;
        order_pricecheck = orderData.order_pricecheck;
        order_supplier_id = orderData.order_supplier_id;
        order_state = orderData.order_state;
      }

      _initialCamera = CameraPosition(
        target: LatLng(double.parse(sorLat ?? ''), double.parse(sorlong ?? '')),
        zoom: 14.0000,
      );

      sourceLatLong = LatLng(
        double.parse(sorLat ?? ""),
        double.parse(sorlong ?? ''),
      );
      destinationLatLong = LatLng(
        double.parse(disLat ?? ''),
        double.parse(disLong ?? ''),
      );
    });

    _markers.add(
      Marker(
        markerId: MarkerId("1"),
        position: sourceLatLong,
        infoWindow: InfoWindow(title: "source"),
        icon: BitmapDescriptor.defaultMarker,
        visible: true,
      ),
    );

    _markers.add(
      Marker(
        markerId: MarkerId("2"),
        position: destinationLatLong,
        infoWindow: InfoWindow(title: "destination"),
        icon: BitmapDescriptor.defaultMarker,
        visible: true,
      ),
    );
  }

  Future getcurrentOrder() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();

    token = preferences.getString("token") ?? '';
    id = preferences.getString("id") ?? '';
    if (type.toString() == "shipper") {
      try {
        if (id != null) {
          int id = int.parse(this.id ?? '', radix: 10);
          String Url =
              "https://www.ordervite.com/api/shippier/current_order/$id";

          var response = await http.get(
            Uri.parse(Url),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',

              'Authorization': 'Bearer $token',
            },
          );

          var reposnsebody = jsonDecode(response.body);

          if (isConfirm) {
            if (reposnsebody["data"] != null) {
              setState(() {
                order_state =
                    reposnsebody["data"]["order_state"]?.toString() ?? '';
                order_cost = reposnsebody["data"]["cost"]?.toString() ?? '';
                order_price = reposnsebody["data"]["price"]?.toString() ?? '';
                order_pricecheck =
                    reposnsebody["data"]["pricecheck"]?.toString() ?? '';
                order_supplier_id =
                    reposnsebody["data"]["supplier_id"]?.toString() ?? '';
              });

              if (reposnsebody["data"]["order_cancel"] != null) {
                setState(() {
                  isCnacelSupplier = true;
                });
              }

              if (reposnsebody["data"]["order_state"].toString() ==
                  "order received") {
                setState(() {
                  isConfirm = true;
                  isReceived = true;
                });
              }

              if (reposnsebody["data"]["order_state"].toString() ==
                  "order delivered") {
                setState(() {
                  isConfirm = true;
                  isReceived = true;
                  isDelviered = true;
                });
              }

              if (reposnsebody["data"]["order_state"].toString() ==
                  "order complete") {
                isComplete = true;
              }
            }
          }

          return reposnsebody["data"];
        } else {
          return null;
        }
      } catch (e) {}
    } else if (type.toString() == "supplier") {
      try {
        if (id != null) {
          int id = int.parse(this.id ?? '', radix: 10);
          String Url =
              "https://www.ordervite.com/api/supplier/current_order/$id";

          var response = await http.get(
            Uri.parse(Url),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',

              'Authorization': 'Bearer $token',
            },
          );

          var reposnsebody = jsonDecode(response.body);

          if (isConfirmSupplier) {
            if (reposnsebody["data"] != null) {
              setState(() {
                order_state =
                    reposnsebody["data"]["order_state"]?.toString() ?? '';
                order_shippier_id =
                    reposnsebody["data"]["shippier_id"]?.toString() ?? '';
                order_cost = reposnsebody["data"]["cost"]?.toString() ?? '';
                order_price = reposnsebody["data"]["price"]?.toString() ?? '';
                order_pricecheck =
                    reposnsebody["data"]["pricecheck"]?.toString() ?? '';
              });

              if (reposnsebody["data"]["order_cancel"] != null) {
                setState(() {
                  isCnacel = true;
                });
              }

              if (reposnsebody["data"]["order_state"] == "order delivered") {
                setState(() {
                  isConfirmOrder = true;
                });
              }

              if (reposnsebody["data"]["shippier_id"] != null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: Colors.redAccent,
                    content: Text(
                      'your order  has confirmed please wait',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18.sp,
                      ),
                    ),
                  ),
                );
              }

              if (reposnsebody["data"]["order_state"].toString() ==
                  "order complete") {
                setState(() {
                  isComplete = true;
                });
              }
            }
          }

          return reposnsebody["data"];
        } else {
          return null;
        }
      } catch (e) {}
    } else {
      return null;
    }
  }

  loadcurrentOrder() async {
    getcurrentOrder().then((res) async {
      _orderController.add(res);
      return res;
    });
  }

  @override
  void dispose() {
    timer?.cancel();

    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    getPref();
    loadcurrentOrder();

    timer = Timer.periodic(
      const Duration(seconds: 100),
      (_) => loadcurrentOrder(),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isCnacelSupplier && type.toString() == "shipper") {
      Message message = new Message("sorry supplier  have canceld order");
      Navigator.pushNamed(context, RoutesManager.shOrders, arguments: message);
    }

    if (isCnacel && type.toString() == "supplier") {
      Message message = new Message("sorry shippier  have canceld order");
      Navigator.pushNamed(context, RoutesManager.search, arguments: message);
    }
    if (isComplete && type.toString() == "shipper") {
      Message message = new Message("good work order has done");
      Navigator.pushNamed(context, RoutesManager.shOrders, arguments: message);
    }

    if (isConfirmOrder && type.toString() == "supplier") {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.redAccent,
          content: Text(
            'your order  has complete please press confirm order',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.sp),
          ),
        ),
      );
    }

    if (type.toString() == "shipper") {
      return WillPopScope(
        child: Scaffold(
          key: _scaffoldkey,

          appBar: AppBar(
            title: Text(
              'Order $order_id',
              style: TextStyle(
                fontSize: 25.sp,
                fontWeight: FontWeight.bold,
                fontStyle: FontStyle.normal,
                color: Colors.white,
              ),
            ),
            automaticallyImplyLeading: false,
          ),
          body: Stack(
            children: <Widget>[
              Positioned.fill(
                child: GoogleMap(
                  mapType: MapType.normal,
                  polylines: _polyline,
                  myLocationEnabled: true,
                  onCameraIdle: () {},
                  initialCameraPosition: _initialCamera,
                  onMapCreated: (GoogleMapController controller) {
                    _mapController.complete(controller);
                    _getPoliLine();
                  },
                  markers: _markers,
                ),
              ),

              Positioned(
                left: 0.0.w,
                right: 0.0.w,
                bottom: 0.0.h,
                child: Container(
                  height: 300.h,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topRight,
                      end: Alignment.topLeft,
                      colors: [
                        ColorsManager.darkerGreen,
                        ColorsManager.primaryGreen,
                      ],
                    ),

                    color: ColorsManager.darkerGreen,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(18.0.r),
                      topRight: Radius.circular(18.0.r),
                    ),
                  ),

                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 24.w,
                      vertical: 18.h,
                    ),
                    child: SingleChildScrollView(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(18.0.r),
                            topRight: Radius.circular(18.0.r),
                          ),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(15.0.r),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Row(
                                children: <Widget>[
                                  Expanded(
                                    child: Text(
                                      "Order data id : $order_id  ",
                                      style: TextStyle(
                                        fontSize: 20.sp,
                                        fontWeight: FontWeight.bold,
                                        fontStyle: FontStyle.normal,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              SizedBox(height: 30.h),

                              Row(
                                children: <Widget>[
                                  Expanded(
                                    child: Text(
                                      "order id:   $order_id ",
                                      style: TextStyle(
                                        fontSize: 15.sp,
                                        fontWeight: FontWeight.bold,
                                        fontStyle: FontStyle.normal,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),

                                  SizedBox(width: 20.w),

                                  Expanded(
                                    child: Text(
                                      "order cost:   $order_cost ",
                                      style: TextStyle(
                                        fontSize: 15.sp,
                                        fontWeight: FontWeight.bold,
                                        fontStyle: FontStyle.normal,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 20.h),
                              Row(
                                children: <Widget>[
                                  Expanded(
                                    child: Text(
                                      "order price:   $order_price ",
                                      style: TextStyle(
                                        fontSize: 15.sp,
                                        fontWeight: FontWeight.bold,
                                        fontStyle: FontStyle.normal,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),

                                  SizedBox(width: 20.w),

                                  Expanded(
                                    child: Text(
                                      "order supplier Id:   $order_supplier_id ",
                                      style: TextStyle(
                                        fontSize: 15.sp,
                                        fontWeight: FontWeight.bold,
                                        fontStyle: FontStyle.normal,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 20.h),

                              Row(
                                children: <Widget>[
                                  Expanded(
                                    child: Text(
                                      "order price state:   $order_state",
                                      style: TextStyle(
                                        fontSize: 15.sp,
                                        fontWeight: FontWeight.bold,
                                        fontStyle: FontStyle.normal,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              SizedBox(height: 20.h),

                              Row(
                                children: <Widget>[
                                  Expanded(
                                    child: Text(
                                      "order price check:   $order_pricecheck ",
                                      style: TextStyle(
                                        fontSize: 15.sp,
                                        fontWeight: FontWeight.bold,
                                        fontStyle: FontStyle.normal,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              SizedBox(height: 30.h),

                              !isConfirm
                                  ? Row(
                                      children: <Widget>[
                                        SizedBox(width: 10.w),

                                        Expanded(
                                          child: TextButton.icon(
                                            onPressed: () async {
                                              try {
                                                Location locationTracker =
                                                    Location();
                                                var location =
                                                    await locationTracker
                                                        .getLocation();

                                                if (isConfirm) {
                                                  ScaffoldMessenger.of(
                                                    context,
                                                  ).showSnackBar(
                                                    SnackBar(
                                                      backgroundColor:
                                                          Colors.redAccent,
                                                      content: Text(
                                                        'Please wait to Response your order have sended  ...',
                                                        style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 18.sp,
                                                        ),
                                                      ),
                                                    ),
                                                  );
                                                } else {
                                                  int id = int.parse(
                                                    order_id ?? '',
                                                    radix: 10,
                                                  );

                                                  await SharedPreferences.getInstance();

                                                  String url =
                                                      "https://www.ordervite.com/api/shippier/orders/$id";

                                                  var response = await http.put(
                                                    Uri.parse(url),
                                                    body: {
                                                      "shippier_id": this.id
                                                          .toString(),
                                                      "sh_longitude": location
                                                          .longitude
                                                          .toString(),
                                                      "sh_latitude": location
                                                          .latitude
                                                          .toString(),
                                                      "order_state":
                                                          "shipper confirmed",
                                                    },
                                                    headers: {
                                                      'Authorization':
                                                          'Bearer ${this.token}',
                                                    },
                                                  );

                                                  var reposnsebody = jsonDecode(
                                                    response.body,
                                                  );

                                                  setState(() {
                                                    isConfirm = true;
                                                    order_state =
                                                        reposnsebody["data"]["order_state"]
                                                            .toString();
                                                  });

                                                  ScaffoldMessenger.of(
                                                    context,
                                                  ).showSnackBar(
                                                    SnackBar(
                                                      backgroundColor:
                                                          Colors.redAccent,
                                                      content: Text(
                                                        'sucussfully,you own that order  ...',
                                                        style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 18.sp,
                                                        ),
                                                      ),
                                                    ),
                                                  );
                                                }
                                              } catch (e) {
                                                debugPrint(e.toString());
                                              }
                                            },
                                            icon: Icon(
                                              Icons.done_all,
                                              size: 20.sp,
                                              color: Colors.white,
                                            ),
                                            label: Text(
                                              "Confirm",
                                              style: TextStyle(
                                                fontSize: 12.sp,
                                                color: Colors.white,
                                              ),
                                            ),
                                            style: TextButton.styleFrom(
                                              backgroundColor: Colors.green,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                      30.0.r,
                                                    ),
                                              ),
                                            ),
                                          ),
                                        ),

                                        SizedBox(width: 15.w),

                                        Expanded(
                                          child: ElevatedButton.icon(
                                            onPressed: () async {
                                              setState(() {
                                                isConfirm = false;
                                                isCnacel = true;
                                              });

                                              Message message = Message(
                                                "you have canceld order",
                                              );

                                              Navigator.pushNamed(
                                                context,
                                                RoutesManager.shOrders,
                                                arguments: message,
                                              );
                                            },
                                            icon: Icon(
                                              Icons.cancel,
                                              size: 20.sp,
                                              color: Colors.white,
                                            ),
                                            label: Text(
                                              "Cancel",
                                              style: TextStyle(
                                                fontSize: 12.sp,
                                                color: Colors.white,
                                              ),
                                            ),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.red,
                                              splashFactory:
                                                  InkRipple.splashFactory,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                      30.0.r,
                                                    ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    )
                                  : !isReceived
                                  ? Row(
                                      children: <Widget>[
                                        SizedBox(width: 10.w),

                                        Expanded(
                                          child: TextButton.icon(
                                            onPressed: () async {
                                              try {
                                                if (isReceived) {
                                                  ScaffoldMessenger.of(
                                                    context,
                                                  ).showSnackBar(
                                                    SnackBar(
                                                      backgroundColor:
                                                          Colors.redAccent,
                                                      content: Text(
                                                        'error order not recevied until yet  ...',
                                                        style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 18.sp,
                                                        ),
                                                      ),
                                                    ),
                                                  );
                                                } else {
                                                  int id = int.parse(
                                                    order_id ?? "",
                                                    radix: 10,
                                                  );

                                                  await SharedPreferences.getInstance();

                                                  String url =
                                                      "https://www.ordervite.com/api/shippier/order_update/$id";

                                                  var response = await http.put(
                                                    Uri.parse(url),
                                                    body: {
                                                      "order_state":
                                                          "order received",
                                                    },
                                                    headers: {
                                                      'Authorization':
                                                          'Bearer ${this.token}',
                                                    },
                                                  );

                                                  var reposnsebody = jsonDecode(
                                                    response.body,
                                                  );

                                                  setState(() {
                                                    isReceived = true;
                                                    order_state =
                                                        reposnsebody["data"]["order_state"]
                                                            .toString();
                                                  });

                                                  ScaffoldMessenger.of(
                                                    context,
                                                  ).showSnackBar(
                                                    SnackBar(
                                                      backgroundColor:
                                                          Colors.redAccent,
                                                      content: Text(
                                                        'sucussfully,you have recieved this order ...',
                                                        style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 18.sp,
                                                        ),
                                                      ),
                                                    ),
                                                  );
                                                }
                                              } catch (e) {
                                                debugPrint(e.toString());
                                              }
                                            },
                                            icon: Icon(
                                              Icons.done_all,
                                              size: 20.sp,
                                              color: Colors.white,
                                            ),
                                            label: Text(
                                              "Received PK ",
                                              style: TextStyle(
                                                fontSize: 12.sp,
                                                color: Colors.white,
                                              ),
                                            ),
                                            style: TextButton.styleFrom(
                                              backgroundColor: Colors.green,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                      30.0.r,
                                                    ),
                                              ),
                                            ),
                                          ),
                                        ),

                                        SizedBox(width: 15.w),

                                        Expanded(
                                          child: ElevatedButton.icon(
                                            onPressed: () async {
                                              setState(() {
                                                isConfirm = false;
                                              });

                                              if (order_id != null) {
                                                String name =
                                                    '${this.id}  shipper  ${this.username}';

                                                int id = int.parse(
                                                  order_id ?? '',
                                                  radix: 10,
                                                );

                                                String url =
                                                    "https://www.ordervite.com/api/shippier/order_update/$id";

                                                await http.put(
                                                  Uri.parse(url),
                                                  body: {
                                                    "order_cancel":
                                                        "$name cancel order",
                                                  },
                                                  headers: {
                                                    'Authorization':
                                                        'Bearer ${this.token}',
                                                  },
                                                );

                                                setState(() {
                                                  isCnacel = true;
                                                });

                                                ScaffoldMessenger.of(
                                                  context,
                                                ).showSnackBar(
                                                  SnackBar(
                                                    backgroundColor:
                                                        Colors.redAccent,
                                                    content: Text(
                                                      'Order have canceled ...',
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 18.sp,
                                                      ),
                                                    ),
                                                  ),
                                                );
                                              }

                                              Message message = Message(
                                                "you  have canceld order",
                                              );

                                              Navigator.pushNamed(
                                                context,
                                                "shorders",
                                                arguments: message,
                                              );
                                            },
                                            icon: Icon(
                                              Icons.cancel,
                                              size: 20.sp,
                                              color: Colors.white,
                                            ),
                                            label: Text(
                                              "Cancel",
                                              style: TextStyle(
                                                fontSize: 12.sp,
                                                color: Colors.white,
                                              ),
                                            ),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.red,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                      30.0.r,
                                                    ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    )
                                  : !isDelviered
                                  ? Row(
                                      children: <Widget>[
                                        SizedBox(width: 10.w),

                                        Expanded(
                                          child: TextButton.icon(
                                            onPressed: () async {
                                              try {
                                                if (isDelviered) {
                                                  ScaffoldMessenger.of(
                                                    context,
                                                  ).showSnackBar(
                                                    SnackBar(
                                                      backgroundColor:
                                                          Colors.redAccent,
                                                      content: Text(
                                                        'error order not delivered until yet  ...',
                                                        style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 18.sp,
                                                        ),
                                                      ),
                                                    ),
                                                  );
                                                } else {
                                                  int id = int.parse(
                                                    order_id ?? '',
                                                    radix: 10,
                                                  );
                                                  debugPrint(id.toString());

                                                  await SharedPreferences.getInstance();

                                                  String url =
                                                      "https://www.ordervite.com/api/shippier/order_update/$id";

                                                  var response = await http.put(
                                                    Uri.parse(url),
                                                    body: {
                                                      "order_state":
                                                          "order delivered",
                                                    },
                                                    headers: {
                                                      'Authorization':
                                                          'Bearer ${this.token}',
                                                    },
                                                  );

                                                  var reposnsebody = jsonDecode(
                                                    response.body,
                                                  );

                                                  setState(() {
                                                    isDelviered = true;
                                                    isConfirmOrder = true;
                                                    order_state =
                                                        reposnsebody["data"]["order_state"]
                                                            .toString();
                                                  });

                                                  ScaffoldMessenger.of(
                                                    context,
                                                  ).showSnackBar(
                                                    SnackBar(
                                                      backgroundColor:
                                                          Colors.redAccent,
                                                      content: Text(
                                                        'sucussfully,you have delivered this order ...',
                                                        style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 18.sp,
                                                        ),
                                                      ),
                                                    ),
                                                  );
                                                }
                                              } catch (e) {
                                                debugPrint(e.toString());
                                              }
                                            },
                                            icon: Icon(
                                              Icons.done_all,
                                              size: 20.sp,
                                              color: Colors.white,
                                            ),
                                            label: Text(
                                              "Delivered PK ",
                                              style: TextStyle(
                                                fontSize: 12.sp,
                                                color: Colors.white,
                                              ),
                                            ),
                                            style: TextButton.styleFrom(
                                              backgroundColor: Colors.green,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                      30.0.r,
                                                    ),
                                              ),
                                            ),
                                          ),
                                        ),

                                        SizedBox(width: 15.w),

                                        Expanded(
                                          child: ElevatedButton.icon(
                                            onPressed: () async {
                                              setState(() {
                                                isCnacel = true;
                                              });

                                              if (order_id != null) {
                                                String name =
                                                    '${this.id}  shipper  ${this.username}';

                                                int id = int.parse(
                                                  order_id ?? '',
                                                  radix: 10,
                                                );

                                                String url =
                                                    "https://www.ordervite.com/api/shippier/order_update/$id";

                                                await http.put(
                                                  Uri.parse(url),
                                                  body: {
                                                    "order_cancel":
                                                        "$name cancel order",
                                                  },
                                                  headers: {
                                                    'Authorization':
                                                        'Bearer ${this.token}',
                                                  },
                                                );

                                                ScaffoldMessenger.of(
                                                  context,
                                                ).showSnackBar(
                                                  SnackBar(
                                                    backgroundColor:
                                                        Colors.redAccent,
                                                    content: Text(
                                                      'Order have canceled ...',
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 18.sp,
                                                      ),
                                                    ),
                                                  ),
                                                );
                                              }

                                              Message message = Message(
                                                "you  have canceld order",
                                              );

                                              Navigator.pushNamed(
                                                context,
                                                RoutesManager.shOrders,
                                                arguments: message,
                                              );
                                            },
                                            icon: Icon(
                                              Icons.cancel,
                                              size: 20.sp,
                                              color: Colors.white,
                                            ),
                                            label: Text(
                                              "Cancel",
                                              style: TextStyle(
                                                fontSize: 12.sp,
                                                color: Colors.white,
                                              ),
                                            ),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.red,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                      30.0.r,
                                                    ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    )
                                  : Container(
                                      decoration: BoxDecoration(
                                        color: Colors.green,
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(18.0.r),
                                        ),
                                      ),
                                      child: Padding(
                                        padding: EdgeInsets.all(3.r),
                                        child: Row(
                                          children: <Widget>[
                                            SizedBox(width: 10.w),

                                            Expanded(
                                              child: Text(
                                                "you have delivered order but please wait to order confirm from supplier ",
                                                style: TextStyle(
                                                  fontSize: 17.sp,
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        onWillPop: () {
          return showDialog<bool>(
            context: context,
            builder: (c) => AlertDialog(
              title: Text('Warning', style: TextStyle(color: Colors.red)),
              content: Text(
                'Please you cant exist until order complete  ',
                style: TextStyle(fontSize: 15.sp, color: Colors.red),
              ),
              actions: [],
            ),
          ).then((value) => value ?? false);
        },
      );
    } else if (type.toString() == "supplier") {
      return WillPopScope(
        child: Scaffold(
          key: _scaffoldkey,

          appBar: AppBar(
            title: Text(
              'OrderVite',
              style: TextStyle(
                fontSize: 25.sp,
                fontWeight: FontWeight.bold,
                fontStyle: FontStyle.normal,
                color: Colors.white,
              ),
            ),
            automaticallyImplyLeading: false,
          ),
          body: Stack(
            children: <Widget>[
              Positioned(
                child: GoogleMap(
                  mapType: MapType.normal,
                  polylines: _polyline,
                  myLocationEnabled: true,
                  onCameraIdle: () {},
                  initialCameraPosition: _initialCamera,
                  onMapCreated: (GoogleMapController controller) {
                    _mapController.complete(controller);
                    _getPoliLine();
                  },
                  markers: _markers,
                ),
              ),

              Positioned(
                left: 0.0.w,
                right: 0.0.w,
                bottom: 0.0.h,
                child: !isConfirmSupplier
                    ? Container(
                        height: 350.h,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topRight,
                            end: Alignment.topLeft,
                            colors: [
                              Color.fromRGBO(21, 42, 72, 1),
                              Color.fromRGBO(7, 15, 33, 1),
                            ],
                          ),

                          color: Color.fromRGBO(7, 15, 33, 0.9),
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(18.0.r),
                            topRight: Radius.circular(18.0.r),
                          ),
                        ),

                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 24.w,
                            vertical: 18.h,
                          ),
                          child: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Row(
                                  children: <Widget>[
                                    Expanded(
                                      child: Text(
                                        'Choose package size ',
                                        style: TextStyle(
                                          fontSize: 15.sp,
                                          fontWeight: FontWeight.bold,
                                          fontStyle: FontStyle.normal,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),

                                SizedBox(height: 6.h),
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(18.0.r),
                                    ),
                                  ),

                                  child: Row(
                                    children: <Widget>[
                                      Expanded(
                                        child: ListTile(
                                          title: Text(
                                            'SM',
                                            style: TextStyle(
                                              fontSize: 10.sp,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          tileColor: Colors.white,

                                          leading: Radio<BestSize>(
                                            activeColor: Color.fromRGBO(
                                              21,
                                              42,
                                              72,
                                              1,
                                            ),
                                            value: BestSize.small,
                                            groupValue: _sizegl,
                                            onChanged: (BestSize? value) {
                                              if (value == null) return;

                                              setState(() {
                                                _sizegl = value;
                                                _size = "small";
                                              });
                                            },
                                          ),
                                        ),
                                      ),

                                      Expanded(
                                        child: ListTile(
                                          title: Text(
                                            'MD',
                                            style: TextStyle(
                                              fontSize: 10.sp,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          tileColor: Colors.white,

                                          leading: Radio<BestSize>(
                                            activeColor: Color.fromRGBO(
                                              21,
                                              42,
                                              72,
                                              1,
                                            ),
                                            value: BestSize.medium,
                                            groupValue: _sizegl,
                                            onChanged: (BestSize? value) {
                                              if (value == null) return;

                                              setState(() {
                                                _sizegl = value;
                                                _size = "medium";
                                              });
                                            },
                                          ),
                                        ),
                                      ),

                                      Expanded(
                                        child: ListTile(
                                          title: Text(
                                            'LG',
                                            style: TextStyle(
                                              fontSize: 10.sp,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          tileColor: Colors.white,

                                          leading: Radio<BestSize>(
                                            activeColor: Color.fromRGBO(
                                              21,
                                              42,
                                              72,
                                              1,
                                            ),
                                            value: BestSize.large,
                                            groupValue: _sizegl,
                                            onChanged: (BestSize? value) {
                                              if (value == null) return;

                                              setState(() {
                                                _sizegl = value;
                                                _size = "large";
                                              });
                                            },
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                SizedBox(height: 6.h),

                                Row(
                                  children: <Widget>[
                                    Expanded(
                                      child: Text(
                                        'Choose package price checker ',
                                        style: TextStyle(
                                          fontSize: 15.sp,
                                          fontWeight: FontWeight.bold,
                                          fontStyle: FontStyle.normal,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),

                                SizedBox(height: 6.h),

                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(18.0.r),
                                    ),
                                  ),
                                  child: Row(
                                    children: <Widget>[
                                      Expanded(
                                        child: ListTile(
                                          title: Text(
                                            'TRANSFER',
                                            style: TextStyle(
                                              fontSize: 12.sp,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          tileColor: Colors.white,

                                          leading: Radio<BestPrice>(
                                            activeColor: Color.fromRGBO(
                                              21,
                                              42,
                                              72,
                                              1,
                                            ),
                                            value: BestPrice.transfer,
                                            groupValue: _pricegl,
                                            onChanged: (BestPrice? value) {
                                              if (value == null) return;

                                              setState(() {
                                                _pricegl = value;
                                                _priceCheck = "transfer";
                                              });
                                            },
                                          ),
                                        ),
                                      ),

                                      Expanded(
                                        child: ListTile(
                                          title: Text(
                                            'CASH',
                                            style: TextStyle(
                                              fontSize: 12.sp,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          tileColor: Colors.white,

                                          leading: Radio<BestPrice>(
                                            activeColor: Color.fromRGBO(
                                              21,
                                              42,
                                              72,
                                              1,
                                            ),
                                            value: BestPrice.cash,
                                            groupValue: _pricegl,
                                            onChanged: (BestPrice? value) {
                                              if (value == null) return;

                                              setState(() {
                                                _pricegl = value;
                                                _priceCheck = "cash";
                                              });
                                            },
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                SizedBox(height: 6.h),

                                Row(
                                  children: <Widget>[
                                    Expanded(
                                      child: Text(
                                        'Enter package price value ',
                                        style: TextStyle(
                                          fontSize: 15.sp,
                                          fontWeight: FontWeight.bold,
                                          fontStyle: FontStyle.normal,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),

                                SizedBox(height: 6.h),

                                Row(
                                  children: <Widget>[
                                    Expanded(
                                      child: TextFormField(
                                        controller: price,
                                        validator: validprice,

                                        keyboardType: TextInputType.number,

                                        scrollPadding: EdgeInsets.only(
                                          top: 1.h,
                                        ),

                                        style: TextStyle(
                                          fontSize: 15.sp,
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        maxLength: 30,
                                        onEditingComplete: () {},
                                        onFieldSubmitted: (_) {},
                                        onChanged: (_) {},
                                        onTap: () {},

                                        decoration: InputDecoration(
                                          contentPadding: EdgeInsets.only(
                                            top: 2.h,
                                            bottom: 2.h,
                                          ),
                                          hintText: " PACKADE PRICE",
                                          hintStyle: TextStyle(
                                            fontSize: 15.sp,
                                            color: Colors.black,
                                            fontWeight: FontWeight.bold,
                                          ),

                                          fillColor: Colors.white,
                                          filled: true,
                                          prefixIcon: Padding(
                                            padding: EdgeInsets.only(left: 5.w),
                                            child: Icon(
                                              Icons.money,
                                              size: 30.sp,
                                              color: Colors.blue,
                                            ),
                                          ),
                                          prefixStyle: TextStyle(
                                            fontSize: 50.sp,
                                            color: Colors.red,
                                          ),
                                          labelText: "PACKADE PRICE",
                                          labelStyle: TextStyle(
                                            fontSize: 15.sp,
                                            color: Colors.black,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              20,
                                            ),
                                            borderSide: BorderSide(
                                              color: Colors.black,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 5.h),

                                Row(
                                  children: <Widget>[
                                    SizedBox(width: 10.w),

                                    Expanded(
                                      child: ElevatedButton.icon(
                                        onPressed: () async {
                                          if (isConfirm) {
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              SnackBar(
                                                backgroundColor:
                                                    Colors.redAccent,
                                                content: Text(
                                                  'Please wait to Response your order have sended ...',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 18.sp,
                                                  ),
                                                ),
                                              ),
                                            );
                                            return;
                                          }

                                          double distance =
                                              double.tryParse(
                                                this.distance ?? '',
                                              ) ??
                                              0.0;
                                          double cost = 0.0;

                                          SharedPreferences preferences =
                                              await SharedPreferences.getInstance();

                                          token = preferences.getString(
                                            "token",
                                          );
                                          id = preferences.getString("id");

                                          try {
                                            String url =
                                                "https://www.ordervite.com/api/supplier/finance";

                                            var response = await http.get(
                                              Uri.parse(url),
                                              headers: {
                                                'Content-Type':
                                                    'application/json',
                                                'Accept': 'application/json',
                                                'Authorization':
                                                    'Bearer $token',
                                              },
                                            );

                                            var body = jsonDecode(
                                              response.body,
                                            );

                                            if (body["data"] != null) {
                                              double PPKS =
                                                  double.tryParse(
                                                    body["data"]["PPKS"]
                                                        .toString(),
                                                  ) ??
                                                  0;
                                              double PPKM =
                                                  double.tryParse(
                                                    body["data"]["PPKM"]
                                                        .toString(),
                                                  ) ??
                                                  0;
                                              double PPKL =
                                                  double.tryParse(
                                                    body["data"]["PPKL"]
                                                        .toString(),
                                                  ) ??
                                                  0;
                                              double minCharge =
                                                  double.tryParse(
                                                    body["data"]["min_charge"]
                                                        .toString(),
                                                  ) ??
                                                  0;
                                              double cashCC =
                                                  double.tryParse(
                                                    body["data"]["cash_cc"]
                                                        .toString(),
                                                  ) ??
                                                  1;

                                              switch (_size) {
                                                case "small":
                                                  cost = distance * PPKS;
                                                  break;
                                                case "medium":
                                                  cost = distance * PPKM;
                                                  break;
                                                case "large":
                                                  cost = distance * PPKL;
                                                  break;
                                                default:
                                                  cost = 0.0;
                                              }

                                              if (cost < minCharge) {
                                                cost = minCharge;
                                              }

                                              if (_priceCheck == "cash") {
                                                cost *= cashCC;
                                              }

                                              setState(() {
                                                this.cost = cost
                                                    .toStringAsFixed(2);
                                              });
                                            }
                                          } catch (e) {}

                                          if (price.text.isNotEmpty) {
                                            try {
                                              String url =
                                                  "https://www.ordervite.com/api/supplier/orders";

                                              var response = await http.post(
                                                Uri.parse(url),
                                                body: {
                                                  "supplier_id": id.toString(),
                                                  "cost": cost.toString(),
                                                  "size": _size,
                                                  "price": price.text,
                                                  "order_state": "new",
                                                  "pricecheck": _priceCheck,
                                                  "so_longitude": sorlong
                                                      .toString(),
                                                  "so_latitude": sorLat
                                                      .toString(),
                                                  "dist_longitude": disLong
                                                      .toString(),
                                                  "dist_latitude": disLat
                                                      .toString(),
                                                  "distance": distance
                                                      .toString(),
                                                },
                                                headers: {
                                                  'Authorization':
                                                      'Bearer $token',
                                                },
                                              );

                                              var body = jsonDecode(
                                                response.body,
                                              );

                                              setState(() {
                                                isConfirmSupplier = true;
                                                order_id =
                                                    body["data"]["id"]
                                                        ?.toString() ??
                                                    '';
                                                order_state =
                                                    body["data"]["order_state"]
                                                        ?.toString() ??
                                                    '';
                                                order_cost =
                                                    body["data"]["cost"]
                                                        ?.toString() ??
                                                    '';
                                                order_price =
                                                    body["data"]["price"]
                                                        ?.toString() ??
                                                    '';
                                                order_pricecheck =
                                                    body["data"]["pricecheck"]
                                                        ?.toString() ??
                                                    '';
                                              });

                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                SnackBar(
                                                  backgroundColor: Colors.green,
                                                  content: Text(
                                                    'Successfully, please wait for response ...',
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 18.sp,
                                                    ),
                                                  ),
                                                ),
                                              );
                                            } catch (e) {}
                                          } else {
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              SnackBar(
                                                backgroundColor:
                                                    Colors.redAccent,
                                                content: Text(
                                                  'Error must insert all details ...',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 18.sp,
                                                  ),
                                                ),
                                              ),
                                            );
                                          }
                                        },
                                        icon: Icon(Icons.done_all, size: 20.sp),
                                        label: Text(
                                          "Confirm",
                                          style: TextStyle(
                                            fontSize: 12.sp,
                                            color: Colors.white,
                                          ),
                                        ),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.green,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              30.0,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 40.w),

                                    Expanded(
                                      child: ElevatedButton.icon(
                                        onPressed: () async {
                                          setState(() {
                                            isConfirmSupplier = false;
                                          });

                                          Navigator.pushNamed(
                                            context,
                                            RoutesManager.search,
                                            arguments: Message(
                                              "You have canceled",
                                            ),
                                          );
                                        },
                                        icon: Icon(Icons.cancel, size: 20.sp),
                                        label: Text(
                                          "Cancel",
                                          style: TextStyle(
                                            fontSize: 12.sp,
                                            color: Colors.white,
                                          ),
                                        ),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.red,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              30.0,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      )
                    : Container(
                        height: 300.h,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topRight,
                            end: Alignment.topLeft,
                            colors: [
                              Color.fromRGBO(21, 42, 72, 1),
                              Color.fromRGBO(7, 15, 33, 1),
                            ],
                          ),

                          color: Color.fromRGBO(7, 15, 33, 0.9),
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(18.0.r),
                            topRight: Radius.circular(18.0.r),
                          ),
                        ),

                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 24.w,
                            vertical: 18.h,
                          ),
                          child: SingleChildScrollView(
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(18.0.r),
                                  topRight: Radius.circular(18.0.r),
                                ),
                              ),
                              child: Padding(
                                padding: EdgeInsets.all(20.0.r),

                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Column(
                                      children: <Widget>[
                                        Row(
                                          children: <Widget>[
                                            Expanded(
                                              child: Text(
                                                "Order data id : $order_id  ",
                                                style: TextStyle(
                                                  fontSize: 20.sp,
                                                  fontWeight: FontWeight.bold,
                                                  fontStyle: FontStyle.normal,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),

                                        SizedBox(height: 30.h),

                                        Row(
                                          children: <Widget>[
                                            Expanded(
                                              child: Text(
                                                "order id:   $order_id ",
                                                style: TextStyle(
                                                  fontSize: 15.sp,
                                                  fontWeight: FontWeight.bold,
                                                  fontStyle: FontStyle.normal,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),

                                            SizedBox(width: 20.w),

                                            Expanded(
                                              child: Text(
                                                "order cost:   $order_cost ",
                                                style: TextStyle(
                                                  fontSize: 15.sp,
                                                  fontWeight: FontWeight.bold,
                                                  fontStyle: FontStyle.normal,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 20.h),
                                        Row(
                                          children: <Widget>[
                                            Expanded(
                                              child: Text(
                                                "order price:   $order_price ",
                                                style: TextStyle(
                                                  fontSize: 15.sp,
                                                  fontWeight: FontWeight.bold,
                                                  fontStyle: FontStyle.normal,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),

                                            SizedBox(width: 20.w),

                                            Expanded(
                                              child: Text(
                                                "order Shipper Id:   $order_shippier_id ",
                                                style: TextStyle(
                                                  fontSize: 15.sp,
                                                  fontWeight: FontWeight.bold,
                                                  fontStyle: FontStyle.normal,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),

                                        SizedBox(height: 20.h),

                                        Row(
                                          children: <Widget>[
                                            Expanded(
                                              child: Text(
                                                "order price state:   $order_state",
                                                style: TextStyle(
                                                  fontSize: 15.sp,
                                                  fontWeight: FontWeight.bold,
                                                  fontStyle: FontStyle.normal,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),

                                        SizedBox(height: 20.h),

                                        Row(
                                          children: <Widget>[
                                            Expanded(
                                              child: Text(
                                                "order price check:   $order_pricecheck ",
                                                style: TextStyle(
                                                  fontSize: 15.sp,
                                                  fontWeight: FontWeight.bold,
                                                  fontStyle: FontStyle.normal,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),

                                    SizedBox(height: 30.h),

                                    Expanded(
                                      child: ElevatedButton.icon(
                                        onPressed: () async {
                                          try {
                                            if (order_id != null) {
                                              if (isConfirmOrder) {
                                                int id = int.parse(
                                                  order_id ?? '',
                                                );

                                                String url =
                                                    "https://www.ordervite.com/api/supplier/order_update/$id";

                                                await http.put(
                                                  Uri.parse(url),
                                                  body: {
                                                    "order_state":
                                                        "order complete",
                                                  },
                                                  headers: {
                                                    'Authorization':
                                                        'Bearer $token',
                                                  },
                                                );

                                                setState(() {
                                                  isComplete = true;
                                                });

                                                Navigator.pushNamed(
                                                  context,
                                                  RoutesManager.search,
                                                  arguments: Message(
                                                    "Your order have complete",
                                                  ),
                                                );
                                              } else {
                                                ScaffoldMessenger.of(
                                                  context,
                                                ).showSnackBar(
                                                  SnackBar(
                                                    backgroundColor:
                                                        Colors.redAccent,
                                                    content: Text(
                                                      'Your order have not be complete please wait ...',
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 18.sp,
                                                      ),
                                                    ),
                                                  ),
                                                );
                                              }
                                            }
                                          } catch (e) {}
                                        },
                                        icon: Icon(Icons.done_all, size: 20.sp),
                                        label: Text(
                                          "Complete",
                                          style: TextStyle(
                                            fontSize: 12.sp,
                                            color: Colors.white,
                                          ),
                                        ),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.green,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              30.0,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
              ),
            ],
          ),
        ),
        onWillPop: () async {
          if (isComplete) return true;

          await showDialog(
            context: context,
            builder: (c) => AlertDialog(
              title: Text('Warning', style: TextStyle(color: Colors.red)),
              content: Text(
                'Please you can’t exit until order complete',
                style: TextStyle(fontSize: 15.sp, color: Colors.red),
              ),
              actions: [
                TextButton(
                  child: Text('OK'),
                  onPressed: () => Navigator.pop(c),
                ),
              ],
            ),
          );

          return false;
        },
      );
    } else {
      return SizedBox.shrink();
    }
  }

  Future<dynamic> _getPoliLine() {
    final JsonDecoder _decoder = JsonDecoder();

    final uri = Uri.parse(
      '$_mapsBaseUrl?origin=${sourceLatLong.latitude},${sourceLatLong.longitude}'
      '&destination=${destinationLatLong.latitude},${destinationLatLong.longitude}'
      '&key=$_googleApiKey',
    );

    return http.get(uri).then((http.Response response) {
      String res = response.body;
      int statusCode = response.statusCode;
      if (statusCode < 200 || statusCode > 400) {
        res =
            "{\"status\":" +
            statusCode.toString() +
            ",\"message\":\"error\",\"response\":" +
            res +
            "}";
        throw new Exception(res);
      }

      try {
        String _distance = _decoder
            .convert(res)["routes"][0]["legs"][0]["distance"]['text']
            .toString();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.redAccent,
            content: Text(
              'Distance: $_distance',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.sp),
            ),
          ),
        );
      } catch (e) {
        throw new Exception(res);
      }

      List<Steps> steps;
      try {
        steps = parseSteps(
          _decoder.convert(res)["routes"][0]["legs"][0]["steps"],
        );

        List<LatLng> _listOfLatLongs = [];

        for (final i in steps) {
          _listOfLatLongs.add(i.startLocation!);
          _listOfLatLongs.add(i.endLocation!);
        }

        Future.delayed(Duration(seconds: 1), () {
          setState(() {
            _polyline.add(
              Polyline(
                polylineId: PolylineId("2"),
                visible: true,
                width: 8,
                points: _listOfLatLongs,
                color: Colors.blue,
              ),
            );
          });
        });
      } catch (e) {
        throw new Exception(res);
      }

      return steps;
    });
  }

  List<Steps> parseSteps(final responseBody) {
    var list = responseBody
        .map<Steps>((json) => new Steps.fromJson(json))
        .toList();
    return list;
  }
}

class Steps {
  LatLng? startLocation;
  LatLng? endLocation;

  Steps({this.startLocation, this.endLocation});

  factory Steps.fromJson(Map<String, dynamic> json) {
    return new Steps(
      startLocation: new LatLng(
        json["start_location"]["lat"],
        json["start_location"]["lng"],
      ),
      endLocation: new LatLng(
        json["end_location"]["lat"],
        json["end_location"]["lng"],
      ),
    );
  }
}
