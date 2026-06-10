



import 'dart:async';
import 'package:captainemirates/views/screens/attendance/checkinpage.dart';
import 'package:captainemirates/views/screens/attendance/checkoutscreen.dart';
import 'package:captainemirates/views/screens/employeereportspage.dart';
import 'package:captainemirates/views/screens/profilescreen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:new_version_plus/model/version_status.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/constant/app_assets.dart';
import '../../core/constant/app_color.dart';
import '../../core/constant/app_constants.dart';
import '../../core/utils/prefs.dart';
import '../../data/model/getmonthlyattendance/getmonthlyattendancemodel.dart';
import '../../main.dart';
import '../../provider/getstatus_provider.dart';
import '../../provider/login_provider.dart';
import '../../provider/monthlyattendance_provider.dart';
import '../../widgets/cleanderwidget.dart';
import 'attendance/attendance_helper.dart';
import 'package:new_version_plus/new_version_plus.dart';
class Homescreen extends StatefulWidget {
  const Homescreen({super.key});

  @override
  State<Homescreen> createState() => _HomescreenState();
}

class _HomescreenState extends State<Homescreen> with RouteAware{
  String employeeName = "";
  String supervisorId = "";
  String supervisor = "";

  DateTime _focusedDay = DateTime.now();
  DateTime? selectedDay;
  Map<String, dynamic>? selectedData;

  bool isLoading = false;

  String lastCheckedInTime = "";
  String? lastSalesOrderId;
  String lastCheckoutTime = "";

  CalendarFormat _calendarFormat = CalendarFormat.month;

  late String currentTime;
  late Timer timer;

  Timer? statusTimer;
bool isLoggingOut = false;


@override
void initState() {
  super.initState();

  WidgetsBinding.instance.addPostFrameCallback((_) {
    context.read<GetStatusProvider>().fetchStatus(context);

    // ✅ ADD THIS
    context.read<MonthlyAttendanceProvider>()
        .fetchMonthlyAttendance(DateTime.now());
  });

  selectedDay = DateTime.now();
  currentTime = DateFormat('hh:mm:ss a').format(DateTime.now());

  timer = Timer.periodic(const Duration(seconds: 1), (timer) {
    setState(() {
      currentTime = DateFormat('hh:mm:ss a').format(DateTime.now());
    });
  });

  loadName();
}

@override
void didChangeDependencies() {
  super.didChangeDependencies();

  routeObserver.subscribe(this, ModalRoute.of(context)! as PageRoute);
}

@override
void dispose() {
   timer?.cancel();
  statusTimer?.cancel();
  routeObserver.unsubscribe(this);
  super.dispose();
}
void loadApis() {
  WidgetsBinding.instance.addPostFrameCallback((_) {
    if (!mounted) return;

    context.read<GetStatusProvider>().fetchStatus(context);
    context.read<MonthlyAttendanceProvider>()
        .fetchMonthlyAttendance(DateTime.now());
         startAutoLogout(); 
  });
}

@override
void didPopNext() {
  loadApis(); 
}

@override
void didPush() {
  loadApis(); 
}

  Future<void> loadName() async {
    employeeName = await Prefs.getName("Name") ?? "";
    setState(() {});
  }


  
void startAutoLogout() {
  statusTimer?.cancel();

  statusTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
    context.read<GetStatusProvider>().fetchStatus(context);
  });
}

 void showBottomTab(
  BuildContext context,
  DateTime selectedDay,
  List<Map<String, dynamic>> monthlyData,
) {
  final data = getAttendanceForDate(monthlyData, selectedDay);

    // ✅ HANDLE NULL (MOST IMPORTANT)
    if (data == null) {
      showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (context) {
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("Attendance Result", style: TextStyle(fontSize: 20)),
                SizedBox(height: 20),
                Text(
                  "Not Scheduled",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          );
        },
      );
      return;
    }

    Widget row(String title, dynamic value) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: const TextStyle(color: Colors.grey)),
            Text(value?.toString() ?? "-"),
          ],
        ),
      );
    }

    // ✅ NORMAL FLOW
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16.0),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Center(
                  child: Text(
                    "Attendance Result",
                    style: TextStyle(fontSize: 20),
                  ),
                ),
                const SizedBox(height: 20),

                /// ✅ STATUS (USE SAFE FUNCTION)
                Row(
                  children: [
                    Text(
                      getDisplayStatus(data),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                row("Clock In Time", data['clockIn']),
                row("Clock Out Time", data['clockOut']),
                row("Worked Hours", data['workedHours']),
                row("Overtime Duration", data['otHours']),
              ],
            ),
          ),
        );
      },
    );
  }

 int getPresentDays(List<Map<String, dynamic>> data) {
  return data.where((d) => d['status'] == 'Present').length;
}

int getAbsentDays(List<Map<String, dynamic>> data) {
  return data.where((d) => d['status'] == 'Absent').length;
}

int getLateDays(List<Map<String, dynamic>> data) {
  return data.where((d) => d['status'] == 'Late').length;
}

int getLeaveDays(List<Map<String, dynamic>> data) {
  return data.where((d) => d['status'] == 'Leave').length;
}

  String getDisplayStatus(Map<String, dynamic>? data) {
    if (data == null) return "Not Scheduled";

    final status = data['status']?.toString() ?? "";

    switch (status) {
      case "":
      case "Future":
        return "Not Scheduled";
      case "Present":
        return "Present";
      case "Absent":
        return "Absent";
      case "Late":
        return "Late";
      case "Leave":
        return "Leave";
      default:
        return status; // in case of other unexpected values
    }
  }

  Color getStatusTextColor(String status) {
    switch (status) {
      case 'Absent':
        return AppColors.red;
      case 'Present':
        return AppColors.green;
      case 'Late':
        return AppColors.yellow;
      case 'Leave':
        return AppColors.blue;
      case 'Future':
        return Colors.grey.shade800;
      case 'Weekend':
        return Colors.grey;
      case 'Not Scheduled':
        return Colors.grey.shade200;
      default:
        return Colors.black87;
    }
  }

  Future<void> refreshAll() async {}


//update

 Future<void> checkForUpdates(BuildContext context) async {
    final newVersion = NewVersionPlus(
      androidId: AppConstants.androidAppPackageName,
      iOSId: AppConstants.iOSAppID,
      androidHtmlReleaseNotes: true,
    );

    final status = await newVersion.getVersionStatus();
    if (status?.canUpdate == true) {
      showForceUpdateDialog(status!, context);
    }
  }

  void showForceUpdateDialog(VersionStatus status, BuildContext context) {
    showDialog(
      barrierDismissible: false, // cannot dismiss by tapping outside
      context: context,
      builder: (BuildContext context) {
        return WillPopScope(
          onWillPop: () async => false, // disable back button
          child: AlertDialog(
            title: const Text('Update Required'),
            content: Text(
              'A new version of the app is available!\n\n'
              'Current Version: ${status.localVersion}\n'
              'Latest Version: ${status.storeVersion}\n\n'
              'Please update to continue using the app.',
            ),
            actions: [
              TextButton(
                onPressed: () async {
                  if (status.appStoreLink.isNotEmpty) {
                    await launchUrl(Uri.parse(status.appStoreLink),
                        mode: LaunchMode.externalApplication);
                  } else {
                    print('App Store link not available');
                  }
                },
                child: const Text('Update Now'),
              ),
            ],
          ),
        );
      },
    );
  }

 

  @override
  Widget build(BuildContext context) {
   final statusProvider = context.watch<GetStatusProvider>();
    final isCheckedIn = statusProvider.statusResponse?.status == true;
    final attendanceProvider = context.watch<MonthlyAttendanceProvider>();
final monthlyData = attendanceProvider.monthlyData;
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 50),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
              child:
             
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            GestureDetector(
                              onTap: () {
                            
                                Get.to(() => Profilescreen());
                              },
                              child: CircleAvatar(
                                radius: 25,
                                backgroundColor: AppColors.primary,
                                child: Icon(Icons.person, color: Colors.white),
                              ),
                            ),

                            const SizedBox(width: 12),

                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Emirates Captain',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: AppColors.litgrey,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),

                                  Text(
                                    employeeName,
                                    maxLines: 2,
                                    overflow: TextOverflow.visible,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(width: 8),

                      GestureDetector(
                        onTap: () async {
                          context.read<LoginProvider>().logout(context);
                        },
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Color(0xFF359CC1), Color(0xFF005675)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                          ),
                          child: const Icon(
                            Icons.logout_rounded,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
            ),
            SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: GestureDetector(
             onTap: () async {
                  if (!isCheckedIn) {
                    final result = await Get.to(() => Checkinscreen());
                    if (result != null &&
                        result["status"] == "checkin_done") {
                      context.read<GetStatusProvider>().fetchStatus(context);
                    }
                  } else {
                    final result = await Get.to(() => Checkoutscreen());
                    if (result != null &&
                        result["status"] == "checkout_done") {
                      context.read<GetStatusProvider>().fetchStatus(context);
                    }
                  }
                },
                      child: Container(
                        height: 110,
                        decoration: BoxDecoration(
                          color: const Color(0x0D3085FE),
                          border: Border.all(
                            color: isCheckedIn   ? Colors.red : AppColors.blue,
                          ),
                          borderRadius: const BorderRadius.all(
                            Radius.circular(14),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isCheckedIn   ? "Check \nOut" : "Check \nIn",
                                style: TextStyle(
                                  color: isCheckedIn  
                                      ? AppColors.red
                                      : AppColors.darker,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 12),
                              SvgPicture.asset(
                                isCheckedIn   ? Appassets.out : Appassets.check,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(
                    width: 10,
                  ), // spacing between the two containers
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Get.to(Employeereportspage());
                      },
                      child: Container(
                        height: 110,

                        decoration: BoxDecoration(
                          color: const Color(0x0D30BEB6),
                          border: Border.all(color: AppColors.green),
                          borderRadius: const BorderRadius.all(
                            Radius.circular(14),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Employee\nReports",
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(height: 12),
                              SvgPicture.asset(Appassets.report),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 24),
            Container(
              height: 60,
              width: double.infinity,
              decoration: BoxDecoration(color: Colors.white),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Icon(
                      Icons.access_time_filled_rounded,
                      color: AppColors.blue,
                    ),
                    Text(DateFormat('dd/MM/yyyy').format(DateTime.now())),
                    // Text(DateFormat('hh:mm:ss a').format(DateTime.now())),
                    Text(currentTime),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.darker),
                        borderRadius: BorderRadius.circular(
                          12,
                        ), // 👈 set radius here
                      ),
                      child: Text(
                        'My Schedule',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                   
                  ],
                ),

                CalendarWidget(
                  focusedDay: _focusedDay,
                  selectedDay: selectedDay,
                  monthlyData: monthlyData,
                  onDaySelected: (day, focus) {
                    setState(() {
                      selectedDay = day;
                      _focusedDay = focus;
                      selectedData = getAttendanceForDate(monthlyData, day);
                    });
                  },
                  onPageChanged: (focus) async {
                    _focusedDay = focus;
                    // await loadData();
                  },
                ),
              ],
            ),

            SizedBox(height: 30),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      // Present
                      Expanded(
                        child: Container(
                          height: 85,
                          decoration: BoxDecoration(
                            color: Color(0xFF009227).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Column(
                            children: [
                              Container(
                                height: 10,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: AppColors.green,
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(6),
                                    topRight: Radius.circular(6),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          width: 4,
                                          height: 4,
                                          decoration: BoxDecoration(
                                            color: Colors.black,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                        SizedBox(width: 4),
                                        Text(
                                          'Present',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 16),
                                    Text(
                                      getPresentDays(monthlyData).toString(),
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(width: 10),
                      // Absent
                      Expanded(
                        child: Container(
                          height: 85,
                          decoration: BoxDecoration(
                            color: Color(0xFFCF0027).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Column(
                            children: [
                              Container(
                                height: 10,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: AppColors.red,
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(6),
                                    topRight: Radius.circular(6),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          width: 4,
                                          height: 4,
                                          decoration: BoxDecoration(
                                            color: AppColors.red,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                        SizedBox(width: 4),
                                        Text(
                                          'Absent',
                                          style: TextStyle(
                                            color: AppColors.red,
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 16),
                                    Text(
                                      getAbsentDays(monthlyData).toString(),
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(width: 10),
                      // Late
                      Expanded(
                        child: Container(
                          height: 85,
                          decoration: BoxDecoration(
                            color: Color(0xFFE7AC00).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Column(
                            children: [
                              Container(
                                height: 10,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: AppColors.yellow,
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(6),
                                    topRight: Radius.circular(6),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          width: 4,
                                          height: 4,
                                          decoration: BoxDecoration(
                                            color: AppColors.yellow,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                        SizedBox(width: 4),
                                        Text(
                                          'Late',
                                          style: TextStyle(
                                            color: AppColors.yellow,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 16),
                                    Text(
                                      getLateDays(monthlyData).toString(),
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(width: 10),
                      // Leave
                      Expanded(
                        child: Container(
                          height: 85,
                          decoration: BoxDecoration(
                            color: Color(0xFF359CC1).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Column(
                            children: [
                              Container(
                                height: 10,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: AppColors.bluelit,
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(6),
                                    topRight: Radius.circular(6),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          width: 4,
                                          height: 4,
                                          decoration: BoxDecoration(
                                            color: AppColors.bluelit,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                        SizedBox(width: 4),
                                        Text(
                                          'Leave',
                                          style: TextStyle(
                                            color: AppColors.bluelit,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 16),
                                    Text(
                                      getLeaveDays(monthlyData).toString(),
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
             SizedBox(height: 20),

            // GestureDetector(
            //   onTap: () {
            //     if (selectedData != null &&
            //         selectedData!['status'] != null &&
            //         selectedData!['status'] != "Future" &&
            //         selectedData!['status'] != "Weekend") {
            //       showBottomTab(context, selectedData!['date']);
            //     } else {
            //       ScaffoldMessenger.of(context).showSnackBar(
            //         const SnackBar(
            //           content: Text("Cannot open details for this day"),
            //         ),
            //       );
            //     }
            //   },
            //   child: Container(
            //     height: 50,
            //     width: double.infinity,
            //     color: Colors.white,
            //     padding: const EdgeInsets.symmetric(horizontal: 16),
            //     child: Row(
            //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //       children: [
            //         Row(
            //           children: [
            //             Container(
            //               width: 4,
            //               height: 4,
            //               decoration: const BoxDecoration(
            //                 color: Colors.black,
            //                 shape: BoxShape.circle,
            //               ),
            //             ),
            //             const SizedBox(width: 8),
            //             Text(
            //               getDisplayStatus(selectedData),
            //               style: TextStyle(
            //                 fontWeight: FontWeight.bold,
            //                 fontSize: 16,
            //                 color: getStatusTextColor(
            //                   getDisplayStatus(selectedData),
            //                 ),
            //               ),
            //             ),
            //           ],
            //         ),
            //         const Icon(CupertinoIcons.chevron_up, size: 20),
            //       ],
            //     ),
            //   ),
            // ),
            // SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}


