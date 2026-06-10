import 'dart:async';
import 'package:location/location.dart';
import 'package:latlong2/latlong.dart';

class LocationService {
  Location location = Location();
  StreamSubscription<LocationData>? _subscription;

  /// 📍 GET CURRENT LOCATION
  Future<LatLng?> getCurrentLocation() async {
    bool serviceEnabled;
    PermissionStatus permissionGranted;

    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) return null;
    }

    permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
    }

    if (permissionGranted != PermissionStatus.granted) {
      return null;
    }

    final data = await location.getLocation();

    if (!_isValid(data.latitude, data.longitude)) return null;

    return LatLng(data.latitude!, data.longitude!);
  }

  /// 🔄 LIVE TRACKING
  StreamSubscription<LocationData> startLiveTracking(
    Function(LatLng) onUpdate,
  ) {
    _subscription = location.onLocationChanged.listen((data) {
      if (!_isValid(data.latitude, data.longitude)) return;

      onUpdate(
        LatLng(data.latitude!, data.longitude!),
      );
    });

    return _subscription!;
  }

  /// 🛑 STOP
  void stopTracking() {
    _subscription?.cancel();
  }

  /// ✅ VALIDATION (IMPORTANT)
  bool _isValid(double? lat, double? lng) {
    if (lat == null || lng == null) return false;
    if (lat.isNaN || lng.isNaN) return false;
    if (lat.isInfinite || lng.isInfinite) return false;
    if (lat == 0.0 && lng == 0.0) return false;
    if (lat < -90 || lat > 90) return false;
    if (lng < -180 || lng > 180) return false;
    return true;
  }
}