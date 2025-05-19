import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class LocationPermissionHandler {
  static final LocationPermissionHandler _instance = LocationPermissionHandler._internal();
  factory LocationPermissionHandler() => _instance;
  LocationPermissionHandler._internal();

  Future<bool> handleLocationPermission(BuildContext context) async {
    bool serviceEnabled;
    LocationPermission permission;

    // First check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await _showLocationDisabledDialog(context);
      return false;
    }

    // Check current permission status
    permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      // Show rationale before requesting permission
      final shouldProceed = await _showPermissionRationaleDialog(context);
      if (!shouldProceed) return false;

      // Request permission
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // User denied permission
        await _showPermissionDeniedDialog(context);
        return false;
      }
    }

    // Handle permanently denied case
    if (permission == LocationPermission.deniedForever) {
      await _showPermanentlyDeniedDialog(context);
      return false;
    }

    // Permission granted
    return permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always;
  }

  Widget _buildDialogTitle(BuildContext context, IconData icon, String text, {Color? iconColor}) {
    return Flexible(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: iconColor ?? Theme.of(context).primaryColor),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              text,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 18),
            ),
          ),
        ],
      ),
    );
  }

  Future<bool> _showPermissionRationaleDialog(BuildContext context) async {
    return await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => AlertDialog(
        titlePadding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
        contentPadding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
        title: _buildDialogTitle(
          context,
          Icons.location_on,
          'Location Access Needed',
        ),
        content: SingleChildScrollView(
          child: ListBody(
            children: [
              const Text(
                'This app needs access to location to:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              _buildBulletPoint(context, 'Select accurate pickup locations'),
              _buildBulletPoint(context, 'Choose precise drop-off points'),
              _buildBulletPoint(context, 'Track delivery progress'),
              _buildBulletPoint(context, 'Ensure efficient delivery routing'),
              const SizedBox(height: 16),
              Text(
                'Your location data will only be used while using the app.',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('NOT NOW'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 16),
            ),
            child: const Text('CONTINUE'),
          ),
        ],
      ),
    ) ?? false;
  }

  Future<void> _showLocationDisabledDialog(BuildContext context) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => AlertDialog(
        titlePadding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
        contentPadding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
        title: _buildDialogTitle(
          context,
          Icons.location_disabled,
          'Location Services Disabled',
        ),
        content: SingleChildScrollView(
          child: ListBody(
            children: [
              const Text(
                'Location services are disabled. Please enable location services in your device settings to use this feature.',
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await Geolocator.openLocationSettings();
            },
            style: ElevatedButton.styleFrom(
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 16),
            ),
            child: const Text('OPEN SETTINGS'),
          ),
        ],
      ),
    );
  }

  Future<void> _showPermissionDeniedDialog(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        titlePadding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
        contentPadding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
        title: _buildDialogTitle(
          context,
          Icons.warning,
          'Permission Denied',
          iconColor: Colors.orange,
        ),
        content: SingleChildScrollView(
          child: ListBody(
            children: [
              const Text(
                'Location permission is required to select pickup and drop-off locations. '
                    'Please grant permission to use this feature.',
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _showPermanentlyDeniedDialog(BuildContext context) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => AlertDialog(
        titlePadding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
        contentPadding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
        title: _buildDialogTitle(
          context,
          Icons.location_disabled,
          'Permission Permanently Denied',
          iconColor: Colors.red,
        ),
        content: SingleChildScrollView(
          child: ListBody(
            children: [
              const Text(
                'Location permission has been permanently denied. Please enable it in your device settings:',
              ),
              const SizedBox(height: 16),
              const Text(
                '1. Open Settings\n'
                    '2. Go to Permissions\n'
                    '3. Enable Location permission',
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await Geolocator.openAppSettings();
            },
            style: ElevatedButton.styleFrom(
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 16),
            ),
            child: const Text('OPEN SETTINGS'),
          ),
        ],
      ),
    );
  }

  Widget _buildBulletPoint(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.check_circle,
            size: 20,
            color: Theme.of(context).primaryColor,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text),
          ),
        ],
      ),
    );
  }
}