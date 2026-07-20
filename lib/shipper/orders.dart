import 'dart:async';
import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_maps/classes.dart';
import 'package:flutter_maps/core/colors_manager.dart';
import 'package:flutter_maps/core/routes_manager.dart';
import 'package:flutter_maps/lang.dart';
import 'package:flutter_maps/services/realtime_service.dart';
import 'package:flutter_maps/shipper/shipper_drawer.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:location/location.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ShOrders extends StatefulWidget {
  const ShOrders({Key? key}) : super(key: key);

  final String title = "OrderVite";

  @override
  _ShOrdersState createState() => _ShOrdersState();
}

class _ShOrdersState extends State<ShOrders> {
  final Set<Marker> _markers = {};
  final RealtimeService _realtimeService = RealtimeService();

  LatLng _sourceLatLong = const LatLng(30.059445, 31.1933067);

  String? _username;
  String? _email;
  String? _id;
  String? _token;
  String? _logoSrc;

  bool _isSignIn = false;
  bool _isMessage = true;

  int _orderNum = 0;
  String? _statename;

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  Future<void> _getPreferences() async {
    final prefs = await SharedPreferences.getInstance();

    _username = prefs.getString("username");
    _email = prefs.getString("email");
    _token = prefs.getString("token");
    _logoSrc = prefs.getString("logo_src");
    _id = prefs.getString("id");

    if (_username != null && _email != null) {
      setState(() => _isSignIn = true);
    }

    final location = Location();
    final loc = await location.getLocation();

    setState(() {
      _sourceLatLong = LatLng(loc.latitude ?? 0, loc.longitude ?? 0);
    });

    _markers.add(
      Marker(
        markerId: const MarkerId("1"),
        position: _sourceLatLong,
        infoWindow: InfoWindow(title: _username ?? ''),
        icon: BitmapDescriptor.defaultMarker,
        visible: true,
      ),
    );
  }

  void _handleFcmMessage(RemoteMessage message) {
    if (!mounted) return;

    final stateName = message.data["state_name"] ?? "";
    final stateType = message.data["state_type"] ?? "";

    setState(() => _statename = stateName);

    if (stateName == "new order" || stateName == "order cancel") {
      // Stream will auto-update, but we can show a snackbar
      final lang = Lang.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.green,
          content: Text(
            lang.lang == "en" ? 'New orders available' : 'طلبات جديدة متاحة',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.sp),
          ),
        ),
      );
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

  Future<void> _firebaseMessagingBackgroundHandler(
    RemoteMessage message,
  ) async {
    await Firebase.initializeApp();
    debugPrint('Handling background message: ${message.messageId}');
  }

  void _showInitialMessage() {
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args == null || args is! Message) return;

    if (_isMessage) {
      final messageShow = args.message;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.redAccent,
          content: Text(
            messageShow,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.sp),
          ),
        ),
      );
      setState(() => _isMessage = false);
    }
  }

  @override
  void initState() {
    super.initState();
    _getPreferences();

    _firebaseMessaging.getToken().then((fcmToken) async {
      if (_id != null && _token != null && fcmToken != null) {
        final url =
            "https://www.ordervite.com/api/shippier/complete_profile/$_id";
        await http.put(
          Uri.parse(url),
          body: {"api_token": fcmToken},
          headers: {'Authorization': 'Bearer $_token'},
        );
      }
    });

    FirebaseMessaging.onMessage.listen(_handleFcmMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(_handleFcmMessage);
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }

  bool _isInit = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isInit) {
      Future.delayed(const Duration(seconds: 5), () {
        if (!mounted) return;
        _showInitialMessage();
      });
      _isInit = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = Lang.of(context);

    return Directionality(
      textDirection: lang.lang == "en" ? TextDirection.ltr : TextDirection.rtl,
      child: Scaffold(
        drawer: ShipperDrawer(
          username: _username ?? '',
          email: _email ?? '',
          lang: lang,
          isSignIn: _isSignIn, id: _id??'',
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
        body: StreamBuilder<List<dynamic>?>(
          stream: _realtimeService.getShipperDailyOrdersStream(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting &&
                !snapshot.hasData) {
              return const Center(
                child: CircularProgressIndicator(
                  color: ColorsManager.primaryGreen,
                ),
              );
            }

            if (snapshot.hasError) {
              return Center(
                child: Text(
                  lang.lang == "en"
                      ? 'Error loading orders'
                      : 'خطأ في تحميل الطلبات',
                ),
              );
            }

            final orders = snapshot.data ?? [];

            if (orders.isEmpty) {
              return Center(
                child: Text(
                  lang.lang == "en"
                      ? 'No orders available'
                      : 'لا توجد طلبات متاحة',
                  style: TextStyle(fontSize: 18.sp),
                ),
              );
            }

            if (orders.length > _orderNum && _orderNum > 0) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: Colors.redAccent,
                    content: Text(
                      lang.lang == "en"
                          ? 'There are ${orders.length} orders you can match'
                          : ' هناك ${orders.length} طلبات يمكنك مشاهدتهم',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18.sp,
                      ),
                    ),
                  ),
                );
              });
            }
            _orderNum = orders.length;

            return ListView.builder(
              itemCount: orders.length,
              itemBuilder: (context, index) {
                final order = orders[index];
                final id = order["id"]?.toString() ?? '';
                final size = order["size"]?.toString() ?? '';
                final cost = order["cost"]?.toString() ?? '';
                final orderNote =
                    order["order_note"]?.toString() ??
                    order["orderNote"]?.toString();

                String sizeLabel;
                if (lang.lang == "en") {
                  sizeLabel = "Size: $size";
                } else {
                  sizeLabel = size == "small"
                      ? " الحجم : صغير"
                      : size == "medium"
                      ? " الحجم : وسط"
                      : " الحجم : كبير";
                }

                return ListTile(
                  title: Text(
                    "${lang.lang == "en" ? "id : " : "الكود:"}$id    $sizeLabel",
                  ),
                  subtitle: Text(
                    "${lang.lang == "en" ? "cost " : "التكلفة "}$cost${lang.lang == "en" ? " EGP " : " جم "}",
                  ),
                  onTap: () {
                    final orderData = OrderData(
                      order["dist_latitude"]?.toString() ?? '',
                      order["so_latitude"]?.toString() ?? '',
                      order["dist_longitude"]?.toString() ?? '',
                      order["so_longitude"]?.toString() ?? '',
                      id,
                      false,
                      order["cost"]?.toString() ?? '',
                      order["price"]?.toString() ?? '',
                      order["pricecheck"]?.toString() ?? '',
                      order["order_state"]?.toString() ?? '',
                      order["supplier_id"]?.toString() ?? '',
                      orderNote: orderNote?.trim().isNotEmpty == true
                          ? orderNote
                          : null, destinationAddress: order["destination_address"], sourceAddress: order["source_address"],


                    );
                    Navigator.pushNamed(
                      context,
                      RoutesManager.shOrder,
                      arguments: orderData,
                    );
                  },
                  leading: CircleAvatar(
                    backgroundColor: ColorsManager.primaryGreen,
                    child: Icon(
                      Icons.shopping_cart,
                      size: 20.sp,
                      color: Colors.white,
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    _realtimeService.dispose();
    super.dispose();
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
      onTap: onTap,
      child: Container(
        width: 72.w,
        padding: REdgeInsets.symmetric(horizontal: 8.w),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(iconData),
                Text(text, overflow: TextOverflow.ellipsis),
              ],
            ),
            Positioned(
              top: 0.h,
              right: 0.w,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                decoration: const BoxDecoration(
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
