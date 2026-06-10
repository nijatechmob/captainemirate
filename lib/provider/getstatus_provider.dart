// import 'package:flutter/material.dart';
// import '../data/model/status/statusmodel.dart';
// import '../data/services/fm_apiservice.dart';


// class GetStatusProvider extends ChangeNotifier {
//   final FMapiservice apiService = FMapiservice();

//   bool isLoading = false;
//   String? error;

//   GetstatusModel? statusResponse;
//   List<Statuslist> statusList = [];

//   // =========================
//   // GET STATUS API CALL
//   // =========================
// Future<void> fetchStatus() async {
//   isLoading = true;
//   error = null;
//   notifyListeners();

//   try {
//     final response = await apiService.getStatus();

//     statusResponse = response;
//     statusList = response.data;

//     isLoading = false;
//     notifyListeners();
//   } catch (e) {
//     isLoading = false;
//     error = e.toString();
//     notifyListeners();
//   }
// }

//   // Optional: clear data
//   void clearStatus() {
//     statusResponse = null;
//     statusList = [];
//     error = null;
//     notifyListeners();
//   }
// }



import 'package:captainemirates/views/screens/auth/loginscreen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../data/model/status/statusmodel.dart';
import '../data/services/fm_apiservice.dart';
import '../core/utils/prefs.dart';


class GetStatusProvider extends ChangeNotifier {
  final FMapiservice apiService = FMapiservice();

  bool isLoading = false;
  String? error;

  GetstatusModel? statusResponse;
  List<Statuslist> statusList = [];

  // =========================
  // GET STATUS API
  // =========================
  Future<void> fetchStatus(BuildContext context) async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final response = await apiService.getStatus();

      statusResponse = response;
      statusList = response.data;

      // 🔥 AUTO LOGOUT CONDITION
      if (response.status == "N") {
        await forceLogout();
        return;
      }

      isLoading = false;
      notifyListeners();
    } catch (e) {
      isLoading = false;
      error = e.toString();
      notifyListeners();
    }
  }

  // =========================
  // FORCE LOGOUT
  // =========================
Future<void> forceLogout() async {
  await Prefs.clear();

  Get.offAll(() => Loginscreen());

  Get.snackbar(
    "Session Expired",
    "Your account is deactivated",
    snackPosition: SnackPosition.BOTTOM,
  );
}

  // =========================
  // CLEAR
  // =========================
  void clearStatus() {
    statusResponse = null;
    statusList = [];
    error = null;
    notifyListeners();
  }
}