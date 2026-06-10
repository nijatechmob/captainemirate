




import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart' hide LocationAccuracy;
import 'package:provider/provider.dart';

import '../../../core/constant/app_color.dart';
import '../../../core/utils/prefs.dart';
import '../../../data/model/salesordermomodel/salesorderno_model.dart';
import '../../../data/services/location_service.dart';
import '../../../provider/timesheet_provider.dart';
import '../../../provider/salesorder_provider.dart';
import '../../../widgets/checkinmap_page.dart';
import '../../../widgets/custom_dropdown.dart';
import '../../../widgets/custom_textfield.dart';

class Checkinscreen extends StatefulWidget {
  const Checkinscreen({super.key});

  @override
  State<Checkinscreen> createState() => _CheckinscreenState();
}

class _CheckinscreenState extends State<Checkinscreen> {
  final TextEditingController remark = TextEditingController();
  String? empType;
  double? lat;
  double? lng;
  bool isInsideFence = false;
  double currentDistance = 0;
  bool isLoading = true;

  final LocationService locationService = LocationService();
  StreamSubscription<LocationData>? positionStream;

  SalesOrderItem? selectedsalesorderno;

  Map<String, dynamic>? usershift;

  final GlobalKey<CheckInMapState> mapKey = GlobalKey();

  String? shiftId;

  List<Map<String, dynamic>> shiftlist = [
    {"label": "GENERAL SHIFT", "value": "2"},
    {"label": "NIGHT SHIFT", "value": "4"},
  ];

  @override
  void initState() {
    super.initState();
    loadEmpType();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<SalesOrderProvider>(
        context,
        listen: false,
      ).getAllSalesOrderNo();
    });

    initLocation();
  }

  Future<void> loadEmpType() async {
    final type = await Prefs.getEmpType("EmpType");
    setState(() {
      empType = type;
    });
  }

  Future<void> initLocation() async {
    final location = await locationService.getCurrentLocation();

    if (!mounted || location == null) return;

    setState(() {
      lat = location.latitude;
      lng = location.longitude;
      isLoading = false;
    });

    positionStream = locationService.startLiveTracking((newLatLng) {
      if (!mounted) return;

      if (newLatLng.latitude == 0.0 || newLatLng.longitude == 0.0) return;

      lat = newLatLng.latitude;
      lng = newLatLng.longitude;

      mapKey.currentState?.updateLocation(LatLng(lat!, lng!));
    });
  }

  Future<void> refreshLocation() async {
    setState(() => isLoading = true);

    final location = await locationService.getCurrentLocation();

    if (location == null) {
      setState(() => isLoading = false);
      return;
    }

    setState(() {
      lat = location.latitude;
      lng = location.longitude;
      isLoading = false;
    });

    mapKey.currentState?.updateLocation(location);
  }

  @override
  void dispose() {
    positionStream?.cancel();
    locationService.stopTracking();
    remark.dispose();
    super.dispose();
  }

  Future<void> submitCheckIn() async {
    // 1️⃣ Sales order
    if (selectedsalesorderno == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Select Sales Order")));
      return;
    }

 // 2️⃣ GEO-FENCE BLOCK

    if (isInsideFence == false) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return AlertDialog(
            title: const Text("Check-in Blocked"),
            content: const Text(
              "You are outside the geo-fence. Please move inside the allowed area.",
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text("OK"),
              ),
            ],
          );
        },
      );
      return;
    }
 

    // 3️⃣ Location
    if (lat == null || lng == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Location not found")));
      return;
    }

    // 4️⃣ Shift
    if (shiftId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Select Shift")));
      return;
    }

    final employeeId = await Prefs.getInternalID("InternalID");

    if (employeeId == null || employeeId.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Session expired")));
      return;
    }

    final gpsUrl =
        "https://maps.google.com/?q=${lat!.toStringAsFixed(6)},${lng!.toStringAsFixed(6)}";

    final timesheetProvider = Provider.of<TimesheetProvider>(
      context,
      listen: false,
    );

    await timesheetProvider.addTimesheet(
      employee: employeeId,
      salesOrder: selectedsalesorderno!.internalId.toString(),
        tranId: selectedsalesorderno!.tranId.toString(),
      shiftMaster: shiftId.toString(),
      fromGpsAddress: gpsUrl,
      remarks: remark.text,
    );

    if (timesheetProvider.error != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(timesheetProvider.error!)));
      return;
    }

    final response = timesheetProvider.addResponse;

    if (response != null) {
      await Prefs.setselected_sales_order_id(
        "selected_sales_order_id",
        selectedsalesorderno!.internalId.toString(),
      );

      await Prefs.setLoggedIn("isCheckedIn", true);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(response.message ?? "Check-in success")),
      );

      Get.back(
        result: {
          "status": "checkin_done",
          "salesOrder": selectedsalesorderno!.internalId.toString(),
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPage,
      appBar: AppBar(
        title: const Text("Check In"),
        backgroundColor: AppColors.bgPage,
        elevation: 0,
      ),
      body: Consumer<TimesheetProvider>(
        builder: (context, provider, child) {
          return Stack(
            children: [
              AbsorbPointer(
                absorbing: provider.isLoading,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      /// MAP
                      Container(
                        height: 300,
                        width: double.infinity,
                        child: (isLoading || lat == null || lng == null)
                            ? const Center(child: CircularProgressIndicator())
                            : ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: CheckInMap(
                                  key: mapKey,
                                  initialLocation: LatLng(lat!, lng!),
                                ),
                              ),
                      ),

                      const SizedBox(height: 20),

                      /// SALES ORDER
                      // Consumer<SalesOrderProvider>(
                      //   builder: (context, provider, child) {
                      //     if (provider.isLoading) {
                      //       return Container(
                      //         height: 55,
                      //         padding: const EdgeInsets.symmetric(
                      //           horizontal: 12,
                      //         ),
                      //         decoration: BoxDecoration(
                      //           border: Border.all(color: Colors.grey),
                      //           borderRadius: BorderRadius.circular(8),
                      //         ),
                      //         alignment: Alignment.centerLeft,
                      //         child: const Text(
                      //           "Please wait loading Sales Order...",
                      //           style: TextStyle(color: Colors.grey),
                      //         ),
                      //       );
                      //     }

                      //     // ⛔ STAFF: hide entire dropdown + message
                      //     if (empType == "staff") {
                      //       return const SizedBox.shrink();
                      //     }

                      //     // ❗ NON-STAFF: show empty state
                      //     if (provider.salesOrderList.isEmpty) {
                      //       return Container(
                      //         height: 55,
                      //         padding: const EdgeInsets.symmetric(
                      //           horizontal: 12,
                      //         ),
                      //         decoration: BoxDecoration(
                      //           border: Border.all(color: Colors.grey),
                      //           borderRadius: BorderRadius.circular(8),
                      //         ),
                      //         alignment: Alignment.centerLeft,
                      //         child: const Text(
                      //           "No Sales Order Found",
                      //           style: TextStyle(color: Colors.redAccent),
                      //         ),
                      //       );
                      //     }

                      //     return CustomDropdownWidget(
                      //       valArr: provider.salesOrderList,
                      //       labelText: "Sales Order",
                      //       selectedItem: selectedsalesorderno,

                      //       labelField: (item) =>  "Sales Order : ${item.tranId.toString()}",

                      //       onChanged: (value) async {
                      //         setState(() {
                      //           selectedsalesorderno = value;
                      //           isInsideFence = false;
                      //         });

                      //         try {
                      //           Position position =
                      //               await Geolocator.getCurrentPosition(
                      //                 desiredAccuracy:
                      //                     LocationAccuracy.bestForNavigation,
                      //               );

                      //           final centerLat = (value.latitude ?? 0)
                      //               .toDouble();
                      //           final centerLng = (value.longitude ?? 0)
                      //               .toDouble();

                      //           // 🔥 FIXED / API radius (optional)
                      //           final double radius = (value.radius ?? 200)
                      //               .toDouble();

                      //           // 📏 CALCULATE DISTANCE
                      //           double distance = Geolocator.distanceBetween(
                      //             position.latitude,
                      //             position.longitude,
                      //             centerLat,
                      //             centerLng,
                      //           );

                      //           setState(() {
                      //             currentDistance = distance;
                      //             isInsideFence = distance <= radius;
                      //           });

                      //           // 🔥 PRINT EVERYTHING
                      //           print("========== GEO FENCE DEBUG ==========");
                      //           print("User Lat: ${position.latitude}");
                      //           print("User Lng: ${position.longitude}");
                      //           print("Center Lat: $centerLat");
                      //           print("Center Lng: $centerLng");
                      //           print("Allowed Radius: $radius meters");
                      //           print("Current Distance: $distance meters");
                      //           print("Inside Fence: $isInsideFence");
                      //           print("=====================================");

                      //           ScaffoldMessenger.of(context).showSnackBar(
                      //             SnackBar(
                      //               content: Text(
                      //                 isInsideFence
                      //                     ? "Inside Fence ✅ ${distance.toStringAsFixed(2)} m"
                      //                     : "Outside Fence ❌ ${distance.toStringAsFixed(2)} m",
                      //               ),
                      //             ),
                      //           );
                      //         } catch (e) {
                      //           print("Geo error: $e");
                      //         }
                      //       },
                      //     );
                      //   },
                      // ),
                      Consumer<SalesOrderProvider>(
  builder: (context, provider, child) {

    // 🔥 DEBUG LOGS
    print("========== SALES ORDER DEBUG ==========");
    print("isLoading => ${provider.isLoading}");
    print("empType => $empType");
    print("salesOrderList Count => ${provider.salesOrderList.length}");
    print("salesOrderList => ${provider.salesOrderList}");
    print("=======================================");

    /// 🔄 LOADING STATE
    if (provider.isLoading) {
      return Container(
        height: 55,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(8),
        ),
        alignment: Alignment.centerLeft,
        child: const Text(
          "Please wait loading Sales Order...",
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    /// ⛔ STAFF USER → HIDE DROPDOWN
    if (empType.toString().toLowerCase() == "staff") {
      return Container(
        height: 55,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.orange),
          borderRadius: BorderRadius.circular(8),
        ),
        alignment: Alignment.centerLeft,
        child: const Text(
          "Sales Order hidden for Staff",
          style: TextStyle(color: Colors.orange),
        ),
      );

      // If you want complete hide use this:
      // return const SizedBox.shrink();
    }

    /// ❌ EMPTY STATE
    if (provider.salesOrderList.isEmpty) {
      return Container(
        height: 55,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(8),
        ),
        alignment: Alignment.centerLeft,
        child: const Text(
          "No Sales Order Found",
          style: TextStyle(color: Colors.redAccent),
        ),
      );
    }

    /// ✅ DROPDOWN
    return CustomDropdownWidget(
      valArr: provider.salesOrderList,

      labelText: "Sales Order",

      selectedItem: selectedsalesorderno,

      /// 🔥 SAFE LABEL
      labelField: (item) =>
          "Sales Order : ${item.tranId ?? ''}",

      onChanged: (value) async {

        setState(() {
          selectedsalesorderno = value;
          isInsideFence = false;
        });

        try {

          /// 📍 GET CURRENT LOCATION
          Position position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.bestForNavigation,
          );

          /// 📍 SALES ORDER LOCATION
          final double centerLat =
              (value.latitude ?? 0).toDouble();

          final double centerLng =
              (value.longitude ?? 0).toDouble();

          /// 🔥 API RADIUS
          final double radius =
              (value.radius ?? 200).toDouble();

          /// 📏 CALCULATE DISTANCE
          double distance = Geolocator.distanceBetween(
            position.latitude,
            position.longitude,
            centerLat,
            centerLng,
          );

          /// ✅ CHECK INSIDE FENCE
          setState(() {
            currentDistance = distance;
            isInsideFence = distance <= radius;
          });

          /// 🔥 DEBUG LOGS
          print("========== GEO FENCE DEBUG ==========");
          print("User Lat => ${position.latitude}");
          print("User Lng => ${position.longitude}");
          print("Center Lat => $centerLat");
          print("Center Lng => $centerLng");
          print("Allowed Radius => $radius");
          print("Current Distance => $distance");
          print("Inside Fence => $isInsideFence");
          print("=====================================");

          /// 🔔 MESSAGE
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor:
                  isInsideFence ? Colors.green : Colors.red,
              content: Text(
                isInsideFence
                    ? "Inside Fence ✅ ${distance.toStringAsFixed(2)} m"
                    : "Outside Fence ❌ ${distance.toStringAsFixed(2)} m",
              ),
            ),
          );

        } catch (e) {

          print("GEO ERROR => $e");

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Colors.red,
              content: Text("Location Error : $e"),
            ),
          );
        }
      },
    );
  },
),

                      const SizedBox(height: 16),

                      /// SHIFT
                      CustomDropdownWidget(
                        valArr: shiftlist,
                        labelText: "Shift",
                        selectedItem: usershift,
                        onChanged: (value) {
                          setState(() {
                            shiftId = value['value'];
                            usershift = value;
                          });
                        },
                        labelField: (item) => item["label"],
                      ),

                      const SizedBox(height: 16),

                      /// REMARK
                      CustomRoundedTextField(
                        controller: remark,
                        labelText: "Note",
                        maxLines: 3,
                      ),

                      const SizedBox(height: 25),

                      /// BUTTON
                      // SizedBox(
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: Consumer<TimesheetProvider>(
                          builder: (context, provider, child) {
                            return ElevatedButton(
                              onPressed: provider.isLoading
                                  ? null
                                  : submitCheckIn,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                              ),
                              child: const Text(
                                "Check In",
                                style: TextStyle(color: Colors.white),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (provider.isLoading)
                Positioned.fill(
                  child: Container(
                    color: Colors.black.withOpacity(0.4),
                    child: const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    ),
                  ),
                ),
            ],
          );
        },
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: refreshLocation,
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.refresh, color: AppColors.bgCard),
      ),
    );
  }
}
