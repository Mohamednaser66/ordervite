import 'dart:async';
import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_maps/Core/routes_manager.dart';
import 'package:flutter_maps/classes.dart';
import 'package:flutter_maps/lang.dart';
import 'package:flutter_maps/shipper/models/steps.dart';
import 'package:flutter_maps/shipper/widgets/chat_named_icon.dart';
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

  late Timer timer;

  String? statename;
  String? api_token;
  late StreamController _orderController;

  bool isConfirm = false;

  bool isReceived = false;
  bool isDelviered = false;
  bool isComplete = false;
  bool isCnacel = false;

  bool isSignIn = false;

  int order_messges_count = 0;
  GlobalKey<FormState> formstatesorder = new GlobalKey<FormState>();

late  TextEditingController size ;
late  TextEditingController price ;
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
  void listenToLocationChanges()async {
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

    location.onLocationChanged.listen((LocationData currentLocation) {

    });
    location.onLocationChanged.listen((LocationData currentLocation) {
      LatLng currentLatLng = LatLng(currentLocation.latitude!, currentLocation.longitude!);


      if (lastUpdatedLocation == null || _getDistance(lastUpdatedLocation!, currentLatLng) > 50) {

        setState(() {
          sourceLatLong = currentLatLng;
          lastUpdatedLocation = currentLatLng;
        });

        _getPoliLine();
        _updateCamera(currentLatLng,currentLocation.heading ?? 0.0);
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
        start.latitude, start.longitude,
        end.latitude, end.longitude
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
              //  print("delevierd");
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
    } catch (e) {
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
    timer.cancel();
    size.dispose();
    price.dispose();
    _orderController.close();
    super.dispose();
  }

  void initState() {
    getPref();

    loadcurrentOrder();
    listenToLocationChanges();
    super.initState();
    size =  TextEditingController();
 price =  TextEditingController();

    _firebaseMessaging.getToken().then((token) async {
      String Url =
          "https://www.ordervite.com/api/shippier/complete_profile/$id";

      await http.put(
        Uri.parse(Url),
        body: {"api_token": token.toString()},

        headers: {'Authorization': 'Bearer  ' + this.token!},
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
                fontSize: 25,
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
                api_token: this.api_token,
                disLat: this.disLat.toString(),
                disLong: this.disLong.toString(),
                sorLat: this.sorLat.toString(),
                sorlong: this.sorlong.toString(),
                isConfirm: true,
                order_cost: this.order_cost.toString(),
                order_price: this.order_price.toString(),
                order_pricecheck: this.order_pricecheck.toString(),
                order_state: this.order_state.toString(),
                order_supplier_id: order_supplier_id.toString(),
                order_shippier_id: this.id.toString(),
                permission: this.isConfirm,
                onTap: () {},
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
                left: 0.0,
                right: 0.0,
                bottom: 0.0,
                child: Container(
                  height: 300.0,
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
                      topLeft: Radius.circular(18.0),
                      topRight: Radius.circular(18.0),
                    ),
                  ),

                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24.0,
                      vertical: 18.0,
                    ),
                    child: SingleChildScrollView(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(18.0),
                            topRight: Radius.circular(18.0),
                          ),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(15.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Row(
                                children: <Widget>[
                                  Expanded(
                                    child: Text(
                                      lang.lang == "en"
                                          ? "Order State: $order_state"
                                          : (order_state == "new"
                                                ? "حالة الطلب : جديد"
                                                : (order_state ==
                                                          "shipper confirmed"
                                                      ? "حالة الطلب : تاكيد مسئول الشحن  "
                                                      : (order_state ==
                                                                "order received"
                                                            ? "حالة الطلب :   استلام الشحنة   "
                                                            : (order_state ==
                                                                      "order delivered"
                                                                  ? "حالة الطلب :      اكتمال الطلب    "
                                                                  : "حالة الطلب :   توصيل الشحنة  الشحنة   ")))),
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        fontStyle: FontStyle.normal,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              SizedBox(height: 20),

                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  Expanded(
                                    child: Container(
                                      height: 30.0,
                                      width: 20.0,

                                      decoration: new BoxDecoration(
                                        borderRadius: new BorderRadius.circular(
                                          50.0,
                                        ),
                                        color: Color(0xFF18D191),
                                        image: DecorationImage(
                                          image: AssetImage(
                                            'assets/icons_New order.png',
                                          ),
                                          fit: BoxFit.fill,
                                        ),
                                      ),
                                    ),
                                  ),

                                  SizedBox(width: 5),
                                  Expanded(
                                    child: Container(
                                      height: 30.0,
                                      width: 20.0,

                                      decoration: new BoxDecoration(
                                        borderRadius: new BorderRadius.circular(
                                          50.0,
                                        ),
                                        color: isConfirm
                                            ? Color(0xFF18D191)
                                            : Color(0xFFFC6A7F),
                                        image: DecorationImage(
                                          image: AssetImage(
                                            'assets/icons_shipper confirm.png',
                                          ),
                                          fit: BoxFit.fill,
                                        ),
                                      ),
                                    ),
                                  ),

                                  SizedBox(width: 5),
                                  Expanded(
                                    child: Container(
                                      height: 30.0,
                                      width: 20.0,
                                      decoration: new BoxDecoration(
                                        borderRadius: new BorderRadius.circular(
                                          50.0,
                                        ),
                                        color: isReceived
                                            ? Color(0xFF18D191)
                                            : Color(0xFFFC6A7F),
                                        image: DecorationImage(
                                          image: AssetImage(
                                            'assets/icons_shipper received.png',
                                          ),
                                          fit: BoxFit.fill,
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 5),
                                  Expanded(
                                    child: Container(
                                      height: 30.0,
                                      width: 20.0,
                                      decoration: new BoxDecoration(
                                        borderRadius: new BorderRadius.circular(
                                          50.0,
                                        ),
                                        color: isDelviered
                                            ? Color(0xFF18D191)
                                            : Color(0xFFFC6A7F),
                                        image: DecorationImage(
                                          image: AssetImage(
                                            'assets/icons_package delivered.png',
                                          ),
                                          fit: BoxFit.fill,
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 5),
                                  Expanded(
                                    child: Container(
                                      height: 30.0,
                                      width: 20.0,
                                      decoration: new BoxDecoration(
                                        borderRadius: new BorderRadius.circular(
                                          50.0,
                                        ),
                                        color: Color(0xFFFC6A7F),
                                        image: DecorationImage(
                                          image: AssetImage(
                                            'assets/icons_order complete.png',
                                          ),
                                          fit: BoxFit.fill,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              SizedBox(height: 15),

                              Row(
                                children: <Widget>[
                                  Expanded(
                                    child: Text(
                                      lang.lang == "en"
                                          ? "Order ID: $order_id"
                                          : "كود الطلب :$order_id",
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        fontStyle: FontStyle.normal,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),

                                  SizedBox(width: 20.0),

                                  Expanded(
                                    child: Text(
                                      lang.lang == "en"
                                          ? "Supplier ID: $order_supplier_id "
                                          : "كود المورد : $order_supplier_id",
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        fontStyle: FontStyle.normal,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              SizedBox(height: 10),
                              Row(
                                children: <Widget>[
                                  Expanded(
                                    child: Text(
                                      lang.lang == "en"
                                          ? "Shipping Cost:"
                                          : "تكلفة الشحن ",
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        fontStyle: FontStyle.normal,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),

                                  SizedBox(width: 20),
                                  Expanded(
                                    child: Text(
                                      lang.lang == "en"
                                          ? "Package Price:"
                                          : "سعر الشحنة ",
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        fontStyle: FontStyle.normal,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 5),

                              Row(
                                children: <Widget>[
                                  Expanded(
                                    child: Text(
                                      lang.lang == "en"
                                          ? "$order_cost L.E."
                                          : "$order_cost جم",
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        fontStyle: FontStyle.normal,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),

                                  SizedBox(width: 20),
                                  Expanded(
                                    child: Text(
                                      lang.lang == "en"
                                          ? "$order_price L.E."
                                          : "$order_price جم",
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        fontStyle: FontStyle.normal,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              SizedBox(height: 20.0),
                              Row(
                                children: <Widget>[
                                  Expanded(
                                    child: Text(
                                      lang.lang == "en"
                                          ? "Payment Method : $order_pricecheck"
                                          : (order_pricecheck == "cash"
                                                ? "نظام الدفع  : كاش"
                                                : "نظام الدفع  : تحويل"),
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        fontStyle: FontStyle.normal,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 10),
                              !isConfirm
                                  ? Row(
                                      children: <Widget>[
                                        SizedBox(width: 10.0),
                                        Expanded(
                                          child: TextButton.icon(
                                            onPressed: () async {
                                              Location _locationTracker =
                                                  Location();
                                              var location =
                                                  await _locationTracker
                                                      .getLocation();
                                              if (isConfirm) {
                                                ScaffoldMessenger.of(
                                                  context,
                                                ).showSnackBar(
                                                  SnackBar(
                                                    backgroundColor:
                                                        Colors.redAccent,
                                                    content: Text(
                                                      lang.lang == "en"
                                                          ? 'Please wait to Response your order have sended  ...'
                                                          : '  الرجاء الانتظار حتى يتم على طلبك الذي أرسلته.  ',
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 18,
                                                      ),
                                                    ),
                                                  ),
                                                );
                                              } else {
                                                try {
                                                  showDialog<bool>(
                                                    context: context,
                                                    builder: (c) => AlertDialog(
                                                      title: Text(
                                                        lang.lang == "en"
                                                            ? 'Confirm'
                                                            : 'تاكيد ',
                                                        style: TextStyle(
                                                          color: Colors.red,
                                                        ),
                                                      ),
                                                      content: Text(
                                                        lang.lang == "en"
                                                            ? 'Are you sure you want to acquire this order?'
                                                            : 'هل أنت متأكد أنك تريد الحصول على هذا الطلب؟ ',
                                                        style: TextStyle(
                                                          fontSize: 15,
                                                          color: Colors.red,
                                                        ),
                                                      ),
                                                      actions: [
                                                        TextButton(
                                                          child: Text(
                                                            lang.lang == "en"
                                                                ? 'Yes'
                                                                : 'نعم',
                                                          ),
                                                          onPressed: () async {
                                                            int id = int.parse(
                                                              this.order_id ??
                                                                  '',
                                                              radix: 10,
                                                            );

                                                            String Url =
                                                                "https://www.ordervite.com/api/shippier/orders/$id";

                                                            var response = await http.put(
                                                              Uri.parse(Url),
                                                              body: {
                                                                "shippier_id": this
                                                                    .id
                                                                    .toString(),
                                                                "sh_longitude":
                                                                    location
                                                                        .longitude
                                                                        .toString(),
                                                                "sh_latitude":
                                                                    location
                                                                        .latitude
                                                                        .toString(),
                                                                "order_state":
                                                                    "shipper confirmed",
                                                              },
                                                              headers: {
                                                                'Authorization':
                                                                    'Bearer  ' +
                                                                    this.token!,
                                                              },
                                                            );

                                                            var reposnsebody =
                                                                jsonDecode(
                                                                  response.body,
                                                                );
                                                            int
                                                            sub_id = int.parse(
                                                              reposnsebody["data"]["supplier_id"]
                                                                  .toString(),
                                                              radix: 10,
                                                            );

                                                            String Url2 =
                                                                "https://www.ordervite.com/api/shippier/supplier/$sub_id";

                                                            var response2 = await http.get(
                                                              Uri.parse(Url2),
                                                              headers: {
                                                                'Content-Type':
                                                                    'application/json',
                                                                'Accept':
                                                                    'application/json',
                                                                'Authorization':
                                                                    'Bearer ' +
                                                                    this.token!,
                                                              },
                                                            );

                                                            var reposnsebody2 =
                                                                jsonDecode(
                                                                  response2
                                                                      .body,
                                                                );

                                                            setState(() {
                                                              this.api_token =
                                                                  reposnsebody2["data"]["name"]["api_token"]
                                                                      .toString();
                                                            });

                                                            setState(() {
                                                              isConfirm = true;
                                                              order_state =
                                                                  reposnsebody["data"]["order_state"]
                                                                      .toString();
                                                            });

                                                            Navigator.of(
                                                              context,
                                                            ).pop();

                                                            if (reposnsebody !=
                                                                null) {
                                                              ScaffoldMessenger.of(
                                                                context,
                                                              ).showSnackBar(
                                                                SnackBar(
                                                                  backgroundColor:
                                                                      Colors
                                                                          .redAccent,
                                                                  content: Text(
                                                                    lang.lang ==
                                                                            "en"
                                                                        ? 'You have acquired this order, please head to the supplier to pick up.  '
                                                                        : 'لقد حصلت على هذا الطلب، يُرجى التوجه إلى المورد لاستلامه.',
                                                                    style: TextStyle(
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                      fontSize:
                                                                          18,
                                                                    ),
                                                                  ),
                                                                ),
                                                              );
                                                            }
                                                          },
                                                        ),
                                                        TextButton(
                                                          child: Text(
                                                            lang.lang == "en"
                                                                ? 'No'
                                                                : 'لا',
                                                          ),
                                                          onPressed: () =>
                                                              Navigator.of(
                                                                context,
                                                              ).pop(),
                                                        ),
                                                      ],
                                                    ),
                                                  );
                                                } catch (e) {
                                                  showDialog<bool>(
                                                    context: context,
                                                    builder: (c) => AlertDialog(
                                                      title: Text(
                                                        lang.lang == "en"
                                                            ? 'Warning'
                                                            : 'تحذير',
                                                        style: TextStyle(
                                                          color: Colors.red,
                                                        ),
                                                      ),
                                                      content: Text(
                                                        lang.lang == "en"
                                                            ? 'Please check your network  '
                                                            : '  يرجي التحقق من اتصال الشبكة الخاص بك   ',
                                                        style: TextStyle(
                                                          fontSize: 15,
                                                          color: Colors.red,
                                                        ),
                                                      ),
                                                      actions: [],
                                                    ),
                                                  );
                                                }
                                              }
                                            },
                                            icon: Icon(
                                              Icons.done_all,
                                              size: 20,
                                            ),
                                            label: Text(
                                              lang.lang == "en"
                                                  ? "Confirm"
                                                  : "تاكيد",
                                              style: TextStyle(
                                                fontSize: 12.0,
                                                color: Colors.white,
                                              ),
                                            ),
                                            style: TextButton.styleFrom(
                                              backgroundColor: Colors.green,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12.0),
                                              ),
                                            ),
                                          ),
                                        ),

                                        SizedBox(width: 15.0),
                                        Expanded(
                                          child: ElevatedButton.icon(
                                            onPressed: () async {
                                              setState(() {
                                                isConfirm = false;
                                              });
                                              showDialog<bool>(
                                                context: context,
                                                builder: (c) => AlertDialog(
                                                  title: Text(
                                                    lang.lang == "en"
                                                        ? 'Confirm'
                                                        : 'تاكيد',
                                                    style: TextStyle(
                                                      color: Colors.red,
                                                    ),
                                                  ),
                                                  content: Text(
                                                    lang.lang == "en"
                                                        ? 'Are you sure you want to cancel the order (a fine may apply) '
                                                        : 'هل أنت متأكد أنك تريد إلغاء الطلب (قد يتم تطبيق غرامة)؟ ',
                                                    style: TextStyle(
                                                      fontSize: 15,
                                                      color: Colors.red,
                                                    ),
                                                  ),
                                                  actions: [
                                                    TextButton(
                                                      child: Text(
                                                        lang.lang == "en"
                                                            ? 'Yes'
                                                            : 'نعم',
                                                      ),
                                                      onPressed: () {
                                                        Message
                                                        message = Message(
                                                          lang.lang == "en"
                                                              ? "Order is Canceled"
                                                              : "تم اإلغاء الطلب ",
                                                        );
                                                        Navigator.pushNamedAndRemoveUntil(
                                                          context,
                                                          RoutesManager.shHome,
                                                          (route) => false,
                                                          arguments: message,
                                                        );
                                                      },
                                                    ),
                                                    TextButton(
                                                      child: Text(
                                                        lang.lang == "en"
                                                            ? 'No'
                                                            : 'لا',
                                                      ),
                                                      onPressed: () =>
                                                          Navigator.of(
                                                            context,
                                                          ).pop(),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            },
                                            icon: Icon(Icons.cancel, size: 20),
                                            label: Text(
                                              lang.lang == "en"
                                                  ? "Cancel"
                                                  : "إلغاء",
                                              style: TextStyle(
                                                fontSize: 12.0,
                                                color: Colors.white,
                                              ),
                                            ),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.red,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12.0),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    )
                                  : !isReceived
                                  ? Row(
                                      children: <Widget>[
                                        SizedBox(width: 10.0),

                                        Expanded(
                                          child: TextButton.icon(
                                            onPressed: () async {
                                              if (isReceived) {
                                                ScaffoldMessenger.of(
                                                  context,
                                                ).showSnackBar(
                                                  SnackBar(
                                                    backgroundColor:
                                                        Colors.redAccent,
                                                    content: Text(
                                                      lang.lang == "en"
                                                          ? 'error order not recevied until yet  ...'
                                                          : ' هناك خطأ، لم يتم استقبال طلبك حتى الآن ',
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 18,
                                                      ),
                                                    ),
                                                  ),
                                                );
                                              } else {
                                                try {
                                                  showDialog<bool>(
                                                    context: context,
                                                    builder: (c) => AlertDialog(
                                                      title: Text(
                                                        lang.lang == "en"
                                                            ? 'Confirm'
                                                            : 'تاكيد',
                                                        style: TextStyle(
                                                          color: Colors.red,
                                                        ),
                                                      ),
                                                      content: Text(
                                                        lang.lang == "en"
                                                            ? 'Please confirm that you have received the package'
                                                            : '     ُرجى تأكيد أنك استلمت الطرد ',
                                                        style: TextStyle(
                                                          fontSize: 15,
                                                          color: Colors.red,
                                                        ),
                                                      ),
                                                      actions: [
                                                        TextButton(
                                                          child: Text(
                                                            lang.lang == "en"
                                                                ? 'Yes'
                                                                : 'نعم',
                                                          ),
                                                          onPressed: () async {
                                                            int id = int.parse(
                                                              this.order_id!,
                                                              radix: 10,
                                                            );
                                                            String Url =
                                                                "https://www.ordervite.com/api/shippier/order_update/$id";
                                                            var response = await http.put(
                                                              Uri.parse(Url),
                                                              body: {
                                                                "order_state":
                                                                    "order received",
                                                              },
                                                              headers: {
                                                                'Authorization':
                                                                    'Bearer  ' +
                                                                    this.token!,
                                                              },
                                                            );

                                                            var reposnsebody =
                                                                jsonDecode(
                                                                  response.body,
                                                                );
                                                            setState(() {
                                                              isReceived = true;
                                                              order_state =
                                                                  reposnsebody["data"]["order_state"]
                                                                      .toString();
                                                            });
                                                            Navigator.of(
                                                              context,
                                                            ).pop();
                                                            if (reposnsebody !=
                                                                null) {
                                                              ScaffoldMessenger.of(
                                                                context,
                                                              ).showSnackBar(
                                                                SnackBar(
                                                                  backgroundColor:
                                                                      Colors
                                                                          .redAccent,
                                                                  content: Text(
                                                                    lang.lang ==
                                                                            "en"
                                                                        ? 'You have confirmed receiving the package, Now head to the destination.  '
                                                                        : 'لقد أكدت استلام الطرد ، توجه الآن إلى الوجهة.    ',
                                                                    style: TextStyle(
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                      fontSize:
                                                                          18,
                                                                    ),
                                                                  ),
                                                                ),
                                                              );
                                                            }
                                                          },
                                                        ),
                                                        TextButton(
                                                          child: Text(
                                                            lang.lang == "en"
                                                                ? 'No'
                                                                : 'لا ',
                                                          ),
                                                          onPressed: () =>
                                                              Navigator.of(
                                                                context,
                                                              ).pop(),
                                                        ),
                                                      ],
                                                    ),
                                                  );
                                                } catch (e) {
                                                  showDialog<bool>(
                                                    context: context,
                                                    builder: (c) => AlertDialog(
                                                      title: Text(
                                                        lang.lang == "en"
                                                            ? 'Warning'
                                                            : 'تحذير',
                                                        style: TextStyle(
                                                          color: Colors.red,
                                                        ),
                                                      ),
                                                      content: Text(
                                                        lang.lang == "en"
                                                            ? 'Please check your network  '
                                                            : '  يرجي التحقق من اتصال الشبكة الخاص بك   ',
                                                        style: TextStyle(
                                                          fontSize: 15,
                                                          color: Colors.red,
                                                        ),
                                                      ),
                                                      actions: [],
                                                    ),
                                                  );
                                                }
                                              }
                                            },
                                            icon: Icon(
                                              Icons.done_all,
                                              size: 20,
                                            ),
                                            label: Text(
                                              lang.lang == "en"
                                                  ? "Received PK "
                                                  : "استلام ",
                                              style: TextStyle(
                                                fontSize: 12.0,
                                                color: Colors.white,
                                              ),
                                            ),
                                            style: TextButton.styleFrom(
                                              backgroundColor: Colors.green,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12.0),
                                              ),
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: 15.0),
                                        Expanded(
                                          child: ElevatedButton.icon(
                                            onPressed: () async {
                                              setState(() {
                                                isConfirm = false;
                                              });
                                              showDialog<bool>(
                                                context: context,
                                                builder: (c) => AlertDialog(
                                                  title: Text(
                                                    lang.lang == "en"
                                                        ? 'Confirm'
                                                        : 'تاكيد',
                                                    style: TextStyle(
                                                      color: Colors.red,
                                                    ),
                                                  ),
                                                  content: Text(
                                                    lang.lang == "en"
                                                        ? 'Are you sure you want to cancel the order (a fine may apply) '
                                                        : ' هل أنت متأكد أنك تريد إلغاء الطلب (قد يتم تطبيق غرامة)؟    ',
                                                    style: TextStyle(
                                                      fontSize: 15,
                                                      color: Colors.red,
                                                    ),
                                                  ),
                                                  actions: [
                                                    TextButton(
                                                      child: Text(
                                                        lang.lang == "en"
                                                            ? 'Yes'
                                                            : 'نعم ',
                                                      ),
                                                      onPressed: () async {
                                                        try {
                                                          if (this.order_id !=
                                                              null) {
                                                            String name =
                                                                this.id! +
                                                                ' ' +
                                                                '  shipper  ' +
                                                                this.username!;

                                                            int id = int.parse(
                                                              this.order_id!,
                                                              radix: 10,
                                                            );
                                                            String Url =
                                                                "https://www.ordervite.com/api/shippier/order_update/$id";
                                                            var response = await http.put(
                                                              Uri.parse(Url),
                                                              body: {
                                                                "order_cancel":
                                                                    "$name cancel order",
                                                              },
                                                              headers: {
                                                                'Authorization':
                                                                    'Bearer  ' +
                                                                    this.token!,
                                                              },
                                                            );
                                                            var reposnsebody =
                                                                jsonDecode(
                                                                  response.body,
                                                                );
                                                            String text =
                                                                lang.lang ==
                                                                    "en"
                                                                ? "your order is canceled by shipper"
                                                                : "تم  الغاء الطلب بواسطة مسئول الشحن  ";
                                                            String
                                                            supplier_api_token =
                                                                this.api_token
                                                                    .toString();
                                                            String Url3 =
                                                                "https://www.ordervite.com/api/notify/page/ordervite/$text/$supplier_api_token/1/ordervite/shipper/order cancel";
                                                            await http.get(
                                                              Uri.parse(Url3),
                                                              headers: {
                                                                'Content-Type':
                                                                    'application/json',
                                                                'Accept':
                                                                    'application/json',
                                                                'Authorization':
                                                                    'Bearer  ' +
                                                                    this.token!,
                                                              },
                                                            );
                                                            Navigator.of(
                                                              context,
                                                            ).pop();
                                                            if (reposnsebody !=
                                                                null) {
                                                              ScaffoldMessenger.of(
                                                                context,
                                                              ).showSnackBar(
                                                                SnackBar(
                                                                  backgroundColor:
                                                                      Colors
                                                                          .redAccent,
                                                                  content: Text(
                                                                    lang.lang ==
                                                                            "en"
                                                                        ? 'Order have canceled ...'
                                                                        : 'تم الغاء الطلب ',
                                                                    style: TextStyle(
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                      fontSize:
                                                                          18,
                                                                    ),
                                                                  ),
                                                                ),
                                                              );
                                                            }

                                                            Message
                                                            message = Message(
                                                              lang.lang == "en"
                                                                  ? "you  have canceld order"
                                                                  : "لقد قمت بالغاء الطلب ",
                                                            );

                                                            Navigator.pushNamedAndRemoveUntil(
                                                              context,
                                                              RoutesManager.shHome,
                                                              (route) => false,
                                                              arguments:
                                                                  message,
                                                            );
                                                          }
                                                        } catch (e) {
                                                          showDialog<bool>(
                                                            context: context,
                                                            builder: (c) => AlertDialog(
                                                              title: Text(
                                                                lang.lang ==
                                                                        "en"
                                                                    ? 'Warning'
                                                                    : 'تحذير',
                                                                style: TextStyle(
                                                                  color: Colors
                                                                      .red,
                                                                ),
                                                              ),
                                                              content: Text(
                                                                lang.lang ==
                                                                        "en"
                                                                    ? 'Please check your network  '
                                                                    : '  يرجي التحقق من اتصال الشبكة الخاص بك   ',
                                                                style: TextStyle(
                                                                  fontSize: 15,
                                                                  color: Colors
                                                                      .red,
                                                                ),
                                                              ),
                                                              actions: [],
                                                            ),
                                                          );
                                                        }
                                                      },
                                                    ),
                                                    TextButton(
                                                      child: Text(
                                                        lang.lang == "en"
                                                            ? 'No'
                                                            : 'لا ',
                                                      ),
                                                      onPressed: () =>
                                                          Navigator.of(
                                                            context,
                                                          ).pop(),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            },
                                            icon: Icon(Icons.cancel, size: 20),
                                            label: Text(
                                              lang.lang == "en"
                                                  ? "Cancel"
                                                  : "الغاء",
                                              style: TextStyle(
                                                fontSize: 12.0,
                                                color: Colors.white,
                                              ),
                                            ),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.red,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12.0),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    )
                                  : !isDelviered
                                  ? Row(
                                      children: <Widget>[
                                        SizedBox(width: 10.0),

                                        Expanded(
                                          child: TextButton.icon(
                                            onPressed: () async {
                                              if (isDelviered) {
                                                ScaffoldMessenger.of(
                                                  context,
                                                ).showSnackBar(
                                                  SnackBar(
                                                    backgroundColor:
                                                        Colors.redAccent,
                                                    content: Text(
                                                      lang.lang == "en"
                                                          ? 'error order not delivered until yet  ...'
                                                          : 'هناك خطأ، لم يتم تسليم طلبك حتى الآن',
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 18,
                                                      ),
                                                    ),
                                                  ),
                                                );
                                              } else {
                                                try {
                                                  showDialog<bool>(
                                                    context: context,
                                                    builder: (c) => AlertDialog(
                                                      title: Text(
                                                        lang.lang == "en"
                                                            ? 'Confirm'
                                                            : 'تاكيد',
                                                        style: TextStyle(
                                                          color: Colors.red,
                                                        ),
                                                      ),
                                                      content: Text(
                                                        lang.lang == "en"
                                                            ? 'Please confirm that you have delivered the package'
                                                            : 'من فضلك قم بتاكيد تسليم الشحنة',
                                                        style: TextStyle(
                                                          fontSize: 15,
                                                          color: Colors.red,
                                                        ),
                                                      ),
                                                      actions: [
                                                        TextButton(
                                                          child: Text(
                                                            lang.lang == "en"
                                                                ? 'Yes'
                                                                : 'نعم',
                                                          ),
                                                          onPressed: () async {
                                                            int id = int.parse(
                                                              this.order_id!,
                                                              radix: 10,
                                                            );

                                                            String Url =
                                                                "https://www.ordervite.com/api/shippier/order_update/$id";

                                                            var response = await http.put(
                                                              Uri.parse(Url),
                                                              body: {
                                                                "order_state":
                                                                    "order delivered",
                                                              },
                                                              headers: {
                                                                'Authorization':
                                                                    'Bearer  ' +
                                                                    this.token!,
                                                              },
                                                            );

                                                            var reposnsebody =
                                                                jsonDecode(
                                                                  response.body,
                                                                );

                                                            String text =
                                                                lang.lang ==
                                                                    "en"
                                                                ? "your order is delveried by shipper"
                                                                : "تم تسليم الشحنة بواسطة مسئول الشحن  ";

                                                            String
                                                            supplier_api_token =
                                                                this.api_token
                                                                    .toString();

                                                            String Url3 =
                                                                "https://www.ordervite.com/api/notify/page/ordervite/$text /$supplier_api_token/1/ordervite/shipper/order delivered";

                                                            await http.get(
                                                              Uri.parse(Url3),
                                                              headers: {
                                                                'Content-Type':
                                                                    'application/json',
                                                                'Accept':
                                                                    'application/json',
                                                                'Authorization':
                                                                    'Bearer  ' +
                                                                    this.token!,
                                                              },
                                                            );

                                                            setState(() {
                                                              isDelviered =
                                                                  true;
                                                              order_state =
                                                                  reposnsebody["data"]["order_state"]
                                                                      .toString();
                                                            });

                                                            Navigator.of(
                                                              context,
                                                            ).pop();

                                                            if (reposnsebody !=
                                                                null) {
                                                              ScaffoldMessenger.of(
                                                                context,
                                                              ).showSnackBar(
                                                                SnackBar(
                                                                  backgroundColor:
                                                                      Colors
                                                                          .redAccent,
                                                                  content: Text(
                                                                    lang.lang ==
                                                                            "en"
                                                                        ? 'Well Done! Now wait for the supplier to confirm the order'
                                                                        : 'أحسنت! الآن انتظر المورد لتأكيد الطلب. ',
                                                                    style: TextStyle(
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                      fontSize:
                                                                          18,
                                                                    ),
                                                                  ),
                                                                ),
                                                              );
                                                            }
                                                          },
                                                        ),
                                                        TextButton(
                                                          child: Text(
                                                            lang.lang == "en"
                                                                ? 'No'
                                                                : 'لا',
                                                          ),
                                                          onPressed: () =>
                                                              Navigator.of(
                                                                context,
                                                              ).pop(),
                                                        ),
                                                      ],
                                                    ),
                                                  );
                                                } catch (e) {
                                                  showDialog<bool>(
                                                    context: context,
                                                    builder: (c) => AlertDialog(
                                                      title: Text(
                                                        lang.lang == "en" ? 'Warning' : 'تحذير',
                                                        style: TextStyle(
                                                          color: Colors.red,
                                                        ),
                                                      ),
                                                      content: Text(
                                                        lang.lang == "en"
                                                            ? 'Please check your network  '
                                                            : '  يرجي التحقق من اتصال الشبكة الخاص بك   ',
                                                        style: TextStyle(
                                                          fontSize: 15,
                                                          color: Colors.red,
                                                        ),
                                                      ),
                                                      actions: [],
                                                    ),
                                                  );
                                                }
                                              }
                                            },
                                            icon: Icon(
                                              Icons.done_all,
                                              size: 20,
                                            ),
                                            label: Text(
                                              lang.lang == "en"
                                                  ? "Delivered PK "
                                                  : "تسليم",
                                              style: TextStyle(
                                                fontSize: 12.0,
                                                color: Colors.white,
                                              ),
                                            ),
                                            style: TextButton.styleFrom(
                                              backgroundColor: Colors.green,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12.0),
                                              ),
                                            ),
                                          ),
                                        ),

                                        SizedBox(width: 15.0),

                                        Expanded(
                                          child: ElevatedButton.icon(
                                            onPressed: () async {
                                              setState(() {
                                                isConfirm = false;
                                              });

                                              showDialog<bool>(
                                                context: context,
                                                builder: (c) => AlertDialog(
                                                  title: Text(
                                                    lang.lang == "en"
                                                        ? 'Confirm'
                                                        : 'تاكيد',
                                                    style: TextStyle(
                                                      color: Colors.red,
                                                    ),
                                                  ),
                                                  content: Text(
                                                    lang.lang == "en"
                                                        ? 'Are you sure you want to cancel the order (a fine may apply) '
                                                        : '   هل أنت متأكد أنك تريد إلغاء الطلب (قد يتم تطبيق غرامة)؟',
                                                    style: TextStyle(
                                                      fontSize: 15,
                                                      color: Colors.red,
                                                    ),
                                                  ),
                                                  actions: [
                                                    TextButton(
                                                      child: Text(
                                                        lang.lang == "en"
                                                            ? 'Yes'
                                                            : 'نعم',
                                                      ),
                                                      onPressed: () async {
                                                        try {
                                                          if (this.order_id !=
                                                              null) {
                                                            String name =
                                                                this.id! +
                                                                ' ' +
                                                                '  shipper  ' +
                                                                this.username!;

                                                            int id = int.parse(
                                                              this.order_id!,
                                                              radix: 10,
                                                            );

                                                            String Url =
                                                                "https://www.ordervite.com/api/shippier/order_update/$id";

                                                            var response = await http.put(
                                                              Uri.parse(Url),
                                                              body: {
                                                                "order_cancel":
                                                                    "$name cancel order",
                                                              },
                                                              headers: {
                                                                'Authorization':
                                                                    'Bearer  ' +
                                                                    this.token!,
                                                              },
                                                            );

                                                            var reposnsebody =
                                                                jsonDecode(
                                                                  response.body,
                                                                );

                                                            String
                                                            supplier_api_token =
                                                                this.api_token
                                                                    .toString();

                                                            String text =
                                                                lang.lang ==
                                                                    "en"
                                                                ? "your order is canceled by shipper"
                                                                : " تم  الغاء الطلب بواسطة مسئول الشحن  ";

                                                            String Url3 =
                                                                "https://www.ordervite.com/api/notify/page/ordervite/$text /$supplier_api_token/1/ordervite/shipper/order cancel";

                                                            await http.get(
                                                              Uri.parse(Url3),
                                                              headers: {
                                                                'Content-Type': 'application/json',
                                                                'Accept': 'application/json',
                                                                'Authorization': 'Bearer  ' + this.token!,
                                                              },
                                                            );

                                                            Navigator.of(
                                                              context,
                                                            ).pop();

                                                            if (reposnsebody !=
                                                                null) {
                                                              ScaffoldMessenger.of(
                                                                context,
                                                              ).showSnackBar(
                                                                SnackBar(
                                                                  backgroundColor:
                                                                      Colors
                                                                          .redAccent,
                                                                  content: Text(
                                                                    lang.lang ==
                                                                            "en"
                                                                        ? 'Order have canceled ...'
                                                                        : '...تم الغاء الطلب',
                                                                    style: TextStyle(
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                      fontSize:
                                                                          18,
                                                                    ),
                                                                  ),
                                                                ),
                                                              );
                                                            }

                                                            Message
                                                            message = Message(
                                                              lang.lang == "en"
                                                                  ? "you  have canceld order"
                                                                  : "تم الغاء الطلب ...",
                                                            );

                                                            Navigator.pushNamedAndRemoveUntil(
                                                              context,
                                                              RoutesManager.shHome,
                                                              (route) => false,
                                                              arguments:
                                                                  message,
                                                            );
                                                          }
                                                        } catch (e) {
                                                          showDialog<bool>(
                                                            context: context,
                                                            builder: (c) => AlertDialog(
                                                              title: Text(
                                                                lang.lang ==
                                                                        "en"
                                                                    ? 'Warning'
                                                                    : 'تحذير',
                                                                style: TextStyle(
                                                                  color: Colors
                                                                      .red,
                                                                ),
                                                              ),
                                                              content: Text(
                                                                lang.lang ==
                                                                        "en"
                                                                    ? 'Please check your network  '
                                                                    : '  يرجي التحقق من اتصال الشبكة الخاص بك   ',
                                                                style: TextStyle(
                                                                  fontSize: 15,
                                                                  color: Colors
                                                                      .red,
                                                                ),
                                                              ),
                                                              actions: [],
                                                            ),
                                                          );
                                                        }
                                                      },
                                                    ),
                                                    TextButton(
                                                      child: Text(
                                                        lang.lang == "en"
                                                            ? 'No'
                                                            : 'لا ',
                                                      ),
                                                      onPressed: () =>
                                                          Navigator.of(
                                                            context,
                                                          ).pop(),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            },
                                            icon: Icon(Icons.cancel, size: 20),
                                            label: Text(
                                              lang.lang == "en"
                                                  ? "Cancel"
                                                  : "الغاء",
                                              style: TextStyle(
                                                fontSize: 12.0,
                                                color: Colors.white,
                                              ),
                                            ),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.red,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12.0),
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
                                          Radius.circular(18.0),
                                        ),
                                      ),
                                      child: Padding(
                                        padding: EdgeInsets.all(3),
                                        child: Row(
                                          children: <Widget>[
                                            SizedBox(width: 10.0),

                                            Expanded(
                                              child: Text(
                                                lang.lang == "en"
                                                    ? "You have confirmed the package delivery, please wait for the supplier final confirmation "
                                                    : "لقد أكدت تسليم الطرد، يُرجى انتظار التأكيد النهائي للمورد",
                                                style: TextStyle(
                                                  fontSize: 17,
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
              style: TextStyle(fontSize: 15, color: Colors.red),
            ),
          ),
        );

        return Future.value(false);
      },
    );
  }

  Future<dynamic> _getPoliLine() async {
    final String url = "https://maps.googleapis.com/maps/api/directions/json?" +
        "origin=${sourceLatLong.latitude},${sourceLatLong.longitude}" +
        "&destination=${destinationLatLong.latitude},${destinationLatLong.longitude}" +
        "&key=$GoogleApiKEY";

    try {
      var response = await http.get(Uri.parse(url));
      var jsonResponse = jsonDecode(response.body);

      if (jsonResponse["status"] == "OK") {
        String _distance = jsonResponse["routes"][0]["legs"][0]["distance"]['text'];
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('الـمسافة: $_distance')),
        );
        String encodedPoints = jsonResponse["routes"][0]["overview_polyline"]["points"];
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

