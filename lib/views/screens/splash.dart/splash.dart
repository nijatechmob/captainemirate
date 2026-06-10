




import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';


import '../../../core/constant/app_assets.dart';
import '../../../core/constant/app_color.dart';
import '../../../core/utils/prefs.dart';

import '../../../router/getx_routes.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      checkLogin();
    });
  }

 Future<void> checkLogin() async {
  await Future.delayed(const Duration(seconds: 2));

  final isLoggedIn = await Prefs.getLoggedIn("isLoggedIn") ?? false;

  if (!mounted) return;

  if (isLoggedIn) {
    Get.offAllNamed(AppRoutes.home);
  } else {
    Get.offAllNamed(AppRoutes.login);
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPage,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.bgPage,
          border: Border.all(color: const Color(0x4d9e9e9e), width: 1),
        ),
        child: const Stack(
          alignment: Alignment.center,
          children: [
            Image(
              image: AssetImage(Appassets.app_icon),
              width: 100,
            ),
            Align(
              alignment: Alignment(0.0, 0.9),
              child: Text(
                "Captain Emirates",
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 22,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}