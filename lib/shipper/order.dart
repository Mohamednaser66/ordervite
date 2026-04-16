import 'dart:async';
import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_maps/Core/routes_manager.dart';
import 'package:flutter_maps/classes.dart';
import 'package:flutter_maps/lang.dart';
import 'package:flutter_maps/shipper/models/steps.dart';
import 'package:flutter_maps/shipper/widgets/chat_named_icon.dart';
import 'package:flutter_maps/shipper/widgets/sh_order_states_widget.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:location/location.dart';
import 'package:rate_my_app/rate_my_app.dart';

String GoogleApiKEY = "AIzaSyDl8LFLQn24CbaZyQ0F4wnzoF9NY3_gMWY";

class ShOrder extends StatefulWidget {
  ShOrder({Key? key}) : super(key: key);

  final String title = "OrderVite";

  @override
  _ShOrderState createState() => _ShOrderState();
}

enum BestSize { small, medium, large }

enum BestPrice { transfer, cash }

class _ShOrderState extends State<ShOrder> {
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
  String? username;
  String? email;
  String? id;
  String? token;
  String? disLat;
  String? sorLat;
  String? disLong;
  String? sorlong;
  String? order_id;
  LatLng? lastUpdatedLocation;
  String? order_cost;
  String? order_size;
  String? order_pricecheck;
  String? order_supplier_id;
  String? order_price;
  String? order_state;

   Timer? timer;

  String? statename;
  String? api_token;
  StreamController _orderController = StreamController();
  bool isConfirm = false;

  bool isReceived = false;
  bool isDelviered = false;
  bool isComplete = false;
  bool isCnacel = false;

  bool isSignIn = false;

  int order_messges_count = 0;
  GlobalKey<FormState> formstatesorder = new GlobalKey<FormState>();

   TextEditingController? size;

   TextEditingController? price;

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  late BuildContext mainContext;

  late Map<String, dynamic> formData;

  getPref() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    OrderData orderData =
        ModalRoute.of(context)?.settings.arguments as OrderData;

    username = preferences.getString("username");
    email = preferences.getString("email");

    if (username != null && email != null) {
      setState(() {
        username = preferences.getString("username");
        email = preferences.getString("email");
        token = preferences.getString("token");
        id = preferences.getString("id");
        isSignIn = true;
      });
    }

    print(orderData.disLat);
    print(orderData.disLong);
    print(orderData.sorLat);
    print(orderData.sorlong);

    setState(() {
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

      _initialCamera = CameraPosition(
        target: LatLng(double.parse(sorLat!), double.parse(sorlong!)),
        zoom: 14.0000,
      );

      sourceLatLong = LatLng(double.parse(sorLat!), double.parse(sorlong!));
      destinationLatLong = LatLng(
        double.parse(disLat!),
        double.parse(disLong!),
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

  void listenToLocationChanges() async {
    Location location = Location();
    bool _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) return;
    }

    PermissionStatus _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) return;
    }

    location.onLocationChanged.listen((LocationData currentLocation) {});
    location.onLocationChanged.listen((LocationData currentLocation) {
      LatLng currentLatLng = LatLng(
        currentLocation.latitude!,
        currentLocation.longitude!,
      );

      if (lastUpdatedLocation == null ||
          _getDistance(lastUpdatedLocation!, currentLatLng) > 50) {
        setState(() {
          sourceLatLong = currentLatLng;
          lastUpdatedLocation = currentLatLng;
        });

        _getPoliLine();
        _updateCamera(currentLatLng, currentLocation.heading ?? 0.0);
      }
    });
  }

  Future<void> _updateCamera(LatLng currentLatLng, double heading) async {
    final GoogleMapController controller = await _mapController.future;

    controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: currentLatLng,
          zoom: 16.0,
          tilt: 45.0,
          bearing: heading,
        ),
      ),
    );
  }

  double _getDistance(LatLng start, LatLng end) {
    return Geolocator.distanceBetween(
      start.latitude,
      start.longitude,
      end.latitude,
      end.longitude,
    );
  }

  changeMainContext(BuildContext context) {
    mainContext = context;
  }

  Future getcurrentOrder() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();

    token = preferences.getString("token");
    id = preferences.getString("id");

    try {
      if (id != null) {
        int id = int.parse(this.id!, radix: 10);
        String Url = "https://www.ordervite.com/api/shippier/current_order/$id";

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
            int sub_id = int.parse(
              reposnsebody["data"]["supplier_id"].toString(),
              radix: 10,
            );

            String Url2 =
                "https://www.ordervite.com/api/shippier/supplier/$sub_id";

            var response2 = await http.get(
              Uri.parse(Url2),
              headers: {
                'Content-Type': 'application/json',
                'Accept': 'application/json',

                'Authorization': 'Bearer ' + this.token!,
              },
            );

            var reposnsebody2 = jsonDecode(response2.body);

            setState(() {
              this.api_token = reposnsebody2["data"]["name"]["api_token"]
                  .toString();
            });
            if (reposnsebody["data"]["order_cancel"] != null) {
              Message message = new Message("Order is Canceled by supplier");

              Navigator.pushNamedAndRemoveUntil(
                context,
                RoutesManager.shHome,
                (route) => false,
                arguments: message,
              );
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
              Message message = new Message("Order is complete");

              Navigator.pushNamedAndRemoveUntil(
                context,
                RoutesManager.shHome,
                (route) => false,
                arguments: message,
              );
            }
          }
        }

        return reposnsebody["data"];
      } else {
        return null;
      }
    } catch (e) {}
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
    size?.dispose();
    price?.dispose();
    _orderController.close();
    super.dispose();
  }
@override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    getPref();

}
  void initState() {

    loadcurrentOrder();
    listenToLocationChanges();
    super.initState();
    size = TextEditingController();
    price = TextEditingController();

    _firebaseMessaging.getToken().then((token) async {
      String Url =
          "https://www.ordervite.com/api/shippier/complete_profile/$id";

      await http.put(
        Uri.parse(Url),
        body: {"api_token": token.toString()},

        headers: {'Authorization': 'Bearer ${this.token}',},
      );

      if (this.order_id != null) {
        int con_id = int.parse(this.order_id.toString(), radix: 10);

        String Url2 =
            "https://www.ordervite.com/api/shippier/order/$con_id/messages/unread/supplier";
        var response2 = await http.get(
          Uri.parse(Url2),

          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': 'Bearer  ' + this.token!,
          },
        );

        var reposnsebody2 = jsonDecode(response2.body);

        setState(() {
          this.order_messges_count =
              reposnsebody2["data"]["order unread messages count"];
        });
      }
    });

    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      setState(() {
        this.statename = message.data["state_name"].toString();
      });

      if (message.data["state_name"].toString() == "new message") {
        int con_id = int.parse(this.order_id.toString(), radix: 10);

        String Url2 =
            "https://www.ordervite.com/api/shippier/order/$con_id/messages/unread/supplier";

        var response2 = await http.get(
          Uri.parse(Url2),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': 'Bearer ${this.token}',
          },
        );

        var reposnsebody2 = jsonDecode(response2.body);

        setState(() {
          this.order_messges_count =
              reposnsebody2["data"]["order unread messages count"];
        });
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async {
      setState(() {
        this.statename = message.data["state_name"].toString();
      });

      if (message.data["state_name"].toString() == "new message") {
        int con_id = int.parse(this.order_id.toString(), radix: 10);

        String Url2 =
            "https://www.ordervite.com/api/shippier/order/$con_id/messages/unread/supplier";

        var response2 = await http.get(
          Uri.parse(Url2),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': 'Bearer  ' + this.token!,
          },
        );

        var reposnsebody2 = jsonDecode(response2.body);

        setState(() {
          this.order_messges_count =
              reposnsebody2["data"]["order unread messages count"];
        });
      }
    });

    FirebaseMessaging.instance.getInitialMessage().then((
      RemoteMessage? message,
    ) async {
      if (message != null) {
        setState(() {
          this.statename = message.data["state_name"].toString();
        });

        if (message.data["state_name"].toString() == "new message") {
          int con_id = int.parse(this.order_id.toString(), radix: 10);

          String Url2 =
              "https://www.ordervite.com/api/shippier/order/$con_id/messages/unread/supplier";

          var response2 = await http.get(
            Uri.parse(Url2),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
              'Authorization': 'Bearer  ' + this.token!,
            },
          );

          var reposnsebody2 = jsonDecode(response2.body);

          setState(() {
            this.order_messges_count =
                reposnsebody2["data"]["order unread messages count"];
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    Lang lang = Lang.of(context);
    if (statename == "order cancel") {
      Message message = new Message(
        lang.lang == "en" ? "Order is cancled by supplier" : "",
      );
      Navigator.pushNamed(context, RoutesManager.shHome, arguments: message);

      setState(() {
        isCnacel = true;
      });
    }
    if (statename == "order complete") {
      Message message = new Message(
        lang.lang == "en" ? "Order is complete" : "تم اكمال الطلب بنجاح",
      );
      Navigator.pushNamed(context, RoutesManager.shHome, arguments: message);

      setState(() {
        isComplete = true;
      });
    }

    return WillPopScope(
      child: Directionality(
        textDirection: lang.lang == "en"
            ? TextDirection.ltr
            : TextDirection.rtl,

        child: Scaffold(
          key: _scaffoldkey,

          appBar: AppBar(
            title: Text(
              lang.lang == "en" ? 'OrderVite' : ' أوردرفيت ',
              style: TextStyle(
                fontSize: 25.sp,
                fontWeight: FontWeight.bold,
                fontStyle: FontStyle.normal,
                color: Colors.white,
              ),
            ),
            actions: <Widget>[
              ChatNamedIcon(
                text: lang.lang == "en" ? 'Chats' : 'محادثات ',
                iconData: Icons.message,
                order_id: this.order_id,
                notificationCount: order_messges_count,
                api_token: this.token,
                disLat: this.disLat.toString(),
                disLong: this.disLong.toString(),
                sorLat: this.sorLat.toString(),
                sorlong: this.sorlong.toString(),
                isConfirm: this.isConfirm,
                order_cost: this.order_cost.toString(),
                order_price: this.order_price.toString(),
                order_pricecheck: this.order_pricecheck.toString(),
                order_state: this.order_state.toString(),
                order_supplier_id: order_supplier_id.toString(),
                order_shippier_id: this.id.toString(),
                permission: this.isConfirm,
              ),
            ],
            automaticallyImplyLeading: false,
          ),
          body: Stack(
            children: <Widget>[
              Positioned(
                child: GoogleMap(
                  mapType: MapType.normal,
                  polylines: _polyline,
                  myLocationEnabled: true,
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
                    padding: REdgeInsets.symmetric(
                      horizontal: 16.0.w,
                      vertical: 12.0.h,
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(18.0.r),
                          topRight: Radius.circular(18.0.r),
                        ),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(8.0.r),
                        child: ShOrderStatesWidget(
                          order_id: order_id,
                          order_supplier_id: order_supplier_id ?? '',
                          order_price: order_price ?? '',
                          order_pricecheck: order_pricecheck ?? '',
                          id: id ?? '',
                          token: token ?? '',
                          order_cost: order_cost ?? '',
                          lang: lang,
                          order_state: order_state ?? '',
                          api_token: api_token ?? '',
                          isConfirm: isConfirm,
                          isReceived: isReceived,
                          isDelviered: isDelviered,
                          username: username,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      onWillPop: () async {
        await showDialog<bool>(
          context: context,
          builder: (c) => AlertDialog(
            title: Text(
              lang.lang == "en" ? 'Warning' : 'تحذير',
              style: TextStyle(color: Colors.red),
            ),
            content: Text(
              lang.lang == "en"
                  ? 'Please you cant exit until order complete'
                  : 'من فضلك تحقق من جودة الانترنت',
              style: TextStyle(fontSize: 15.sp, color: Colors.red),
            ),
          ),
        );

        return Future.value(false);
      },
    );
  }

  Future<dynamic> _getPoliLine() async {
    final String url =
        "https://maps.googleapis.com/maps/api/directions/json?" +
        "origin=${sourceLatLong.latitude},${sourceLatLong.longitude}" +
        "&destination=${destinationLatLong.latitude},${destinationLatLong.longitude}" +
        "&key=$GoogleApiKEY";

    try {
      var response = await http.get(Uri.parse(url));
      var jsonResponse = jsonDecode(response.body);

      if (jsonResponse["status"] == "OK") {
        String _distance =
            jsonResponse["routes"][0]["legs"][0]["distance"]['text'];
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('الـمسافة: $_distance')));
        String encodedPoints =
            jsonResponse["routes"][0]["overview_polyline"]["points"];
        List<LatLng> polylinePoints = _decodePoly(encodedPoints);

        setState(() {
          _polyline.add(
            Polyline(
              polylineId: PolylineId("route_line"),
              visible: true,
              width: 5,
              points: polylinePoints,
              color: Colors.blue,
              startCap: Cap.roundCap,
              endCap: Cap.roundCap,
            ),
          );
        });
      }
    } catch (e) {
      print("Error fetching polyline: $e");
    }
  }

  List<LatLng> _decodePoly(String poly) {
    var list = poly.codeUnits;
    var lList = <double>[];
    int index = 0;
    int len = poly.length;
    int c = 0;
    do {
      var shift = 0;
      int result = 0;
      do {
        c = list[index] - 63;
        result |= (c & 0x1F) << (shift);
        shift += 5;
        index++;
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

    List<LatLng> res = <LatLng>[];
    for (var i = 0; i < lList.length; i += 2) {
      res.add(LatLng(lList[i], lList[i + 1]));
    }
    return res;
  }

  List<Steps> parseSteps(final responseBody) {
    var list = responseBody
        .map<Steps>((json) => new Steps.fromJson(json))
        .toList();
    return list;
  }
}
