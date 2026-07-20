import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_maps/services/order_repository.dart';
import 'package:flutter_maps/shipper/order/presentation/shipper_order_cubit.dart';
import 'package:flutter_maps/supplier/order/presentation/supplier_order__cubit.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'core/di/di.dart';
import 'firebase_options.dart';
import 'my_app.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {}
Future<void> initNotifications() async {
  try {
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    await messaging.requestPermission(alert: true, badge: true, sound: true);
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {});
  } catch (e) {}
}

Future<void> main() async {
  configureDependencies();
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  await initNotifications();

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider<SupplierOrderCubit>(
          create: (_) => SupplierOrderCubit(
            OrderRepository(),
          ),
        ),
        BlocProvider<ShipperOrderCubit>(
          create: (_) => ShipperOrderCubit(),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class PointObject {
  final Widget? child;
  final LatLng? location;

  const PointObject({this.child, this.location});
}
