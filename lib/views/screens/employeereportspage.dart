


import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/utils/prefs.dart';
import '../../data/model/regularization/getregularizationlistmodel.dart';
import '../../data/services/comFuncService.dart';
import '../../provider/regularizationlist_Provider.dart';
import '../../provider/single_regularization_provider.dart';
import 'regularizescreen.dart';

class Employeereportspage extends StatefulWidget {
  final String? timesheetId;

  const Employeereportspage({super.key, this.timesheetId});

  @override
  State<Employeereportspage> createState() => _EmployeereportspageState();
}

class _EmployeereportspageState extends State<Employeereportspage> {
  DateTime? fromDate;
  DateTime? toDate;
  String searchQuery = "";

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    final employeeId = await Prefs.getInternalID("InternalID") ?? "";

    Provider.of<RegularizationProvider>(
      context,
      listen: false,
    ).getRegularizationList(employeeId);
  }

  String formatFromDate(DateTime? date) =>
      date == null ? "From Date" : DateFormat("dd MMM yyyy").format(date);

  String formatToDate(DateTime? date) =>
      date == null ? "To Date" : DateFormat("dd MMM yyyy").format(date);

  Future<void> _pickFromDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: fromDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        fromDate = picked;
        toDate = null;
      });
    }
  }

  Future<void> _pickToDate() async {
    if (fromDate == null) {
      showInSnackBar(context, "Select From Date first");
      return;
    }

    final picked = await showDatePicker(
      context: context,
      initialDate: toDate ?? fromDate!,
      firstDate: fromDate!,
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => toDate = picked);
    }
  }


  // 🔥 FIXED DATE PARSER (handles dd-MM-yyyy / yyyy-MM-dd)
  DateTime? parseDate(String? date) {
    if (date == null || date.isEmpty) return null;

    try {
      return DateTime.parse(date); // yyyy-MM-dd
    } catch (_) {
      try {
        return DateFormat("dd-MM-yyyy").parse(date);
      } catch (_) {
        try {
          return DateFormat("dd/MM/yyyy").parse(date);
        } catch (_) {
          return null;
        }
      }
    }
  }


String formatWorkingTimeSmart(dynamic hoursWorked) {
  if (hoursWorked == null) return "0 mins";

  String timeStr = hoursWorked.toString();

  // Case 1: already in HH:mm format
  if (timeStr.contains(":")) {
    final parts = timeStr.split(":");

    final hours = int.tryParse(parts[0]) ?? 0;
    final minutes = int.tryParse(parts[1]) ?? 0;

    final totalMinutes = (hours * 60) + minutes;

    if (totalMinutes < 60) {
      return "$totalMinutes mins";
    }

    final hrs = totalMinutes ~/ 60;
    final mins = totalMinutes % 60;

    return "$hrs:${mins.toString().padLeft(2, '0')} hrs";
  }

  // Case 2: decimal hours (e.g. 1.5)
  final h = double.tryParse(timeStr) ?? 0;
  final minutes = (h * 60).round();

  if (minutes < 60) return "$minutes mins";

  final hrs = minutes ~/ 60;
  final mins = minutes % 60;

  return "$hrs:${mins.toString().padLeft(2, '0')} hrs";
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        
         
    backgroundColor: Colors.white, // or your fixed color

    surfaceTintColor: Colors.transparent,

    
        title: const Text("Employee Reports"), centerTitle: true),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: _dateBox(formatFromDate(fromDate), _pickFromDate),
                ),
                const SizedBox(width: 10),
                Expanded(child: _dateBox(formatToDate(toDate), _pickToDate)),
                 IconButton(
      icon: const Icon(Icons.clear, color: Colors.red),
      onPressed: () {
        setState(() {
          fromDate = null;
          toDate = null;
        });
      },
    )
              ],
            ),
          ),

          
  Expanded(
            child: Consumer<RegularizationProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (provider.errorMessage != null) {
                  return Center(child: Text(provider.errorMessage!));
                }

                if (provider.regularizationList.isEmpty) {
                  return const Center(child: Text("No Records"));
                }

                // 🔥 FILTER LOGIC
                final filteredList =
                    provider.regularizationList.where((e) {
                  final recordDate = parseDate(e.attendanceDate);
                  if (recordDate == null) return false;

                  if (fromDate != null &&
                      recordDate.isBefore(
                        DateTime(fromDate!.year, fromDate!.month, fromDate!.day),
                      )) {
                    return false;
                  }

                  if (toDate != null &&
                      recordDate.isAfter(
                        DateTime(toDate!.year, toDate!.month, toDate!.day, 23, 59, 59),
                      )) {
                    return false;
                  }

                  return true;
                }).toList();

                if (filteredList.isEmpty) {
                  return const Center(
                      child: Text("No Records for selected date"));
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredList.length,
                  itemBuilder: (_, i) => buildCard(filteredList[i]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _dateBox(String text, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.blue.shade50,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(child: Text(text)),
      ),
    );
  }

  Widget buildCard(RegularizationList e) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(colors: [Colors.white, Colors.blue.shade50]),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 10),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
         //     const Icon(Icons.timer, color: Colors.blue, size: 18),
           //   SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Total Working Time"),
                  Text(
                    formatWorkingTimeSmart(e.hoursWorked),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              Row(
                children: [
                  Text(
                    e.salesOrderId.toString(),
                    style: const TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  e.reqstatus == "C"
                      ? IconButton(
                          icon: const Icon(
                            Icons.access_time,
                            size: 28,
                            color: Colors.black,
                          ),
                          onPressed: () async {
                            final provider =
                                Provider.of<SingleRegularizationProvider>(
                                  context,
                                  listen: false,
                                );
          
                            await provider.getSingleRegularizationList(
                              e.internalId.toString(),
                            );
          
                            if (!mounted) return;
          
                            if (provider.singleRegularizationList.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("⚠️ No details found!"),
                                ),
                              );
                              return;
                            }
          
                            final data =
                                provider.singleRegularizationList.first;
          
                            Get.dialog(
                              AlertDialog(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                title: const Text("Regularization Details"),
                                content: provider.isLoading
                                    ? const Center(
                                        child: CircularProgressIndicator(),
                                      )
                                    : Column(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "📅 Date: ${data.attendanceDate ?? '-'}",
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            "🕒 Time In: ${data.timeIn ?? '-'}",
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            "🕔 Time Out: ${data.timeOut ?? '-'}",
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            "⏱ Hours Worked: ${formatWorkingTimeSmart(data.hoursWorked)}",
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            "👤 Employee: ${data.employee ?? '-'}",
                                          ),
                                        ],
                                      ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Get.back(),
                                    child: const Text("Close"),
                                  ),
                                ],
                              ),
                            );
                          },
                        )
                      : PopupMenuButton<String>(
                          position: PopupMenuPosition.under,
                          icon: const Icon(
                            Icons.more_vert,
                            size: 28,
                            color: Colors.black,
                          ),
                          onSelected: (value) {
                            if (value == 'Regularize') {
                              if (e.timeOut == null ||
                                  e.timeOut.toString().isEmpty) {
                                // checkOut null ah irundha
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      "❌ Cannot regularize because check-out is missing.",
                                    ),
                                    duration: Duration(seconds: 2),
                                  ),
                                );
                                return; // stop navigation
                              }
          
                              // otherwise navigate to Regularize screen
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => Regularizescreen(
                                    date: e.attendanceDate.toString(),
                                    checkIn: e.timeIn.toString(),
                                    checkOut: e.timeOut.toString(),
                                    internalId: e.internalId.toString(),
                                    employee: e.employee.toString(),
                                    hoursWorked: e.hoursWorked.toString(),
                                    salesOrderId: e.salesOrderId.toString(),
                                    shiftMaster: e.shiftMaster.toString(),
                                  ),
                                ),
                              ).then((regularized) {
                                if (regularized == true) {
                                  setState(() {
                                    e.reqstatus = "C";
                                  });
                                }
                              });
                            }
                          },
                          itemBuilder: (context) => const [
                            PopupMenuItem(
                              value: 'Regularize',
                              child: Text("Regularize"),
                            ),
                          ],
                        ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 10),
          Divider(color: Colors.grey.shade300),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              col("Date", e.attendanceDate),
              col("In", e.timeIn),
              col("Out", e.timeOut),
              col("OT", formatWorkingTimeSmart(e.otHours)),
            ],
          ),
        ],
      ),
    );
  }

  Widget col(String title, String? value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(color: Colors.grey)),
        const SizedBox(height: 4),
        Text(value ?? "-", style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }
}


