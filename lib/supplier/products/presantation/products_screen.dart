import 'dart:convert';
import 'package:flutter_maps/core/constant_manager.dart';
import 'package:flutter_maps/core/routes_manager.dart';
import 'package:flutter_maps/models/placeAtuocomplete.dart';
import 'package:flutter_maps/classes.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_maps/lang.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:location/location.dart';

import '../../../core/app_validators.dart';

class ProductsScreen extends StatefulWidget {
  ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  late TextEditingController orderController;
  late TextEditingController destinationController;
  final TextEditingController storeController =
  TextEditingController(text: "مصر الجديدة");
  final _formKey = GlobalKey<FormState>();

  Location _locationTracker = Location();
  var location;
  String placeaddress = "pick up your address";
  int selectedCategory = 0;
  String selectedArea = 'new_cairo';
  List<PlacePredictions> placePredictionsList = [];
  String? sorlat;
  String? sorlng;

  static const Map<String, Map<String, String>> areaStoreLocation = {
    'new_cairo': {
      'en': 'Fixed store location: New Cairo warehouse',
      'ar': 'مكان المخزن الثابت: مخزن مصر الجديدة',
    },
  };

  static const Map<String, LatLng> areaStoreLatLng = {
    'new_cairo': LatLng(30.082726, 31.339483),
  };

  final List<CategoryData> categories = [
    CategoryData(icon: Icons.set_meal, en: 'Meat', ar: 'لحوم'),
    CategoryData(icon: Icons.lunch_dining, en: 'Chicken', ar: 'دجاج'),
    CategoryData(icon: Icons.shopping_bag, en: 'Grocery', ar: 'بقالة'),
    CategoryData(icon: Icons.eco, en: 'Vegetables', ar: 'خضار'),
    CategoryData(icon: Icons.emoji_food_beverage, en: 'Fruits', ar: 'فاكهة'),
  ];

  @override
  void initState() {
    super.initState();
    orderController = TextEditingController();
    destinationController = TextEditingController();
    savelocation();
  }

  @override
  void dispose() {
    orderController.dispose();
    destinationController.dispose();
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
      sorlng = location.longitude?.toString();

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
          "https://maps.googleapis.com/maps/api/geocode/json?latlng=$lat,$lng&key=${ConstantManager.API}";
      final response = await http.get(Uri.parse(url));
      final data = jsonDecode(response.body);

      if (data["results"] != null && data["results"].isNotEmpty) {
        final address = data["results"][0]["formatted_address"] as String?;
        if (address != null && mounted) {
          setState(() {
            placeaddress = address;
            destinationController.text = address;
          });
        }
      } else if (mounted) {
        setState(() {
          placeaddress = "$lat,$lng";
          destinationController.text = placeaddress;
        });
      }
    } catch (e) {
      print("Unable to reverse geocode current location: $e");
      if (mounted) {
        setState(() {
          placeaddress = "${location.latitude},${location.longitude}";
          destinationController.text = placeaddress;
        });
      }
    }
  }

  void findPlace(String placeName) async {
    if (placeName.length > 1) {
      try {
        String url =
            "https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$placeName&key=${ConstantManager.API}&sessiontoken=1234567890&components=country:EGY";

        var response = await http.get(Uri.parse(url));
        var responseBody = jsonDecode(response.body);

        if (responseBody != null) {
          var predictions = responseBody["predictions"];
          var placeList = (predictions as List)
              .map((e) => PlacePredictions.fromJson(e))
              .toList();

          setState(() {
            placePredictionsList = placeList;
          });
        }
      } catch (e) {
        print("Error in findPlace: $e");
      }
    }
  }

  void getPlaceAddressDetails(BuildContext context, String placeId) async {
    try {
      String url =
          "https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=${ConstantManager.API}";
      var response = await http.get(Uri.parse(url));
      var responseBody = jsonDecode(response.body);

      if (!mounted) return;

      String lat = responseBody["result"]["geometry"]["location"]["lat"]
          .toString();
      String lng = responseBody["result"]["geometry"]["location"]["lng"]
          .toString();
      String address = responseBody["result"]["formatted_address"] ?? "";

      if (!mounted) return;

      setState(() {
        destinationController.text = address;
        sorlat = lat;
        sorlng = lng;
        placePredictionsList.clear();
      });
    } catch (e) {
      print("Error in getPlaceAddressDetails: $e");
    }
  }

  void _confirmOrder(BuildContext context) {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    final fixedLocation = areaStoreLatLng[selectedArea]!;
    if (sorlat == null ||
        sorlng == null ||
        destinationController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            Lang.of(context).lang == 'en'
                ? 'Please choose a destination from the list first.'
                : 'يرجى اختيار وجهة من القائمة أولاً.',
          ),
        ),
      );
      return;
    }

    final orderDist = OrderDist(
      fixedLocation.latitude.toString(),
      sorlat!,
      fixedLocation.longitude.toString(),
      sorlng!,
      false,
      null,
      null,
      null,
      null,
      null,
      null,
      orderNote: orderController.text.trim().isNotEmpty
          ? orderController.text.trim()
          : null,
      orderType: 'goods',
    );

    Navigator.pushNamed(context, RoutesManager.orderPage, arguments: orderDist);
  }

  @override
  Widget build(BuildContext context) {
    Lang lang = Lang.of(context);
    final isEnglish = lang.lang == 'en';
    return Directionality(
      textDirection: isEnglish ? TextDirection.ltr : TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(title: Text(isEnglish ? 'Products' : 'المنتجات')),
        body: SingleChildScrollView(
          padding: REdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Text(
                //   isEnglish ? 'Choose a category' : 'اختر الفئة',
                //   style: TextStyle(
                //     fontSize: 18.sp,
                //     fontWeight: FontWeight.bold,
                //   ),
                // ),
                // SizedBox(height: 12.h),
                // SizedBox(
                //   height: 120.h,
                //   child: ListView.separated(
                //     scrollDirection: Axis.horizontal,
                //     itemCount: categories.length,
                //     separatorBuilder: (_, __) => SizedBox(width: 12.w),
                //     itemBuilder: (context, index) {
                //       final category = categories[index];
                //       final isSelected = selectedCategory == index;
                //       return GestureDetector(
                //         onTap: () => setState(() => selectedCategory = index),
                //         child: Container(
                //           width: 110.w,
                //           padding: REdgeInsets.all(12),
                //           decoration: BoxDecoration(
                //             color: isSelected
                //                 ? Colors.blue.shade50
                //                 : Colors.grey.shade100,
                //             borderRadius: BorderRadius.circular(16.r),
                //             border: Border.all(
                //               color: isSelected
                //                   ? Colors.blue
                //                   : Colors.grey.shade300,
                //               width: 1.5,
                //             ),
                //           ),
                //           child: Column(
                //             mainAxisAlignment: MainAxisAlignment.center,
                //             children: [
                //               Container(
                //                 decoration: BoxDecoration(
                //                   color: isSelected
                //                       ? Colors.blue
                //                       : Colors.blueGrey.shade100,
                //                   shape: BoxShape.circle,
                //                 ),
                //                 padding: REdgeInsets.all(12),
                //                 child: Icon(
                //                   category.icon,
                //                   size: 28.sp,
                //                   color: Colors.white,
                //                 ),
                //               ),
                //               SizedBox(height: 10.h),
                //               Text(
                //                 isEnglish ? category.en : category.ar,
                //                 textAlign: TextAlign.center,
                //                 style: TextStyle(
                //                   fontSize: 14.sp,
                //                   fontWeight: FontWeight.w600,
                //                   color: Colors.black87,
                //                 ),
                //               ),
                //             ],
                //           ),
                //         ),
                //       );
                //     },
                //   ),
                // ),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                   Navigator.pushNamed(context, RoutesManager.goodsScreen);


                    },
                    icon: const Icon(Icons.inventory_2),
                    label:  Text(
                        isEnglish?"Goods List":"قائمة المنتجات"),
                  ),
                ),
                SizedBox(height: 24.h),
                Text(
                  isEnglish ? 'Your order details' : 'تفاصيل الطلب',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8.h),
                TextFormField(
                  controller: orderController,
                  validator: (value) => AppValidators.minLength(
                    value,
                    6,
                    isEnglish ? 'en' : 'ar',
                  ),
                  maxLines: 4,
                  style: TextStyle(fontSize: 18.sp, color: Colors.black),
                  decoration: InputDecoration(
                    hintText: isEnglish
                        ? 'Write your order here'
                        : 'اكتب طلبك هنا',
                    labelText: isEnglish ? 'Order' : 'الطلب',
                    alignLabelWithHint: true,
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20.r),
                      borderSide: BorderSide(color: Colors.blue),
                    ),
                  ),
                ),
                SizedBox(height: 24.h),
                Text(
                  isEnglish ? 'Choose area' : 'اختر المنطقة',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8.h),
                // Row(
                //   children: [
                //     Expanded(
                //       child: ChoiceChip(
                //         label: Text(isEnglish ? "Heliopolis" : 'مصر الجديدة'),
                //         selected: selectedArea == "Heliopolis" ,
                //         onSelected: (_) =>
                //             setState(() => selectedArea = "Heliopolis" ),
                //       ),
                //     ),
                //   ],
                // ),
                SizedBox(height: 12.h),
                Container(
                  width: double.infinity,
                  padding: REdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Text(
                    areaStoreLocation[selectedArea]?[lang.lang] ?? '',
                    style: TextStyle(fontSize: 16.sp, color: Colors.black87),
                  ),
                ),
                SizedBox(height: 24.h),
                Text(
                  isEnglish ? 'Destination address' : 'عنوان التوصيل',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8.h),
                TextFormField(
                  controller: destinationController,
                  onChanged: (val) {
                    findPlace(val);
                  },
                  style: TextStyle(fontSize: 18.sp, color: Colors.black),
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.location_on, size: 20.sp),
                    hintText: isEnglish
                        ? 'Enter destination address'
                        : 'ادخل عنوان التوصيل',
                    labelText: isEnglish ? 'Destination' : 'الوجهة',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20.r),
                      borderSide: BorderSide(color: Colors.blue),
                    ),
                  ),
                ),
                if (placePredictionsList.isNotEmpty) ...[
                  SizedBox(height: 8.h),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16.r),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Column(
                      children: placePredictionsList.map((place) {
                        return InkWell(
                          onTap: () {
                            getPlaceAddressDetails(
                              context,
                              place.place_id ?? '',
                            );
                          },
                          child: Padding(
                            padding: REdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 12,
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.location_on,
                                  color: Colors.blue,
                                  size: 20.sp,
                                ),
                                SizedBox(width: 10.w),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        place.main_text ?? '',
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: 16.sp,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      Text(
                                        place.secondary_text ?? '',
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: 12.sp,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
                SizedBox(height: 12.h),
                SizedBox(
                  width: double.infinity,
                  height: 40.h,
                  child: ElevatedButton(
                    onPressed: () {
                      _confirmOrder(context);
                    },
                    child: Text(
                      isEnglish ? 'Confirm' : 'تاكيد',
                      style: TextStyle(color: Colors.white, fontSize: 14.sp),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class CategoryData {
  final IconData icon;
  final String en;
  final String ar;

  const CategoryData({required this.icon, required this.en, required this.ar});
}
