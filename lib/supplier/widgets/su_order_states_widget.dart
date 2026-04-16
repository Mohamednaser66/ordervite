import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_maps/Core/routes_manager.dart';
import 'package:flutter_maps/classes.dart';
import 'package:flutter_maps/lang.dart';
import 'package:flutter_maps/supplier/widgets/su_order_states_icons.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;

class SuOrderStatesWidget extends StatelessWidget {
  SuOrderStatesWidget({
    super.key,
    required this.lang,
    required this.order_state,
    required this.isConfirm,
    required this.isShConfirm,
    required this.isShReceived,
    required this.isShDelviered,
    required this.order_id,
    required this.order_shippier_id,
    required this.order_cost,
    required this.username,
    required Function showSnackBar,
    required Function showNetworkErrorDialog,
    required this.id,
    required this.api_token,
    required this.token,
    required this.order_price,
    required this.order_pricecheck,
    required this.isConfirmOrder,
  }) : _showSnackBar = showSnackBar,
       _showNetworkErrorDialog = showNetworkErrorDialog;

  Lang lang;
  String order_state;
  final String order_cost;
  final String username;
  final Function _showSnackBar;
  final Function _showNetworkErrorDialog;
  final String id;
  final String api_token;
  final String token;
  final String order_id;
  final String order_price;
  final String order_pricecheck;
  final String order_shippier_id;
  final bool isConfirm;
  final bool isShConfirm;
  final bool isShReceived;
  final bool isShDelviered;
  final bool isConfirmOrder;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: <Widget>[
            Expanded(
              child: Text(
                lang.lang == "en"
                    ? "Order State: $order_state"
                    : (order_state == "new"
                          ? "حالة الطلب : جديد"
                          : (order_state == "shipper confirmed"
                                ? "حالة الطلب : تأكيد مسئول الشحن  "
                                : (order_state == "order received"
                                      ? "حالة الطلب :   استلام الشحنة   "
                                      : (order_state == "order delivered"
                                            ? "حالة الطلب :      اكتمال الطلب    "
                                            : "حالة الطلب :   توصيل الشحنة  الشحنة   ")))),
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.bold,
                  fontStyle: FontStyle.normal,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),

        SizedBox(height: 6.h),

        SuOrderStatesIcons(
          isConfirm: isConfirm,
          isShConfirm: isShConfirm,
          isShDelviered: isShDelviered,
          isShReceived: isShReceived,
        ),
        SizedBox(height: 15.h),

        Row(
          children: <Widget>[
            Expanded(
              child: Text(
                lang.lang == "en"
                    ? "Order ID: $order_id"
                    : "كود الطلب :$order_id",
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.bold,
                  fontStyle: FontStyle.normal,
                  color: Colors.white,
                ),
              ),
            ),

            SizedBox(width: 20.w),
            Expanded(
              child: isShConfirm
                  ? Text(
                      lang.lang == "en"
                          ? "Shipper ID: $order_shippier_id "
                          : "كود المسئول : $order_shippier_id",
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.bold,
                        fontStyle: FontStyle.normal,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      lang.lang == "en"
                          ? "Shipper ID: Pending "
                          : "كود المسئول : .... ",
                      style: TextStyle(
                        fontSize: 15.sp,
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
                lang.lang == "en" ? "Shipping Cost:" : "تكلفة الشحن ",
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.bold,
                  fontStyle: FontStyle.normal,
                  color: Colors.white,
                ),
              ),
            ),

            SizedBox(width: 20.w),
            Expanded(
              child: Text(
                lang.lang == "en" ? "Package Price:" : "سعر الشحنة ",
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.bold,
                  fontStyle: FontStyle.normal,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
   SizedBox(height: 6.h,),
        Row(
          children: <Widget>[
            Expanded(
              child: Text(
                lang.lang == "en" ? "$order_cost L.E." : "$order_cost جم",
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.bold,
                  fontStyle: FontStyle.normal,
                  color: Colors.white,
                ),
              ),
            ),

            SizedBox(width: 20.w),
            Expanded(
              child: Text(
                lang.lang == "en" ? "$order_price L.E." : "$order_price جم",
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.bold,
                  fontStyle: FontStyle.normal,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 6.h,),
        Row(
          children: <Widget>[
            Expanded(
              child: Text(
                lang.lang == "en"
                    ? "Payment Method : $order_pricecheck"
                    : (order_pricecheck == "cash"
                          ? "نظام الدفع  : كاش"
                          : "نظام الدفع  : تحويل"),
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.bold,
                  fontStyle: FontStyle.normal,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 6.h,),
        Row(
          children: <Widget>[
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () async {
                  try {
                    if (order_id != null) {
                      if (isConfirmOrder) {
                        showDialog<bool>(
                          context: context,
                          builder: (c) => AlertDialog(
                            title: Text(
                              lang.lang == "en" ? 'Confirm' : 'تحذير ',
                              style: TextStyle(color: Colors.red),
                            ),
                            content: Text(
                              lang.lang == "en"
                                  ? 'Please confirm that the order is complete '
                                  : '     يرجي تأكيد عملية اكتمال الطلب ',
                              style: TextStyle(
                                fontSize: 15.sp,
                                color: Colors.red,
                              ),
                            ),
                            actions: [
                              TextButton(
                                child: Text(lang.lang == "en" ? 'Yes' : 'نعم'),
                                onPressed: () async {
                                  int id = int.parse(order_id ?? '', radix: 10);

                                  String url =
                                      "https://www.ordervite.com/api/supplier/order_update/$id";

                                  var response = await http.put(
                                    Uri.parse(url),
                                    body: {"order_state": "order complete"},
                                    headers: {'Authorization': 'Bearer $token'},
                                  );

                                  var reposnsebody = jsonDecode(response.body);

                                  String shipper_api_token = api_token
                                      .toString();

                                  String text = lang.lang == "en"
                                      ? "your order is complete great work !!!"
                                      : "   هنيأ تم إكمال الطلب !!!   ";

                                  String url3 =
                                      "https://www.ordervite.com/api/notify/page/ordervite/$text/$shipper_api_token/1/ordervite/supplier/order complete";

                                  await http.get(
                                    Uri.parse(url3),
                                    headers: {
                                      'Content-Type': 'application/json',
                                      'Accept': 'application/json',
                                      'Authorization': 'Bearer $token',
                                    },
                                  );

                                  Navigator.of(context).pop();

                                  if (reposnsebody != null) {
                                    OrderView orderView = OrderView(
                                      order_id.toString(),
                                      api_token.toString(),
                                    );

                                    Navigator.pushNamed(
                                      context,
                                      RoutesManager.rating,
                                      arguments: orderView,
                                    );
                                  }
                                },
                              ),
                              TextButton(
                                child: Text(lang.lang == "en" ? 'No' : 'لا'),
                                onPressed: () => Navigator.of(context).pop(),
                              ),
                            ],
                          ),
                        );
                      } else {
                        _showSnackBar(
                          lang,
                          en: 'You can not complete the order before its delivered',
                          ar: 'لا يمكنك اكمال الطلب قبل أن يتم تسليمه',
                        );
                      }
                    }
                  } catch (e) {
                    await _showNetworkErrorDialog(lang);
                    return;
                  }
                },
                icon: Icon(Icons.done_all, size: 20.sp),
                label: Text(
                  lang.lang == "en" ? "Complete " : "اكمال ",
                  style: TextStyle(fontSize: 12.sp, color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0.r),
                  ),
                ),
              ),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () async {
                  try {
                    showDialog<bool>(
                      context: context,
                      builder: (c) => AlertDialog(
                        title: Text(
                          lang.lang == "en" ? 'Confirm' : "تأكيد ",
                          style: TextStyle(color: Colors.red),
                        ),
                        content: Text(
                          lang.lang == "en"
                              ? 'Are you sure you want to cancel the order (a fine may apply) '
                              : 'هل أنت متأكد لإلغاء الطلب ',
                          style: TextStyle(fontSize: 15.sp, color: Colors.red),
                        ),
                        actions: [
                          TextButton(
                            child: const Text('Yes'),
                            onPressed: () async {
                              try {
                                if (order_id != null) {
                                  String name = "$id   supplier  $username";
                                  int parsedId = int.parse(
                                    order_id ?? '',
                                    radix: 10,
                                  );
                                  String url =
                                      "https://www.ordervite.com/api/supplier/order_update/$parsedId";
                                  var response = await http.put(
                                    Uri.parse(url),
                                    body: {
                                      "order_cancel": "$name cancel order",
                                    },
                                    headers: {'Authorization': 'Bearer $token'},
                                  );
                                  var reposnsebody = jsonDecode(response.body);
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
                                  Navigator.pop(context);
                                  if (reposnsebody != null) {
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
                                await _showNetworkErrorDialog(lang);
                                return;
                              }
                            },
                          ),
                          TextButton(
                            child: const Text('No'),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      ),
                    );
                  } catch (e) {
                    await _showNetworkErrorDialog(lang);
                    return;
                  }
                },
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
          ],
        ),
      ],
    );
  }
}
