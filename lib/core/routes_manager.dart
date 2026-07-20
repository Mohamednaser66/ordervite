import 'package:flutter/cupertino.dart';
import 'package:flutter_maps/authpages.dart';
import 'package:flutter_maps/chat_screen.dart';
import 'package:flutter_maps/order.dart';
import 'package:flutter_maps/shipper/authantication/otp_screen.dart';
import 'package:flutter_maps/shipper/authantication/register_with_phone.dart';
import 'package:flutter_maps/shipper/chat_screen.dart';
import 'package:flutter_maps/shipper/home.dart';
import 'package:flutter_maps/shipper/authantication/login.dart';
import 'package:flutter_maps/shipper/order.dart';
import 'package:flutter_maps/shipper/orders.dart';
import 'package:flutter_maps/shipper/profile.dart';
import 'package:flutter_maps/shipper/authantication/register.dart';
import 'package:flutter_maps/shipper/shipper_history_screen.dart';
import 'package:flutter_maps/supplier/chat_screen.dart';
import 'package:flutter_maps/supplier/home_page/home_page.dart';
import 'package:flutter_maps/supplier/authantication/login.dart';
import 'package:flutter_maps/supplier/order.dart';
import 'package:flutter_maps/supplier/orderList.dart';
import 'package:flutter_maps/supplier/products/presantation/cart.dart';
import 'package:flutter_maps/supplier/products/presantation/goods_list_screen.dart';
import 'package:flutter_maps/supplier/profile.dart';
import 'package:flutter_maps/supplier/authantication/register.dart';
import 'package:flutter_maps/supplier/review.dart';
import 'package:flutter_maps/supplier/searchscreen.dart';
import 'package:flutter_maps/supplier/terms.dart';
import '../landing_page.dart';
import '../my_app.dart';
import '../supplier/products/presantation/products_screen.dart';

class RoutesManager {
  static const String login = '/login';
  static const String registerWithPhone = '/registerWithPhone';
  static const String register = '/register';
  static const String home = '/homepage';
  static const String suHome = '/suhome';
  static const String authPage = '/authpages';
  static const String shLogin = '/shlogin';
  static const String shRegister = '/shregister';
  static const String shHome = "/shhome";
  static const String search = '/searchscreen';
  static const String orderPage = '/orderscreen';
  static const String shOrders = '/shorders';
  static const String shOrder = '/shorder';
  static const String shListOrders = '/shlistorders';
  static const String shListOrder = '/shlistorder';
  static const String suListOrders = '/sulistorders';
  static const String terms = '/terms';
  static const String order = '/Order';
  static const String chatScreen = '/chatScreen';
  static const String suChatScreen = "/su_chat_screen";
  static const String shChatScreen = "/ShChatScreen";
  static const String rating = '/raring';
  static const String cart = '/cart';
  static const String suProfile = '/suProfile';
  static const String shProfile = '/shProfile';
  static const String landingPage = '/landingPage';
  static const String productsScreen = '/productsScreen';
  static const String otpScreen = '/otpScreen';
  static const String userOrderList = '/userOrderList';
  static const String goodsScreen = '/goodsScreen';
  static const String shipperOrdersScreen = '/shipperOrderScreen';

  static Map<String, WidgetBuilder> router = {
    login: (_) => LogIn(),
    userOrderList:  (context) {
  final supplierId =
  ModalRoute.of(context)!.settings.arguments as String;

  return UserOrderList(
  supplierId: supplierId,
  );
  },
    shipperOrdersScreen:  (context) {
  final shipperId =
  ModalRoute.of(context)!.settings.arguments as String;

  return ShipperHistoryScreen(
  shipperId: shipperId,
  );
  },
    otpScreen: (_) => OtpScreen(verificationId: '', role: '',),
    registerWithPhone: (_) => RegisterWithPhone(),
    goodsScreen: (_) => GoodsListScreen(),
    cart: (_) {
      return Cart();
    },
    landingPage: (_) => LandingPage(),
    register: (_) {
      return Register();
    },
    home: (_) {
      return MyApp();
    },
    suHome: (_) {
      return MyHomePage();
    },
    authPage: (_) {
      return AuthPages();
    },
    shLogin: (_) {
      return LogInSH(key: null);
    },
    shRegister: (_) {
      return RegisterSH();
    },
    shHome: (_) {
      return SHHomePage();
    },

    search: (_) {
      return SearchScreen();
    },
    orderPage: (_) {
      return OrderPage();
    },
    shOrders: (_) {
      return ShOrders();
    },
    shOrder: (_) {
      return ShOrder();
    },

    // shListOrders: (_) {
    //   return ShListOrders();
    // },
    // shListOrder: (_) {
    //   return ShListOrder();
    // },
    // suListOrders: (_) {
    //   return SuListOrders();
    // },
    terms: (_) {
      return Terms();
    },
    order: (_) {
      return Order();
    },

    chatScreen: (_) {
      return ChatScreen();
    },
    suChatScreen: (_) {
      return SuChatScreen();
    },
    shChatScreen: (_) {
      return ShChatScreen();
    },
    rating: (_) {
      return RatingsPage();
    },
    suProfile: (_) {
      return SUProfilePage();
    },
    shProfile: (_) {
      return SHProfilePage();
    },
    productsScreen: (_) => ProductsScreen(),
  };
}
