



import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class CheckInMap extends StatefulWidget {
  final LatLng initialLocation;

  const CheckInMap({
    super.key,
    required this.initialLocation,
  });

  @override
  State<CheckInMap> createState() => CheckInMapState();
}

class CheckInMapState extends State<CheckInMap> {
  late LatLng currentLocation;
  final MapController _mapController = MapController();

  @override
  void initState() {
    super.initState();

    if (widget.initialLocation.latitude.isNaN ||
        widget.initialLocation.longitude.isNaN) {
      currentLocation = const LatLng(11.9416, 79.8083);
    } else {
      currentLocation = widget.initialLocation;
    }
  }

  /// 🔥 Safe location
  LatLng get safeLocation {
    if (currentLocation.latitude.isNaN ||
        currentLocation.longitude.isNaN) {
      return const LatLng(11.9416, 79.8083);
    }
    return currentLocation;
  }

  /// 🔥 Only external update allowed
  void updateLocation(LatLng newLocation) {
    if (newLocation.latitude.isNaN ||
        newLocation.longitude.isNaN) {
      print("❌ Invalid location");
      return;
    }

    setState(() {
      currentLocation = newLocation;
    });

    _mapController.move(newLocation, _mapController.camera.zoom);
  }

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: safeLocation,
        initialZoom: 15,

        /// 🔥 prevent crash
        minZoom: 3,
        maxZoom: 18,

        cameraConstraint: CameraConstraint.contain(
          bounds: LatLngBounds(
            const LatLng(-90, -180),
            const LatLng(90, 180),
          ),
        ),

        /// ❌ REMOVE THIS (IMPORTANT)
        // onPositionChanged: ...
      ),

      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          tileProvider: NetworkTileProvider(
            headers: {
              'User-Agent': 'MyFlutterCheckInApp/1.0 (me@myapp.com)',
            },
          ),
        ),

        /// 🔥 Marker always fixed
        MarkerLayer(
          markers: [
            Marker(
              point: safeLocation,
              width: 120,
              height: 120,
              alignment: Alignment.center,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.blue.withOpacity(0.2),
                    ),
                  ),
                  Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}