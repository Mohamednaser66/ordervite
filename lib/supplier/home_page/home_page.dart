import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_maps/Core/routes_manager.dart';
import 'package:flutter_maps/classes.dart';
import 'package:flutter_maps/lang.dart';
import 'package:flutter_maps/supplier/home_page/widgets/home_drawer.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:location/location.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _googleGeocodeApiKey = 'AIzaSyDl8LFLQn24CbaZyQ0F4wnzoF9NY3_gMWY';

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, this.title}) : super(key: key);
  final String? title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String? username;
  String? email;
  String? id;
  String? token2;
  String? logo_src;
  bool isSignIn = false;

  late StreamController _shipperController;
  StreamSubscription<LocationData>? _locationSubscription;
  StreamSubscription? _mapIdleSubscription;
  Location _locationTracker = Location();

  LatLng? _initialLocation;
  GoogleMapController? _controller;
  final Set<Marker> _markers = {};
  Circle? _circle;
  late BitmapDescriptor iconHalte;
  late BitmapDescriptor iconMe;
  bool _locationPermissionGranted = false;

  double bottomPaddingOfMap = 0;
  String? placeAddress;

  final GlobalKey<ScaffoldState> _scaffoldkey = GlobalKey<ScaffoldState>();

  Future<List<dynamic>> getShippers() async {
    try {
      String Url = "https://www.ordervite.com/api/supplier/shippiers";
      var response = await http.get(
        Uri.parse(Url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token2',
        },
      );
      var reposnsebody = jsonDecode(response.body);
      return reposnsebody["data"];
    } catch (e) {
      return [];
    }
  }

  Future<void> loadShipper() async {
    var res = await getShippers();

    Set<Marker> tempMarkers = {};

    for (var shipper in res) {
      double lat = double.tryParse(shipper["cur_latitude"].toString()) ?? 0;
      double lng = double.tryParse(shipper["cur_longitude"].toString()) ?? 0;

      tempMarkers.add(
        Marker(
          markerId: MarkerId(shipper["id"].toString()),
          icon: iconHalte,
          position: LatLng(lat, lng),
          infoWindow: InfoWindow(title: shipper["name"]),
        ),
      );
    }

    if (mounted) {
      setState(() {
        _markers.addAll(tempMarkers);
      });
    }
  }

  getPref() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    username = preferences.getString("username");
    email = preferences.getString("email");
    token2 = preferences.getString("token");
    id = preferences.getString("id");

    if (username != null && email != null) {
      setState(() {
        isSignIn = true;
      });
    }

    if (id != null) {
      int myid = int.parse(id!);
      String Url = "https://www.ordervite.com/api/supplier/show/$myid";
      var response = await http.get(
        Uri.parse(Url),
        headers: {'Authorization': 'Bearer $token2'},
      );
      var reposnsebody = jsonDecode(response.body);
      if (reposnsebody["success"] == true && mounted) {
        setState(() {
          logo_src = reposnsebody["data"]["logo"].toString();
          preferences.setString('logo_src', logo_src!);
          preferences.setString(
            'email',
            reposnsebody["data"]["name"]["email"].toString(),
          );
          preferences.setString(
            'username',
            reposnsebody["data"]["name"]["name"].toString(),
          );
        });
      }
    }
  }

  Future<Uint8List> getMarker() async {
    ByteData byteData = await DefaultAssetBundle.of(
      context,
    ).load("assets/mark.png");
    return byteData.buffer.asUint8List();
  }

  void updateMarkerAndCircle(LocationData newLocalData, Uint8List imageData) {
    final latlng = LatLng(
      newLocalData.latitude ?? 0,
      newLocalData.longitude ?? 0,
    );

    final marker = Marker(
      markerId: const MarkerId("home"),
      position: latlng,
      rotation: newLocalData.heading ?? 0,
      draggable: false,
      zIndex: 2,
      flat: true,
      anchor: const Offset(0.5, 0.5),
      icon: BitmapDescriptor.fromBytes(imageData),
    );

    _circle = Circle(
      circleId: const CircleId("car"),
      radius: newLocalData.accuracy ?? 0,
      zIndex: 1,
      strokeColor: Colors.blue,
      center: latlng,
      fillColor: Colors.blue.withAlpha(70),
    );

    setState(() {
      _markers.removeWhere((m) => m.markerId == const MarkerId("home"));
      _markers.add(marker);
    });
  }

  void getCurrentLocation() async {
    bool serviceEnabled;
    PermissionStatus permissionGranted;

    serviceEnabled = await _locationTracker.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await _locationTracker.requestService();
      if (!serviceEnabled) {
        _setDefaultLocation();
        return;
      }
    }

    permissionGranted = await _locationTracker.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await _locationTracker.requestPermission();
    }

    if (permissionGranted != PermissionStatus.granted) {
      _locationPermissionGranted = false;
      _showLocationDialog();
      _setDefaultLocation();
      return;
    }

    _locationPermissionGranted = true;
    var locationData = await _locationTracker.getLocation();
    if (locationData == null ||
        locationData.latitude == null ||
        locationData.longitude == null) {
      _setDefaultLocation();
      return;
    }

    LatLng currentLatLng = LatLng(
      locationData.latitude!,
      locationData.longitude!,
    );

    if (mounted) {
      setState(() {
        _initialLocation = currentLatLng;
      });
    }

    await _saveLocationAddress();
  }

  void _showLocationDialog() {
    if (!mounted) return;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Location Required"),
        content: Text(
          "Please enable location to get accurate delivery and nearby services.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("OK"),
          ),
        ],
      ),
    );
  }

  void _setDefaultLocation() {
    if (mounted) {
      setState(() {
        _initialLocation = LatLng(30.0444, 31.2357);
        placeAddress = "Cairo, Egypt";
      });
    }
  }

  Future<void> _saveLocationAddress() async {
    try {
      final serviceEnabled = await _locationTracker.serviceEnabled();
      if (!serviceEnabled) {
        if (mounted) {
          setState(() {
            placeAddress ??= "Cairo, Egypt";
          });
        }
        return;
      }

      final permissionGranted = await _locationTracker.hasPermission();
      if (permissionGranted != PermissionStatus.granted &&
          permissionGranted != PermissionStatus.grantedLimited) {
        if (mounted) {
          setState(() {
            placeAddress ??= "Cairo, Egypt";
          });
        }
        return;
      }

      final locationData = await _locationTracker.getLocation();
      if (locationData.latitude == null || locationData.longitude == null) {
        if (mounted) {
          setState(() {
            placeAddress ??= "Cairo, Egypt";
          });
        }
        return;
      }

      final url =
          "https://maps.googleapis.com/maps/api/geocode/json?latlng=${locationData.latitude},${locationData.longitude}&key=$_googleGeocodeApiKey";

      final response = await http
          .get(Uri.parse(url))
          .timeout(Duration(seconds: 10));

      final reposnsebody = jsonDecode(response.body);

      if (mounted) {
        setState(() {
          if (reposnsebody["results"] != null &&
              reposnsebody["results"].isNotEmpty) {
            placeAddress =
                "${reposnsebody["results"][0]["address_components"][0]["long_name"]} ${reposnsebody["results"][0]["address_components"][1]["long_name"]}";
          } else {
            placeAddress =
                "${locationData.latitude}, ${locationData.longitude}";
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          placeAddress ??= "Cairo, Egypt";
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();

    _shipperController = StreamController();

    getPref();
    getCurrentLocation();

    Future.wait([
      BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(devicePixelRatio: 2.5),
        'assets/orderViteBicycle.png',
      ),
      BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(devicePixelRatio: 2),
        'assets/meMark.png',
      ),
    ]).then((icons) {
      iconHalte = icons[0];
      iconMe = icons[1];

      loadShipper();
    });
  }

  @override
  void dispose() {
    _shipperController.close();
    _locationSubscription?.cancel();
    _mapIdleSubscription?.cancel();
    super.dispose();
  }

  void showMessage() {
    if (!mounted) return;
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args == null || args is! Message) return;

    Message message = args;
    String messageShow = message.message.toString();
    if (messageShow.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.redAccent,
          content: Text(
            messageShow,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.sp),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    Lang lang = Lang.of(context);

    return WillPopScope(
      onWillPop: () async => false,
      child: Directionality(
        textDirection: lang.lang == "en"
            ? TextDirection.ltr
            : TextDirection.rtl,
        child: Scaffold(
          key: _scaffoldkey,
          drawer: SupplierDrawer(
            username: username ?? '',
            email: email ?? '',
            lang: lang,
            isSignIn: isSignIn,
          ),
          appBar: buildAppBar(lang),
          body: buildBody(lang),
          floatingActionButton: FloatingActionButton(
            foregroundColor: Colors.white,
            backgroundColor: Colors.blue,
            child: Icon(Icons.location_searching),
            onPressed: () => getCurrentLocation(),
          ),
        ),
      ),
    );
  }

  AppBar buildAppBar(Lang lang) {
    return AppBar(
      title: Text(
        lang.lang == "en" ? "OrderVite" : "أوردرفيت",
        style: TextStyle(
          fontSize: 25.sp,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget buildBody(Lang lang) {
    return SafeArea(
      child: _initialLocation == null
          ? Center(child: CircularProgressIndicator(color: Colors.blue))
          : Stack(
              children: [
                GoogleMap(
                  padding: EdgeInsets.only(bottom: 3.h),
                  mapType: MapType.normal,
                  markers: _markers,
                  circles: _circle != null ? {_circle!} : {},
                  initialCameraPosition: CameraPosition(
                    target: _initialLocation!,
                    zoom: 16,
                  ),
                  myLocationEnabled: _locationPermissionGranted,
                  myLocationButtonEnabled: false,
                  onMapCreated: (GoogleMapController controller) {
                    _controller = controller;
                  },
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    height: 300.h,
                    decoration: BoxDecoration(
                      color: Color.fromRGBO(21, 42, 72, 0.9),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(18.0.r),
                        topRight: Radius.circular(18.0.r),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black,
                          blurRadius: 16.0.r,
                          spreadRadius: 0.5.r,
                          offset: Offset(0.7.w, 0.7.h),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 10.w,
                        vertical: 10.h,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            lang.lang == "en"
                                ? "Hi  ${username ?? ''}"
                                : "مرحبًا   ${username ?? ''}",
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 10.h),
                          Text(
                            lang.lang == "en"
                                ? "Create a shipping order "
                                : " قم بإنشاء امر الشحن ",
                            style: TextStyle(
                              fontSize: 25.sp,
                              fontFamily: "Brand-bold",
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 20.h),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.all(
                                Radius.circular(18.r),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black54,
                                  blurRadius: 6.r,
                                  spreadRadius: 0.5.r,
                                  offset: Offset(0.7.w, 0.7.h),
                                ),
                              ],
                            ),
                            child: TextButton.icon(
                              onPressed: () {
                                Navigator.of(
                                  context,
                                ).pushNamed(RoutesManager.terms);
                              },
                              icon: Icon(Icons.search, color: Colors.red),
                              label: Text(
                                lang.lang == "en"
                                    ? "Search your destination  "
                                    : " ابحث عن وجهتك ",
                                style: TextStyle(
                                  fontSize: 15.sp,
                                  color: Colors.red,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 10.h),
                          Divider(height: 10.h, thickness: 1.w),
                          SizedBox(height: 10.h),
                          Row(
                            children: [
                              Icon(
                                Icons.work,
                                color: Colors.white,
                                size: 30.sp,
                              ),
                              SizedBox(width: 12.w),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      lang.lang == "en"
                                          ? "Your Address "
                                          : " عناوينك ",
                                      style: TextStyle(
                                        fontSize: 17.sp,
                                        color: Colors.white,
                                      ),
                                    ),
                                    SizedBox(height: 4.h),
                                    placeAddress != null
                                        ? Text(
                                            placeAddress!,
                                            style: TextStyle(
                                              fontSize: 15.sp,
                                              color: Colors.white,
                                            ),
                                          )
                                        : const Center(
                                            child: CircularProgressIndicator(
                                              color: Colors.blue,
                                            ),
                                          ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
