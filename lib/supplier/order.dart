import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_maps/Core/routes_manager.dart';
import 'package:flutter_maps/classes.dart';
import 'package:flutter_maps/config/app_config.dart';
import 'package:flutter_maps/core/map_utils.dart';
import 'package:flutter_maps/lang.dart';
import 'package:flutter_maps/models/order.dart';
import 'package:flutter_maps/services/order_repository.dart';
import 'package:flutter_maps/supplier/models/named_icon.dart';
import 'package:flutter_maps/supplier/order/presentation/supplier_order__cubit.dart';
import 'package:flutter_maps/supplier/widgets/order_status_widget.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OrderPage extends StatefulWidget {
  const OrderPage({super.key});
  final String title = "OrderVite";
  @override
  State<OrderPage> createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> {
  final OrderRepository _orderRepository = OrderRepository();
  late final SupplierOrderCubit _cubit;
  CameraPosition? _initialCamera;
  final Completer<GoogleMapController> _mapController = Completer();
  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};
  final Location _locationTracker = Location();
  LatLng? _sourceLatLng;
  LatLng? _destinationLatLng;
  String? _username;
  String? _userId;
  String? _token;
  bool _isConfirm = false;
  String? _orderId;
  String? _orderCost;
  String? _orderPrice;
  String? _orderPriceCheck;
  String _orderShipperId = "....";
  String? _orderState;
  String? _shipperApiToken;
  int _unreadMessageCount = 0;
  bool _isShipperConfirmed = false;
  bool _isShipperReceived = false;
  bool _isShipperDelivered = false;
  bool _isConfirmOrder = false;
  String? _distance;

  final TextEditingController _priceController = TextEditingController();
  String _packageSize = 'small';
  String _paymentMethod = 'transfer';

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  String _loc(Lang lang, String en, String ar) => lang.lang == "en" ? en : ar;

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
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _cubit = SupplierOrderCubit(_orderRepository);
    _locationTracker.requestPermission();
    _initializeFcm();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is! OrderDist) return;
    final orderDist = args;

    final prefs = await SharedPreferences.getInstance();
    _username = prefs.getString("username");
    _token = prefs.getString("token");
    _userId = prefs.getString("id");

    setState(() {
      _isConfirm = orderDist.isConfirm;
      _orderId = orderDist.order_id;
      _orderCost = orderDist.order_cost;
      _orderPrice = orderDist.order_price;
      _orderPriceCheck = orderDist.order_pricecheck;
      _orderShipperId = orderDist.order_shippier_id ?? 'pending';
      _orderState = orderDist.order_state;

      _sourceLatLng = LatLng(
        double.parse(orderDist.sorLat.toString()),
        double.parse(orderDist.sorlong.toString()),
      );
      _destinationLatLng = LatLng(
        double.parse(orderDist.disLat.toString()),
        double.parse(orderDist.disLong.toString()),
      );
      _initialCamera = CameraPosition(target: _sourceLatLng!, zoom: 17.0);
    });

    _markers.addAll([
      Marker(
        markerId: const MarkerId("1"),
        position: _sourceLatLng!,
        infoWindow: const InfoWindow(title: "source"),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
      ),
      Marker(
        markerId: const MarkerId("2"),
        position: _destinationLatLng!,
        infoWindow: const InfoWindow(title: "destination"),
        icon: BitmapDescriptor.defaultMarker,
      ),
    ]);

    await _cubit.fetchRoute(
      _sourceLatLng!,
      _destinationLatLng!,
      AppConfig.googleMapsApiKey,
    );

    if (_isConfirm && _userId != null && _token != null) {
      _cubit.listenToCurrentOrder(_userId!, _token!);
      _cubit.getUnreadMessageCount(_orderId ?? '', _token!);
    }
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

    FirebaseMessaging.onMessage.listen((message) => _handleFcmMessage(message));
    FirebaseMessaging.onMessageOpenedApp.listen(
      (message) => _handleFcmMessage(message),
    );
    FirebaseMessaging.instance.getInitialMessage().then((message) {
      if (message != null) _handleFcmMessage(message);
    });
  }

  Future<void> _handleFcmMessage(RemoteMessage message) async {
    final data = message.data;
    final stateName = data["state_name"]?.toString();
    if (stateName == null || _token == null) return;

    await _cubit.handleOrderStateMessage(data, _token!);

    setState(() {
      if (stateName == "shipper confirmed") {
        _orderShipperId = data["state_type"]?.toString() ?? _orderShipperId;
        _isShipperConfirmed = true;
      } else if (stateName == "order received") {
        _isShipperReceived = true;
        _isShipperConfirmed = true;
      } else if (stateName == "order delivered") {
        _isConfirmOrder = true;
        _isShipperDelivered = true;
        _isShipperConfirmed = true;
        _isShipperReceived = true;
      } else if (stateName == "order cancel") {
        _navigateToHome(
          "Order is Canceled by shipper",
          " تم إلغاء الطلب من قِبل مسئول الشحن ",
        );
      }
    });

    final lang = Lang.of(context);
    if (stateName == "shipper confirmed" && !_isShipperReceived) {
      _showSnackBar(
        lang,
        en: 'Your order is confirmed by a shipper, please wait for him to pick up your package.',
        ar: 'تم تأكيد طلبك من قِبل مسئول الشحن، يُرجى انتظاره لاستلام الطرد الخاص بك',
        backgroundColor: Colors.green,
      );
    } else if (stateName == "order received" && !_isShipperDelivered) {
      _showSnackBar(
        lang,
        en: 'Your order is received by a shipper, please wait for him to pick up your package.',
        ar: 'تم استلام الحمولة بواسطة مسئول الشحن، من فضلك انتظر حتى ينقل الحمولة إلى وجهتك',
        backgroundColor: Colors.green,
      );
    } else if (stateName == "order delivered") {
      _showSnackBar(
        lang,
        en: 'Your package is delivered, if you received the payment please confirm the order is complete.',
        ar: 'تم تسليم الطرد الخاص بك، إذا تلقيت الدفع، فيُرجى تأكيد عملية اكتمال الطلب',
        backgroundColor: Colors.green,
      );
    }
  }

  void _navigateToHome(String en, String ar) {
    if (!mounted) return;
    final lang = Lang.of(context);
    Navigator.pushNamedAndRemoveUntil(
      context,
      RoutesManager.suHome,
      (route) => false,
      arguments: Message(_loc(lang, en, ar)),
    );
  }

  void _navigateToRating() {
    Navigator.pushReplacementNamed(
      context,
      RoutesManager.rating,
      arguments: OrderView(_orderId ?? '', _shipperApiToken ?? ''),
    );
  }

  Future<void> _createOrder(Lang lang) async {
    if (_priceController.text.trim().isEmpty) {
      _showSnackBar(
        lang,
        en: 'Please fill all order entries',
        ar: 'يُرجى ملء جميع بيانات الطلب',
      );
      return;
    }
    if (_userId == null || _token == null) return;
    await _cubit.createOrder(
      token: _token!,
      supplierId: _userId!,
      size: _packageSize,
      price: _priceController.text.trim(),
      priceCheck: _paymentMethod,
      source: _sourceLatLng!,
      destination: _destinationLatLng!,
      distance: _distance ?? '0.0',
    );
  }

  Future<void> _cancelOrder(Lang lang) async {
    if (_orderId == null || _userId == null || _token == null) return;
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
            'Are you sure you want to cancel the order (a fine may apply)',
            'هل أنت متأكد لإلغاء الطلب',
          ),
          style: const TextStyle(fontSize: 15, color: Colors.red),
        ),
        actions: [
          TextButton(
            child: const Text('Yes'),
            onPressed: () => Navigator.pop(context, true),
          ),
          TextButton(
            child: const Text('No'),
            onPressed: () => Navigator.pop(context, false),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await _cubit.cancelOrder(
      orderId: _orderId!,
      supplierId: _userId!,
      username: _username ?? '',
      token: _token!,
      shipperApiToken: _shipperApiToken ?? '',
      lang: lang,
    );
    _navigateToHome("Order is Canceled", "تم إلغاء الطلب ");
  }

  Future<void> _completeOrder(Lang lang) async {
    if (!_isConfirmOrder) {
      _showSnackBar(
        lang,
        en: 'You can not complete the order before its delivered',
        ar: 'لا يمكنك اكمال الطلب قبل أن يتم تسليمه',
      );
      return;
    }

    if (_orderId == null || _token == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: Text(
          _loc(lang, 'Confirm', 'تأكيد'),
          style: const TextStyle(
            color: Colors.red,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          _loc(
            lang,
            'Please confirm that the order is complete',
            'يرجى تأكيد عملية اكتمال الطلب',
          ),
          style: TextStyle(fontSize: 15.sp),
        ),
        actions: [
          TextButton(
            child: Text(
              _loc(lang, 'No', 'لا'),
              style: const TextStyle(color: Colors.grey),
            ),
            onPressed: () => Navigator.pop(c, false),
          ),
          TextButton(
            child: Text(
              _loc(lang, 'Yes', 'نعم'),
              style: const TextStyle(color: Colors.red),
            ),
            onPressed: () => Navigator.pop(c, true),
          ),
        ],
      ),
    );

    if (confirmed == false && mounted && _userId != null && _token != null) {
      _cubit.refreshCurrentOrder(_userId!, _token!);
      return;
    }

    if (confirmed != true) return;

    await _cubit.completeOrder(
      orderId: _orderId!,
      token: _token!,
      shipperApiToken: _shipperApiToken ?? '',
      lang: lang,
    );

    if (mounted) {
      Navigator.pushNamedAndRemoveUntil(
        context,
        RoutesManager.suHome,
        (route) => false,
      );
    }
  }

  void _animateCamera() async {
    final controller = await _mapController.future;
    controller.animateCamera(
      CameraUpdate.newLatLngBounds(
        getBounds(_sourceLatLng!, _destinationLatLng!),
        70,
      ),
    );
  }

  void _updateOrderStateUI(Order order) {
    final state = order.state;
    setState(() {
      _orderState = state;
      if (state == "shipper confirmed")
        _isShipperConfirmed = true;
      else if (state == "order received") {
        _isShipperReceived = true;
        _isShipperConfirmed = true;
      } else if (state == "order delivered") {
        _isConfirmOrder = true;
        _isShipperDelivered = true;
        _isShipperReceived = true;
        _isShipperConfirmed = true;
      } else if (state == "order complete")
        _navigateToRating();
    });
  }

  @override
  Widget build(BuildContext context) {
    final lang = Lang.of(context);
    return BlocProvider.value(
      value: _cubit,
      child: BlocListener<SupplierOrderCubit, SupplierOrderState>(
        listener: (context, state) {
          if (state is SupplierOrderRouteLoaded) {
            setState(() {
              _polylines.clear();
              _polylines.add(
                Polyline(
                  polylineId: const PolylineId("route"),
                  points: state.polylinePoints,
                  color: Colors.blueAccent,
                  width: 5,
                ),
              );
              _distance = state.distance;
            });
            _animateCamera();
          }
          if (state is SupplierOrderCreated) {
            final order = state.order;
            setState(() {
              _isConfirm = true;
              _orderId = order.id;
              _orderCost = order.cost;
              _orderPrice = order.price;
              _orderPriceCheck = order.priceCheck;
              _orderState = order.state;
              _orderShipperId = order.shipperId;
            });
            _showSnackBar(
              lang,
              en: 'Your order is created successfully, please wait for a shipper confirmation ...',
              ar: 'تم إنشاء طلبك بنجاح، يُرجى انتظار التأكيد من قِبل مسئول الشحن...',
              backgroundColor: Colors.green,
            );
            if (_userId != null && _token != null)
              _cubit.listenToCurrentOrder(_userId!, _token!);
          }
          if (state is SupplierOrderCurrentLoaded && state.order != null)
            _updateOrderStateUI(state.order!);
          if (state is SupplierOrderStatusChanged)
            _updateOrderStateUI(state.order);
          if (state is SupplierOrderMessageCountUpdated)
            setState(() => _unreadMessageCount = state.count);
          if (state is SupplierOrderError)
            _showSnackBar(lang, en: state.message, ar: state.message);
          if (state is SupplierOrderCompleted) _navigateToRating();
          if (state is SupplierOrderCancelled)
            _navigateToHome("Order is Canceled", "تم إلغاء الطلب ");
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
                    'Please you cant exist until order complete',
                    'من فضلك انتظر حتي يتم اكتمال مراحل الطلب ',
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
                  NamedIcon(
                    text: lang.lang == "en" ? 'Chats' : 'محادثات ',
                    iconData: Icons.message,
                    order_id: _orderId ?? '',
                    api_token: _shipperApiToken ?? '',
                    notificationCount: _unreadMessageCount,
                    disLat: _destinationLatLng?.latitude.toString(),
                    disLong: _destinationLatLng?.longitude.toString(),
                    sorLat: _sourceLatLng?.latitude.toString(),
                    sorlong: _sourceLatLng?.longitude.toString(),
                    isConfirm: _isConfirm,
                    order_cost: _orderCost ?? '',
                    order_price: _orderPrice ?? '',
                    order_pricecheck: _orderPriceCheck ?? '',
                    order_state: _orderState ?? '',
                    order_supplier_id: _userId ?? '',
                    order_shippier_id: _orderShipperId,
                    permission: _isConfirm,
                  ),
                ],
                automaticallyImplyLeading: false,
              ),
              body: InkWell(
                onTap: () {
                  FocusScope.of(context).unfocus();
                },
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: _initialCamera != null
                          ? GoogleMap(
                              zoomControlsEnabled: true,
                              scrollGesturesEnabled: true,
                              zoomGesturesEnabled: true,
                              initialCameraPosition: _initialCamera!,
                              markers: _markers,
                              polylines: _polylines,
                              onMapCreated: (controller) =>
                                  _mapController.complete(controller),
                              myLocationButtonEnabled: true,
                              mapType: MapType.normal,
                            )
                          : Center(
                              child: CircularProgressIndicator(
                                color: Colors.blue,
                              ),
                            ),
                    ),
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: !_isConfirm
                          ? _buildOrderForm(lang)
                          : _buildOrderStatus(lang),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOrderForm(Lang lang) {
    return Container(
      height: 350.h,
      decoration:  BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.topLeft,
          colors: [Color.fromRGBO(21, 42, 72, 1), Color.fromRGBO(7, 15, 33, 1)],
        ),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(18.r),
          topRight: Radius.circular(18.r),
        ),
      ),
      child: Padding(
        padding:  REdgeInsets.symmetric(horizontal: 24, vertical: 18),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle(
                lang.lang == "en" ? 'Choose Package Size ' : 'اختار حجم الطرد ',
              ),
               SizedBox(height: 6.h),
              _buildSizeSelector(),
               SizedBox(height: 6.h),
              _buildSectionTitle(
                lang.lang == "en"
                    ? 'Distance: $_distance km'
                    : 'المسافة: $_distance كم',
              ),
               SizedBox(height: 6.h),
              _buildSectionTitle(
                lang.lang == "en"
                    ? 'Choose Payment Method'
                    : ' اختر  نظام الدفع  ',
              ),
               SizedBox(height: 6.h),
              _buildPaymentSelector(),
               SizedBox(height: 6.h),
              _buildSectionTitle(
                lang.lang == "en"
                    ? 'Enter Package Price  '
                    : '  ادخل سعر الطرد  ',
              ),
               SizedBox(height: 6.h),
              TextFormField(
                controller: _priceController,
                keyboardType: TextInputType.number,
                style:  TextStyle(
                  fontSize: 15.sp,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
                maxLength: 30,
                onChanged: (value) => setState(() {}),
                decoration: InputDecoration(
                  contentPadding:  REdgeInsets.only(top: 20, bottom: 20),
                  hintText: lang.lang == "en"
                      ? "Package Price"
                      : "  سعر الطرد ",
                  hintStyle: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                  fillColor: Colors.white,
                  filled: true,
                  prefixIcon: Padding(
                    padding: REdgeInsets.only(left: 5),
                    child: Icon(Icons.money, size: 24.sp, color: Colors.blue),
                  ),
                  labelText: lang.lang == "en"
                      ? "click here to set the price"
                      : "اضغط هنا لتحديد السعر",
                  labelStyle: TextStyle(
                    fontSize: 15.sp,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20.r),
                    borderSide: const BorderSide(color: Colors.black),
                  ),
                ),
              ),
              SizedBox(height: 6.h),
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 34.h,
                      child: ElevatedButton.icon(
                        onPressed: () => _createOrder(lang),
                        icon: Icon(Icons.done_all, size: 20.sp),
                        label: Text(
                          lang.lang == "en" ? "Confirm" : "تأكيد ",
                          style: TextStyle(fontSize: 12.sp, color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                        ),
                      ),
                    ),
                  ),
                   SizedBox(width: 40.w),
                  Expanded(
                    child: SizedBox(
                      height: 34.h,
                      child: ElevatedButton.icon(
                        onPressed: () =>
                            _navigateToHome("You have canceld", " تم الإلغاء "),
                        icon:  Icon(Icons.cancel, size: 20.sp),
                        label: Text(
                          lang.lang == "en" ? "Cancel" : "إلغاء",
                          style:  TextStyle(
                            fontSize: 12.sp,
                            color: Colors.white,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
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
    );
  }

  Widget _buildSectionTitle(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 15.sp,
        fontWeight: FontWeight.bold,
        fontStyle: FontStyle.normal,
        color: Colors.white,
      ),
    );
  }

  Widget _buildSizeSelector() {
    final lang = Lang.of(context);
    final sizes = ['small', 'medium', 'large'];
    final labels = {'small': 'صغير', 'medium': 'وسط', 'large': 'كبير'};
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.r),
      ),
      child: Row(
        children: List.generate(3, (index) {
          final size = sizes[index];
          final isSelected = _packageSize == size;
          return Expanded(
            child: Padding(
              padding: REdgeInsets.symmetric(horizontal: 5, vertical: 8),
              child: ElevatedButton(
                onPressed: () => setState(() => _packageSize = size),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isSelected ? Colors.blueAccent : Colors.grey,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      lang.lang == "en" ? size : labels[size]!,
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.black,
                      ),
                    ),
                    Text(
                      (index == 0
                              ? ' 1-5 '
                              : index == 1
                              ? ' 5-10 '
                              : ' 10+ ') +
                          (lang.lang == "en" ? 'KG' : 'كجم'),
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.black,
                        fontSize: 10.sp,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildPaymentSelector() {
    final lang = Lang.of(context);
    final payments = ['cash', 'transfer'];
    final labels = {'cash': 'كاش', 'transfer': 'تحويل'};
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: payments.map((payment) {
          final isSelected = _paymentMethod == payment;
          return Expanded(
            child: Padding(
              padding: REdgeInsets.symmetric(horizontal: 5, vertical: 5),
              child: ElevatedButton(
                onPressed: () => setState(() => _paymentMethod = payment),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isSelected ? Colors.blueAccent : Colors.grey,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                ),
                child: Text(
                  lang.lang == "en" ? payment : labels[payment]!,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.black,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildOrderStatus(Lang lang) {
    return Container(
      height: 300.h,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.topLeft,
          colors: [Color.fromRGBO(21, 42, 72, 1), Color.fromRGBO(7, 15, 33, 1)],
        ),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(18.r),
          topRight: Radius.circular(18.r),
        ),
      ),
      child: Padding(
        padding: REdgeInsets.symmetric(horizontal: 24, vertical: 18),
        child: SingleChildScrollView(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(18.r),
                topRight: Radius.circular(18.r),
              ),
            ),
            child: Padding(
              padding: REdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  OrderStatusWidget(
                    isConfirm: _isConfirm,
                    isShConfirm: _isShipperConfirmed,
                    isShDelviered: _isShipperDelivered,
                    isShReceived: _isShipperReceived,
                    orderState: _orderState,
                    orderId: _orderId,
                  ),
                  SizedBox(height: 10.h),
                  _buildInfoRow(
                    lang.lang == "en"
                        ? "Shipper ID: $_orderShipperId"
                        : "كود المسئول : $_orderShipperId",
                  ),
                  SizedBox(height: 10.h),
                  Row(
                    children: [
                      Expanded(
                        child: _buildInfoColumn(
                          lang.lang == "en" ? "Shipping Cost:" : "تكلفة الشحن ",
                          lang.lang == "en"
                              ? "${_orderCost ?? '0'} L.E."
                              : "${_orderCost ?? '0'} جم",
                        ),
                      ),
                      Expanded(
                        child: _buildInfoColumn(
                          lang.lang == "en" ? "Package Price:" : "سعر الشحنة ",
                          lang.lang == "en"
                              ? "${_orderPrice ?? '0'} L.E."
                              : "${_orderPrice ?? '0'} جم",
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10.h),
                  _buildInfoRow(
                    lang.lang == "en"
                        ? "Payment Method : $_orderPriceCheck"
                        : (_orderPriceCheck == "cash"
                              ? "نظام الدفع  : كاش"
                              : "نظام الدفع  : تحويل"),
                  ),
                  SizedBox(height: 10.h),
                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 32.h,
                          child: ElevatedButton.icon(
                            onPressed: () => _completeOrder(lang),
                            icon: Icon(Icons.done_all, size: 20.sp),
                            label: Text(
                              lang.lang == "en" ? "Complete " : "اكمال ",
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: Colors.white,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 20.w),
                      Expanded(
                        child: SizedBox(height: 32.h,
                          child: ElevatedButton.icon(
                            onPressed: () => _cancelOrder(lang),
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
                                borderRadius: BorderRadius.circular(12),
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
        ),
      ),
    );
  }

  Widget _buildInfoRow(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 15.sp,
        fontWeight: FontWeight.bold,
        fontStyle: FontStyle.normal,
        color: Colors.white,
      ),
    );
  }

  Widget _buildInfoColumn(String title, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 15.sp,
            fontWeight: FontWeight.bold,
            fontStyle: FontStyle.normal,
            color: Colors.white,
          ),
        ),
        SizedBox(height: 5.h),
        Text(
          value,
          style: TextStyle(
            fontSize: 15.sp,
            fontWeight: FontWeight.bold,
            fontStyle: FontStyle.normal,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _priceController.dispose();
    _cubit.close();
    super.dispose();
  }
}
