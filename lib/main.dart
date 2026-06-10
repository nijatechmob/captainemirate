import 'package:captainemirates/provider/regularizationlist_Provider.dart';
import 'package:captainemirates/provider/salesorder_provider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';


import 'core/theme/app_theme.dart';
import 'core/utils/prefs.dart';

import 'provider/addregularization_provider.dart';
import 'provider/getstatus_provider.dart';
import 'provider/monthlyattendance_provider.dart';
import 'provider/single_regularization_provider.dart';
import 'provider/timesheet_provider.dart';
import 'provider/login_provider.dart';
import 'router/getx_routes.dart';

final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();
Future<void> main() async {
   WidgetsFlutterBinding.ensureInitialized();

  await Prefs.init(); 
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
           ChangeNotifierProvider(create: (_) => LoginProvider()),
           ChangeNotifierProvider(create: (_) => SalesOrderProvider()),
              ChangeNotifierProvider(create: (_) => TimesheetProvider()),
              ChangeNotifierProvider(create: (_) => RegularizationProvider()),
              ChangeNotifierProvider(create: (_) => GetStatusProvider()),
              ChangeNotifierProvider(create: (_) => AddRegularizationProvider()),
                 ChangeNotifierProvider(create: (_) => MonthlyAttendanceProvider()),
                 ChangeNotifierProvider(create: (_) => SingleRegularizationProvider()),    
        ],
      child: GetMaterialApp(
        title: 'Emirate',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        initialRoute: AppRoutes.splash,
        getPages: getPages,
        navigatorObservers: [
    routeObserver, 
  ],
      ),
    );
  }
}