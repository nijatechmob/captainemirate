



import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../../../core/constant/app_assets.dart';
import '../../../core/constant/app_color.dart';
import '../../../core/enums/status.dart';
import '../../../provider/login_provider.dart';
import '../../../router/getx_routes.dart';
import '../../../widgets/custom_textfield.dart';
import 'auth_validation.dart';

class Loginscreen extends StatefulWidget {
  const Loginscreen({super.key});

  @override
  State<Loginscreen> createState() => _LoginscreenState();
}

class _LoginscreenState extends State<Loginscreen> {
  final formKey = GlobalKey<FormState>();

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final validator = AuthValidation();

  bool isPasswordVisible = false;

  void handleLogin(LoginProvider provider) async {
    if (!formKey.currentState!.validate()) return;

    await provider.login(
      emailController.text.trim(),
      passwordController.text.trim(),
    );

    if (provider.status == Status.success) {
      Get.offAllNamed(AppRoutes.home);
    } else if (provider.status == Status.error) {
      Get.snackbar(
        "Error",
        provider.error,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPage,
      body: SafeArea(
        child: Consumer<LoginProvider>(
          builder: (context, provider, _) {
            return Stack(
              children: [
                /// 🔹 MAIN UI
                Column(
                  children: [
                    const SizedBox(height: 60),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Image.asset(
                        Appassets.app_icon,
                        width: 120,
                        height: 120,
                      ),
                    ),

                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Form(
                          key: formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 40),

                              Row(
                                children: [
                                  Text(
                                    "Welcome Back",
                                    style: TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.darker,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Image.asset(Appassets.hi, scale: 4),
                                ],
                              ),

                              const SizedBox(height: 10),

                              Text(
                                "Hello there, login to continue",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: AppColors.litgrey,
                                ),
                              ),

                              const SizedBox(height: 20),

                              /// EMAIL
                              CustomRoundedTextField(
                                width: double.infinity,
                                keyboardType: TextInputType.emailAddress,
                                labelText: 'Email Address',
                                controller: emailController,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return "Email is required";
                                  }
                                  return null;
                                },
                              ),

                              const SizedBox(height: 24),

                              /// PASSWORD
                              CustomRoundedTextField(
                                width: double.infinity,
                                keyboardType: TextInputType.text,
                                labelText: 'Password',
                                controller: passwordController,
                                obscureText: !isPasswordVisible,
                                validator:
                                    validator.validateLoginPassword,
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    isPasswordVisible
                                        ? Icons.visibility
                                        : Icons.visibility_off,
                                    color: AppColors.litgrey,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      isPasswordVisible =
                                          !isPasswordVisible;
                                    });
                                  },
                                ),
                              ),

                              const SizedBox(height: 8),

                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton(
                                  onPressed: () {},
                                  child: Text(
                                    "Forgot Password ?",
                                    style: TextStyle(
                                        color: AppColors.primary),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 20),

                              /// LOGIN BUTTON
                              SizedBox(
                                width: double.infinity,
                                height: 50,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primary,
                                    shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(12),
                                    ),
                                  ),
                                  onPressed:
                                      provider.status == Status.loading
                                          ? null
                                          : () => handleLogin(provider),
                                  child: Text(
                                    "Log In",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.bgCard,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                /// 🔥 FULL SCREEN LOADER
                if (provider.status == Status.loading)
                  BackdropFilter(
                    filter:
                        ImageFilter.blur(sigmaX: 3, sigmaY: 3),
                    child: Container(
                      color: Colors.black.withOpacity(0.4),
                      child: const Center(
                        child: CircularProgressIndicator(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}