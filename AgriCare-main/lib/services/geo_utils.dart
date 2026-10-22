import 'dart:math';

/// Great-circle distance between two lat/lng points, in kilometres.
/// Same formula as the "Haversine Formula — Distance Calculation" section
/// of the project spec.
double haversineKm(double lat1, double lon1, double lat2, double lon2) {
  const r = 6371.0; // Earth radius in km
  final dLat = _toRad(lat2 - lat1);
  final dLon = _toRad(lon2 - lon1);
  final a = sin(dLat / 2) * sin(dLat / 2) +
      cos(_toRad(lat1)) * cos(_toRad(lat2)) * sin(dLon / 2) * sin(dLon / 2);
  final c = 2 * atan2(sqrt(a), sqrt(1 - a));
  return r * c;
}

double _toRad(double deg) => deg * pi / 180;
