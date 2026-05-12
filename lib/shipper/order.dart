import 'dart:async';
import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_maps/Core/routes_manager.dart';
import 'package:flutter_maps/classes.dart';
import 'package:flutter_maps/config/app_config.dart';
import 'package:flutter_maps/lang.dart';
import 'package:flutter_maps/shipper/order/presentation/shipper_order_cubit.dart';
import 'package:flutter_maps/shipper/widgets/chat_named_icon.dart';
import 'package:flutter_maps/shipper/widgets/sh_order_icons.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:location/location.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/map_utils.dart';

class ShOrder extends StatefulWidget {
  const ShOrder({Key? key}) : super(key: key);

  final String title = "OrderVite";

  @override
  _ShOrderState createState() => _ShOrderState();
}

class _ShOrderState extends State<ShOrder> {
  late CameraPosition _initialCamera;
  final Completer<GoogleMapController> _mapController = Completer();
  final Set<Marker> _markers = {};
  final Set<Polyline> _polyline = {};
  LatLng _sourceLatLong = const LatLng(30.059445, 31.1933067);
  LatLng _destinationLatLong = const LatLng(30.060671, 31.204131);
  LatLng? _currentLatLong;
  LatLng? _lastUpdatedLocation;

  String? _username;
  String? _email;
  String? _userId;
  String? _token;
  String? _apiToken;
  String? _orderId;
  String? _orderCost;
  String? _orderPriceCheck;
  String? _orderSupplierId;
  String? _orderPrice;
  String? _orderState;
  String? _disLat;
  String? _disLong;
  String? _sorLat;
  String? _sorLong;

  bool _isConfirm = false;
  bool _isReceived = false;
  bool _isDelivered = false;

  int _orderMessagesCount = 0;

  late final ShipperOrderCubit _cubit;
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  @override
  void initState() {
    super.initState();
    _cubit = ShipperOrderCubit();
    _listenToLocationChanges();
    _initializeFcm();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is! OrderData) return;
    final orderData = args;

    final prefs = await SharedPreferences.getInstance();

    _username =prefs.getString('gmailName')?? prefs.getString("username");
    _email =prefs.getString('gmailEmail')?? prefs.getString("email");
    _token =prefs.getString('gmailToken')?? prefs.getString("token");
    _userId = prefs.getString('gmailToken')??prefs.getString("id");

    setState(() {
      _disLat = orderData.disLat;
      _disLong = orderData.disLong;
      _sorLat = orderData.sorLat;
      _sorLong = orderData.sorlong;
      _orderId = orderData.order_id;
      _isConfirm = orderData.isConfirm;
      _orderCost = orderData.order_cost;
      _orderPrice = orderData.order_price;
      _orderPriceCheck = orderData.order_pricecheck;
      _orderSupplierId = orderData.order_supplier_id;
      _orderState = orderData.order_state;

      _sourceLatLong = LatLng(double.parse(_sorLat!), double.parse(_sorLong!));
      _destinationLatLong = LatLng(
        double.parse(_disLat!),
        double.parse(_disLong!),
      );
      _initialCamera = CameraPosition(target: _sourceLatLong, zoom: 14.0);
    });

    _markers.addAll([
      Marker(
        markerId: const MarkerId("1"),
        position: _sourceLatLong,
        infoWindow: const InfoWindow(title: "source"),
        icon: BitmapDescriptor.defaultMarker,
      ),
      Marker(
        markerId: const MarkerId("2"),
        position: _destinationLatLong,
        infoWindow: const InfoWindow(title: "destination"),
        icon: BitmapDescriptor.defaultMarker,
      ),
    ]);

    _cubit.fetchRoute(
      _sourceLatLong,
      _destinationLatLong,
      AppConfig.googleMapsApiKey,
    );

    if (_isConfirm && _userId != null && _token != null) {
      _cubit.listenToCurrentOrder(_userId!, _token!);
      _cubit.getUnreadMessageCount(_orderId ?? '', _token!);
    }
  }

  void _listenToLocationChanges() async {
    final location = Location();

    bool serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) return;
    }

    PermissionStatus permission = await location.hasPermission();
    if (permission == PermissionStatus.denied) {
      permission = await location.requestPermission();
      if (permission != PermissionStatus.granted) return;
    }

    location.onLocationChanged.listen((LocationData currentLocation) {
      if (currentLocation.latitude == null ||
          currentLocation.longitude == null) {
        return;
      }

      final currentLatLng = LatLng(
        currentLocation.latitude!,
        currentLocation.longitude!,
      );

      if (_lastUpdatedLocation == null ||
          _getDistance(_lastUpdatedLocation!, currentLatLng) > 50) {
        setState(() {
          _currentLatLong = currentLatLng;
          _lastUpdatedLocation = currentLatLng;
          _markers.removeWhere((marker) => marker.markerId.value == 'current');
          _markers.add(
            Marker(
              markerId: const MarkerId('current'),
              position: currentLatLng,
              infoWindow: const InfoWindow(title: 'Current location'),
              icon: BitmapDescriptor.defaultMarkerWithHue(
                BitmapDescriptor.hueAzure,
              ),
            ),
          );
        });
        _getPolyline();
        _updateCamera(currentLatLng, currentLocation.heading ?? 0.0);
      }
    });
  }

  Future<void> _updateCamera(LatLng latLng, double heading) async {
    final controller = await _mapController.future;
    controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: latLng,
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

  Future<void> _initializeFcm() async {
    _firebaseMessaging.getToken().then((fcmToken) async {
      if (_userId != null && _token != null && fcmToken != null) {
        await _cubit.updateFcmToken(_userId!, fcmToken, _token!);
        if (_orderId != null) {
          await _cubit.getUnreadMessageCount(_orderId!, _token!);
        }
      }
    });

    FirebaseMessaging.onMessage.listen(_handleFcmMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(_handleFcmMessage);
    FirebaseMessaging.instance.getInitialMessage().then((msg) {
      if (msg != null) _handleFcmMessage(msg);
    });
  }

  Future<void> _handleFcmMessage(RemoteMessage message) async {
    if (_token == null) return;

    final stateName = await _cubit.handleOrderStateMessage(
      message.data,
      _token!,
    );
    if (stateName == null) return;

    if (stateName == "order cancel") {
      _navigateToHome(
        "Order is canceled by supplier",
        "تم إلغاء الطلب من قِبل المورد",
      );
      return;
    }

    if (stateName == "order complete") {
      _navigateToHome("Order is complete", "تم اكمال الطلب بنجاح");
      return;
    }
  }

  String _loc(Lang lang, String en, String ar) => lang.lang == "en" ? en : ar;

  void _navigateToHome(String en, String ar) {
    if (!mounted) return;
    final lang = Lang.of(context);
    Navigator.pushNamedAndRemoveUntil(
      context,
      RoutesManager.shHome,
      (route) => false,
      arguments: Message(_loc(lang, en, ar)),
    );
  }

  void _showSnackBar(
    Lang lang, {
    required String en,
    required String ar,
    Color backgroundColor = Colors.redAccent,
  }) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: backgroundColor,
        content: Text(
          _loc(lang, en, ar),
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp),
        ),
      ),
    );
  }

  Future<void> _onConfirm(Lang lang) async {
    if (_isConfirm) {
      _showSnackBar(
        lang,
        en: 'Please wait, your order request is already sent...',
        ar: 'الرجاء الانتظار، تم إرسال طلبك بالفعل',
      );
      return;
    }

    try {
      final location = Location();
      final loc = await location.getLocation();

      if (loc.latitude == null || loc.longitude == null) {
        throw Exception("Location not available");
      }

      final confirmed = await showDialog<bool>(
        context: context,
        builder: (c) => AlertDialog(
          title: Text(
            _loc(lang, 'Confirm', 'تأكيد'),
            style: const TextStyle(color: Colors.red),
          ),
          content: Text(
            _loc(
              lang,
              'Are you sure you want to acquire this order?',
              'هل أنت متأكد أنك تريد استلام هذا الطلب؟',
            ),
            style: TextStyle(fontSize: 15.sp, color: Colors.red),
          ),
          actions: [
            TextButton(
              child: Text(_loc(lang, 'Yes', 'نعم')),
              onPressed: () => Navigator.of(c).pop(true),
            ),
            TextButton(
              child: Text(_loc(lang, 'No', 'لا')),
              onPressed: () => Navigator.of(c).pop(false),
            ),
          ],
        ),
      );

      // Real-time data sync: Refresh order when dialog closes
      if (confirmed == false && mounted && _userId != null && _token != null) {
        _cubit.refreshCurrentOrder(_userId!, _token!);
        return;
      }

      if (confirmed != true) return;

      if (_orderId == null || _userId == null || _token == null) return;

      final success = await _cubit.confirmOrder(
        orderId: _orderId!,
        shipperId: _userId!,
        token: _token!,
        latitude: loc.latitude!,
        longitude: loc.longitude!,
      );

      if (success && mounted) {
        setState(() {
          _isConfirm = true;
          _orderState = "shipper confirmed";
        });
        _showSnackBar(
          lang,
          en: 'Order confirmed successfully, go to supplier.',
          ar: 'تم تأكيد الطلب، توجه إلى المورد.',
          backgroundColor: Colors.green,
        );
        _cubit.listenToCurrentOrder(_userId!, _token!);
      }
    } catch (e) {
      _showSnackBar(
        lang,
        en: 'Please check your location & network',
        ar: 'يرجى التحقق من الموقع والإنترنت',
      );
    }
  }

  Future<void> _onReceive(Lang lang) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: Text(
          _loc(lang, 'Confirm', 'تاكيد'),
          style: const TextStyle(color: Colors.red),
        ),
        content: Text(
          _loc(lang, 'Confirm receiving the package?', 'تأكيد استلام الطلب؟'),
          style: TextStyle(fontSize: 15.sp),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c, true),
            child: Text(_loc(lang, 'Yes', 'نعم')),
          ),
          TextButton(
            onPressed: () => Navigator.pop(c, false),
            child: Text(_loc(lang, 'No', 'لا')),
          ),
        ],
      ),
    );

    if (confirmed == false && mounted && _userId != null && _token != null) {
      _cubit.refreshCurrentOrder(_userId!, _token!);
      return;
    }

    if (confirmed != true || _orderId == null || _token == null) return;

    final success = await _cubit.receiveOrder(
      orderId: _orderId!,
      token: _token!,
    );

    if (success && mounted) {
      setState(() {
        _isReceived = true;
        _orderState = "order received";
      });
      _showSnackBar(
        lang,
        en: 'Order received successfully',
        ar: 'تم استلام الطلب بنجاح',
        backgroundColor: Colors.green,
      );
      await _updateSourceToDestinationPolyline();
    }
  }

  Future<void> _onDeliver(Lang lang) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: Text(
          _loc(lang, 'Confirm', 'تاكيد'),
          style: const TextStyle(color: Colors.red),
        ),
        content: Text(
          _loc(
            lang,
            'Please confirm that you have delivered the package',
            'من فضلك قم بتاكيد تسليم الشحنة',
          ),
          style: TextStyle(fontSize: 14.sp, color: Colors.red),
        ),
        actions: [
          TextButton(
            child: Text(_loc(lang, 'Yes', 'نعم')),
            onPressed: () async {
              final success = await _cubit.deliverOrder(
                orderId: _orderId!,
                token: _token!,
                supplierApiToken: _apiToken ?? '',
                lang: lang,
              );
              if (success && mounted) {
                setState(() {
                  _isDelivered = true;
                  _orderState = "order delivered";
                });
                _showSnackBar(
                  lang,
                  en: 'Well Done! ',
                  ar: 'أحسنت ',
                  backgroundColor: Colors.green,
                );
              }
              Navigator.pushNamedAndRemoveUntil(
                context,
                RoutesManager.shHome,
                (route) => true,
              );
            },
          ),
          TextButton(
            child: Text(_loc(lang, 'No', 'لا')),
            onPressed: () => Navigator.of(c).pop(false),
          ),
        ],
      ),
    );

    if (confirmed == false && mounted && _userId != null && _token != null) {
      _cubit.refreshCurrentOrder(_userId!, _token!);
    }
  }

  Future<void> _onCancel(Lang lang) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: Text(
          _loc(lang, 'Confirm', 'تاكيد'),
          style: const TextStyle(color: Colors.red),
        ),
        content: Text(
          _loc(
            lang,
            'Are you sure you want to cancel the order (a fine may apply)',
            'هل أنت متأكد أنك تريد إلغاء الطلب (قد يتم تطبيق غرامة)؟',
          ),
          style: TextStyle(fontSize: 15.sp, color: Colors.red),
        ),
        actions: [
          TextButton(
            child: Text(_loc(lang, 'Yes', 'نعم')),
            onPressed: () => Navigator.of(c).pop(true),
          ),
          TextButton(
            child: Text(_loc(lang, 'No', 'لا ')),
            onPressed: () => Navigator.of(c).pop(false),
          ),
        ],
      ),
    );

    if (confirmed == false && mounted && _userId != null && _token != null) {
      _cubit.refreshCurrentOrder(_userId!, _token!);
      return;
    }

    if (confirmed != true ||
        _orderId == null ||
        _userId == null ||
        _token == null ||
        _username == null) {
      return;
    }

    final success = await _cubit.cancelOrder(
      orderId: _orderId!,
      shipperId: _userId!,
      username: _username!,
      token: _token!,
      supplierApiToken: _apiToken ?? '',
      lang: lang,
    );

    if (success && mounted) {
      _navigateToHome("Order canceled", "تم إلغاء الطلب");
    }
  }

  Future<void> _getPolyline() async {
    await _updateCurrentToSourcePolyline();
    await _updateSourceToDestinationPolyline();
  }

  Future<List<LatLng>> _fetchRoutePoints(
    LatLng origin,
    LatLng destination,
  ) async {
    final url =
        "https://maps.googleapis.com/maps/api/directions/json?"
        "origin=${origin.latitude},${origin.longitude}"
        "&destination=${destination.latitude},${destination.longitude}"
        "&key=${AppConfig.googleMapsApiKey}";

    try {
      final response = await http
          .get(Uri.parse(url))
          .timeout(const Duration(seconds: 10));
      if (response.statusCode != 200) return [];

      final json = jsonDecode(response.body);
      if (json['routes'] == null || (json['routes'] as List).isEmpty) {
        return [];
      }

      final route = json['routes'][0];
      final encodedPoints = route['overview_polyline']?['points'] as String?;
      if (encodedPoints == null || encodedPoints.isEmpty) {
        return [];
      }

      return decodePolyline(encodedPoints);
    } catch (e) {
      debugPrint('Error fetching route points: $e');
      return [];
    }
  }

  Future<void> _updateCurrentToSourcePolyline() async {
    if (_currentLatLong == null) return;
    final points = await _fetchRoutePoints(_currentLatLong!, _sourceLatLong);
    if (points.isEmpty) return;

    setState(() {
      _polyline.removeWhere(
        (p) => p.polylineId == const PolylineId('current_source_route'),
      );
      _polyline.add(
        Polyline(
          polylineId: const PolylineId('current_source_route'),
          visible: true,
          width: 5,
          points: points,
          color: Colors.green,
          startCap: Cap.roundCap,
          endCap: Cap.roundCap,
        ),
      );
    });
  }

  Future<void> _updateSourceToDestinationPolyline() async {
    final points = await _fetchRoutePoints(_sourceLatLong, _destinationLatLong);
    if (points.isEmpty) return;

    setState(() {
      _polyline.removeWhere(
        (p) => p.polylineId == const PolylineId('source_destination_route'),
      );
      _polyline.add(
        Polyline(
          polylineId: const PolylineId('source_destination_route'),
          visible: true,
          width: 5,
          points: points,
          color: Colors.blue,
          startCap: Cap.roundCap,
          endCap: Cap.roundCap,
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final lang = Lang.of(context);

    return BlocProvider.value(
      value: _cubit,
      child: BlocListener<ShipperOrderCubit, ShipperOrderState>(
        listener: (context, state) {
          if (state is ShipperOrderRouteLoaded) {
            setState(() {
              _polyline.removeWhere(
                (p) =>
                    p.polylineId ==
                    const PolylineId('source_destination_route'),
              );
              _polyline.add(
                Polyline(
                  polylineId: const PolylineId('source_destination_route'),
                  visible: true,
                  width: 5,
                  points: state.polylinePoints,
                  color: Colors.blue,
                  startCap: Cap.roundCap,
                  endCap: Cap.roundCap,
                ),
              );
            });
          }

          if (state is ShipperOrderCurrentLoaded && state.orderData != null) {
            final data = state.orderData!;
            final newState = data['order_state']?.toString() ?? _orderState;

            setState(() {
              _orderState = newState;
              if (newState == "shipper confirmed") {
                _isConfirm = true;
              } else if (newState == "order received") {
                _isConfirm = true;
                _isReceived = true;
              } else if (newState == "order delivered") {
                _isConfirm = true;
                _isReceived = true;
                _isDelivered = true;
              }

              _orderCost = data['cost']?.toString() ?? _orderCost;
              _orderPrice = data['price']?.toString() ?? _orderPrice;
              _orderSupplierId =
                  data['supplier_id']?.toString() ?? _orderSupplierId;
            });
          }

          if (state is ShipperOrderStatusChanged) {
            final data = state.orderData;
            final newState = data['order_state']?.toString() ?? '';
            _showSnackBar(
              lang,
              en: 'Order status updated: $newState',
              ar: 'تم تحديث حالة الطلب: $newState',
              backgroundColor: Colors.green,
            );
          }

          if (state is ShipperOrderMessageCountUpdated) {
            setState(() => _orderMessagesCount = state.count);
          }

          if (state is ShipperOrderError) {
            _showSnackBar(lang, en: state.message, ar: state.message);
          }

          if (state is ShipperOrderCancelled) {
            _navigateToHome("Order canceled", "تم إلغاء الطلب");
          }

          if (state is ShipperOrderCompleted) {
            _navigateToHome("Order is complete", "تم اكمال الطلب بنجاح");
          }
        },
        child: WillPopScope(
          onWillPop: () async {
            await showDialog(
              context: context,
              builder: (c) => AlertDialog(
                title: Text(
                  _loc(lang, 'Warning', 'تحذير'),
                  style: const TextStyle(color: Colors.red),
                ),
                content: Text(
                  _loc(
                    lang,
                    'Please you cant exit until order complete',
                    'من فضلك انتظر حتي يتم اكتمال مراحل الطلب',
                  ),
                  style: const TextStyle(fontSize: 15, color: Colors.red),
                ),
              ),
            );
            return false;
          },
          child: Directionality(
            textDirection: lang.lang == "en"
                ? TextDirection.ltr
                : TextDirection.rtl,
            child: Scaffold(
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
                actions: [
                  ChatNamedIcon(
                    text: lang.lang == "en" ? 'Chats' : 'محادثات ',
                    iconData: Icons.message,
                    order_id: _orderId ?? '',
                    notificationCount: _orderMessagesCount,
                    api_token: _token ?? '',
                    disLat: _disLat ?? '',
                    disLong: _disLong ?? '',
                    sorLat: _sorLat ?? '',
                    sorlong: _sorLong ?? '',
                    isConfirm: _isConfirm,
                    order_cost: _orderCost ?? '',
                    order_price: _orderPrice ?? '',
                    order_pricecheck: _orderPriceCheck ?? '',
                    order_state: _orderState ?? '',
                    order_supplier_id: _orderSupplierId ?? '',
                    order_shippier_id: _userId ?? '',
                    permission: _isConfirm,
                  ),
                ],
                automaticallyImplyLeading: false,
              ),
              body: Stack(
                children: [
                  Positioned.fill(
                    child: GoogleMap(
                      mapType: MapType.normal,
                      polylines: _polyline,
                      myLocationEnabled: true,
                      initialCameraPosition: _initialCamera,
                      onMapCreated: (controller) {
                        _mapController.complete(controller);
                      },
                      markers: _markers,
                    ),
                  ),
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: _buildBottomPanel(lang),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomPanel(Lang lang) {
    return Container(
      height: 300.h,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.topLeft,
          colors: [Color.fromRGBO(21, 42, 72, 1), Color.fromRGBO(7, 15, 33, 1)],
        ),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(18.0.r),
          topRight: Radius.circular(18.0.r),
        ),
      ),
      child: Padding(
        padding: REdgeInsets.symmetric(horizontal: 14.0, vertical: 12.0),
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildOrderStatusText(lang),
                SizedBox(height: 8.h),
                ShOrderIcons(
                  isConfirm: _isConfirm,
                  isDelviered: _isDelivered,
                  isReceived: _isReceived,
                ),
                SizedBox(height: 8.h),
                _buildInfoRow(
                  lang.lang == "en"
                      ? "Order ID: $_orderId"
                      : "كود الطلب :$_orderId",
                  lang.lang == "en"
                      ? "Supplier ID: $_orderSupplierId"
                      : "كود المورد : $_orderSupplierId",
                ),
                SizedBox(height: 8.h),
                _buildInfoRow(
                  lang.lang == "en"
                      ? "Shipping Cost: $_orderCost L.E."
                      : "تكلفة الشحن : $_orderCost جم",
                  lang.lang == "en"
                      ? "Package Price: $_orderPrice L.E."
                      : "سعر الشحنة : $_orderPrice جم",
                ),
                SizedBox(height: 6.h),
                _buildPaymentMethodText(lang),
                SizedBox(height: 10.h),
                _buildActionButtons(lang),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOrderStatusText(Lang lang) {
    String statusText;
    if (lang.lang == "en") {
      statusText = "Order State: ${_orderState ?? 'Unknown'}";
    } else {
      switch (_orderState) {
        case "new":
          statusText = "حالة الطلب : جديد";
          break;
        case "shipper confirmed":
          statusText = "حالة الطلب : تاكيد مسئول الشحن";
          break;
        case "order received":
          statusText = "حالة الطلب : استلام الشحنة";
          break;
        case "order delivered":
          statusText = "حالة الطلب : توصيل الشحنة";
          break;
        default:
          statusText = "حالة الطلب : توصيل الشحنة";
      }
    }
    return Row(
      children: [
        Expanded(
          child: Text(
            statusText,
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentMethodText(Lang lang) {
    String text;
    if (lang.lang == "en") {
      text = "Payment Method : $_orderPriceCheck";
    } else {
      text = _orderPriceCheck == "cash"
          ? "نظام الدفع : كاش"
          : "نظام الدفع : تحويل";
    }
    return Row(
      children: [
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String left, String right) {
    return Row(
      children: [
        Expanded(
          child: Text(
            left,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        SizedBox(width: 20.w),
        Expanded(
          child: Text(
            right,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(Lang lang) {
    if (_isDelivered) {
      return Container(
        decoration: BoxDecoration(
          color: Colors.green,
          borderRadius: BorderRadius.all(Radius.circular(18.0.r)),
        ),
        child: Padding(
          padding: EdgeInsets.all(3.r),
          child: Row(
            children: [
              SizedBox(width: 10.w),
              Expanded(
                child: Text(
                  lang.lang == "en"
                      ? "You have confirmed the package delivery, please wait for the supplier final confirmation"
                      : "لقد أكدت تسليم الطرد، يُرجى انتظار التأكيد النهائي للمورد",
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_isReceived) {
      return Row(
        children: [
          SizedBox(width: 10.w),
          Expanded(
            child: SizedBox(
              height: 40.h,
              child: TextButton.icon(
                onPressed: () => _onDeliver(lang),
                icon: Icon(Icons.done_all, size: 20.sp),
                label: Text(
                  lang.lang == "en" ? "Delivered PK " : "تسليم",
                  style: TextStyle(fontSize: 12.sp, color: Colors.white),
                ),
                style: TextButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0.r),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(width: 15.w),
          Expanded(
            child: SizedBox(
              height: 40.h,
              child: ElevatedButton.icon(
                onPressed: () => _onCancel(lang),
                icon: Icon(Icons.cancel, size: 20.sp),
                label: Text(
                  lang.lang == "en" ? "Cancel" : "إلغاء",
                  style: TextStyle(fontSize: 12.sp, color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0.r),
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    }

    if (_isConfirm) {
      return Row(
        children: [
          SizedBox(width: 10.w),
          Expanded(
            child: SizedBox(
              height: 40.h,
              child: TextButton.icon(
                onPressed: () => _onReceive(lang),
                icon: Icon(Icons.done_all, size: 20.sp),
                label: Text(
                  lang.lang == "en" ? "Received PK" : "استلام",
                  style: TextStyle(fontSize: 12.sp, color: Colors.white),
                ),
                style: TextButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0.r),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(width: 15.w),
          Expanded(
            child: SizedBox(
              height: 40.h,
              child: ElevatedButton.icon(
                onPressed: () => _onCancel(lang),
                icon: Icon(Icons.cancel, size: 20.sp),
                label: Text(
                  lang.lang == "en" ? "Cancel" : "إلغاء",
                  style: TextStyle(fontSize: 12.sp, color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0.r),
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    }

    return Row(
      children: [
        SizedBox(width: 10.w),
        Expanded(
          child: SizedBox(
            height: 40.h,
            child: TextButton.icon(
              onPressed: () => _onConfirm(lang),
              icon: Icon(Icons.done_all, size: 20.sp),
              label: Text(
                lang.lang == "en" ? "Confirm" : "تأكيد",
                style: TextStyle(fontSize: 12.sp, color: Colors.white),
              ),
              style: TextButton.styleFrom(
                backgroundColor: Colors.green,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0.r),
                ),
              ),
            ),
          ),
        ),
        SizedBox(width: 15.w),
        Expanded(
          child: SizedBox(
            height: 40.h,
            child: ElevatedButton.icon(
              onPressed: () => _onCancel(lang),
              icon: Icon(Icons.cancel, size: 20.sp),
              label: Text(
                lang.lang == "en" ? "Cancel" : "إلغاء",
                style: TextStyle(fontSize: 12.sp, color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0.r),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }
}
