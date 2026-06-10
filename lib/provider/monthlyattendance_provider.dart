

import 'package:flutter/material.dart';
import '../data/model/getmonthlyattendance/getmonthlyattendancemodel.dart';
import '../data/services/fm_apiservice.dart';

class MonthlyAttendanceProvider extends ChangeNotifier {
  final FMapiservice apiService = FMapiservice();

  bool isLoading = false;
  String? errorMessage;

  GetMonthlyAttendanceModel? attendanceModel;

  DateTime selectedMonth = DateTime.now();

  // ================= STATUS HANDLING =================
  void _setLoading(bool value) {
    isLoading = value;
    notifyListeners();
  }

  void _setError(String? error) {
    errorMessage = error;
    notifyListeners();
  }

  // ================= FETCH DATA =================
 

  Future<void> fetchMonthlyAttendance(DateTime month) async {
  try {
    _setLoading(true);
    _setError(null);

    selectedMonth = month;

    final response = await apiService.getMonthlyattendance(month);

    // ❗ IMPORTANT: handle "No Data" case properly
    if (response.status == false || response.data.records.isEmpty) {
      attendanceModel = null; // 🔥 CLEAR OLD DATA
    } else {
      attendanceModel = response;
    }

    _setLoading(false);
    notifyListeners();
  } catch (e) {
    attendanceModel = null; // 🔥 CLEAR ON ERROR ALSO
    _setLoading(false);
    _setError(e.toString());
  }
}

  // ================= CHANGE MONTH =================
  Future<void> changeMonth(DateTime month) async {
    await fetchMonthlyAttendance(month);
  }

  // ================= REFRESH (IMPORTANT FOR YOUR ISSUE) =================
  Future<void> refresh() async {
    await fetchMonthlyAttendance(selectedMonth);
  }

  // ================= DELETE / UPDATE SUPPORT (IMPORTANT FIX) =================
  Future<void> removeLocalRecord(String date) async {
    final records = attendanceModel?.data.records;

    if (records == null) return;

    records.removeWhere((e) => e.attendanceDate == date);

    notifyListeners();
  }

  // ================= CLEAN UI DATA =================
  

List<Map<String, dynamic>> get monthlyData {
  final records = attendanceModel?.data?.records;

  if (records == null || records.isEmpty) {
    return []; // 🔥 IMPORTANT: return empty list
  }

  return records.map((item) {
    return {
      "date": _parseDate(item.attendanceDate),
      "status": _normalizeStatus(item.attendanceStatus),
      "clockIn": item.timeIn ?? "-",
      "clockOut": item.timeOut ?? "-",
      "workedHours": item.hoursWorked ?? "-",
      "otHours": item.otHours ?? "-",
    };
  }).toList();
}
  // ================= DATE PARSER =================
  DateTime _parseDate(String? date) {
    if (date == null || date.isEmpty) return DateTime(2000);

    try {
      final parts = date.split('/');

      if (parts.length != 3) return DateTime(2000);

      return DateTime(
        int.parse(parts[2]),
        int.parse(parts[1]),
        int.parse(parts[0]),
      );
    } catch (_) {
      return DateTime(2000);
    }
  }

  // ================= STATUS NORMALIZER =================
  String _normalizeStatus(String? status) {
    if (status == null || status.isEmpty) return "Not Scheduled";

    switch (status.trim().toLowerCase()) {
      case "present":
        return "Present";
      case "absent":
        return "Absent";
      case "late":
        return "Late";
      case "leave":
        return "Leave";
      default:
        return "Not Scheduled";
    }
  }
}