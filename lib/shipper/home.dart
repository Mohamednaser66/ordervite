import 'dart:async';
import 'dart:convert';
import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_maps/classes.dart';
import 'package:flutter_maps/core/colors_manager.dart';
import 'package:flutter_maps/core/images_manager.dart';
import 'package:flutter_maps/lang.dart';
import 'package:flutter_maps/main.dart';
import 'package:flutter_maps/shipper/shipper_drawer.dart';
import 'package:flutter_maps/shipper/widgets/order_named_icon.dart';

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:location/location.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../core/map_utils.dart';

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
  bool isLoading = false;
  late final StreamController<List<dynamic>?> _orderController;
  dynamic order_id_session;
  dynamic order_data_session;

  late Map<String, dynamic> formData;
  Timer? timer;
  String data = "";
  String? statename;
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  Map<String, String> get _authHeaders {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  void _showSnackBar(
    String message, {
    Color backgroundColor = Colors.redAccent,
  }) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: backgroundColor,
        content: Text(
          message,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.sp),
        ),
      ),
    );
  }

  Future<LocationData?> _getCurrentLocation() async {
    final locationService = Location();
    bool serviceEnabled = await locationService.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await locationService.requestService();
      if (!serviceEnabled) {
        _showSnackBar(
          Lang.of(context).lang == 'en'
              ? 'Location services are disabled.'
              : 'خدمات الموقع معطلة.',
        );
        return null;
      }
    }

    PermissionStatus permissionGranted = await locationService.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await locationService.requestPermission();
    }

    if (permissionGranted != PermissionStatus.granted &&
        permissionGranted != PermissionStatus.grantedLimited) {
      _showSnackBar(
        Lang.of(context).lang == 'en'
            ? 'Location permission denied.'
            : 'تم رفض إذن الموقع.',
      );
      return null;
    }

    try {
      return await locationService.getLocation();
    } catch (error) {
      debugPrint('Location read failed: $error');
      _showSnackBar(
        Lang.of(context).lang == 'en'
            ? 'Unable to determine current location.'
            : 'غير قادر على تحديد الموقع الحالي.',
      );
      return null;
    }
  }

  void _updateMarker(LatLng position) async {
    final icon = await BitmapDescriptor.asset(
      ImageConfiguration(size: Size(20.w, 20.h)),
      ImagesManager.cycle,
    );

    _markers
      ..clear()
      ..add(
        Marker(
          markerId: const MarkerId('1'),
          position: position,
          infoWindow: InfoWindow(title: username),
          icon: icon,
        ),
      );

    setState(() {});
  }

  Future<void> _updateLocationOnServer(LocationData locationData) async {
    if (id == null || token == null) return;

    final shipperId = int.tryParse(id!);
    if (shipperId == null) return;

    try {
      final response = await http.put(
        Uri.parse(
          'https://www.ordervite.com/api/shippier/location_update/$shipperId',
        ),
        headers: _authHeaders,
        body: {
          'cur_longitude': locationData.longitude?.toString() ?? '0',
          'cur_latitude': locationData.latitude?.toString() ?? '0',
        },
      );

      if (response.statusCode != 200) {
        debugPrint('Location update returned ${response.statusCode}');
        return;
      }

      final responseBody = jsonDecode(response.body);
      final verified = responseBody['data']?['verified']?.toString();
      if (verified == '0' || verified == '2') {
        if (!mounted) return;
        setState(() {
          isVerifed = false;
        });
      }
    } catch (error) {
      debugPrint('Location update failed: $error');
    }
  }

  Future<void> getPref() async {
    setState(() {
      isLoading = true;
    });

    try {
      final preferences = await SharedPreferences.getInstance();

      order_id_session = preferences.get('order_id_session');
      if (order_id_session != null) {
        order_data_session = preferences.get('order_data $order_id_session');
      }
      username =
          preferences.getString('gmailName') ??
          preferences.getString('username');
      email =
          preferences.getString('gmailEmail') ?? preferences.getString('email');
      token =
          preferences.getString('gmailToken') ?? preferences.getString('token');
      id = preferences.getString('gmailToken') ?? preferences.getString('id');
      if (username != null && email != null && token != null && id != null) {
        if (mounted) {
          setState(() {
            isSignIn = true;
          });
        }
      }

      if (token == null || id == null) {
        if (mounted) {
          setState(() {
            isLoading = false;
          });
        }
        return;
      }

      final shipperId = int.tryParse(id!);
      if (shipperId == null) {
        _showSnackBar(
          Lang.of(context).lang == 'en'
              ? 'Invalid user identifier.'
              : 'معرف المستخدم غير صالح.',
        );
        if (mounted) {
          setState(() {
            isLoading = false;
          });
        }
        return;
      }

      try {
        final response = await http.get(
          Uri.parse('https://www.ordervite.com/api/shippier/show/$shipperId'),
          headers: _authHeaders,
        );

        if (response.statusCode != 200) {
          _showSnackBar(
            Lang.of(context).lang == 'en'
                ? 'Unable to load profile information.'
                : 'لا يمكن تحميل معلومات الملف الشخصي.',
          );
          if (mounted) {
            setState(() {
              isLoading = false;
            });
          }
          return;
        }

        final responseBody = jsonDecode(response.body);
        if (responseBody['success'] != true || responseBody['data'] == null) {
          _showSnackBar(
            Lang.of(context).lang == 'en'
                ? 'Profile data is unavailable.'
                : 'بيانات الملف الشخصي غير متوفرة.',
          );
          if (mounted) {
            setState(() {
              isLoading = false;
            });
          }
          return;
        }

        final data = responseBody['data'];
        final fetchedLogo = data['logo']?.toString();
        final userEmail = data['name']?['email']?.toString();
        final userName = data['name']?['name']?.toString();

        if (!mounted) return;
        setState(() {
          logo_src = fetchedLogo;
          if (logo_src != null) {
            preferences.setString('logo_src', logo_src!);
          }
          if (userEmail != null) {
            email = userEmail;
            preferences.setString('email', userEmail);
          }
          if (userName != null) {
            username = userName;
            preferences.setString('username', userName);
          }
        });
      } catch (error) {
        debugPrint('Profile fetch failed: $error');
        _showSnackBar(
          Lang.of(context).lang == 'en'
              ? 'Failed to load profile. Please try again.'
              : 'فشل تحميل الملف الشخصي. حاول مرة أخرى.',
        );
        if (mounted) {
          setState(() {
            isLoading = false;
          });
        }
        return;
      }

      final location = await _getCurrentLocation();
      final currentLocation = location != null
          ? LatLng(location.latitude ?? 0, location.longitude ?? 0)
          : const LatLng(30.0444, 31.2357);

      if (!mounted) return;
      setState(() {
        _initialCamera = CameraPosition(target: currentLocation, zoom: 14.0);
        sourceLatLong = currentLocation;
        _updateMarker(currentLocation);
        isLoading = false;
      });

      _mapController.future.then((controller) {
        controller.animateCamera(
          CameraUpdate.newLatLngZoom(currentLocation, 14.0),
        );
      });

      if (location != null) {
        await _updateLocationOnServer(location);
      }
    } catch (error) {
      debugPrint('getPref failed: $error');
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
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
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.sp),
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
    _init();
    _orderController = StreamController<List<dynamic>?>.broadcast();

    timer = Timer.periodic(const Duration(seconds: 10), (_) {
      if (mounted) {
        loaddailyOrders();
      }
    });

    FirebaseMessaging.onMessage.listen(handleMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(handleMessage);

    _initialize();
  }

  Future<void> _init() async {
    await initNotifications();

    await Future.delayed(Duration(milliseconds: 500));

    final trackingStatus =
        await AppTrackingTransparency.trackingAuthorizationStatus;

    if (trackingStatus == TrackingStatus.notDetermined) {
      await AppTrackingTransparency.requestTrackingAuthorization();
    }
  }

  Future<void> _initialize() async {
    await getPref();
    await _registerFcmToken();
    await loaddailyOrders();
    await checkInitialMessage();

    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) {
        showMessage();
      }
    });
  }

  Future<void> _registerFcmToken() async {
    try {
      final fcmToken = await _firebaseMessaging.getToken();
      if (fcmToken == null || id == null || token == null) return;

      final url = 'https://www.ordervite.com/api/shippier/complete_profile/$id';
      await http.put(
        Uri.parse(url),
        body: {'api_token': fcmToken},
        headers: _authHeaders,
      );
    } catch (error) {
      debugPrint('FCM registration failed: $error');
    }
  }

  Future<List<dynamic>?> getdailyOrders() async {
    final preferences = await SharedPreferences.getInstance();
    final lang = Lang.of(context);
    token = preferences.getString('token');

    if (token == null) {
      debugPrint('Daily orders prevented: missing auth token.');
      return null;
    }

    try {
      final response = await http.get(
        Uri.parse('https://www.ordervite.com/api/shippier/daily/orders'),
        headers: _authHeaders,
      );

      if (response.statusCode != 200) {
        _showSnackBar(
          lang.lang == 'en'
              ? 'Unable to load daily orders.'
              : 'غير قادر على تحميل الطلبات اليومية.',
        );
        return null;
      }

      final responseBody = jsonDecode(response.body);
      final orders = responseBody['data'] as List<dynamic>?;

      if (orders != null && orders.length > order_num) {
        if (!mounted) return orders;

        setState(() {
          data = responseBody.toString();
          order_num = orders.length;
        });

        if (order_num >= 1) {
          _showSnackBar(
            lang.lang == 'en'
                ? 'There are $order_num orders you can match'
                : 'هناك $order_num طلب يمكنك مشاهدتهم',
          );
        }
      }
      return orders;
    } catch (error) {
      debugPrint('Daily orders request failed: $error');
      _showSnackBar(
        lang.lang == 'en'
            ? 'Failed to load orders. Please try again.'
            : 'فشل تحميل الطلبات. حاول مرة أخرى.',
      );
      return null;
    }
  }

  Future<void> loaddailyOrders() async {
    try {
      final res = await getdailyOrders();
      if (!_orderController.isClosed) {
        _orderController.add(res);
      }
    } catch (error) {
      debugPrint('loadDailyOrders failed: $error');
    }
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
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.sp),
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
              lang.lang == "en" ? "OrderVite" : "أوردرفيت",
              style: TextStyle(
                fontSize: 25.sp,
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
              if (isLoading)
                Positioned(
                  child: Container(
                    color: Colors.black54,
                    child: Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(ColorsManager.primaryGreen),
                        strokeWidth: 6.0,
                      ),
                    ),
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
              style: TextStyle(fontSize: 15.sp, color: Colors.red),
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
