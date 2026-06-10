import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../data/model/timesheetmodel/addtimesheet_model.dart';
import '../data/model/timesheetmodel/updatetimemodel.dart';
import '../data/services/fm_apiservice.dart';
import '../core/utils/prefs.dart';

class TimesheetProvider extends ChangeNotifier {
  final FMapiservice apiService = FMapiservice();

  bool isLoading = false;
  String? error;

  AddTimesheetModel? addResponse;
  UpdatetimeModel? updateResponse;

  // =========================
  // CHECK-IN (ADD TIMESHEET)
  // =========================
  Future<void> addTimesheet({
    required String employee,
    required String salesOrder,
    required String tranId,
    required String shiftMaster,
    required String fromGpsAddress,
    required String remarks,

  }) async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final attendanceDate =
            DateFormat('dd/MM/yyyy').format(DateTime.now());

      final now = DateTime.now();
     final timeIn = DateFormat('hh:mm a').format(DateTime.now()).toLowerCase();

      final body = {
        "attendanceDate": attendanceDate,
        "employee": employee,
        "salesOrder": salesOrder,
        "tranId": tranId,
        "timeIn": timeIn,
        "shiftMaster": shiftMaster,
        "fromGpsAddress": fromGpsAddress,
        "remarks": remarks,
      };

      addResponse = await apiService.addTimesheet(body);

      // SAVE TO PREFS (IMPORTANT)
      if (addResponse != null && addResponse!.internalId != null) {
        await Prefs.settimesheet_internal_id(
          "timesheet_internal_id",
          addResponse!.internalId.toString(),
        );

        await Prefs.settimesheet_time_in(
          "timesheet_time_in",
          timeIn,
        );

        await Prefs.setselected_sales_order_id(
          "selected_sales_order_id",
          salesOrder,
        );
      }
    } catch (e) {
      error = e.toString();
    }

    isLoading = false;
    notifyListeners();
  }
Future<void> updateTimesheet({
 String? internalId,
    String? transId,
  required String timeIn,
  String? timeOut,
  String? remarks,
  String? toGpsAddress,
}) async {
  isLoading = true;
  error = null;
  notifyListeners();

  try {
    final currentDate =
        DateFormat('dd/MM/yyyy').format(DateTime.now());

    final finalTimeOut =
        DateFormat('hh:mm a').format(DateTime.now()).toLowerCase();

    final body = {
      "currentDate": currentDate,
      "internalId": internalId ?? "",
        "transId": transId ?? "",
      "timeIn": timeIn,
      "timeOut": finalTimeOut,
      "remarks": remarks ?? "",
      "toGpsAddress": toGpsAddress ?? "",
    };

    updateResponse = await apiService.updateTimesheet(body);
  } catch (e) {
    error = e.toString();
  }

  isLoading = false;
  notifyListeners();
}
}
