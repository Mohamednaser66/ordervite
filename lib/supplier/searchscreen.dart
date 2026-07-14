import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_maps/Core/routes_manager.dart';
import 'package:flutter_maps/classes.dart';
import 'package:flutter_maps/core/colors_manager.dart';
import 'package:flutter_maps/lang.dart';
import 'package:flutter_maps/models/placeAtuocomplete.dart';
import 'package:flutter_maps/supplier/home_page/widgets/home_drawer.dart';
import 'package:http/http.dart' as http;
import 'package:location/location.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SearchScreen extends StatefulWidget {
  SearchScreen({Key? key}) : super(key: key);

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final GlobalKey<ScaffoldState> _scaffoldkey = GlobalKey<ScaffoldState>();

  late TextEditingController pickUpTextEditingController;
  late TextEditingController dropOffTextEditingController;
  Location _locationTracker = Location();
  var location;
  String placeaddress = "pick up your address";
  String username = '';
  String email = '';
  String? id;
  String? token2;
  String? logo_src;
  bool isSignIn = false;
  bool isMessage = true;
  String? sorlang;
  String? sorlat;
  List<PlacePredictions> placePredictionsList = [];
  List<PlacePredictions> placePredictionsList2 = [];

  final String _API = 'AIzaSyDl8LFLQn24CbaZyQ0F4wnzoF9NY3_gMWY';
  @override
  @override
  void initState() {
    super.initState();
    pickUpTextEditingController = TextEditingController();
    dropOffTextEditingController = TextEditingController();

    savelocation();
    getPref();

    Future.delayed(Duration(seconds: 5)).then((_) {
      showMessage();
    });
  }

  @override
  void dispose() {
    pickUpTextEditingController.dispose();
    dropOffTextEditingController.dispose();
    super.dispose();
  }

  Future<void> savelocation() async {
    bool serviceEnabled;
    PermissionStatus permissionGranted;

    serviceEnabled = await _locationTracker.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await _locationTracker.requestService();
      if (!serviceEnabled) return;
    }

    permissionGranted = await _locationTracker.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await _locationTracker.requestPermission();
      if (permissionGranted != PermissionStatus.granted) return;
    }

    try {
      location = await _locationTracker.getLocation();
      sorlat = location.latitude?.toString();
      sorlang = location.longitude?.toString();

      await _setCurrentLocationAddress();
    } catch (e) {
      print("Unable to get current location: $e");
    }
  }

  Future<void> _setCurrentLocationAddress() async {
    if (location == null) return;

    final lat = location.latitude;
    final lng = location.longitude;
    if (lat == null || lng == null) return;

    try {
      final url =
          "https://maps.googleapis.com/maps/api/geocode/json?latlng=$lat,$lng&key=$_API";
      final response = await http.get(Uri.parse(url));
      final data = jsonDecode(response.body);

      if (data["results"] != null && data["results"].isNotEmpty) {
        final address = data["results"][0]["formatted_address"] as String?;
        if (address != null && mounted) {
          setState(() {
            placeaddress = address;
            pickUpTextEditingController.text = address;
          });
        }
      } else if (mounted) {
        setState(() {
          placeaddress = "$lat,$lng";
          pickUpTextEditingController.text = placeaddress;
        });
      }
    } catch (e) {
      print("Unable to reverse geocode current location: $e");
      if (mounted) {
        setState(() {
          placeaddress = "${location.latitude},${location.longitude}";
          pickUpTextEditingController.text = placeaddress;
        });
      }
    }
  }

  getPref() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();

    username = preferences.getString("username") ?? '';
    email = preferences.getString("email") ?? '';

    if (!mounted) return;
    if (username.isNotEmpty && email.isNotEmpty) {
      setState(() {
        id =preferences.getString('id');
        token2 = preferences.getString("token") ?? '';
        logo_src = preferences.getString("logo_src") ?? '';
        isSignIn = true;
      });
    }
  }

  showMessage() {
    if (!mounted) return;
    Message? message = ModalRoute.of(context)?.settings.arguments as Message?;
    if (message != null && isMessage) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.redAccent,
          content: Text(
            message.message,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.sp),
          ),
        ),
      );
      setState(() {
        isMessage = false;
      });
    }
  }

  void findPlace(String placeName, {bool isSource = true}) async {
    if (placeName.length > 1) {
      try {
        String url =
            "https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$placeName&key=$_API&sessiontoken=1234567890&components=country:EGY";

        var response = await http.get(Uri.parse(url));
        var reposnsebody = jsonDecode(response.body);

        if (reposnsebody != null) {
          var predictions = reposnsebody["predictions"];
          var placelist = (predictions as List)
              .map((e) => PlacePredictions.fromJson(e))
              .toList();

          setState(() {
            if (isSource) {
              placePredictionsList2 = placelist;
              placePredictionsList.clear();
            } else {
              placePredictionsList = placelist;
              placePredictionsList2.clear();
            }
          });
        }
      } catch (e) {
        print("Error in findPlace: $e");
      }
    }
  }

  Widget getPlaceAddressSource(
    BuildContext context,
    String placeId,
    PlacePredictions placePredictions,
  ) {
    return TextButton(
      onPressed: () async {
        try {
          String url =
              "https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=$_API";
          var response = await http.get(Uri.parse(url));
          var reposnsebody = jsonDecode(response.body);

          setState(() {
            placeaddress = placePredictions.main_text ?? '';
            sorlat = reposnsebody["result"]["geometry"]["location"]["lat"]
                .toString();
            sorlang = reposnsebody["result"]["geometry"]["location"]["lng"]
                .toString();
            pickUpTextEditingController.text = placeaddress;
            placePredictionsList2.clear();
          });
        } catch (e) {
          print("Error in getPlaceAddressSource: $e");
        }
      },
      child: Container(
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(width: 10.w),
              Row(
                children: [
                  Icon(Icons.add_location, color: Colors.white),
                  SizedBox(width: 14.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 8.h),
                        Text(
                          placePredictions.main_text ?? '',
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 12.sp, color: Colors.white),
                        ),
                        SizedBox(height: 3.h),
                        Text(
                          placePredictions.secondary_text ?? '',
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 12.sp, color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(width: 10.w),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Lang lang = Lang.of(context);

    return Directionality(
      textDirection: lang.lang == "en" ? TextDirection.ltr : TextDirection.rtl,
      child: Scaffold(
        key: _scaffoldkey,
        backgroundColor: ColorsManager.darkerGreen,
        drawer: SupplierDrawer(
          id: id??'',
          username: username,
          email: email,
          lang: lang,
          isSignIn: isSignIn,
        ),
        appBar: AppBar(
          title: Text(
            lang.lang == "en" ? 'Make Order' : 'طلب شحن',
            style: TextStyle(),
          ),
        ),
        body: Column(
          children: [
            Container(
              height: 215.h,
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black,
                    blurRadius: 6.0,
                    spreadRadius: 0.5,
                    offset: Offset(0.7, 0.7),
                  ),
                ],
              ),
              child: Padding(
                padding: EdgeInsets.all(25.0.r),
                child: Column(
                  children: [
                    SizedBox(height: 5.h),
                    Stack(
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: Icon(Icons.arrow_back,size: 20.sp,color: ColorsManager.darkerGreen,),
                        ),
                        Center(
                          child: Text(
                            lang.lang == "en" ? "Set Drop off" : " اضف وجهتك ",
                            style: TextStyle(
                              color: ColorsManager.darkerGreen,
                              fontSize: 18.sp,
                              fontFamily: "Brand-bold",
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16.h),

                    Row(
                      children: [
                        Icon(
                          Icons.location_city,
                          size: 30.sp,
                          color: ColorsManager.darkerGreen
                        ),
                        SizedBox(width: 18.w),
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(5.0.r),
                            ),
                            child: Padding(
                              padding: REdgeInsets.all(4.0),
                              child: TextField(
                                cursorColor: Colors.white,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15.sp,
                                ),
                                onChanged: (val) {
                                  findPlace(val, isSource: true);
                                },
                                controller: pickUpTextEditingController,
                                decoration: InputDecoration(
                                  hintText: placeaddress,
                                  hintStyle: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15.sp,
                                  ),
                                  fillColor: ColorsManager.darkerGreen,
                                  filled: true,
                                  border: InputBorder.none,
                                  isDense: true,
                                  contentPadding: EdgeInsets.only(
                                    left: 1.w,
                                    top: 8.h,
                                    bottom: 8.h,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10.h),
                    Row(
                      children: [
                        Icon(
                          Icons.bike_scooter,
                          size: 30.sp,
                          color: ColorsManager.darkerGreen
                        ),
                        SizedBox(width: 18.w),
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(5.0.r),
                            ),
                            child: Padding(
                              padding: EdgeInsets.all(3.0.r),
                              child: TextField(
                                cursorColor: Colors.white,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15.sp,
                                ),
                                onChanged: (val) {
                                  findPlace(val, isSource: false);
                                },
                                controller: dropOffTextEditingController,
                                decoration: InputDecoration(
                                  hintText: lang.lang == "en"
                                      ? "Where To"
                                      : " إلي أين ",
                                  hintStyle: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15.sp,
                                  ),
                                  fillColor: ColorsManager.darkerGreen,
                                  filled: true,
                                  border: InputBorder.none,
                                  isDense: true,
                                  contentPadding: EdgeInsets.only(
                                    left: 1.w,
                                    top: 8.h,
                                    bottom: 8.h,
                                  ),
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
            SizedBox(height: 10.h),
            Expanded(
              child: ListView(
                padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 16.w),
                children: [
                  ...placePredictionsList2.map(
                    (p) => getPlaceAddressSource(context, p.place_id ?? '', p),
                  ),
                  ...placePredictionsList.map(
                    (p) => PredictionsTile(
                      currentLocation: location,
                      placePredictions: p,
                      sorlat: sorlat,
                      sorlang: sorlang,
                      onSelect: (address, lat, lng) {
                        setState(() {
                          dropOffTextEditingController.text = address;
                          placePredictionsList.clear();
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PredictionsTile extends StatelessWidget {
  final PlacePredictions placePredictions;
  final String? sorlang;
  final String? sorlat;
  final LocationData currentLocation;
  final Function(String, String, String) onSelect;

  const PredictionsTile({
    required this.currentLocation,
    required this.onSelect,
    Key? key,
    required this.placePredictions,
    this.sorlang,
    this.sorlat,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () {
        FocusScope.of(context).unfocus();
        getPlaceAddressDetails(context, placePredictions.place_id ?? "");
      },
      child: Container(
        child: Column(
          children: [
            Row(
              children: [
                Icon(Icons.add_location, color: Colors.white),
                SizedBox(width: 14.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        placePredictions.main_text ?? "",
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 12.sp, color: Colors.white),
                      ),
                      Text(
                        placePredictions.secondary_text ?? "",
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 12.sp, color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void getPlaceAddressDetails(BuildContext context, String placeId) async {
    final _API = 'AIzaSyDl8LFLQn24CbaZyQ0F4wnzoF9NY3_gMWY';
    try {
      String url =
          "https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=$_API";
      var response = await http.get(Uri.parse(url));
      var reposnsebody = jsonDecode(response.body);

      if (!context.mounted) return;

      String lat = reposnsebody["result"]["geometry"]["location"]["lat"]
          .toString();
      String lng = reposnsebody["result"]["geometry"]["location"]["lng"]
          .toString();
      String address = placePredictions.main_text ?? "";

      if (!context.mounted) return;

      OrderDist orderDist = OrderDist(
        lat,
        sorlat ?? currentLocation.latitude?.toString() ?? "",
        lng,
        sorlang ?? currentLocation.longitude?.toString() ?? "",
        false,
        null,
        null,
        null,
        null,
        null,
        null,
      );
      onSelect(address, lat, lng);
      Navigator.pushNamed(
        context,
        RoutesManager.orderPage,
        arguments: orderDist,
      );
      onSelect(address, lat, lng);
    } catch (e) {
      print("Error in getPlaceAddressDetails: $e");
    }
  }
}