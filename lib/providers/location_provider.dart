import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class LocationData {
  final LatLng location;
  final String address;
  final String? addressAr;

  LocationData({
    required this.location,
    required this.address,
    this.addressAr,
  });
}

class LocationProvider extends ChangeNotifier {
  LocationData? _projectLocation;

  LocationData? get projectLocation => _projectLocation;

  void setProjectLocation(LocationData location) {
    _projectLocation = location;
    notifyListeners();
  }

  void clearProjectLocation() {
    _projectLocation = null;
    notifyListeners();
  }
}