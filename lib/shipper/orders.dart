import 'dart:async';
import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_maps/classes.dart';
import 'package:flutter_maps/core/routes_manager.dart';
import 'package:flutter_maps/lang.dart';
import 'package:flutter_maps/shipper/shipper_drawer.dart';
import 'package:flutter_maps/supplier/order.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:location/location.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/map_utils.dart';

String GoogleApiKEY = "AIzaSyDl8LFLQn24CbaZyQ0F4wnzoF9NY3_gMWY";

const oneSec = const Duration(seconds: 1);
const interval = const Duration(minutes: 1);
const iconCancel = Icons.cancel;
const iconStart = Icons.alarm;

class ShOrders extends StatefulWidget {
  ShOrders({Key? key}) : super(key: key);

  final String title = "OrderVite";

  @override
  _ShOrdersState createState() => _ShOrdersState();
}

enum BestSize { small, medium, large }

enum BestPrice { transfer, cash }

class _ShOrdersState extends State<ShOrders> {
  final Set<Marker> _markers = Set();

  LatLng sourceLatLong = LatLng(30.059445, 31.1933067);
  LatLng destinationLatLong = LatLng(30.060671, 31.204131);
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

  bool isOrderDate = false;

  bool isConfirm = false;

  bool isSignIn = false;
  bool isMessage = true;

  GlobalKey<FormState> formstatesorder = new GlobalKey<FormState>();

  late StreamController _orderController;

  TextEditingController size = new TextEditingController();
  TextEditingController price = new TextEditingController();
  late BuildContext mainContext;
  dynamic order_id_session;
  dynamic order_data_session;

  Map<String, dynamic>? formData;
  Timer? timer;
  String data = "";
  String? statename;

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  String? validprice(String val) {
    if (val.trim().isEmpty) {
      return 'package price  Is Required';
    }

    return null;
  }

  getPref() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();

    order_id_session = await preferences.get("order_id_session");
    order_data_session = await preferences.get('order_data $order_id_session');

    username = preferences.getString("username")!;
    email = preferences.getString("email")!;

    if (username != null && email != null) {
      setState(() {
        username = preferences.getString("username")!;
        email = preferences.getString("email")!;

        token = preferences.getString("token")!;
        logo_src = preferences.getString("logo_src")!;
        id = preferences.getString("id")!;

        isSignIn = true;
      });
    }
    Location _locationTracker = Location();
    var location = await _locationTracker.getLocation();

    setState(() {
      sourceLatLong = LatLng(location.latitude ?? 0, location.longitude ?? 0);
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
  }

  changeMainContext(BuildContext context) {
    mainContext = context;
  }

  Future getdailyOrders() async {
    Lang lang = Lang.of(context);
    SharedPreferences preferences = await SharedPreferences.getInstance();

    token = preferences.getString("token")!;

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
          setState(() {
            data = reposnsebody.toString();
            isOrderDate = true;

            order_num = reposnsebody["data"].length;
            if (order_num >= 1) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: Colors.redAccent,
                  content: Text(
                    lang.lang == "en"
                        ? 'There is $order_num order you  can match'
                        : ' طلبات هناك $order_num يمكنك مشاهدتهم',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18.sp,
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
      _orderController.add(res);
      return res;
    });
  }

  showMessage(Message args) {
    Message message = ModalRoute.of(context)?.settings.arguments as Message;

    if (isMessage) {
      String message_show = message.message.toString();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.redAccent,
          content: Text(
            '$message_show',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.sp),
          ),
        ),
      );

      setState(() {
        isMessage = false;
      });

      timer?.cancel();
    }
  }

  void _handleMessage(RemoteMessage message) {
    if (!mounted) return;

    String stateName = message.data["state_name"] ?? "";
    String stateType = message.data["state_type"] ?? "";

    setState(() {
      statename = stateName;
    });

    if (stateName == "new order" || stateName == "order cancel") {
      loaddailyOrders();
    }
    if (stateName == "order confirmed") {
      setState(() {
        isConfirm = true;
      });
    }

    if (stateName == "order review") {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.redAccent,
            content: Text(
              stateType,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.sp),
            ),
          ),
        );
      });
    }
  }

  Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
    await Firebase.initializeApp();
    print('Handling background message: ${message.messageId}');
  }

  void showMessageSafe() {
    final args = ModalRoute.of(context)?.settings.arguments;

    if (args != null && args is Message) {
      showMessage(args);
    }
  }

  @override
  void dispose() {
    timer?.cancel();

    super.dispose();
  }

  bool _isInit = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_isInit) {
      loaddailyOrders();

      Future.delayed(const Duration(seconds: 5), () {
        if (!mounted) return;
        showMessageSafe();
      });

      _isInit = false;
    }
  }

  @override
  void initState() {
    super.initState();

    getPref();

    _orderController = StreamController();

    timer = Timer.periodic(const Duration(seconds: 100), (timer) {
      if (!mounted) return;
      loaddailyOrders();
    });
    _firebaseMessaging.getToken().then((fcmToken) async {
      String url =
          "https://www.ordervite.com/api/shippier/complete_profile/$id";

      await http.put(
        Uri.parse(url),
        body: {"api_token": fcmToken.toString()},
        headers: {'Authorization': 'Bearer $token'},
      );
    });

    FirebaseMessaging.onMessage.listen(_handleMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessage);

    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  }

  @override
  Widget build(BuildContext context) {
    Lang lang = Lang.of(context);

    return Directionality(
      textDirection: lang.lang == "en" ? TextDirection.ltr : TextDirection.rtl,

      child: Scaffold(
        key: _scaffoldkey,
        drawer: ShipperDrawer(
          username: username ?? '',
          email: email ?? '',
          lang: lang,
          isSignIn: isSignIn,
        ),
        appBar: AppBar(
          title: Text(
            lang.lang == "en" ? 'Orders' : 'الطلبات',
            style: TextStyle(
              fontSize: 25.sp,
              fontWeight: FontWeight.bold,
              fontStyle: FontStyle.normal,
              color: Colors.white,
            ),
          ),
        ),
        body: Stack(
          children: <Widget>[
            Positioned(
              child: FutureBuilder(
                future: getdailyOrders(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return ListView.builder(
                      itemCount: snapshot.data.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          title: Text(
                            (lang.lang == "en" ? "id : " : "الكود:") +
                                snapshot.data[index]["id"].toString() +
                                (lang.lang == "en"
                                    ? ("Size : " +
                                          snapshot.data[index]["size"]
                                              .toString())
                                    : ("Size: " +
                                                  snapshot.data[index]["size"]
                                                      .toString() ==
                                              "small"
                                          ? " الحجم : صغير"
                                          : ("Size: " +
                                                        snapshot
                                                            .data[index]["size"]
                                                            .toString() ==
                                                    "medium"
                                                ? " الحجم :   كبير  "
                                                : " الحجم :   متوسط "))) +
                                "      " +
                                "      ",
                          ),
                          subtitle: Text(
                            (lang.lang == "en" ? "cost " : "التكلفة ") +
                                snapshot.data[index]["cost"].toString() +
                                (lang.lang == "en" ? " EGP " : " جم "),
                          ),
                          onTap: () {
                            OrderData orderData = OrderData(
                              snapshot.data[index]["dist_latitude"].toString(),
                              snapshot.data[index]["so_latitude"].toString(),
                              snapshot.data[index]["dist_longitude"].toString(),
                              snapshot.data[index]["so_longitude"].toString(),
                              snapshot.data[index]["id"].toString(),
                              false,
                              snapshot.data[index]["cost"].toString(),
                              snapshot.data[index]["price"].toString(),
                              snapshot.data[index]["pricecheck"].toString(),
                              snapshot.data[index]["order_state"].toString(),
                              snapshot.data[index]["supplier_id"].toString(),
                            );
                            Navigator.pushNamed(
                              context,
                              RoutesManager.shOrder,
                              arguments: orderData,
                            );
                          },
                          leading: CircleAvatar(
                            child: Icon(
                              Icons.card_travel_rounded,
                              size: 20.sp,
                              color: Colors.white,
                            ),
                          ),
                        );
                      },
                    );
                  } else {
                    return Center(
                      child: CircularProgressIndicator(color: Colors.blue),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Steps> parseSteps(final responseBody) {
    var list = responseBody
        .map<Steps>((json) => new Steps.fromJson(json))
        .toList();
    return list;
  }
}

class NamedIcon extends StatelessWidget {
  final IconData iconData;
  final String text;
  final VoidCallback onTap;
  final int notificationCount;

  const NamedIcon({
    Key? key,
    required this.onTap,
    required this.text,
    required this.iconData,
    required this.notificationCount,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.pushNamed(context, RoutesManager.shOrders);
      },
      child: Container(
        width: 72.w,
        padding: REdgeInsets.symmetric(horizontal: 8.w),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(iconData),
                Text(text, overflow: TextOverflow.ellipsis),
              ],
            ),
            Positioned(
              top: 0.h,
              right: 0.w,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.red,
                ),
                alignment: Alignment.center,
                child: Text('$notificationCount'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
