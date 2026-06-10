



import 'package:flutter/material.dart';
import '../core/enums/status.dart';
import '../core/utils/prefs.dart';
import '../data/model/loginpage/loginmodel.dart';
import '../data/services/fm_apiservice.dart';

class LoginProvider extends ChangeNotifier {
  final FMapiservice apiService = FMapiservice();

  Status status = Status.idle;
  LoginModel? loginModel;
  String error = '';

  bool isInitialized = false;
  bool isLoggedIn = false;



  /// 🔥 INIT (called from main)
  Future<void> init() async {
    isLoggedIn = await Prefs.getLoggedIn("isLoggedIn") ?? false;
    isInitialized = true;
    notifyListeners();
  }

  /// 🔐 LOGIN
  Future<void> login(String username, String password) async {
    status = Status.loading;
    error = '';
    notifyListeners();

    try {
      final response = await apiService.loginUser(
        username: username,
        password: password,
      );

      if (response.status == true && response.data != null) {
        loginModel = response;

        /// ✅ Save in prefs
        await Prefs.setLoggedIn("isLoggedIn", true);

        isLoggedIn = true;

      await Prefs.setName(
          "Name",
          response.data?.employeeName ?? "",
        );

        await Prefs.setInternalID(
          "InternalID",
          response.data?.internalId ?? "",
        );

        await Prefs.setEmail(
          "Email",
          response.data?.email ?? "",
        );

        await Prefs.setSupervisor(
          "Supervisor",
          response.data?.supervisor ?? "",
        );

        await Prefs.setSupervisorID(
          "SupervisorId",
          response.data?.supervisorId ?? "",
        );

        await Prefs.setEmpType(
          "EmpType",
          response.data?.emptype ?? "",
        );


print("EmpType: ${response.data?.emptype ?? ""}");

        status = Status.success;
      } else {
        error = response.message ?? "Login failed";
        status = Status.error;
      }
    } catch (e) {
      error = e.toString();
      status = Status.error;
    }

    notifyListeners();
  }

  /// 🚪 LOGOUT
Future<void> logout(BuildContext context) async {
  await Prefs.setLoggedIn("isLoggedIn", false);

  /// 🧹 clear stored user data
  await Prefs.setName("Name", "");
  await Prefs.setInternalID("InternalID", "");
  await Prefs.setEmail("Email", "");
  await Prefs.setSupervisor("Supervisor", "");
  await Prefs.setSupervisorID("SupervisorId", "");

  /// 🧠 reset provider state
  isLoggedIn = false;
  loginModel = null;
  status = Status.idle;
  error = '';

  notifyListeners();

  /// 🚀 go to login and remove all previous pages
  Navigator.pushNamedAndRemoveUntil(
    context,
    '/login',
    (route) => false,
  );
}
}