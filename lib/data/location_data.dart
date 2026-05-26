import 'package:geolocator/geolocator.dart';
import 'package:hive/hive.dart';

Future<Position> determinePosition() async {
  bool serviceEnabled;
  LocationPermission permission;

  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    return Future.error('Location services are disabled.');
  }

  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      return Future.error('Location permissions are denied');
    }
  }

  if (permission == LocationPermission.deniedForever) {
    return Future.error('Location permissions are permanently denied.');
  }

  try {
    final box = Hive.box("lastCity"); // توحيد الاسم

    // جلب الموقع الحالي
    Position position = await Geolocator.getCurrentPosition(
      locationSettings: LocationSettings(
        accuracy: LocationAccuracy.medium,
        timeLimit: const Duration(seconds: 15),
      ),
    );

    // تخزين الإحداثيات كأرقام صحيحة لـ Hive
    await box.put("lat", position.latitude);
    await box.put("lon", position.longitude);
    await box.put("opened", true);

    return position;
  } catch (e) {
    print(e);
    final box = Hive.box("lastCity");
    double? lat = box.get("lat");
    double? lon = box.get("lon");

    // إذا فشل الاتصال، استرجع آخر موقع مسجل
    if (lat != null && lon != null) {
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
