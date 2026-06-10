


import 'package:captainemirates/views/dash_boardscreen.dart';
import 'package:captainemirates/views/screens/auth/loginscreen.dart';
import 'package:captainemirates/views/screens/homescreen.dart';
import 'package:captainemirates/views/screens/profilescreen.dart';
import 'package:get/get.dart';

import '../views/screens/attendance/checkinpage.dart';
import '../views/screens/attendance/checkoutscreen.dart';
import '../views/screens/employeereportspage.dart';
import '../views/screens/regularizescreen.dart';
import '../views/screens/splash.dart/splash.dart';


class AppRoutes {
  static const splash = "/splash";
  static const dash = "/dash";
  static const home = "/home";

  static const login = "/login";
  static const profile = "/profile";
  static const checkin = "/checkin";
  static const checkout = "/checkout";
  static const Regularize = "/Regularize";
  static const Employeereport = "/Employeereport";


}

final List<GetPage> getPages = [
  GetPage(
    name: AppRoutes.splash,
    page: () => const SplashScreen(),
  ),
  GetPage(
    name: AppRoutes.dash,
    page: () => const Dashboard(),
  ),
  GetPage(
    name: AppRoutes.home,
    page: () => const Homescreen(),
  ),
  GetPage(
    name: AppRoutes.login,
    page: () => const Loginscreen(),
  ),
  GetPage(
    name: AppRoutes.profile,
    page: () => const Profilescreen(),
  ),
  GetPage(
    name: AppRoutes.checkin,
    page: () => const Checkinscreen(),
  ),
  GetPage(
    name: AppRoutes.checkin,
    page: () => const Checkoutscreen(),
  ),
  GetPage(
    name: AppRoutes.Employeereport,
    page: () => const Employeereportspage(),
  ),

  GetPage(
    name: AppRoutes.Regularize,
    page: () => const Regularizescreen(date: '', checkIn: '', checkOut: '', internalId: '', employee: '', hoursWorked: '', salesOrderId: '', shiftMaster: '',),
  ),


];
