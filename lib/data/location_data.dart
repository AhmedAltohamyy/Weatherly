import 'package:geolocator/geolocator.dart';
import 'package:hive/hive.dart';

/// Determines the device's current geographic position
/// Handles location permissions and falls back to cached location or Cairo if unavailable
/// Returns a [Position] object with latitude and longitude
Future<Position> determinePosition() async {
  LocationPermission permission;

  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    // Request location permission if not previously granted
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      return Future.error('Location permissions are denied');
    }
  }

  if (permission == LocationPermission.deniedForever) {
    // Permission permanently denied - user must enable in settings
    return Future.error('Location permissions are permanently denied.');
  }

  try {
    final box = Hive.box("lastCity");

    // Get current position with medium accuracy (faster than high accuracy)
    Position position = await Geolocator.getCurrentPosition(
      locationSettings: LocationSettings(
        accuracy: LocationAccuracy.medium,
        timeLimit: const Duration(seconds: 15),
      ),
    );

    // Cache the position for offline use
    await box.put("lat", position.latitude);
    await box.put("lon", position.longitude);
    await box.put("opened", true);

    return position;
  } catch (e) {
    // If real-time location fails, try to use cached location
    print(e);
    final box = Hive.box("lastCity");
    double? lat = box.get("lat");
    double? lon = box.get("lon");

    if (lat != null && lon != null) {
      // Return cached position if available
      return Position(
        longitude: lon,
        latitude: lat,
        timestamp: DateTime.now(),
        accuracy: 0,
        altitude: 0,
        heading: 0,
        headingAccuracy: 0,
        speed: 0,
        speedAccuracy: 0,
        altitudeAccuracy: 0,
      );
    }

    // Fallback to Cairo, Egypt coordinates (30.0444°N, 31.2357°E)
    print("Didnot get any position");
    return Position(
      longitude: 31.2357,
      latitude: 30.0444,
      timestamp: DateTime.now(),
      accuracy: 0,
      altitude: 0,
      heading: 0,
      headingAccuracy: 0,
      speed: 0,
      speedAccuracy: 0,
      altitudeAccuracy: 0,
    );
  }
}
