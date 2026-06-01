import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:weatherly/bloc/weather_bloc.dart';
import 'package:weatherly/bloc/weather_event.dart';
import 'package:weatherly/bloc/weather_state.dart';
import 'package:weatherly/components/forecast_card.dart';
import 'package:weatherly/utils/weather_helper.dart';

/// Represents a single day of forecast data shown in the forecast list.
class ForecastData {
  final String dayName;
  final String date;
  final int maxTemp;
  final int minTemp;
  final String weatherImage;
  final String sunrise;
  final String sunset;

  ForecastData({
    required this.dayName,
    required this.date,
    required this.maxTemp,
    required this.minTemp,
    required this.weatherImage,
    required this.sunrise,
    required this.sunset,
  });
}

/// A screen that shows the 7-day weather forecast for the given position.
///
/// This screen listens to the WeatherBloc and renders loading, error, or
/// forecast views depending on the current state.
class ForecastPage extends StatefulWidget {
  final Position position;
  const ForecastPage({super.key, required this.position});

  @override
  State<ForecastPage> createState() => _ForecastPageState();
}

class _ForecastPageState extends State<ForecastPage> {
  @override
  void initState() {
    super.initState();
    context.read<WeatherBloc>().add(
      FetchWeather(position: widget.position, update: false),
    );
  }

  /// Converts an ISO8601 timestamp to a 12-hour clock string.
  String _formatTime(String isoTime) {
    try {
      final dateTime = DateTime.parse(isoTime);
      final hour = dateTime.hour;
      final minute = dateTime.minute.toString().padLeft(2, '0');
      final period = hour >= 12 ? 'PM' : 'AM';
      final formattedHour = hour % 12 == 0 ? 12 : hour % 12;
      return "${formattedHour.toString().padLeft(2, '0')}:$minute $period";
    } catch (e) {
      return "--:--";
    }
  }


  @override
  Widget build(BuildContext context) {
    // The page uses a stacked layout with decorative background shapes and
    // a content layer rendered on top of a blurred visual effect.
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Stack(
        children: [
          // Decorative background shapes used to create a custom gradient-like
          // ambient glow behind the forecast content.
          Align(
            alignment: const AlignmentDirectional(2.4, 0.5),
            child: Container(
              height: 500, width: 300,
              decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.deepPurple),
            ),
          ),
          Align(
            alignment: const AlignmentDirectional(-2.4, 0.5),
            child: Container(
              height: 500, width: 300,
              decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.deepPurple),
            ),
          ),
          Align(
            alignment: const AlignmentDirectional(0, -1.2),
            child: Container(
              height: 300, width: 600,
              decoration: const BoxDecoration(color: Colors.orange),
            ),
          ),

          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 100, sigmaY: 100),
            child: Container(decoration: const BoxDecoration(color: Colors.transparent)),
          ),

          SafeArea(
            child: BlocBuilder<WeatherBloc, WeatherState>(
              builder: (context, state) {
                // Display a different UI depending on the current weather state.
                if (state is WeatherLoading || state is WeatherInitial) {
                  return const Center(child: CircularProgressIndicator(color: Colors.white));
                } else if (state is WeatherError) {
                  return Center(
                    child: Text(
                      state.message,
                      style: const TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  );
                } else if (state is WeatherSuccess) {
                  final daily = state.weatherData['daily'];
                  final List times = daily['time'] ?? [];
                  final List weatherCodes = daily['weather_code'] ?? [];
                  final List maxTemps = daily['temperature_2m_max'] ?? [];
                  final List minTemps = daily['temperature_2m_min'] ?? [];
                  final List sunrises = daily['sunrise'] ?? [];
                  final List sunsets = daily['sunset'] ?? [];

                  // Transform raw daily arrays into a list of ForecastData objects.
                  final List<ForecastData> forecastList = List.generate(
                    times.length,
                    (index) {
                      final DateTime date = DateTime.parse(times[index]);
                      final List<String> weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                      final now = DateTime.now();
                      final isToday = date.year == now.year && date.month == now.month && date.day == now.day;
                      final appearance = getWeatherImagePath(weatherCodes[index].toInt(), 1);
                      print(date);

                      return ForecastData(
                        dayName: isToday ? "Today" : weekdays[date.weekday - 1],
                        date: "${date.day}/${date.month}",
                        maxTemp: (maxTemps[index] as num).round(),
                        minTemp: (minTemps[index] as num).round(),
                        weatherImage: appearance,
                        sunrise: _formatTime(sunrises[index]),
                        sunset: _formatTime(sunsets[index]),
                      );
                    },
                  );

                  return RefreshIndicator(
                    color: Colors.blueAccent,
                    backgroundColor: Colors.white,
                    // Allow the user to pull down to refresh the forecast data.
                    onRefresh: () async {
                      context.read<WeatherBloc>().add(
                        FetchWeather(position: widget.position, update: true),
                      );
                      await Future.delayed(const Duration(seconds: 1));
                    },
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: EdgeInsets.zero,
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(left: 24.0, top: 20.0, bottom: 20.0),
                          child: Text(
                            "Daily Forecast",
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ),
                        SizedBox(
                          height: MediaQuery.sizeOf(context).height * 0.65,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            physics: const BouncingScrollPhysics(),
                            padding: const EdgeInsets.symmetric(horizontal: 16.0),
                            itemCount: forecastList.length,
                            itemBuilder: (context, index) {
                              return ForecastCard(data: forecastList[index]);
                            },
                          ),
                        ),
                      ],
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }
}