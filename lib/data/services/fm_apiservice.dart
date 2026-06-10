

import 'package:dio/dio.dart';


import '../../core/constant/api_details.dart';
import '../../core/constant/app_constants.dart';
import '../../core/utils/prefs.dart';
import '../model/getmonthlyattendance/getmonthlyattendancemodel.dart';
import '../model/loginpage/loginmodel.dart';
import '../model/regularization/addregularizationmodel.dart';
import '../model/regularization/getregularizationlistmodel.dart';
import '../model/regularization/getsingleregularizationlistmodel.dart';
import '../model/salesordermomodel/salesorderno_model.dart';
import '../model/status/statusmodel.dart';
import '../model/timesheetmodel/addtimesheet_model.dart';
import '../model/timesheetmodel/updatetimemodel.dart';



class FMapiservice {
  late Dio dio;

  FMapiservice() {
    dio = Dio(
      BaseOptions(
        baseUrl: AppConstants.apiBaseUrl,
        connectTimeout: const Duration(seconds: 20),
        receiveTimeout: const Duration(seconds: 20),
        headers: {
          'Content-Type': 'application/json',
        },
      ),
    );

    /// 🔹 Optional: Interceptor (logs)
    dio.interceptors.add(
      LogInterceptor(
        error: true,
        logPrint: (object) {
          print(object);
        },
        request: true,
        requestHeader: true,
        responseHeader: true,
        requestBody: true,
        responseBody: true,
      ),
    );
  }

  /// 🔐 Headers with Bearer token
  Future<Options> getOptions({bool authRequired = true}) async {
    final token = await Prefs.getToken("token");
    

    return Options(
      headers: {
        if (authRequired && token != null && token.isNotEmpty)
          'Authorization': 'Bearer $token',
      },
    );
  }

    

  // ===========================
  // 🔑 LOGIN
  // ===========================
  Future<LoginModel> loginUser({
    required String username,
    required String password,
  }) async {
    try {
      final response = await dio.post(
        ApiDetails.getLogin,
        data: {
          "username": username,
          "password": password,
        },
        options: await getOptions(authRequired: false),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final loginModel = LoginModel.fromJson(response.data);

        return loginModel;
      } else {
        throw Exception("Login failed: ${response.statusMessage}");
      }
    } on DioException catch (e) {
      throw Exception(
        e.response?.data?['message'] ?? "Something went wrong",
      );
    } catch (e) {
      throw Exception("Unexpected error: $e");
    }
  }

// ===========================
// 👥 GET ALL SalesOrder
// ===========================
Future<SalesOrderNoModel> getAllSalesOrderNo() async {
  try {
    final response = await dio.get(
      ApiDetails.getsalesorderNo,
      options: await getOptions(authRequired: true),
    );

    if (response.statusCode == 200) {
      return SalesOrderNoModel.fromJson(response.data);
    } else {
      throw Exception("Failed to fetch assets");
    }
  } on DioException catch (e) {
    throw Exception(
      e.response?.data['message'] ?? 'Get assets error',
    );
  }
}

// ===========================
// 👥 AddTimesheet
// ===========================
Future<AddTimesheetModel> addTimesheet(Map<String, dynamic> body) async {
  try {
    final response = await dio.post(
      ApiDetails.addTimesheet,
      data: body,
      options: await getOptions(authRequired: true),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return AddTimesheetModel.fromJson(response.data);
    } else {
      throw Exception("Failed to add timesheet");
    }
  } on DioException catch (e) {
    final msg = (e.response?.data is Map<String, dynamic>)
        ? e.response?.data['message']
        : e.message;

    throw Exception(msg ?? 'Add timesheet error');
  }
}

// ===========================
// 👥 Updatetime
// ===========================
Future<UpdatetimeModel> updateTimesheet(Map<String, dynamic> body) async {
  try {
    final response = await dio.post(
      ApiDetails.updatetimesheet,
      data: body,
      options: await getOptions(authRequired: true),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return UpdatetimeModel.fromJson(response.data);
    } else {
      throw Exception("Failed to Update timesheet");
    }
  } on DioException catch (e) {
    final msg = (e.response?.data is Map<String, dynamic>)
        ? e.response?.data['message']
        : e.message;

    throw Exception(msg ?? 'Update timesheet error');
  }
}


// ===========================
// 👥 GET ALL Regularizationlist
// ===========================
Future<GetregularizationlistModel> getRegularizationlist(String employeeId) async {
  try {
    final response = await dio.post(
      ApiDetails.getregularizationlist,
      data: {
        "employeeId": employeeId,
      },
      options: await getOptions(authRequired: true),
    );

    if (response.statusCode == 200) {
      return GetregularizationlistModel.fromJson(response.data);
    } else {
      throw Exception("Failed to fetch data");
    }
  } on DioException catch (e) {
    throw Exception(
      e.response?.data['message'] ?? 'Get regularization error',
    );
  }
}

// ===========================
// 👥 Add Regularization
// ===========================
Future<AddRegularizationModel> addRegularization(Map<String, dynamic> body) async {
  try {
    final response = await dio.post(
      ApiDetails.addregularization,
      data: body,
      options: await getOptions(authRequired: true),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return AddRegularizationModel.fromJson(response.data);
    } else {
      throw Exception("Failed to add Regularization");
    }
  } on DioException catch (e) {
    final msg = (e.response?.data is Map<String, dynamic>)
        ? e.response?.data['message']
        : e.message;

    throw Exception(msg ?? 'Add Regularization error');
  }
}



// ===========================
// 👥 GET ALL Getstatus
// ===========================

Future<GetstatusModel> getStatus() async {
  try {
    final employeeId =
        (await Prefs.getInternalID("InternalID"))?.toString() ?? "";

    final response = await dio.post(
      ApiDetails.getstatus,
      data: {
        "employeeId": employeeId,
      },
      options: await getOptions(authRequired: true),
    );

    if (response.statusCode == 200) {
      final model = GetstatusModel.fromJson(response.data);

      // 🔥 AUTO LOGOUT CHECK (IMPORTANT)
      if (model.status == "N") {
        throw Exception("LOGOUT");
      }

      return model;
    } else {
      throw Exception("Failed to fetch data");
    }
  } on DioException catch (e) {
    throw Exception(
      e.response?.data['message'] ?? 'Get Status error',
    );
  }
}
// ===========================
// 👥 GET ALL GetmMonthlyattendance
// ===========================
  Future<GetMonthlyAttendanceModel> getMonthlyattendance(DateTime month) async {
    try {
      final employeeId =
          (await Prefs.getInternalID("InternalID"))?.toString() ?? "";

      String monthYear =
          "${month.month.toString().padLeft(2, '0')}/${month.year}";

      final response = await dio.post(
        ApiDetails.getmonthlyattendance,
        data: {
          "employeeId": employeeId,
          "monthYear": monthYear,
        },
        options: await getOptions(authRequired: true),
      );

      if (response.statusCode == 200) {
        return GetMonthlyAttendanceModel.fromJson(response.data);
      } else {
        throw Exception("Failed to fetch data");
      }
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? 'Get Monthlyattendance error',
      );
    }
  }

  // ===========================
// 👥 GET single regularizationlist
// ===========================
Future<GetsingleregularizationlistModel> getSingleregularizationlist(String timesheetId) async {
  try {
    final response = await dio.post(
      ApiDetails.singleregularizationlist,
      data: {
        "timesheetId": timesheetId, 
      },
      options: await getOptions(authRequired: true),
    );

    if (response.statusCode == 200) {
      return GetsingleregularizationlistModel.fromJson(response.data);
    } else {
      throw Exception("Failed to fetch data");
    }
  } on DioException catch (e) {
    throw Exception(
      e.response?.data['message'] ?? 'Get Single regularization error',
    );
  }
}

}
