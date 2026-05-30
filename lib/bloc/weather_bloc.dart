// ignore_for_file: avoid_print

import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:weatherly/bloc/weather_event.dart';
import 'package:weatherly/bloc/weather_state.dart';
import 'package:hive/hive.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

class WeatherBloc extends Bloc<WeatherEvent, WeatherState> {
  WeatherBloc() : super(WeatherInitial()) {
    Dio dio = Dio();
    final weatherBox = Hive.box("weatherBox");
    final lastCityBox = Hive.box("lastCity");
    on<FetchWeather>((event, emit) async {
      emit(WeatherLoading());

      try {
        bool needsUpdate = event.update;
        final now = DateTime.now();

        // جلب البيانات المخزنة
        final cachedData = weatherBox.get('weatherData');
        final cachedCity = lastCityBox.get('cityName');
        final String? lastUpdateStr = weatherBox.get(
          'lastUpdateTime',
        ); // سنخزن الوقت بالكامل
        final cachedLat = weatherBox.get('lat');
        final cachedLon = weatherBox.get('lon');

        if (cachedData != null &&
            cachedCity != null &&
            lastUpdateStr != null &&
            cachedLat != null &&
            cachedLon != null) {
          final DateTime lastUpdate = DateTime.parse(lastUpdateStr);

          // 1. حساب المسافة
          final distance = Geolocator.distanceBetween(
            event.position.latitude,
            event.position.longitude,
            cachedLat,
            cachedLon,
          );

          // 2. حساب الفارق الزمني بالساعات
          final int hoursDifference = now.difference(lastUpdate).inHours;

          // 3. التحقق مما إذا كان اليوم قد تغير
          final bool isSameDay =
              now.year == lastUpdate.year &&
              now.month == lastUpdate.month &&
              now.day == lastUpdate.day;

          // شرط التحديث:
          // إذا كان في نفس اليوم و المسافة أقل من 5كم و مر أقل من ساعتين -> لا نحتاج تحديث
          if (isSameDay && distance < 5000 && hoursDifference < 1) {
            needsUpdate = true;
          }
        }

        if (needsUpdate) {
          String cityName = "Unknown City"; // Default value

          try {
            // 1. Get the Placemarks
            List<Placemark> placemarks = await placemarkFromCoordinates(
              event.position.latitude,
              event.position.longitude,
            );
            print("$placemarks");
            // 2. Enhanced Fallback Logic
            cityName = "Unknown Location"; // Start with a default

            if (placemarks.isNotEmpty) {
              print("====================================");
              print("Placemarks: $placemarks");
              print("====================================");
              Placemark place = placemarks[0];

              // Try to find the best name available
              cityName =
                  "${place.administrativeArea} - ${place.subAdministrativeArea}";

              print("Found City: $cityName"); // Check your debug console!
            }
          } catch (e) {
            print("Geocoding failed: $e");
            // Don't emit error here, just keep "Unknown City" and proceed to get weather
          }

          // (2) طلب الـ API
          const url = 'https://api.open-meteo.com/v1/forecast';
          final response = await dio.get(
            url,
            
            queryParameters: {
              'latitude': event.position.latitude,
              'longitude': event.position.longitude,
              // أضفنا relative_humidity_2m لجلب الرطوبة الحالية
              'current': "temperature_2m,relative_humidity_2m,is_day,weather_code", 
              'hourly': "temperature_2m,relative_humidity_2m,is_day,weather_code",
              'daily':
                  "weather_code,sunrise,sunset,temperature_2m_max,temperature_2m_min,relative_humidity_2m",
              'timezone': "auto",
            },
          );
          print(response.data);

          // (3) تخزين البيانات الجديدة مع الوقت الحالي بدقة
          await weatherBox.put('weatherData', response.data);
          await lastCityBox.put('cityName', cityName);
          await weatherBox.put(
            'lastUpdateTime',
            now.toIso8601String(),
          ); // تخزين الوقت بصيغة نصية
          await weatherBox.put('lat', event.position.latitude);
          await weatherBox.put('lon', event.position.longitude);

          emit(WeatherSuccess(response.data, cityName));
        } else {
          // العودة للبيانات المخزنة إذا لم نحتاج للتحديث
          emit(WeatherSuccess(cachedData, cachedCity));
        }
      } on DioException catch (e) {
        print("Dio Error: $e");
        final cachedData = weatherBox.get('weatherData');
        final cachedCity = weatherBox.get('cityName');

        if (cachedData != null && cachedCity != null) {
          emit(WeatherSuccess(cachedData, cachedCity));
        } else {
          emit(const WeatherError("No internet connection and no cached data"));
        }
      } catch (e) {
        print("Unexpected Error: $e");
        emit(WeatherError("Unexpected Error: $e"));
      }
    });
  }
}
