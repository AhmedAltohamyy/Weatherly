// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:weatherly/bloc/weather_state.dart';
import 'package:weatherly/utils/weather_helper.dart';

/// Builds a horizontal scrollable list of hourly weather forecasts
/// Shows temperature, weather condition, and time for the next 24 hours
/// 
/// [state]: WeatherSuccess state containing hourly weather data from the API
Widget hourlyForecast(WeatherSuccess state) {
  final Box settings = Hive.box('settings');

  // Get user's preferred temperature unit
  String Degree = settings.get('degree', defaultValue: "celsius");
  String currentUnit = Degree == "celsius" ? "°C" : "°F";

  final hourlyData = state.weatherData['hourly'];
  if (hourlyData == null) return const SizedBox.shrink();

  // Extract hourly data arrays from API response
  final List<dynamic> times = hourlyData['time'] ?? [];
  final List<dynamic> temps = hourlyData['temperature_2m'] ?? [];
  final List<dynamic> codes = hourlyData['weather_code'] ?? [];
  final List<dynamic> isDay = hourlyData['is_day'] ?? [];

  // Limit display to 24 hours (or less if fewer available)
  final int itemCount = times.length > 24 ? 24 : times.length;

  return SizedBox(
    height: 120,
    child: ListView.builder(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        // Parse time string and format as "2 AM", "3 PM", etc.
        final String timeStr = times[index].toString();
        final DateTime dateTime = DateTime.parse(timeStr);
        final String hourFormatted = DateFormat('ha').format(dateTime);

        final dynamic temp = temps[index];
        final int code = codes.isNotEmpty ? (codes[index] as num).toInt() : 0;

        return Container(
          width: 75,
          margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.08),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Hour display (e.g., "2 AM")
              Text(
                hourFormatted,
                style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w500),
              ),
              // Weather icon for this hour
              Image.asset(
                getWeatherImagePath(code, isDay[index].toInt()),
                width: 32,
                height: 32,
              ),
              // Temperature for this hour
              Text(
                "${temp.toString()}$currentUnit",
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ],
          ),
        );
      },
    ),
  );
}