import 'package:google_maps_flutter/google_maps_flutter.dart';

class LocationData {
  final LatLng location;
  final String address;

  LocationData({
    required this.location,
    required this.address,
  });

  Map<String, dynamic> toMap() {
    return {
      'location': location,
      'address': address,
    };
  }
}