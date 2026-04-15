import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_maps/Core/routes_manager.dart';
import 'package:flutter_maps/classes.dart';
import 'package:flutter_maps/lang.dart';
import 'package:flutter_maps/shipper/widgets/sh_order_icons.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;
import 'package:location/location.dart';

class ShOrderStatesWidget extends StatefulWidget {
  ShOrderStatesWidget({
    super.key,
    required this.order_id,
    required this.order_supplier_id,
    required this.order_price,
    required this.order_pricecheck,
    required this.id,
    required this.token,
    required this.order_cost,
    required this.lang,
    required this.order_state,
    required this.api_token,
    required this.isConfirm,
    required this.isReceived,
    required this.isDelviered,
    required this.username,
  });

  Lang lang;

  String order_state;

  String? order_id;

  final String order_supplier_id, order_price, order_pricecheck, id, token;
  String api_token;
  String? username;

  final String order_cost;

  bool isConfirm;

  bool isReceived;

  bool isDelviered;

  @override
  State<ShOrderStatesWidget> createState() => _ShOrderStatesWidgetState();
}

class _ShOrderStatesWidgetState extends State<ShOrderStatesWidget> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: Text(
                widget.lang.lang == "en"
                    ? "Order State: ${widget.order_state}"
                    : (widget.order_state == "new"
                          ? "حالة الطلب : جديد"
                          : (widget.order_state == "shipper confirmed"
                                ? "حالة الطلب : تاكيد مسئول الشحن  "
                                : (widget.order_state == "order received"
                                      ? "حالة الطلب :   استلام الشحنة   "
                                      : (widget.order_state == "order delivered"
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

        SizedBox(height: 8.h),
        ShOrderIcons(
          isConfirm: widget.isConfirm,
          isDelviered: widget.isDelviered,
          isReceived: widget.isReceived,
        ),
        SizedBox(height: 8.h),
        Row(
          children: <Widget>[
            Expanded(
              child: Text(
                widget.lang.lang == "en"
                    ? "Order ID: ${widget.order_id}"
                    : "كود الطلب :${widget.order_id}",
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                  fontStyle: FontStyle.normal,
                  color: Colors.white,
                ),
              ),
            ),

            SizedBox(width: 20.w),

            Expanded(
              child: Text(
                widget.lang.lang == "en"
                    ? "Supplier ID: ${widget.order_supplier_id} "
                    : "كود المورد : ${widget.order_supplier_id}",
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

        SizedBox(height: 8.h),
        Row(
          children: <Widget>[
            Expanded(
              child: Text(
                widget.lang.lang == "en" ? "Shipping Cost:" : "تكلفة الشحن ",
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                  fontStyle: FontStyle.normal,
                  color: Colors.white,
                ),
              ),
            ),

            SizedBox(width: 20.w),
            Expanded(
              child: Text(
                widget.lang.lang == "en" ? "Package Price:" : "سعر الشحنة ",
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
        SizedBox(height: 5.h),

        Row(
          children: <Widget>[
            Expanded(
              child: Text(
                widget.lang.lang == "en"
                    ? "${widget.order_cost} L.E."
                    : "${widget.order_cost} جم",
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                  fontStyle: FontStyle.normal,
                  color: Colors.white,
                ),
              ),
            ),

            SizedBox(width: 20.w),
            Expanded(
              child: Text(
                widget.lang.lang == "en"
                    ? "${widget.order_price} L.E."
                    : "${widget.order_price} جم",
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

        SizedBox(height: 8.h),
        Row(
          children: [
            Expanded(
              child: Text(
                widget.lang.lang == "en"
                    ? "Payment Method : ${widget.order_pricecheck}"
                    : (widget.order_pricecheck == "cash"
                          ? "نظام الدفع  : كاش"
                          : "نظام الدفع  : تحويل"),
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
        SizedBox(height: 10.h),
        !widget.isConfirm
            ? Row(
                children: <Widget>[
                  SizedBox(width: 10.w),

                  Expanded(
                    child: TextButton.icon(
                      onPressed: () async {
                        if (widget.isConfirm) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              backgroundColor: Colors.redAccent,
                              content: Text(
                                widget.lang.lang == "en"
                                    ? 'Please wait, your order request is already sent...'
                                    : 'الرجاء الانتظار، تم إرسال طلبك بالفعل',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16.sp,
                                ),
                              ),
                            ),
                          );
                          return;
                        }

                        try {
                          Location locationTracker = Location();
                          var location = await locationTracker.getLocation();

                          if (location.latitude == null ||
                              location.longitude == null) {
                            throw Exception("Location not available");
                          }

                          showDialog<bool>(
                            context: context,
                            builder: (c) => AlertDialog(
                              title: Text(
                                widget.lang.lang == "en" ? 'Confirm' : 'تأكيد',
                                style: const TextStyle(color: Colors.red),
                              ),
                              content: Text(
                                widget.lang.lang == "en"
                                    ? 'Are you sure you want to acquire this order?'
                                    : 'هل أنت متأكد أنك تريد استلام هذا الطلب؟',
                                style: TextStyle(
                                  fontSize: 15.sp,
                                  color: Colors.red,
                                ),
                              ),
                              actions: [
                                TextButton(
                                  child: Text(
                                    widget.lang.lang == "en" ? 'Yes' : 'نعم',
                                  ),
                                  onPressed: () async {
                                    Navigator.of(context).pop();

                                    try {
                                      if (widget.order_id == null ||
                                          widget.order_id!.isEmpty) {
                                        throw Exception("Invalid order id");
                                      }

                                      int id = int.parse(widget.order_id!);

                                      String url =
                                          "https://www.ordervite.com/api/shippier/orders/$id";

                                      var response = await http.put(
                                        Uri.parse(url),
                                        body: {
                                          "shippier_id":
                                              widget.id?.toString() ?? "",
                                          "sh_longitude": location.longitude
                                              .toString(),
                                          "sh_latitude": location.latitude
                                              .toString(),
                                          "order_state": "shipper confirmed",
                                        },
                                        headers: {
                                          'Authorization':
                                              'Bearer ${widget.token}',
                                        },
                                      );

                                      var responseBody = jsonDecode(
                                        response.body,
                                      );

                                      if (response.statusCode != 200 ||
                                          responseBody == null) {
                                        throw Exception("Server error");
                                      }

                                      int subId = int.parse(
                                        responseBody["data"]["supplier_id"]
                                            .toString(),
                                      );

                                      String url2 =
                                          "https://www.ordervite.com/api/shippier/supplier/$subId";

                                      var response2 = await http.get(
                                        Uri.parse(url2),
                                        headers: {
                                          'Authorization':
                                              'Bearer ${widget.token}',
                                        },
                                      );

                                      var responseBody2 = jsonDecode(
                                        response2.body,
                                      );

                                      setState(() {
                                        widget.api_token =
                                            responseBody2["data"]["name"]["api_token"]
                                                .toString();

                                        widget.isConfirm = true;
                                        widget.order_state =
                                            responseBody["data"]["order_state"]
                                                .toString();
                                      });

                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          backgroundColor: Colors.green,
                                          content: Text(
                                            widget.lang.lang == "en"
                                                ? 'Order confirmed successfully, go to supplier.'
                                                : 'تم تأكيد الطلب، توجه إلى المورد.',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14.sp,
                                            ),
                                          ),
                                        ),
                                      );
                                    } catch (e) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          backgroundColor: Colors.red,
                                          content: Text(
                                            widget.lang.lang == "en"
                                                ? 'Something went wrong'
                                                : 'حدث خطأ ما',
                                          ),
                                        ),
                                      );
                                    }
                                  },
                                ),
                                TextButton(
                                  child: Text(
                                    widget.lang.lang == "en" ? 'No' : 'لا',
                                  ),
                                  onPressed: () => Navigator.of(context).pop(),
                                ),
                              ],
                            ),
                          );
                        } catch (e) {
                          showDialog(
                            context: context,
                            builder: (c) => AlertDialog(
                              title: Text(
                                widget.lang.lang == "en" ? 'Warning' : 'تحذير',
                                style: const TextStyle(color: Colors.red),
                              ),
                              content: Text(
                                widget.lang.lang == "en"
                                    ? 'Please check your location & network'
                                    : 'يرجى التحقق من الموقع والإنترنت',
                                style: TextStyle(
                                  fontSize: 15.sp,
                                  color: Colors.red,
                                ),
                              ),
                            ),
                          );
                        }
                      },
                      icon: Icon(Icons.done_all, size: 20.sp),
                      label: Text(
                        widget.lang.lang == "en" ? "Confirm" : "تأكيد",
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

                  SizedBox(width: 15.w),

                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        showDialog<bool>(
                          context: context,
                          builder: (c) => AlertDialog(
                            title: Text(
                              widget.lang.lang == "en" ? 'Confirm' : 'تأكيد',
                              style: const TextStyle(color: Colors.red),
                            ),
                            content: Text(
                              widget.lang.lang == "en"
                                  ? 'Are you sure you want to cancel the order?'
                                  : 'هل أنت متأكد من إلغاء الطلب؟',
                              style: TextStyle(
                                fontSize: 15.sp,
                                color: Colors.red,
                              ),
                            ),
                            actions: [
                              TextButton(
                                child: Text(
                                  widget.lang.lang == "en" ? 'Yes' : 'نعم',
                                ),
                                onPressed: () {
                                  Navigator.of(context).pop();

                                  Message message = Message(
                                    widget.lang.lang == "en"
                                        ? "Order canceled"
                                        : "تم إلغاء الطلب",
                                  );

                                  Navigator.pushNamedAndRemoveUntil(
                                    context,
                                    RoutesManager.shHome,
                                    (route) => false,
                                    arguments: message,
                                  );
                                },
                              ),
                              TextButton(
                                child: Text(
                                  widget.lang.lang == "en" ? 'No' : 'لا',
                                ),
                                onPressed: () => Navigator.of(context).pop(),
                              ),
                            ],
                          ),
                        );
                      },
                      icon: Icon(Icons.cancel, size: 20.sp),
                      label: Text(
                        widget.lang.lang == "en" ? "Cancel" : "إلغاء",
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
              )
            : !widget.isReceived
            ? Row(
                children: <Widget>[
                  SizedBox(width: 10.w),

                  Expanded(
                    child: TextButton.icon(
                      onPressed: () async {
                        if (widget.isReceived) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              backgroundColor: Colors.redAccent,
                              content: Text(
                                widget.lang.lang == "en"
                                    ? 'Order not received yet'
                                    : 'لم يتم استلام الطلب بعد',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16.sp,
                                ),
                              ),
                            ),
                          );
                          return;
                        }

                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (c) => AlertDialog(
                            title: Text(
                              widget.lang.lang == "en" ? 'Confirm' : 'تاكيد',
                              style: const TextStyle(color: Colors.red),
                            ),
                            content: Text(
                              widget.lang.lang == "en"
                                  ? 'Confirm receiving the package?'
                                  : 'تأكيد استلام الطلب؟',
                              style: TextStyle(fontSize: 15.sp),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(c, true),
                                child: Text(
                                  widget.lang.lang == "en" ? 'Yes' : 'نعم',
                                ),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(c, false),
                                child: Text(
                                  widget.lang.lang == "en" ? 'No' : 'لا',
                                ),
                              ),
                            ],
                          ),
                        );

                        if (confirm != true) return;

                        try {
                          final id = int.tryParse(widget.order_id ?? '');
                          if (id == null) throw Exception("Invalid order id");

                          final response = await http.put(
                            Uri.parse(
                              "https://www.ordervite.com/api/shippier/order_update/$id",
                            ),
                            body: {"order_state": "order received"},
                            headers: {
                              'Authorization': 'Bearer ${widget.token}',
                            },
                          );

                          if (response.statusCode != 200) {
                            throw Exception("Server error");
                          }

                          final data = jsonDecode(response.body);

                          if (!mounted) return;

                          setState(() {
                            widget.isReceived = true;
                            widget.order_state = data["data"]["order_state"]
                                .toString();
                          });

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              backgroundColor: Colors.green,
                              content: Text(
                                widget.lang.lang == "en"
                                    ? 'Order received successfully'
                                    : 'تم استلام الطلب بنجاح',
                              ),
                            ),
                          );
                        } catch (e) {
                          if (!mounted) return;

                          showDialog(
                            context: context,
                            builder: (_) => AlertDialog(
                              title: Text(
                                widget.lang.lang == "en" ? 'Error' : 'خطأ',
                              ),
                              content: Text(
                                widget.lang.lang == "en"
                                    ? 'Check your connection'
                                    : 'تحقق من الاتصال بالإنترنت',
                              ),
                            ),
                          );
                        }
                      },
                      icon: Icon(Icons.done_all, size: 20.sp),
                      label: Text(
                        widget.lang.lang == "en" ? "Received PK" : "استلام",
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

                  SizedBox(width: 15.w),

                  /// ===================== CANCEL BUTTON =====================
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (c) => AlertDialog(
                            title: Text(
                              widget.lang.lang == "en" ? 'Confirm' : 'تاكيد',
                              style: const TextStyle(color: Colors.red),
                            ),
                            content: Text(
                              widget.lang.lang == "en"
                                  ? 'Are you sure you want to cancel the order?'
                                  : 'هل أنت متأكد أنك تريد إلغاء الطلب؟',
                              style: TextStyle(fontSize: 15.sp),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(c, true),
                                child: Text(
                                  widget.lang.lang == "en" ? 'Yes' : 'نعم',
                                ),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(c, false),
                                child: Text(
                                  widget.lang.lang == "en" ? 'No' : 'لا',
                                ),
                              ),
                            ],
                          ),
                        );

                        if (confirm != true) return;

                        try {
                          final id = int.tryParse(widget.order_id ?? '');
                          if (id == null) throw Exception("Invalid order id");

                          final name =
                              "${widget.id} shipper ${widget.username}";

                          final response = await http.put(
                            Uri.parse(
                              "https://www.ordervite.com/api/shippier/order_update/$id",
                            ),
                            body: {"order_cancel": "$name cancel order"},
                            headers: {
                              'Authorization': 'Bearer ${widget.token}',
                            },
                          );

                          if (response.statusCode != 200) {
                            throw Exception("Server error");
                          }

                          final data = jsonDecode(response.body);

                          if (!mounted) return;

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              backgroundColor: Colors.redAccent,
                              content: Text(
                                widget.lang.lang == "en"
                                    ? 'Order canceled'
                                    : 'تم إلغاء الطلب',
                              ),
                            ),
                          );

                          Message message = Message(
                            widget.lang.lang == "en"
                                ? "Order canceled"
                                : "تم إلغاء الطلب",
                          );

                          Navigator.pushNamedAndRemoveUntil(
                            context,
                            RoutesManager.shHome,
                            (route) => false,
                            arguments: message,
                          );
                        } catch (e) {
                          if (!mounted) return;

                          showDialog(
                            context: context,
                            builder: (_) => AlertDialog(
                              title: Text(
                                widget.lang.lang == "en" ? 'Error' : 'خطأ',
                              ),
                              content: Text(
                                widget.lang.lang == "en"
                                    ? 'Check your connection'
                                    : 'تحقق من الاتصال بالإنترنت',
                              ),
                            ),
                          );
                        }
                      },
                      icon: Icon(Icons.cancel, size: 20.sp),
                      label: Text(
                        widget.lang.lang == "en" ? "Cancel" : "الغاء",
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
              )
            : !widget.isDelviered
            ? Row(
                children: <Widget>[
                  SizedBox(width: 10.w),

                  Expanded(
                    child: TextButton.icon(
                      onPressed: () async {
                        if (widget.isDelviered) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              backgroundColor: Colors.redAccent,
                              content: Text(
                                widget.lang.lang == "en"
                                    ? 'error order not delivered until yet  ...'
                                    : 'هناك خطأ، لم يتم تسليم طلبك حتى الآن',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16.sp,
                                ),
                              ),
                            ),
                          );
                        } else {
                          try {
                            showDialog<bool>(
                              context: context,
                              builder: (c) => AlertDialog(
                                title: Text(
                                  widget.lang.lang == "en"
                                      ? 'Confirm'
                                      : 'تاكيد',
                                  style: TextStyle(color: Colors.red),
                                ),
                                content: Text(
                                  widget.lang.lang == "en"
                                      ? 'Please confirm that you have delivered the package'
                                      : 'من فضلك قم بتاكيد تسليم الشحنة',
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    color: Colors.red,
                                  ),
                                ),
                                actions: [
                                  TextButton(
                                    child: Text(
                                      widget.lang.lang == "en" ? 'Yes' : 'نعم',
                                    ),
                                    onPressed: () async {
                                      int id = int.parse(
                                        this.widget.order_id!,
                                        radix: 10,
                                      );

                                      String Url =
                                          "https://www.ordervite.com/api/shippier/order_update/$id";

                                      var response = await http.put(
                                        Uri.parse(Url),
                                        body: {
                                          "order_state": "order delivered",
                                        },
                                        headers: {
                                          'Authorization':
                                              'Bearer  ' + this.widget.token!,
                                        },
                                      );

                                      var reposnsebody = jsonDecode(
                                        response.body,
                                      );

                                      String text = widget.lang.lang == "en"
                                          ? "your order is delveried by shipper"
                                          : "تم تسليم الشحنة بواسطة مسئول الشحن  ";

                                      String supplier_api_token = this
                                          .widget
                                          .api_token
                                          .toString();

                                      String Url3 =
                                          "https://www.ordervite.com/api/notify/page/ordervite/$text /$supplier_api_token/1/ordervite/shipper/order delivered";

                                      await http.get(
                                        Uri.parse(Url3),
                                        headers: {
                                          'Content-Type': 'application/json',
                                          'Accept': 'application/json',
                                          'Authorization':
                                              'Bearer  ' + this.widget.token!,
                                        },
                                      );

                                      setState(() {
                                        widget.isDelviered = true;
                                        widget.order_state =
                                            reposnsebody["data"]["order_state"]
                                                .toString();
                                      });

                                      Navigator.of(context).pop();

                                      if (reposnsebody != null) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            backgroundColor: Colors.redAccent,
                                            content: Text(
                                              widget.lang.lang == "en"
                                                  ? 'Well Done! Now wait for the supplier to confirm the order'
                                                  : 'أحسنت! الآن انتظر المورد لتأكيد الطلب. ',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 18.sp,
                                              ),
                                            ),
                                          ),
                                        );
                                      }
                                    },
                                  ),
                                  TextButton(
                                    child: Text(
                                      widget.lang.lang == "en" ? 'No' : 'لا',
                                    ),
                                    onPressed: () =>
                                        Navigator.of(context).pop(),
                                  ),
                                ],
                              ),
                            );
                          } catch (e) {
                            showDialog<bool>(
                              context: context,
                              builder: (c) => AlertDialog(
                                title: Text(
                                  widget.lang.lang == "en"
                                      ? 'Warning'
                                      : 'تحذير',
                                  style: TextStyle(color: Colors.red),
                                ),
                                content: Text(
                                  widget.lang.lang == "en"
                                      ? 'Please check your network  '
                                      : '  يرجي التحقق من اتصال الشبكة الخاص بك   ',
                                  style: TextStyle(
                                    fontSize: 15.sp,
                                    color: Colors.red,
                                  ),
                                ),
                                actions: [],
                              ),
                            );
                          }
                        }
                      },
                      icon: Icon(Icons.done_all, size: 20.sp),
                      label: Text(
                        widget.lang.lang == "en" ? "Delivered PK " : "تسليم",
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

                  SizedBox(width: 15.w),

                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        setState(() {
                          widget.isConfirm = false;
                        });

                        showDialog<bool>(
                          context: context,
                          builder: (c) => AlertDialog(
                            title: Text(
                              widget.lang.lang == "en" ? 'Confirm' : 'تاكيد',
                              style: TextStyle(color: Colors.red),
                            ),
                            content: Text(
                              widget.lang.lang == "en"
                                  ? 'Are you sure you want to cancel the order (a fine may apply) '
                                  : '   هل أنت متأكد أنك تريد إلغاء الطلب (قد يتم تطبيق غرامة)؟',
                              style: TextStyle(
                                fontSize: 15.sp,
                                color: Colors.red,
                              ),
                            ),
                            actions: [
                              TextButton(
                                child: Text(
                                  widget.lang.lang == "en" ? 'Yes' : 'نعم',
                                ),
                                onPressed: () async {
                                  try {
                                    if (this.widget.order_id != null) {
                                      String name =
                                          this.widget.id! +
                                          ' ' +
                                          '  shipper  ' +
                                          this.widget.username!;

                                      int id = int.parse(
                                        this.widget.order_id!,
                                        radix: 10,
                                      );

                                      String Url =
                                          "https://www.ordervite.com/api/shippier/order_update/$id";

                                      var response = await http.put(
                                        Uri.parse(Url),
                                        body: {
                                          "order_cancel": "$name cancel order",
                                        },
                                        headers: {
                                          'Authorization':
                                              'Bearer  ' + this.widget.token!,
                                        },
                                      );

                                      var reposnsebody = jsonDecode(
                                        response.body,
                                      );

                                      String supplier_api_token = this
                                          .widget
                                          .api_token
                                          .toString();

                                      String text = widget.lang.lang == "en"
                                          ? "your order is canceled by shipper"
                                          : " تم  الغاء الطلب بواسطة مسئول الشحن  ";

                                      String Url3 =
                                          "https://www.ordervite.com/api/notify/page/ordervite/$text /$supplier_api_token/1/ordervite/shipper/order cancel";

                                      await http.get(
                                        Uri.parse(Url3),
                                        headers: {
                                          'Content-Type': 'application/json',
                                          'Accept': 'application/json',
                                          'Authorization':
                                              'Bearer  ' + this.widget.token!,
                                        },
                                      );

                                      Navigator.of(context).pop();

                                      if (reposnsebody != null) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            backgroundColor: Colors.redAccent,
                                            content: Text(
                                              widget.lang.lang == "en"
                                                  ? 'Order have canceled ...'
                                                  : '...تم الغاء الطلب',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 18.sp,
                                              ),
                                            ),
                                          ),
                                        );
                                      }

                                      Message message = Message(
                                        widget.lang.lang == "en"
                                            ? "you  have canceld order"
                                            : "تم الغاء الطلب ...",
                                      );

                                      Navigator.pushNamedAndRemoveUntil(
                                        context,
                                        RoutesManager.shHome,
                                        (route) => false,
                                        arguments: message,
                                      );
                                    }
                                  } catch (e) {
                                    showDialog<bool>(
                                      context: context,
                                      builder: (c) => AlertDialog(
                                        title: Text(
                                          widget.lang.lang == "en"
                                              ? 'Warning'
                                              : 'تحذير',
                                          style: TextStyle(color: Colors.red),
                                        ),
                                        content: Text(
                                          widget.lang.lang == "en"
                                              ? 'Please check your network  '
                                              : '  يرجي التحقق من اتصال الشبكة الخاص بك   ',
                                          style: TextStyle(
                                            fontSize: 15.sp,
                                            color: Colors.red,
                                          ),
                                        ),
                                        actions: [],
                                      ),
                                    );
                                  }
                                },
                              ),
                              TextButton(
                                child: Text(
                                  widget.lang.lang == "en" ? 'No' : 'لا ',
                                ),
                                onPressed: () => Navigator.of(context).pop(),
                              ),
                            ],
                          ),
                        );
                      },
                      icon: Icon(Icons.cancel, size: 20.sp),
                      label: Text(
                        widget.lang.lang == "en" ? "Cancel" : "الغاء",
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
              )
            : Container(
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.all(Radius.circular(18.0.r)),
                ),
                child: Padding(
                  padding: EdgeInsets.all(3.r),
                  child: Row(
                    children: <Widget>[
                      SizedBox(width: 10.w),

                      Expanded(
                        child: Text(
                          widget.lang.lang == "en"
                              ? "You have confirmed the package delivery, please wait for the supplier final confirmation "
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
              ),
      ],
    );
  }
}
