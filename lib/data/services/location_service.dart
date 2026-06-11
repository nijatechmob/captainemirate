import 'dart:async';
import 'package:location/location.dart' hide LocationAccuracy;
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';

class LocationService {
  Location location = Location();
  StreamSubscription<LocationData>? _subscription;

  /// 📍 GET CURRENT LOCATION
  Future<LatLng?> getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();

      if (!serviceEnabled) {
        return null;
      }

      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return null;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 15),
      );

      return LatLng(position.latitude, position.longitude);
    } catch (e) {
      print("Location Error: $e");
      return null;
    }
  }

  /// 🔄 LIVE TRACKING
  StreamSubscription<LocationData> startLiveTracking(
    Function(LatLng) onUpdate,
  ) {
    _subscription = location.onLocationChanged.listen((data) {
      if (!_isValid(data.latitude, data.longitude)) return;

      onUpdate(LatLng(data.latitude!, data.longitude!));
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
