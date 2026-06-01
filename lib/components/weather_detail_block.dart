import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:weatherly/bloc/weather_bloc.dart';
import 'package:weatherly/bloc/weather_state.dart';

/// Widget that displays weather detail information with an icon, title, and dynamic value
/// Used to display metrics like sunrise, sunset, temperature, humidity, etc.
/// 
/// [imagePath]: Path to the weather icon asset
/// [title]: Label for the metric (e.g., "Sunrise", "Humidity")
/// [selectorLogic]: Function that extracts the display value from WeatherState
// ignore: non_constant_identifier_names
Widget WeatherDetailBlock(
  String imagePath,
  String title,
  String Function(WeatherState) selectorLogic,
) {
  return Row(
    children: [
      // Weather icon
      Image.asset(
        imagePath,
        scale: 8,
        errorBuilder: (context, error, stackTrace) =>
            const Icon(Icons.wb_sunny, color: Colors.amber),
      ),
      const SizedBox(width: 5),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Metric title
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w300,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 3),
          // Dynamic value that reactively updates when weather state changes
          BlocSelector<WeatherBloc, WeatherState, String>(
            selector: selectorLogic,
            builder: (context, value) {
              return Text(
                value,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              );
            },
          ),
        ],
      ),
    ],
  );
}
