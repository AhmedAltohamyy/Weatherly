// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:weatherly/pages/days_weather_page.dart';

/// Displays a card with daily forecast including:
/// - Day name and date
/// - Weather icon
/// - Max and min temperatures
/// - Sunrise and sunset times
/// 
/// Used in horizontal scrollable list on the ForecastPage
class ForecastCard extends StatelessWidget {
  final ForecastData data;

  const ForecastCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      margin: const EdgeInsets.only(right: 20.0, top: 20.0, bottom: 40.0),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white.withOpacity(0.2), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // Day name and date (e.g., "Monday, 15/12")
            Text(
              "${data.dayName}, ${data.date}",
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w500,
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 20),
            // Weather icon for the day
            Expanded(
              child: FittedBox(
                fit: BoxFit.contain,
                child: Image.asset(data.weatherImage),
              ),
            ),
            const SizedBox(height: 20),
            // Temperature display with max in large text and min below
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "${data.maxTemp}°",
                  style: const TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 8),
                Padding(
                  padding: const EdgeInsets.only(top: 12.0),
                  child: Text(
                    "/${data.minTemp}°",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w500,
                      color: Colors.white.withOpacity(0.6),
                    ),
                  ),
                ),
              ],
            ),
            const Divider(color: Colors.white30, height: 40, thickness: 1),
            // Sunrise and sunset times
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildSunInfo(Icons.wb_twilight, "Sunrise", data.sunrise),
                _buildSunInfo(Icons.nightlight_round, "Sunset", data.sunset),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Helper widget to display sunrise/sunset information
  /// Shows icon, label, and time in a column
  Widget _buildSunInfo(IconData icon, String label, String time) {
    return Column(
      children: [
        Icon(icon, color: Colors.amberAccent, size: 28),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 14),
        ),
        const SizedBox(height: 4),
        Text(
          time,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}