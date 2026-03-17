import 'package:flutter/material.dart';
import 'package:flutter_maps/Core/routes_manager.dart';
import 'package:flutter_maps/widgets/rating.dart';
import 'package:flutter_maps/classes.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_maps/lang.dart';
import 'package:http/http.dart' as http;

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
            icon: const Icon(Icons.arrow_back_ios),
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
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),

              Rating((rating) {
                setState(() {
                  _rating = rating;
                });
              }, 5),

              SizedBox(
                height: 44,
                child: (_rating != null && _rating != 0)
                    ? Text(
                        lang.lang == "en"
                            ? "You selected $_rating rating"
                            : "تقييمك $_rating نجوم",
                        style: const TextStyle(fontSize: 18),
                      )
                    : const SizedBox.shrink(),
              ),

              const SizedBox(height: 20),

              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey,
                  borderRadius: BorderRadius.circular(32),
                ),
                child: TextField(
                  controller: messageTextEditController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: lang.lang == "en"
                        ? 'Type your Review...'
                        : 'اكتب تعليق',
                    hintStyle: const TextStyle(color: Colors.white),
                  ),
                ),
              ),

              Row(
                children: [
                  const SizedBox(width: 10),

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
                      icon: const Icon(Icons.done_all, size: 20),
                      label: Text(
                        lang.lang == "en" ? "Submit" : "ارسال",
                        style: const TextStyle(
                          fontSize: 22,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 10),

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
                      icon: const Icon(Icons.cancel, size: 20),
                      label: Text(
                        lang.lang == "en" ? "Skip" : "تخطي",
                        style: const TextStyle(
                          fontSize: 22,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 10),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
