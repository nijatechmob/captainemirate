

import 'dart:convert';
import 'dart:math';

SalesOrderNoModel salesOrderNoModelFromJson(String str) =>
    SalesOrderNoModel.fromJson(json.decode(str));

String salesOrderNoModelToJson(SalesOrderNoModel data) =>
    json.encode(data.toJson());

class SalesOrderNoModel {
  bool? success;
  String? message;
  List<SalesOrderItem>? payload;

  SalesOrderNoModel({
    this.success,
    this.message,
    this.payload,
  });

  factory SalesOrderNoModel.fromJson(Map<String, dynamic> json) {
    return SalesOrderNoModel(
      success: json["success"],
      message: json["message"],
      payload: (json["payload"] as List?)
              ?.map((x) => SalesOrderItem.fromJson(x))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "success": success,
      "message": message,
      "payload": payload?.map((x) => x.toJson()).toList() ?? [],
    };
  }
}

class SalesOrderItem {
  String? internalId;
  String? tranId;
  double? latitude;
  double? longitude;
  double? radius;

  SalesOrderItem({
    this.internalId,
    this.tranId,
    this.latitude,
    this.longitude,
    this.radius,
  });

  factory SalesOrderItem.fromJson(Map<String, dynamic> json) {
    return SalesOrderItem(
      internalId: json["internalId"]?.toString(),
      tranId: json["tranId"]?.toString(),

      latitude: _toDouble(json["latitude"]),
      longitude: _toDouble(json["longitude"]),
      radius: _toDouble(json["radius"]),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "internalId": internalId,
      "tranId": tranId,
      "latitude": latitude,
      "longitude": longitude,
      "radius": radius,
    };
  }
  @override
  String toString() {
    return 'SalesOrderItem(internalId: $internalId, lat: $latitude, lng: $longitude, radius: $radius)';
  }
  // =========================
  // SAFE PARSERS
  // =========================

  static double? _toDouble(dynamic value) {
    if (value == null) return null;

    if (value is double) return value;
    if (value is int) return value.toDouble();

    if (value is String) {
      final v = value.trim();

      if (v.isEmpty) return null;
      if (v.toLowerCase() == "null") return null;

      return double.tryParse(v);
    }

    return null;
  }

  // =========================
  // GEO VALIDATION HELPERS
  // =========================

  bool get hasValidGeo =>
      latitude != null && longitude != null && radius != null;

  bool isInsideGeoFence({
    required double userLat,
    required double userLng,
  }) {
    if (!hasValidGeo) return false;

    final distance = _distanceBetween(
      userLat,
      userLng,
      latitude!,
      longitude!,
    );

    return distance <= (radius ?? 200);
  }

  double distanceFromUser({
    required double userLat,
    required double userLng,
  }) {
    if (!hasValidGeo) return 0;

    return _distanceBetween(
      userLat,
      userLng,
      latitude!,
      longitude!,
    );
  }

  // Haversine formula (no external dependency)
  double _distanceBetween(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const earthRadius = 6371000; // meters

    final dLat = _degToRad(lat2 - lat1);
    final dLon = _degToRad(lon2 - lon1);

    final a = (sin(dLat / 2) * sin(dLat / 2)) +
        cos(_degToRad(lat1)) *
            cos(_degToRad(lat2)) *
            (sin(dLon / 2) * sin(dLon / 2));

    final c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return earthRadius * c;
  }

  double _degToRad(double deg) => deg * (3.141592653589793 / 180);
}

