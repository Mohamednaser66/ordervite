import 'dart:async';
import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_maps/classes.dart';
import 'package:flutter_maps/lang.dart';
import 'package:flutter_maps/shipper/shipper_drawer.dart';
import 'package:flutter_maps/shipper/widgets/order_named_icon.dart';
import 'package:flutter_maps/supplier/order.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:location/location.dart';
import 'package:shared_preferences/shared_preferences.dart';

String GoogleApiKEY = "AIzaSyDl8LFLQn24CbaZyQ0F4wnzoF9NY3_gMWY";

const oneSec = const Duration(seconds: 1);
const interval = const Duration(minutes: 1);
const iconCancel = Icons.cancel;
const iconStart = Icons.alarm;

class SHHomePage extends StatefulWidget {
  SHHomePage({Key? key}) : super(key: key);

  @override
  _SHHomePageState createState() => _SHHomePageState();
}

class _SHHomePageState extends State<SHHomePage> {
  CameraPosition _initialCamera = CameraPosition(
    target: LatLng(30.059445, 31.1933067),
    zoom: 14.0000,
  );
  final Set<Marker> _markers = Set();
  Completer<GoogleMapController> _mapController = Completer();

  LatLng sourceLatLong = LatLng(30.059445, 31.1933067);
  LatLng destinationLatLong = LatLng(30.060671, 31.204131);
  final Set<Polyline> _polyline = {};
  final GlobalKey<ScaffoldState> _scaffoldkey = new GlobalKey<ScaffoldState>();
  String? username;
  String? email;
  String? id;
  String? token;
  String? logo_src;
  String? disLat;
  String? sorLat;
  String? disLong;
  String? sorlong;
  String? order_id;
  int order_num = 0;

  bool isConfirm = false;

  bool isSignIn = false;
  bool isMessage = true;

  bool isVerifed = true;

  late StreamController _orderController;

  late BuildContext mainContext;
  dynamic order_id_session;
  dynamic order_data_session;

  late Map<String, dynamic> formData;
  Timer? timer;
  String data = "";
  String? statename;
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  getPref() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();

    order_id_session = await preferences.get("order_id_session");
    if (order_id_session != null) {
      order_data_session = await preferences.get(
        'order_data $order_id_session',
      );
    }

    username = preferences.getString("username");
    email = preferences.getString("email");
    token = preferences.getString("token");
    id = preferences.getString("id");

    if (username != null && email != null && token != null && id != null) {
      setState(() {
        isSignIn = true;
      });
    }

    if (token == null || id == null) {
      return;
    }

    int? myid;
    try {
      myid = int.parse(id!, radix: 10);
    } catch (_) {
      return;
    }

    String Url2 = "https://www.ordervite.com/api/shippier/show/$myid";
    var response2 = await http.get(
      Uri.parse(Url2),
      headers: {'Authorization': 'Bearer $token'},
    );
    var reposnsebody2 = jsonDecode(response2.body);
    if (reposnsebody2["success"] == true) {}

    if (!mounted) return;

    setState(() {
      logo_src = reposnsebody2["data"]["logo"].toString();
      if (logo_src != null) {
        preferences.setString('logo_src', logo_src!);
      }
      preferences.setString(
        'email',
        reposnsebody2["data"]["name"]["email"].toString(),
      );

      preferences.setString(
        'username',
        reposnsebody2["data"]["name"]["name"].toString(),
      );
    });

    Location _locationTracker = Location();
    var location = await _locationTracker.getLocation();

    setState(() {
      _initialCamera = CameraPosition(
        target: LatLng(location.latitude ?? 0, location.longitude ?? 0),
        zoom: 14.0000,
      );

      sourceLatLong = LatLng(location.latitude ?? 0, location.longitude ?? 0);
    });

    _mapController.future.then((controller) {
      controller.animateCamera(CameraUpdate.newLatLngZoom(sourceLatLong, 14.0));
    });

    _markers.add(
      Marker(
        markerId: MarkerId("1"),
        position: sourceLatLong,
        infoWindow: InfoWindow(title: this.username),
        icon: BitmapDescriptor.defaultMarker,
        visible: true,
      ),
    );

    try {
      if (id == null || token == null) return;

      int shipper_id = int.parse(id!, radix: 10);

      String Url =
          "https://www.ordervite.com/api/shippier/location_update/$shipper_id";

      var response = await http.put(
        Uri.parse(Url),
        body: {
          "cur_longitude": location.longitude.toString(),
          "cur_latitude": location.latitude.toString(),
        },
        headers: {'Authorization': 'Bearer $token'},
      );

      var reposnsebody = jsonDecode(response.body);

      if (reposnsebody["data"]["verified"].toString() == "0" ||
          reposnsebody["data"]["verified"].toString() == "2") {
        setState(() {
          isVerifed = false;
        });
      }
    } catch (e) {}
  }

  changeMainContext(BuildContext context) {
    mainContext = context;
  }

  void handleMessage(RemoteMessage message) {
    final data = message.data;
    final stateName = data["state_name"]?.toString() ?? "";

    if (!mounted) return;

    setState(() {
      statename = stateName;
    });

    if (stateName == "new order" || stateName == "order cancel") {
      loaddailyOrders();
    }

    if (stateName == "order review") {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.redAccent,
          content: Text(
            data["state_type"]?.toString() ?? "",
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
        ),
      );
    }
  }

  Future<void> checkInitialMessage() async {
    RemoteMessage? initialMessage = await FirebaseMessaging.instance
        .getInitialMessage();

    if (initialMessage != null) {
      handleMessage(initialMessage);
    }
  }

  @override
  void initState() {
    super.initState();

    _orderController = StreamController();

    timer = Timer.periodic(const Duration(seconds: 100), (timer) {
      if (mounted) {
        loaddailyOrders();
      }
    });

    getPref();
    loaddailyOrders();

    _firebaseMessaging.getToken().then((token) async {
      if (token == null || id == null || this.token == null) return;

      try {
        String Url =
            "https://www.ordervite.com/api/shippier/complete_profile/$id";

        await http.put(
          Uri.parse(Url),
          body: {"api_token": token.toString()},
          headers: {'Authorization': 'Bearer ${this.token}'},
        );
      } catch (e) {}
    });

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      handleMessage(message);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      handleMessage(message);
    });

    checkInitialMessage();

    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) {
        showMessage();
      }
    });
  }

  Future getdailyOrders() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    Lang lang = Lang.of(context);
    token = preferences.getString("token");

    try {
      String Url = "https://www.ordervite.com/api/shippier/daily/orders";

      var response = await http.get(
        Uri.parse(Url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',

          'Authorization': 'Bearer $token',
        },
      );

      var reposnsebody = jsonDecode(response.body);

      if (reposnsebody["data"] != null) {
        if (reposnsebody["data"].length > order_num) {
          if (!mounted) return;

          setState(() {
            data = reposnsebody.toString();

            order_num = reposnsebody["data"].length;

            if (order_num >= 1) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: Colors.redAccent,
                  content: Text(
                    lang.lang == "en"
                        ? 'There are $order_num orders you can match'
                        : 'هناك $order_num طلب يمكنك مشاهدتهم',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
              );
            }
          });
        }
      }
      return reposnsebody["data"];
    } catch (e) {}
  }

  loaddailyOrders() async {
    getdailyOrders().then((res) async {
      if (!_orderController.isClosed) {
        _orderController.add(res);
      }
      return res;
    });
  }

  void showMessage() {
    final args = ModalRoute.of(context)?.settings.arguments;

    if (args != null && args is Message) {
      Message message = args;

      if (message.message.isNotEmpty && isMessage) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.redAccent,
            content: Text(
              message.message,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ),
        );

        if (mounted) {
          setState(() {
            isMessage = false;
          });
        }

        timer?.cancel();
      }
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    _orderController.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Lang lang = Lang.of(context);

    return WillPopScope(
      child: Directionality(
        textDirection: lang.lang == "en"
            ? TextDirection.ltr
            : TextDirection.rtl,

        child: Scaffold(
          key: _scaffoldkey,
          drawer: ShipperDrawer(
            username: username ?? '',
            logo_src: logo_src,
            email: email ?? '',
            lang: lang,
            isSignIn: isSignIn,
          ),
          appBar: AppBar(
            title: Text(
              lang.lang == "en" ? "OrderVite" : "أودرفيت",
              style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
                fontStyle: FontStyle.normal,
                color: Colors.white,
              ),
            ),

            actions: <Widget>[
              OrdersNamedIcon(
                text: lang.lang == "en" ? 'orders' : 'الطلبات ',
                isVerified: this.isVerifed,
                iconData: Icons.notifications,
                notificationCount: order_num,
              ),
            ],
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
                  },
                  markers: _markers,
                ),
              ),
            ],
          ),
        ),
      ),
      onWillPop: () async {
        final shouldPop = await showDialog<bool>(
          context: context,
          builder: (c) => AlertDialog(
            title: Text(
              lang.lang == "en" ? 'Warning' : 'تحذير',
              style: TextStyle(color: Colors.red),
            ),
            content: Text(
              lang.lang == "en"
                  ? 'Please logout first'
                  : 'من فضلك قم بتسجيل الخروج أولاً',
              style: TextStyle(fontSize: 15, color: Colors.red),
            ),
            actions: [
              TextButton(
                child: Text(lang.lang == "en" ? "Logout" : "تسجيل الخروج"),
                onPressed: () {
                  Navigator.pop(c, true);
                },
              ),
              TextButton(
                child: Text(lang.lang == "en" ? "Cancel" : "إلغاء"),
                onPressed: () {
                  Navigator.pop(c, false);
                },
              ),
            ],
          ),
        );

        return shouldPop ?? false;
      },
    );
  }

  List<Steps> parseSteps(final responseBody) {
    var list = responseBody
        .map<Steps>((json) => new Steps.fromJson(json))
        .toList();
    return list;
  }
}
