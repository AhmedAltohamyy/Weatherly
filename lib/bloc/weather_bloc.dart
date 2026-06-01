// ignore_for_file: avoid_print

import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:weatherly/bloc/weather_event.dart';
import 'package:weatherly/bloc/weather_state.dart';
import 'package:hive/hive.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

/// BLoC responsible for managing weather data fetching and caching
/// Handles API calls to Open-Meteo weather service and stores data locally with Hive
class WeatherBloc extends Bloc<WeatherEvent, WeatherState> {
  WeatherBloc() : super(WeatherInitial()) {
    Dio dio = Dio();
    final Box settings = Hive.box('settings');
    final weatherBox = Hive.box("weatherBox");
    final lastCityBox = Hive.box("lastCity");
    
    // Event handler for FetchWeather events - retrieves weather data or serves from cache
    on<FetchWeather>((event, emit) async {
      emit(WeatherLoading());

      try {
        String Degree = settings.get('degree', defaultValue: "celsius");
        bool needsUpdate = event.update; // User can force refresh via pull-to-refresh
        final now = DateTime.now();

        // Retrieve cached data to avoid unnecessary API calls
        final cachedData = weatherBox.get('weatherData');
        final cachedCity = lastCityBox.get('cityName');
        final String? lastUpdateStr = weatherBox.get('lastUpdateTime');
        final cachedLat = weatherBox.get('lat');
        final cachedLon = weatherBox.get('lon');

        // If any cache is missing, force an update from the API
        if (cachedData == null ||
            cachedCity == null ||
            lastUpdateStr == null ||
            cachedLat == null ||
            cachedLon == null) {
         needsUpdate = true;
        }

        if (needsUpdate) {
          String cityName = "Unknown City";

          try {
            // Use reverse geocoding to get the city name from coordinates
            List<Placemark> placemarks = await placemarkFromCoordinates(
              event.position.latitude,
              event.position.longitude,
            );
            print("$placemarks");
            cityName = "Unknown Location";

            if (placemarks.isNotEmpty) {
              print("====================================");
              print("Placemarks: $placemarks");
              print("====================================");
              Placemark place = placemarks[0];

              // Format: State/Province - District/Region
              cityName =
                  "${place.administrativeArea} - ${place.subAdministrativeArea}";

              print("Found City: $cityName");
            }
          } catch (e) {
            print("Geocoding failed: $e");
          }

          // Fetch weather data from Open-Meteo free weather API
          const url = 'https://api.open-meteo.com/v1/forecast';
          final response = await dio.get(
            url,
            queryParameters: {
              'latitude': event.position.latitude,
              'longitude': event.position.longitude,
              'current': "temperature_2m,relative_humidity_2m,is_day,weather_code",
              'hourly': "temperature_2m,relative_humidity_2m,is_day,weather_code",
              'daily': "weather_code,sunrise,sunset,temperature_2m_max,temperature_2m_min",
              'temperature_unit': Degree,
              'timezone': "auto",
            },
          );
          print(response.data);

          // Cache the fetched weather data locally to reduce API calls
          await weatherBox.put('weatherData', response.data);
          await lastCityBox.put('cityName', cityName);
          await weatherBox.put(
            'lastUpdateTime',
            now.toIso8601String(),
          );
          await weatherBox.put('lat', event.position.latitude);
          await weatherBox.put('lon', event.position.longitude);

          emit(WeatherSuccess(response.data, cityName));
        } else {
          // Serve data from cache if no update is needed
          emit(WeatherSuccess(cachedData, cachedCity));
        }
      } on DioException catch (e) {
        // Handle network errors by serving cached data if available
        print("Dio Error: $e");
        final cachedData = weatherBox.get('weatherData');
        final cachedCity = lastCityBox.get('cityName');

        if (cachedData != null && cachedCity != null) {
          // Return cached data even during network failure
          emit(WeatherSuccess(cachedData, cachedCity));
        } else {
          // No cached data and no network connection
          emit(const WeatherError("No internet connection and no cached data"));
        }
      } catch (e) {
        print("Unexpected Error: $e");
        emit(WeatherError("Unexpected Error: $e"));
      }
    });
  }
}
