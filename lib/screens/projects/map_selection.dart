import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';

class MapSelectionScreen extends StatefulWidget {
  final String title;
  final LatLng? initialLocation;

  const MapSelectionScreen({
    super.key,
    required this.title,
    this.initialLocation,
  });

  @override
  _MapSelectionScreenState createState() => _MapSelectionScreenState();
}

class _MapSelectionScreenState extends State<MapSelectionScreen> {
  late GoogleMapController _mapController;
  LatLng? _selectedLocation;
  bool _isLoading = false;
  String? _address;
  String? _addressAr;

  @override
  void initState() {
    super.initState();
    _selectedLocation = widget.initialLocation ?? LatLng(24.7136, 46.6753); // Riyadh
  }

  Future<void> _getReverseGeocode(LatLng location) async {
    setState(() => _isLoading = true);

    try {
      final placemarks = await placemarkFromCoordinates(
        location.latitude,
        location.longitude,
      );

      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        _address = [
          if (place.street?.isNotEmpty == true) place.street,
          if (place.subLocality?.isNotEmpty == true) place.subLocality,
          if (place.locality?.isNotEmpty == true) place.locality,
          if (place.administrativeArea?.isNotEmpty == true) place.administrativeArea,
          if (place.country?.isNotEmpty == true) place.country,
        ].where((e) => e != null).join(', ');

        // For Arabic address, you might want to use a different geocoding service
        // or translate the address using a translation service
        _addressAr = _address; // Replace with actual Arabic address
      }
    } catch (e) {
      debugPrint('Error getting address: $e');
      _address = 'Unable to get address';
      _addressAr = 'تعذر الحصول على العنوان';
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          if (_selectedLocation != null)
            TextButton(
              onPressed: _isLoading
                  ? null
                  : () {
                Navigator.pop(context, {
                  'location': _selectedLocation,
                  'address': _address,
                  'addressAr': _addressAr,
                });
              },
              child: Text(
                'Confirm',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _selectedLocation!,
              zoom: 15,
            ),
            onMapCreated: (controller) => _mapController = controller,
            onCameraMove: (position) {
              _selectedLocation = position.target;
            },
            onCameraIdle: () {
              if (_selectedLocation != null) {
                _getReverseGeocode(_selectedLocation!);
              }
            },
            markers: _selectedLocation == null
                ? {}
                : {
              Marker(
                markerId: MarkerId('selected_location'),
                position: _selectedLocation!,
              ),
            },
          ),
          Center(
            child: Icon(
              Icons.location_on,
              color: Theme.of(context).primaryColor,
              size: 36,
            ),
          ),
          if (_isLoading)
            Center(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: CircularProgressIndicator(),
                ),
              ),
            ),
          if (_address != null)
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _address!,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      if (_addressAr != null) ...[
                        SizedBox(height: 8),
                        Text(
                          _addressAr!,
                          textDirection: TextDirection.rtl,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}