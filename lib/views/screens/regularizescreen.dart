


import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/constant/app_color.dart';
import '../../provider/addregularization_provider.dart';

import '../../widgets/custom_textfield.dart';


class Regularizescreen extends StatefulWidget {
  final String date;
  final String checkIn;
  final String checkOut;
  final String internalId;
  final String employee;
  final String hoursWorked;
  final String salesOrderId;
  final String  shiftMaster;

  const Regularizescreen({
    super.key,
    required this.date,
    required this.checkIn,
    required this.checkOut,
    required this.internalId,
    required this.employee,
    required this.hoursWorked,
    required this.salesOrderId,
    required this.shiftMaster,
  });

  @override
  State<Regularizescreen> createState() => _RegularizescreenState();
}

class _RegularizescreenState extends State<Regularizescreen> {
  final TextEditingController noteController = TextEditingController();
  late DateTime apiDate;
  late TimeOfDay checkInTime;
  late TimeOfDay checkOutTime;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    apiDate = _parseDate(widget.date);
    checkInTime = _stringToTimeOfDay(widget.checkIn);
    checkOutTime = _stringToTimeOfDay(widget.checkOut);
  }

  DateTime _parseDate(String date) {
    try {
      final cleanedDate = date.trim();
      if (cleanedDate.contains("-")) {
        try {
          return DateFormat("dd-MM-yyyy").parse(cleanedDate);
        } catch (_) {
          return DateFormat("yyyy-MM-dd").parse(cleanedDate);
        }
      } else if (cleanedDate.contains("/")) {
        return DateFormat("dd/MM/yyyy").parse(cleanedDate);
      }
      return DateTime.now();
    } catch (_) {
      return DateTime.now();
    }
  }

  TimeOfDay _stringToTimeOfDay(String time) {
    if (time.isEmpty || time == "-" || time.toLowerCase() == "null") {
      return const TimeOfDay(hour: 0, minute: 0);
    }
    try {
      final cleaned = time.trim();
      if (cleaned.contains(":")) {
        final parts = cleaned.split(RegExp(r'[:\s]'));
        int hour = int.parse(parts[0]);
        int minute = int.parse(parts[1]);

        if (parts.length > 2) {
          String period = parts[2].toUpperCase();
          if (period == "PM" && hour != 12) hour += 12;
          if (period == "AM" && hour == 12) hour = 0;
        }

        return TimeOfDay(hour: hour, minute: minute);
      }

      int hour = int.tryParse(cleaned) ?? 0;
      return TimeOfDay(hour: hour, minute: 0);
    } catch (_) {
      return const TimeOfDay(hour: 0, minute: 0);
    }
  }

  String formatTimeOfDay24(TimeOfDay time) {
    return "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}";
  }

  String formatTimeOfDay12(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? "AM" : "PM";
    return "$hour:$minute $period";
  }

  Future<void> _pickCheckInTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: checkInTime,
    );
    if (picked != null) setState(() => checkInTime = picked);
  }

  Future<void> _pickCheckOutTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: checkOutTime,
    );
    if (picked != null) setState(() => checkOutTime = picked);
  }

  double convertToHours(String time) {
  try {
    if (time.isEmpty || time == "-" || time.toLowerCase() == "null") {
      return 0.0;
    }

    // ✅ If already a number (like "1.5")
    final direct = double.tryParse(time);
    if (direct != null) return direct;

    // ✅ Handle HH:mm format
    final parts = time.split(":");

    int hours = int.tryParse(parts[0]) ?? 0;
    int minutes = int.tryParse(parts[1]) ?? 0;

    return hours + (minutes / 60);
  } catch (e) {
    return 0.0;
  }
}

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AddRegularizationProvider>(context);

    return Scaffold(

      appBar: AppBar(
          backgroundColor: Colors.white, 
        surfaceTintColor: Colors.transparent,
        title: const Text("Regularize")),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.primarylight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    "${DateFormat("dd-MM-yyyy").format(apiDate)}, ${DateFormat('EEEE').format(apiDate)}",
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: _timePickerColumn(
                        "Check In",
                        checkInTime,
                        _pickCheckInTime,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _timePickerColumn(
                        "Check Out",
                        checkOutTime,
                        _pickCheckOutTime,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                CustomRoundedTextField(
                  width: double.infinity,
                  keyboardType: TextInputType.text,
                  labelText: 'Note',
                  controller: noteController,
                  maxLines: 5,
                  verticalMargin: 16,
                ),

                const SizedBox(height: 24),

                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 50,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.red,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () => Get.back(),
                          child: const Text("Cancel"),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: SizedBox(
                        height: 50,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),

                          // ✅ REQUEST BUTTON WITH PROVIDER
                          onPressed:  () async {
                                  final timeIn =
                                      formatTimeOfDay24(checkInTime);
                                  final timeOut =
                                      formatTimeOfDay24(checkOutTime);

                                  final postData = {
                                    "timesheetRef": widget.internalId,
                                    "attendanceDate":
                                        DateFormat("dd/MM/yyyy")
                                            .format(apiDate),
                                    "employee": widget.employee,
                                    "salesOrderId": widget.salesOrderId,
                                    "timeIn": timeIn,
                                    "timeOut": timeOut,
                                    "hoursWorked": convertToHours(widget.hoursWorked),
                                    "note": noteController.text.trim(),
                                    "shiftMaster": widget.shiftMaster.toString() ,
                                  };

                                  final success = await provider
                                      .addRegularization(postData);

                                  if (success) {
                                    Get.snackbar(
                                      "Success",
                                     provider.addregularizationmodel?.message ?? "Request Sent",
                                    
                                      backgroundColor: Colors.green,
                                      colorText: Colors.white,
                                       snackPosition: SnackPosition.BOTTOM
                                    );
                                     Navigator.pop(context, true); // send result
                                  } else {
                                    Get.snackbar(
                                      "Error",
                                      provider.errorMessage ?? "Failed",
                                      backgroundColor: Colors.red,
                                      colorText: Colors.white,
                                       snackPosition: SnackPosition.BOTTOM
                                    );
                                  }
                                },

                          child:const Text(
                                  "Request",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // optional overlay loader (your UI unchanged)
          if (provider.isLoading)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }

  Widget _timePickerColumn(
      String label, TimeOfDay time, VoidCallback onTap) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(label, style: const TextStyle(fontSize: 16)),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primarylight,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                formatTimeOfDay12(time),
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ),
        ),
      ],
    );
  }
}