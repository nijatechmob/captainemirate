// import 'package:geolocator/geolocator.dart';

// class GeoFenceService {
//   /// Check if user is inside radius
//   static bool isInsideGeoFence({
//     required double userLat,
//     required double userLng,
//     required double centerLat,
//     required double centerLng,
//     required double radius,
//   }) {
//     double distance = Geolocator.distanceBetween(
//       userLat,
//       userLng,
//       centerLat,
//       centerLng,
//     );

//     return distance <= radius;
//   }

//   /// Get current distance
//   static double calculateDistance({
//     required double userLat,
//     required double userLng,
//     required double centerLat,
//     required double centerLng,
//   }) {
//     return Geolocator.distanceBetween(userLat, userLng, centerLat, centerLng);
//   }

//   /// Get current position safely
//   static Future<Position> getCurrentPosition() async {
//     bool serviceEnabled;
//     LocationPermission permission;

//     serviceEnabled = await Geolocator.isLocationServiceEnabled();
//     if (!serviceEnabled) {
//       throw Exception("Location services are disabled");
//     }

//     permission = await Geolocator.checkPermission();

//     if (permission == LocationPermission.denied) {
//       permission = await Geolocator.requestPermission();
//       if (permission == LocationPermission.denied) {
//         throw Exception("Location permission denied");
//       }
//     }

//     if (permission == LocationPermission.deniedForever) {
//       throw Exception("Location permission permanently denied");
//     }

//     return await Geolocator.getCurrentPosition(
//       desiredAccuracy: LocationAccuracy.bestForNavigation,
//     );
//   }
// }
