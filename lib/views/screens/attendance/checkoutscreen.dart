import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart' hide LocationAccuracy;
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';

import '../../../core/constant/app_color.dart';
import '../../../data/services/location_service.dart';
import '../../../provider/salesorder_provider.dart';
import '../../../provider/timesheet_provider.dart';
import '../../../provider/getstatus_provider.dart';

import '../../../widgets/checkinmap_page.dart';
import '../../../widgets/custom_textfield.dart';

class Checkoutscreen extends StatefulWidget {
  const Checkoutscreen({super.key});

  @override
  State<Checkoutscreen> createState() => _CheckoutscreenState();
}

class _CheckoutscreenState extends State<Checkoutscreen> {
  final TextEditingController salesnumController = TextEditingController();
  final TextEditingController remark = TextEditingController();

  double? lat;
  double? lng;

  bool isPageLoading = true; // initial load
  bool isSubmitting = false; // checkout click

  final LocationService locationService = LocationService();
  StreamSubscription<LocationData>? positionStream;

  final GlobalKey<CheckInMapState> mapKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    initLocation();
  }

  // =========================
  // LOCATION INIT
  // =========================
  Future<void> initLocation() async {
    final location = await locationService.getCurrentLocation();

    if (!mounted || location == null) {
      setState(() => isPageLoading = false);
      return;
    }

    setState(() {
      lat = location.latitude;
      lng = location.longitude;
      isPageLoading = false;
    });

    positionStream = locationService.startLiveTracking((newLatLng) {
      if (!mounted) return;

      lat = newLatLng.latitude;
      lng = newLatLng.longitude;

      mapKey.currentState?.updateLocation(LatLng(lat!, lng!));
    });
  }

  // =========================
  // GEO FENCE CHECK
  // =========================
  bool isInsideGeoFence({
    required double userLat,
    required double userLng,
    required double centerLat,
    required double centerLng,
    required double radius,
  }) {
    double distance = Geolocator.distanceBetween(
      userLat,
      userLng,
      centerLat,
      centerLng,
    );

    return distance <= radius;
  }

  // =========================
  // CHECKOUT FUNCTION
  // =========================
  Future<void> handleCheckout() async {
    if (lat == null || lng == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Location not ready")));
      return;
    }

    setState(() => isSubmitting = true);

    try {
      final timesheetProvider = Provider.of<TimesheetProvider>(
        context,
        listen: false,
      );

      final statusProvider = Provider.of<GetStatusProvider>(
        context,
        listen: false,
      );

      final salesProvider = Provider.of<SalesOrderProvider>(
        context,
        listen: false,
      );

      final data = (statusProvider.statusResponse?.data?.isNotEmpty ?? false)
          ? statusProvider.statusResponse!.data!.first
          : null;

      if (data == null) {
        throw Exception("Check-out data not found");
      }

      final internalId = data.internalId?.toString();
      
      final timeIn = data.timeIn;
      final salesOrderId = data.salesOrder;

      if (internalId == null || timeIn == null || salesOrderId == null) {
        throw Exception("Invalid check-out data");
      }

      // Load sales order if empty
      if (salesProvider.salesOrderList.isEmpty) {
        await salesProvider.getAllSalesOrderNo();
      }

      if (salesProvider.salesOrderList.isEmpty) {
        throw Exception("Sales order list empty");
      }

      final order = salesProvider.salesOrderList.firstWhere(
        (e) =>
            int.tryParse(e.internalId.toString()) ==
            int.tryParse(salesOrderId.toString()),
        orElse: () => throw Exception("Sales order not found"),
      );

      if (order.latitude == null ||
    order.longitude == null ||
    order.radius == null) {

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return AlertDialog(
        title: const Text("Geo Configuration Missing"),
        content: const Text(
          "Latitude, Longitude, or Radius is not set for this Sales Order. Please contact admin.",
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

  return; // stop further execution
}
      final centerLat = double.tryParse(order.latitude.toString()) ?? 0;
      final centerLng = double.tryParse(order.longitude.toString()) ?? 0;
      final radius = double.tryParse(order.radius.toString()) ?? 0;

      final inside = isInsideGeoFence(
        userLat: lat!,
        userLng: lng!,
        centerLat: centerLat,
        centerLng: centerLng,
        radius: radius,
      );

    if (!inside) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return AlertDialog(
        title: const Text("Check-out Blocked"),
        content: const Text(
          "You are outside the geo-fence area. Please move inside the allowed location and try again.",
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

  return; // stop execution
}

      final timeOut = DateFormat(
        'hh:mm a',
      ).format(DateTime.now()).toLowerCase();

      final gpsUrl = "https://maps.google.com/?q=$lat,$lng";

      await timesheetProvider.updateTimesheet(
        internalId: internalId,
        timeIn: timeIn,
        timeOut: timeOut,
        remarks: remark.text,
        toGpsAddress: gpsUrl,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            timesheetProvider.updateResponse?.message ?? "Check-out success",
          ),
        ),
      );

      Navigator.pop(context, {"status": "checkout_done"});
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) {
        setState(() => isSubmitting = false);
      }
    }
  }

  @override
  void dispose() {
    salesnumController.dispose();
    remark.dispose();
    locationService.stopTracking();
    positionStream?.cancel();
    super.dispose();
  }

  Future<void> refreshLocation() async {
    setState(() => isPageLoading = true);

    final location = await locationService.getCurrentLocation();

    if (location == null) {
      setState(() => isPageLoading = false);
      return;
    }

    setState(() {
      lat = location.latitude;
      lng = location.longitude;
      isPageLoading = false;
    });

    mapKey.currentState?.updateLocation(location);
  }

  // =========================
  // UI
  // =========================
  @override
  Widget build(BuildContext context) {
    final statusProvider = context.watch<GetStatusProvider>();

    final salesOrderText =
        statusProvider.statusResponse?.data?.first.salesOrderId?.toString() ?? "";

    salesnumController.text = salesOrderText;

    final isLoading = isPageLoading || isSubmitting;

    return Scaffold(
      appBar: AppBar(title: const Text("Check Out")),
      body: Stack(
        children: [
          AbsorbPointer(
            absorbing: isLoading,
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Container(
                      height: 300,
                      width: double.infinity,
                      child: (isPageLoading || lat == null || lng == null)
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

                    CustomRoundedTextField(
                      controller: salesnumController,
                      labelText: "Sales Order",
                      readOnly: true,
                    ),

                    const SizedBox(height: 10),

                    CustomRoundedTextField(
                      controller: remark,
                      labelText: "Note",
                      maxLines: 3,
                    ),

                    const SizedBox(height: 24),

                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                        ),
                        onPressed: isSubmitting ? null : handleCheckout,
                        child: const Text("Check Out"),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          /// 🔥 FULL SCREEN LOADER
          if (isLoading)
            Positioned.fill(
              child: Container(
                color: Colors.white,
                child: const Center(child: CircularProgressIndicator()),
              ),
            ),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: refreshLocation,
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.refresh, color: AppColors.bgCard),
      ),
    );
  }
}
