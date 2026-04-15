import 'package:flutter/material.dart';
import 'package:flutter_maps/Core/routes_manager.dart';
import 'package:flutter_maps/widgets/rating.dart';
import 'package:flutter_maps/classes.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_maps/lang.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_screenutil/flutter_screenutil.dart';

class RatingsPage extends StatefulWidget {
  const RatingsPage({Key? key}) : super(key: key);

  @override
  _RatingsPage createState() => _RatingsPage();
}

class _RatingsPage extends State<RatingsPage> {
  int? _rating;

  late TextEditingController messageTextEditController ;

  @override
  void dispose() {
    messageTextEditController.dispose();
    super.dispose();
  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    messageTextEditController =TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    Lang lang = Lang.of(context);

    final OrderView orderView =
        ModalRoute.of(context)!.settings.arguments as OrderView;

    return Directionality(
      textDirection: lang.lang == "en" ? TextDirection.ltr : TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            onPressed: () {
              Message message = Message(
                lang.lang == "en" ? "Order is complete" : "تم اكتمال الطلب",
              );
              Navigator.pushNamed(context, RoutesManager.suHome, arguments: message);
            },
            icon: Icon(Icons.arrow_back_ios),
          ),
          title: Text(lang.lang == "en" ? "OrderVite Ratings" : "تقييم طلبك"),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                lang.lang == "en"
                    ? "Order is complete! Rate the delivery service"
                    : "تم إتمام الطلب! فلتُقيم خدمة التوصيل",
                style: TextStyle(
                  fontSize: 17.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),

              Rating((rating) {
                setState(() {
                  _rating = rating;
                });
              }, 5),

              SizedBox(
                height: 44.h,
                child: (_rating != null && _rating != 0)
                    ? Text(
                        lang.lang == "en"
                            ? "You selected $_rating rating"
                            : "تقييمك $_rating نجوم",
                        style: TextStyle(fontSize: 18.sp),
                      )
                    : const SizedBox.shrink(),
              ),

              SizedBox(height: 20.h),

              Container(
                padding: EdgeInsets.all(12.r),
                margin: EdgeInsets.all(12.r),
                decoration: BoxDecoration(
                  color: Colors.grey,
                  borderRadius: BorderRadius.circular(32.r),
                ),
                child: TextField(
                  controller: messageTextEditController,
                  style: TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: lang.lang == "en"
                        ? 'Type your Review...'
                        : 'اكتب تعليق',
                    hintStyle: TextStyle(color: Colors.white),
                  ),
                ),
              ),

              Row(
                children: [
                  SizedBox(width: 10.w),

                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                      ),
                      onPressed: () async {
                        if (_rating == null || _rating == 0) return;

                        try {
                          SharedPreferences preferences =
                              await SharedPreferences.getInstance();

                          String? token = preferences.getString("token");

                          if (token == null) return;

                          int id = int.parse(orderView.order_id.toString());

                          String url =
                              "https://www.ordervite.com/api/supplier/order_update/$id";

                          await http.put(
                            Uri.parse(url),
                            body: {
                              "rating": _rating.toString(),
                              "review": messageTextEditController.text.trim(),
                            },
                            headers: {'Authorization': 'Bearer $token'},
                          );

                          Message message = Message(
                            lang.lang == "en"
                                ? "Order is complete and thanks for review $_rating"
                                : "$_rating تم إتمام الطلب، ونشكرك على تقييم الخدمة",
                          );

                          Navigator.pushNamed(
                            context,
                            RoutesManager.suHome,
                            arguments: message,
                          );
                        } catch (e) {}
                      },
                      icon: Icon(Icons.done_all, size: 20.sp),
                      label: Text(
                        lang.lang == "en" ? "Submit" : "ارسال",
                        style: TextStyle(
                          fontSize: 22.sp,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),

                  SizedBox(width: 10.w),

                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                      onPressed: () {
                        Message message = Message(
                          lang.lang == "en"
                              ? "Order is complete"
                              : "تم ااكتمال طلبك",
                        );
                        Navigator.pushNamed(
                          context,
                          RoutesManager.suHome,
                          arguments: message,
                        );
                      },
                      icon: Icon(Icons.cancel, size: 20.sp),
                      label: Text(
                        lang.lang == "en" ? "Skip" : "تخطي",
                        style: TextStyle(
                          fontSize: 22.sp,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),

                  SizedBox(width: 10.w),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}