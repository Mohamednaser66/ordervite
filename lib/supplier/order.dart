import 'dart:async';
import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_maps/Core/routes_manager.dart';
import 'package:flutter_maps/classes.dart';
import 'package:flutter_maps/lang.dart';
import 'package:flutter_maps/supplier/models/named_icon.dart';
import 'package:flutter_maps/supplier/widgets/su_order_states_widget.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:location/location.dart';
import 'package:shared_preferences/shared_preferences.dart';

String GoogleApiKEY = "AIzaSyDl8LFLQn24CbaZyQ0F4wnzoF9NY3_gMWY";

class OrderPage extends StatefulWidget {
  OrderPage({Key? key}) : super(key: key);

  @override
  _OrderState createState() => _OrderState();
}

class _OrderState extends State<OrderPage> {
  CameraPosition _initialCamera = CameraPosition(
    target: LatLng(30.059445, 31.1933067),
    zoom: 17.0,
  );
  Completer<GoogleMapController> _mapController = Completer();
  final Set<Marker> _markers = Set();
  Location _locationTracker = Location();

  LatLng sourceLatLong = LatLng(30.059445, 31.1933067);
  LatLng destinationLatLong = LatLng(30.060671, 31.204131);
  final Set<Polyline> _polyline = {};
  final GlobalKey<ScaffoldState> _scaffoldkey = new GlobalKey<ScaffoldState>();
  int tapCount = 0;
  String? username;
  String? email;
  String? id;
  String? token;
  String? disLat;
  String? sorLat;
  String? disLong;
  String? sorlong;
  String? distance;

  String? order_id;
  String? cost;
  String? statename;

  String? order_cost;
  String? order_pricecheck;
  String? order_shippier_id;

  String? order_price;
  String? order_state;
  int order_messges_count = 0;

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  late StreamController _orderController = StreamController();

  bool isConfirm = false;
  bool isShConfirm = false;
  bool isShDelviered = false;
  bool isShReceived = false;
  String? api_token;

  bool isConfirmOrder = false;

  bool isSignIn = false;

  Timer? _autoCancelTimer;
  bool _timerStarted = false;

  String _size = 'small';
  String _price = 'default';

  String _priceCheck = 'transfer';

  TextEditingController price = TextEditingController();

  String? validprice(String? val) {
    if (val!.trim().isEmpty) {
      return 'package price  Is Required';
    }

    return null;
  }

  String _loc(Lang lang, String en, String ar) => lang.lang == "en" ? en : ar;

  void _showSnackBar(
    Lang lang, {
    required String en,
    required String ar,
    Color backgroundColor = Colors.redAccent,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: backgroundColor,
        content: Text(
          _loc(lang, en, ar),
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.sp),
        ),
      ),
    );
  }

  Future<void> _showNetworkErrorDialog(Lang lang) async {
    await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: Text(
          _loc(lang, 'Warning', 'تحذير'),
          style: TextStyle(color: Colors.red),
        ),
        content: Text(
          _loc(
            lang,
            'Please check your network',
            'يرجي التحقق من اتصال الشبكة الخاص بك',
          ),
          style: TextStyle(fontSize: 15.sp, color: Colors.red),
        ),
      ),
    );
  }

  savePref(
    String disLat,
    String sorLat,
    String disLong,
    String sorlong,
    String order_id,
  ) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.setString('disLat', disLat);
    preferences.setString('sorLat', sorLat);
    preferences.setString('disLong', disLong);
    preferences.setString('sorlong', sorlong);
    preferences.setString('order_id', order_id);
  }

  getPref() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();

    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is! OrderDist) return;
    OrderDist orderDist = args;
    username = preferences.getString("username");
    email = preferences.getString("email");

    if (username != null && email != null) {
      setState(() {
        username = preferences.getString("username");
        email = preferences.getString("email");

        token = preferences.getString("token");
        id = preferences.getString("id") ?? '';
        print(id);

        isSignIn = true;
      });
    }

    setState(() {
      disLat = orderDist.disLat.toString();
      disLong = orderDist.disLong.toString();
      sorLat = orderDist.sorLat.toString();
      sorlong = orderDist.sorlong.toString();
      isConfirm = orderDist.isConfirm;
      order_id = orderDist.order_id;
      order_cost = orderDist.order_cost;
      order_price = orderDist.order_price;
      order_pricecheck = orderDist.order_pricecheck;
      order_shippier_id = orderDist.order_shippier_id ?? '';
      order_state = orderDist.order_state;
      sourceLatLong = LatLng(double.parse(sorLat!), double.parse(sorlong!));
      destinationLatLong = LatLng(
        double.parse(disLat!),
        double.parse(disLong!),
      );
      _initialCamera = CameraPosition(
        target: LatLng(double.parse(sorLat!), double.parse(sorlong!)),
        zoom: 17.0,
      );
    });
    _markers.add(
      Marker(
        markerId: MarkerId("1"),
        position: sourceLatLong,
        infoWindow: InfoWindow(title: "source"),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
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

    await _fetchRoute(animateCamera: true);
  }

  Future<void> _fetchRoute({bool animateCamera = false}) async {
    final url =
        "https://maps.googleapis.com/maps/api/directions/json?origin=${sourceLatLong.latitude},${sourceLatLong.longitude}&destination=${destinationLatLong.latitude},${destinationLatLong.longitude}&key=$GoogleApiKEY";
    try {
      final response = await http.get(Uri.parse(url));
      final json = jsonDecode(response.body);

      if (json['routes'] != null && json['routes'].isNotEmpty) {
        final encodedPoints = json['routes'][0]['overview_polyline']['points'];
        final points = _decodePoly(encodedPoints);

        _polyline.clear();
        setState(() {
          _polyline.add(
            Polyline(
              polylineId: const PolylineId("route"),
              points: points,
              color: Colors.blueAccent,
              width: 5,
            ),
          );
        });
        final distanceValue = json['routes'][0]['legs'][0]['distance']['value'];
        setState(() {
          distance = (distanceValue / 1000).toStringAsFixed(2);
        });
        print('Calculated Distance:     $distance km');
        LatLngBounds _getBounds(LatLng start, LatLng end) {
          return LatLngBounds(
            southwest: LatLng(
              start.latitude < end.latitude ? start.latitude : end.latitude,
              start.longitude < end.longitude ? start.longitude : end.longitude,
            ),
            northeast: LatLng(
              start.latitude > end.latitude ? start.latitude : end.latitude,
              start.longitude > end.longitude ? start.longitude : end.longitude,
            ),
          );
        }

        if (animateCamera) {
          final controller = await _mapController.future;
          controller.animateCamera(
            CameraUpdate.newLatLngBounds(
              _getBounds(sourceLatLong, destinationLatLong),
              70,
            ),
          );
        }
      }
    } catch (e) {
      debugPrint("Route Error: $e");
    }
  }

  void _onMapTapped(LatLng position) {
    setState(() {
      if (tapCount % 2 == 0) {
        sourceLatLong = position;
        sorLat = position.latitude.toString();
        sorlong = position.longitude.toString();
        _markers.removeWhere((m) => m.markerId.value == "1");
        _markers.add(
          Marker(
            markerId: MarkerId("1"),
            position: position,
            infoWindow: InfoWindow(title: "source"),
            icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueAzure,
            ),
          ),
        );
      } else {
        destinationLatLong = position;
        disLat = position.latitude.toString();
        disLong = position.longitude.toString();
        _markers.removeWhere((m) => m.markerId.value == "2");
        _markers.add(
          Marker(
            markerId: MarkerId("2"),
            position: position,
            infoWindow: InfoWindow(title: "destination"),
            icon: BitmapDescriptor.defaultMarker,
          ),
        );
        _fetchRoute(animateCamera: true);
      }
      tapCount++;
    });
  }

  Future getcurrentOrder() async {
    Lang lang = Lang.of(context);

    SharedPreferences preferences = await SharedPreferences.getInstance();

    token = preferences.getString("token");
    id = preferences.getString("id");

    try {
      if (id != null) {
        int id = int.parse(this.id!, radix: 10);
        String Url = "https://www.ordervite.com/api/supplier/current_order/$id";

        var response = await http.get(
          Uri.parse(Url),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',

            'Authorization': 'Bearer $token',
          },
        );

        var reposnsebody = jsonDecode(response.body);

        print(reposnsebody);
        print(70);

        if (isConfirm) {
          if (reposnsebody["data"] != null) {
            setState(() {
              order_state = reposnsebody["data"]["order_state"].toString();

              order_shippier_id = reposnsebody["data"]["shippier_id"]
                  .toString();
            });

            if (order_state == "new" && !_timerStarted) {
              _timerStarted = true;
              _autoCancelTimer = Timer(Duration(minutes: 20), () async {
                if (mounted && order_state == "new") {
                  _showSnackBar(
                    lang,
                    en: 'No shipper is available at this time, kindly try again later.',
                    ar: 'لا يوجد مسئول شحن متاح في هذا الوقت، يرجى المحاولة لاحقاً.',
                  );
                  try {
                    if (order_id != null) {
                      String name = "$id   supplier  $username";
                      int parsedId = int.parse(order_id ?? '', radix: 10);
                      String url =
                          "https://www.ordervite.com/api/supplier/order_update/$parsedId";
                      var response = await http.put(
                        Uri.parse(url),
                        body: {"order_cancel": "$name cancel order"},
                        headers: {'Authorization': 'Bearer $token'},
                      );
                      jsonDecode(response.body);
                      String shipperApiToken = api_token.toString();
                      String text = lang.lang == "en"
                          ? "your order is cancled by supplier!"
                          : "  تم إلغاء الطلب بواسطة المورد  ";
                      String url3 =
                          "https://www.ordervite.com/api/notify/page/ordervite/$text/$shipperApiToken/1/ordervite/supplier/order cancel";
                      await http.get(
                        Uri.parse(url3),
                        headers: {
                          'Content-Type': 'application/json',
                          'Accept': 'application/json',
                          'Authorization': 'Bearer $token',
                        },
                      );
                      if (mounted) {
                        Message message = Message(
                          lang.lang == "en"
                              ? "Order is Canceled"
                              : "تم إلغاء الطلب ",
                        );
                        Navigator.pushNamedAndRemoveUntil(
                          context,
                          RoutesManager.suHome,
                          (route) => false,
                          arguments: message,
                        );
                      }
                    }
                  } catch (e) {
                    // ignore
                  }
                }
              });
            } else if (order_state != "new") {
              _autoCancelTimer?.cancel();
              _timerStarted = false;
            }

            int sub_id = int.parse(this.order_shippier_id ?? '', radix: 10);

            String Url =
                "https://www.ordervite.com/api/supplier/shippier/$sub_id";

            var response2 = await http.get(
              Uri.parse(Url),
              headers: {
                'Content-Type': 'application/json',
                'Accept': 'application/json',

                'Authorization': 'Bearer $token',
              },
            );

            var reposnsebody2 = jsonDecode(response2.body);

            setState(() {
              this.api_token = reposnsebody2["data"]["name"]["api_token"]
                  .toString();
            });

            if (reposnsebody["data"]["order_cancel"] != null) {
              Message message = new Message(
                lang.lang == "en"
                    ? "Order is Canceled by shipper"
                    : " تم إلغاء الطلب من قِبل مسئول الشحن ",
              );

              Navigator.pushNamedAndRemoveUntil(
                context,
                RoutesManager.suHome,
                (route) => false,
                arguments: message,
              );
            }

            if (reposnsebody["data"]["order_state"] == "order received") {
              setState(() {
                isShReceived = true;
                isShConfirm = true;
              });

              _showSnackBar(
                lang,
                en: 'Your order is recived by a shipper, please wait for him to pick up your package.',
                ar: 'تم استقبال طلبك بواسطة مسئل الشحن من فضلك انتظر حتي يستطيع الوصول اليك',
              );
            }

            if (reposnsebody["data"]["order_state"] == "order delivered") {
              setState(() {
                isConfirmOrder = true;
                isShDelviered = true;
                isShConfirm = true;
                isShReceived = true;
              });

              _showSnackBar(
                lang,
                en: 'Your package is delivered, if you received the payment please confirm the order is complete.',
                ar: 'تم تسليم الطرد الخاص بك، إذا تلقيت الدفع، فيُرجى تأكيد عملية اكتمال الطلب',
              );
            }

            if (reposnsebody["data"]["shippier_id"] != null) {
              setState(() {
                isShConfirm = true;
              });
              _showSnackBar(
                lang,
                en: 'Your order is confirmed by a shipper, please wait for him to pick up your package.',
                ar: 'تم تأكيد طلبك من قِبل مسئول الشحن، يُرجى انتظاره لاستلام الطرد الخاص بك',
              );
            }

            if (reposnsebody["data"]["order_state"].toString() ==
                "order complete") {
              OrderView orderView = new OrderView(
                this.order_id.toString(),
                this.api_token.toString(),
              );
              Navigator.pushNamed(
                context,
                RoutesManager.rating,
                arguments: orderView,
              );
            }
          }
        }

        return reposnsebody["data"];
      } else {
        return null;
      }
    } catch (e) {
      print(e.toString());
    }
  }

  loadcurrentOrder() async {
    var res = await getcurrentOrder();
    if (!mounted) return;
    if (!_orderController.isClosed) {
      _orderController.add(res);
    }
  }
  List<String> lst = ['small', 'medium', 'large'];
  int selectedIndex = 0;

  List<String> lst2 = ['cash', 'transfer'];

  int selectedIndex2 = 0;

  void changeIndex(int index) {
    setState(() {
      selectedIndex = index;
      _size = lst[index].toString();
    });
  }

  Widget customRadio(String txt, int index) {
    Lang lang = Lang.of(context);
    return SizedBox(
      height: 50.h,
      child: ElevatedButton(
        onPressed: () => changeIndex(index),
        style: ElevatedButton.styleFrom(
          backgroundColor: selectedIndex == index
              ? Colors.blueAccent
              : Colors.grey,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0.r),
          ),
          padding: REdgeInsets.symmetric(vertical: 4.h),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              lang.lang == "en"
                  ? txt
                  : (txt == "small"
                        ? "صغير"
                        : (txt == "medium" ? "وسط" : "كبير")),
              style: TextStyle(
                color: selectedIndex == index ? Colors.white : Colors.black,
                fontSize: 12.sp,
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              (index == 0 ? ' 1-5 ' : (index == 1 ? ' 5-10 ' : ' 10+ ')) +
                  (lang.lang == "en" ? 'KG' : 'كجم'),
              style: TextStyle(
                color: selectedIndex == index ? Colors.white : Colors.black,
                fontSize: 10.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void changeIndex2(int index) {
    setState(() {
      selectedIndex2 = index;
      _priceCheck = lst2[index].toString();
    });
  }

  Widget customRadio2(String txt, int index) {
    Lang lang = Lang.of(context);
    return SizedBox(
      height: 40.h,
      child: ElevatedButton(
        onPressed: () => changeIndex2(index),
        style: ElevatedButton.styleFrom(
          backgroundColor: selectedIndex2 == index
              ? Colors.blueAccent
              : Colors.grey,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0.r),
          ),
          padding: REdgeInsets.symmetric(vertical: 4.h, horizontal: 12.w),
        ),
        child: Text(
          lang.lang == "en" ? txt : (txt == "cash" ? "كاش" : "تحويل"),
          style: TextStyle(
            color: selectedIndex2 == index ? Colors.white : Colors.black,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _autoCancelTimer?.cancel();
    _orderController.close();
    super.dispose();
  }

  Future<void> _handleMessage(RemoteMessage message) async {
    final data = message.data;

    if (!mounted) return;

    setState(() {
      statename = data["state_name"]?.toString();
      if (statename == "shipper confirmed") {
        order_shippier_id = data["state_type"]!.toString();
      }
    });

    if (statename == "shipper confirmed") {
      int sub_id = int.parse(data["state_type"].toString());

      String url = "https://www.ordervite.com/api/supplier/shippier/$sub_id";

      var response2 = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      var reposnsebody2 = jsonDecode(response2.body);

      if (!mounted) return;

      setState(() {
        api_token = reposnsebody2["data"]["name"]["api_token"]?.toString();
      });
    }

    if (statename == "new message") {
      int con_id = int.parse(order_id.toString());

      String url2 =
          "https://www.ordervite.com/api/supplier/order/$con_id/messages/unread/shipper";

      var response2 = await http.get(
        Uri.parse(url2),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      var reposnsebody2 = jsonDecode(response2.body);

      if (!mounted) return;

      setState(() {
        order_messges_count =
            reposnsebody2["data"]["order unread messages count"];
      });
    }

    print("Message: ${message.data}");
    print(statename);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    loadcurrentOrder();
  }

  void initState() {
    super.initState();
    _orderController = StreamController();
    getPref();
    _locationTracker.requestPermission();

    _firebaseMessaging.getToken().then((token) async {
      int id = int.parse(this.id!, radix: 10);

      String Url =
          "https://www.ordervite.com/api/supplier/complete_profile/$id";

      await http.put(
        Uri.parse(Url),
        body: {"api_token": token.toString()},

        headers: {'Authorization': 'Bearer  ' + this.token!},
      );

      if (this.order_id != null) {
        print(this.order_id);

        int con_id2 = int.parse(this.order_id.toString(), radix: 10);

        String Url2 =
            "https://www.ordervite.com/api/supplier/order/$con_id2/messages/unread/shipper";
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
      await _handleMessage(message);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async {
      await _handleMessage(message);
    });

    FirebaseMessaging.instance.getInitialMessage().then((message) async {
      if (message != null) {
        await _handleMessage(message);
      }
    });
  }

  void _handleStateChanges(Lang lang) {
    if (statename == "order cancel") {
      Message message = Message(
        lang.lang == "en"
            ? "Order is Canceled by shipper"
            : "     تم إلغاء الطلب من قِبل مسئول الشحن  ",
      );
      Navigator.pushNamed(context, RoutesManager.suHome, arguments: message);
    } else if (statename == "shipper confirmed") {
      setState(() {
        isShConfirm = true;
        order_state = statename.toString();
      });
      if (!isShReceived) {
        _showSnackBar(
          lang,
          en: 'Your order is confirmed by a shipper, please wait for him to pick up your package.',
          ar: 'تم تأكيد طلبك من قِبل مسئول الشحن، يُرجى انتظاره لاستلام الطرد الخاص بك',
        );
      }
    } else if (statename == "order received") {
      setState(() {
        isShReceived = true;
        isShConfirm = true;
        order_state = statename.toString();
      });
      if (!isShDelviered) {
        _showSnackBar(
          lang,
          en: 'Your order is received by a shipper, please wait for him to pick up your package.',
          ar: 'تم استلام الحمولة بواسطة مسئول الشحن، من فضلك انتظر حتى ينقل الحمولة إلى وجهتك',
        );
      }
    } else if (statename == "order delivered") {
      setState(() {
        isConfirmOrder = true;
        isShDelviered = true;
        isShConfirm = true;
        isShReceived = true;
        order_state = statename.toString();
      });
      _showSnackBar(
        lang,
        en: 'Your package is delivered, if you received the payment please confirm the order is complete.',
        ar: 'تم تسليم الطرد الخاص بك، إذا تلقيت الدفع، فيُرجى تأكيد عملية اكتمال الطلب',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    Lang lang = Lang.of(context);

    _handleStateChanges(lang);
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
              NamedIcon(
                text: lang.lang == "en" ? 'Chats' : 'محادثات ',
                iconData: Icons.message,
                order_id: this.order_id ?? '',
                api_token: this.api_token.toString(),
                notificationCount: order_messges_count,
                disLat: this.disLat.toString(),
                disLong: this.disLong.toString(),
                sorLat: this.sorLat.toString(),
                sorlong: this.sorlong.toString(),
                isConfirm: true,
                order_cost: this.order_cost.toString(),
                order_price: this.order_price.toString(),
                order_pricecheck: this.order_pricecheck.toString(),
                order_state: this.order_state.toString(),
                order_supplier_id: this.id.toString(),
                order_shippier_id: this.order_shippier_id.toString(),
                permission: this.isConfirm,
              ),
            ],
            automaticallyImplyLeading: false,
          ),
          body: Stack(
            children: <Widget>[
              Positioned(
                child: GoogleMap(
                  zoomControlsEnabled: true,
                  scrollGesturesEnabled: true,
                  zoomGesturesEnabled: true,
                  initialCameraPosition: _initialCamera,
                  markers: _markers,
                  polylines: _polyline,
                  onMapCreated: (controller) =>
                      _mapController.complete(controller),
                  myLocationButtonEnabled: true,
                  mapType: MapType.normal,
                  onTap: _onMapTapped,
                ),
              ),
              Positioned(
                left: 0.0.w,
                right: 0.0.w,
                bottom: 0.0.h,
                child: !isConfirm
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
                          padding: REdgeInsets.symmetric(
                            horizontal: 24.0.w,
                            vertical: 10.0.h,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Row(
                                children: <Widget>[
                                  Expanded(
                                    child: Text(
                                      lang.lang == "en"
                                          ? 'Choose Package Size '
                                          : 'اختار حجم الطرد ',
                                      style: TextStyle(
                                        fontSize: 14.sp,
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
                                child: Center(
                                  child: Row(
                                    children: <Widget>[
                                      SizedBox(width: 10.w),
                                      Expanded(child: customRadio(lst[0], 0)),
                                      SizedBox(width: 10.w),
                                      Expanded(child: customRadio(lst[1], 1)),
                                      SizedBox(width: 10.w),
                                      Expanded(child: customRadio(lst[2], 2)),
                                      SizedBox(width: 10.w),
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(height: 6.h),
                              Row(
                                children: <Widget>[
                                  Expanded(
                                    child: Text(
                                      lang.lang == "en"
                                          ? 'Distance: $distance km'
                                          : 'المسافة: $distance كم',
                                      style: TextStyle(
                                        fontSize: 14.sp,
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
                                    child: Text(
                                      lang.lang == "en"
                                          ? 'Choose Payment Method'
                                          : ' اختر  نظام الدفع  ',
                                      style: TextStyle(
                                        fontSize: 14.sp,
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
                                child: Center(
                                  child: Row(
                                    children: [
                                      SizedBox(width: 10.w),
                                      Expanded(child: customRadio2(lst2[0], 0)),
                                      SizedBox(width: 10.w),
                                      Expanded(child: customRadio2(lst2[1], 1)),
                                      SizedBox(width: 10.w),
                                    ],
                                  ),
                                ),
                              ),

                              SizedBox(height: 6.h),

                              Row(
                                children: <Widget>[
                                  Expanded(
                                    child: Text(
                                      lang.lang == "en"
                                          ? 'Enter Package Price  '
                                          : '  ادخل سعر الطرد  ',
                                      style: TextStyle(
                                        fontSize: 14.sp,
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
                                    child: SizedBox(
                                      height: 60.h,
                                      child: TextFormField(
                                        controller: price,
                                        validator: validprice,

                                        keyboardType: TextInputType.number,
                                        style: TextStyle(
                                          fontSize: 15.sp,
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        maxLength: 30,
                                        onFieldSubmitted: (val) {
                                          setState(() {
                                            _price = val;
                                          });
                                        },
                                        onChanged: (value) {
                                          setState(() {
                                            _price = value;
                                          });
                                        },
                                        decoration: InputDecoration(
                                          hintText: lang.lang == "en"
                                              ? "Package Price"
                                              : "  سعر الطرد ",
                                          hintStyle: TextStyle(
                                            fontSize: 14.sp.h,
                                            color: Colors.black,
                                            fontWeight: FontWeight.bold,
                                          ),

                                          fillColor: Colors.white,
                                          filled: true,
                                          prefixIcon: Padding(
                                            padding: REdgeInsets.only(left: 5.w),
                                            child: Icon(
                                              Icons.money,
                                              color: Colors.blue,
                                            ),
                                          ),

                                          labelText: lang.lang == "en"
                                              ? "Package Price"
                                              : "  سعر الطرد ",
                                          labelStyle: TextStyle(
                                            fontSize: 12.sp,
                                            color: Colors.black,
                                            fontWeight: FontWeight.w500,
                                          ),
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              20,
                                            ),
                                            borderSide: BorderSide(
                                              color: Colors.blue,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              Row(
                                children: <Widget>[
                                  SizedBox(width: 10.w),

                                  Expanded(
                                    child: ElevatedButton.icon(
                                      onPressed: () async {
                                        if (isConfirm) {
                                          _showSnackBar(
                                            lang,
                                            en: 'Please wait to Response your order have sended ...',
                                            ar: 'الرجاء الانتظار للرد على طلبك الذي تم إرساله...',
                                          );
                                        } else {
                                          double distance = double.parse(
                                            this.distance ?? '',
                                          );
                                          double cost = 0.0;

                                          late double PPKS,
                                              PPKM,
                                              PPKL,
                                              min_charge,
                                              cash_cc,
                                              percentage,
                                              commission,
                                              shipper_pay;

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

                                            var reposnsebody = jsonDecode(
                                              response.body,
                                            );

                                            if (reposnsebody["data"] != null) {
                                              PPKS = double.parse(
                                                reposnsebody["data"]["PPKS"]
                                                    .toString(),
                                              );
                                              PPKM = double.parse(
                                                reposnsebody["data"]["PPKM"]
                                                    .toString(),
                                              );
                                              PPKL = double.parse(
                                                reposnsebody["data"]["PPKL"]
                                                    .toString(),
                                              );
                                              min_charge = double.parse(
                                                reposnsebody["data"]["min_charge"]
                                                    .toString(),
                                              );
                                              cash_cc = double.parse(
                                                reposnsebody["data"]["cash_cc"]
                                                    .toString(),
                                              );
                                              percentage = double.parse(
                                                reposnsebody["data"]["percentage"]
                                                    .toString(),
                                              );

                                              if (_size == "small") {
                                                cost = PPKS;
                                              } else if (_size == "medium") {
                                                cost = PPKM;
                                              } else if (_size == "large") {
                                                cost = PPKL;
                                              }

                                              if (cost < min_charge)
                                                cost = min_charge;

                                              if (_priceCheck == "cash") {
                                                cost = (cost * cash_cc);
                                              }

                                              commission =
                                                  (percentage / 100) * cost;
                                              shipper_pay = cost - commission;

                                              setState(() {
                                                this.cost = cost.toString();
                                              });
                                            }
                                          } catch (e) {
                                            await _showNetworkErrorDialog(lang);
                                            return;
                                          }

                                          if (_price != "default") {
                                            try {
                                              String url =
                                                  "https://www.ordervite.com/api/supplier/orders";

                                              var response = await http.post(
                                                Uri.parse(url),
                                                body: {
                                                  "supplier_id": id.toString(),
                                                  "cost": this.cost.toString(),
                                                  "size": _size,
                                                  "price": _price,
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
                                                  'percentage': percentage
                                                      .toString(),
                                                  'shipper_pay': shipper_pay
                                                      .toStringAsFixed(2),
                                                  'commission': commission
                                                      .toStringAsFixed(2),
                                                },
                                                headers: {
                                                  'Authorization':
                                                      'Bearer $token',
                                                },
                                              );

                                              var reposnsebody = jsonDecode(
                                                response.body,
                                              );

                                              setState(() {
                                                isConfirm = true;
                                                order_id =
                                                    reposnsebody["data"]["id"]
                                                        .toString();
                                                order_cost =
                                                    reposnsebody["data"]["cost"]
                                                        .toString();
                                                order_price =
                                                    reposnsebody["data"]["price"]
                                                        .toString();
                                                order_pricecheck =
                                                    reposnsebody["data"]["pricecheck"]
                                                        .toString();
                                                order_state =
                                                    reposnsebody["data"]["order_state"]
                                                        .toString();
                                              });

                                              _showSnackBar(
                                                lang,
                                                en: 'Your order is created successfully, please wait for a shipper confirmation ...',
                                                ar: 'تم إنشاء طلبك بنجاح، يُرجى انتظار التأكيد من قِبل مسئول الشحن...',
                                              );
                                            } catch (e) {
                                              await _showNetworkErrorDialog(
                                                lang,
                                              );
                                              return;
                                            }
                                          } else {
                                            _showSnackBar(
                                              lang,
                                              en: 'Please fill all order entries',
                                              ar: 'يُرجى ملء جميع بيانات الطلب',
                                            );
                                          }
                                        }
                                      },
                                      icon: Icon(
                                        Icons.done_all,
                                        size: 20.sp,
                                      ),
                                      label: Text(
                                        lang.lang == "en"
                                            ? "Confirm"
                                            : "تأكيد ",
                                        style: TextStyle(
                                          fontSize: 12.sp,
                                          color: Colors.white,
                                        ),
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.green,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            12.0,
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
                                          isConfirm = false;
                                        });

                                        showDialog<bool>(
                                          context: context,
                                          builder: (c) => AlertDialog(
                                            title: Text(
                                              lang.lang == "en"
                                                  ? 'Confirm'
                                                  : 'تأكيد',
                                              style: TextStyle(
                                                color: Colors.red,
                                              ),
                                            ),
                                            content: Text(
                                              lang.lang == "en"
                                                  ? 'Are you sure you want to cancel?  '
                                                  : 'هل أنت متأكد أنك تريد الإلغاء؟',
                                              style: TextStyle(
                                                fontSize: 15.sp,
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
                                                  Navigator.pop(context);

                                                  Message message = Message(
                                                    lang.lang == "en"
                                                        ? "You have canceld"
                                                        : " تم الإلغاء ",
                                                  );

                                                  Navigator.pushNamedAndRemoveUntil(
                                                    context,
                                                    RoutesManager.suHome,
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
                                                    Navigator.of(context).pop(),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                      icon: Icon(Icons.cancel, size: 20.sp),
                                      label: Text(
                                        lang.lang == "en" ? "Cancel" : "إلغاء",
                                        style: TextStyle(
                                          fontSize: 12.sp,
                                          color: Colors.white,
                                        ),
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.red,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            12.0,
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
                          padding: REdgeInsets.symmetric(
                            horizontal: 16.w,
                            vertical: 12.h,
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
                              padding: REdgeInsets.all(12.r),

                              child: SuOrderStatesWidget(
                                lang: lang,
                                order_state: order_state ?? '',
                                isConfirm: isConfirm,
                                isShConfirm: isShConfirm,
                                isShReceived: isShReceived,
                                isShDelviered: isShDelviered,
                                order_id: order_id ?? '',
                                order_shippier_id: order_shippier_id ?? '',
                                order_cost: order_cost ?? '',
                                username: username ?? '',
                                showSnackBar: _showSnackBar,
                                showNetworkErrorDialog: _showNetworkErrorDialog,
                                id: id ?? '',
                                api_token: api_token ?? '',
                                token: token ?? '',
                                order_price: order_price ?? '',
                                order_pricecheck: order_pricecheck ?? '',
                                isConfirmOrder: isConfirmOrder,
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
        final result = await showDialog<bool>(
          context: context,
          builder: (c) => AlertDialog(
            title: Text(
              lang.lang == "en" ? 'Warning' : 'تحذير',
              style: TextStyle(color: Colors.red),
            ),
            content: Text(
              lang.lang == "en"
                  ? 'Please you cant exist until order complete  '
                  : 'من فضلك انتظر حتي يتم اكتمال مراحل الطلب ',
              style: TextStyle(fontSize: 15.sp, color: Colors.red),
            ),
            actions: [],
          ),
        );

        return result ?? false;
      },
    );
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
        c = list[index++] - 63;
        result |= (c & 0x1f) << shift;
        shift += 5;
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

    List<LatLng> res = [];
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

class Steps {
  LatLng startLocation;
  LatLng endLocation;

  Steps({required this.startLocation, required this.endLocation});

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
