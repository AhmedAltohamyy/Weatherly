// ignore_for_file: deprecated_member_use

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:weatherly/bloc/weather_bloc.dart';
import 'package:weatherly/bloc/weather_event.dart';
import 'package:weatherly/bloc/weather_state.dart';
import 'package:weatherly/components/hourly_card.dart';
import 'package:weatherly/components/weather_detail_block.dart';
import 'package:weatherly/pages/days_weather_page.dart';
import 'package:weatherly/pages/settings_page.dart';
import 'package:weatherly/utils/weather_helper.dart';

/// Home page displaying current weather and hourly forecast
/// Shows location, temperature, weather condition, and detailed weather metrics
class Homepage extends StatefulWidget {
  final Position? position; // Device's geographic position
  const Homepage({super.key, this.position});

  @override
  HomepageState createState() => HomepageState();
}

class HomepageState extends State<Homepage> {
  final Box settings = Hive.box('settings');

  @override
  void initState() {
    super.initState();
    // Trigger weather fetch when position is available
    if (widget.position != null) {
      context.read<WeatherBloc>().add(FetchWeather(position: widget.position!, update: true));
    }
  }

  /// Listen for location updates from parent widget
  @override
  void didUpdateWidget(covariant Homepage oldWidget) {
    super.didUpdateWidget(oldWidget);
    // If position becomes available (was null, now has value), fetch weather
    if (oldWidget.position == null && widget.position != null) {
      context.read<WeatherBloc>().add(
            FetchWeather(position: widget.position!, update: true),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    String Degree = settings.get('degree', defaultValue: "celsius");
    String currentUnit = Degree == "celsius" ? "°C" : "°F";

    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        // Calendar icon - navigate to daily forecast page
        leading: IconButton(
          icon: const Icon(Icons.calendar_month, color: Colors.white),
          onPressed: () {
            if (widget.position != null) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      ForecastPage(position: widget.position!),
                ),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Location loading, try again...')),
              );
            }
          },
        ),
        actions: [
          // Settings icon - open settings page
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SettingsPage(position: widget.position!)),
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        color: Colors.blueAccent,
        backgroundColor: Colors.white,
        // Pull-to-refresh functionality to manually update weather
        onRefresh: () async {
          context.read<WeatherBloc>().add(
            FetchWeather(position: widget.position!, update: true),
          );
          await Future.delayed(const Duration(seconds: 1));
        },
        child: SingleChildScrollView(
          physics:
              const AlwaysScrollableScrollPhysics(),

          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height,
            ),
            // Gradient background with blurred decorative shapes
            child: Stack(
              children: [
                // Decorative blurred circles for visual effect
                Align(
                  alignment: const AlignmentDirectional(2.5, -0.5),
                  child: Container(
                    height: 500,
                    width: 300,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.deepPurple,
                    ),
                  ),
                ),
                Align(
                  alignment: const AlignmentDirectional(-2.5, -0.5),
                  child: Container(
                    height: 500,
                    width: 300,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.deepPurple,
                    ),
                  ),
                ),
                Align(
                  alignment: const AlignmentDirectional(0, -1.2),
                  child: Container(
                    height: 300,
                    width: 600,
                    decoration: const BoxDecoration(color: Colors.orange),
                  ),
                ),
                // Backdrop blur effect for depth
                BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 100, sigmaY: 100),
                  child: Container(
                    decoration: const BoxDecoration(color: Colors.transparent),
                  ),
                ),
                // Main content column
                Padding(
                  padding: const EdgeInsets.only(
                    top: 100.0,
                    left: 40,
                    right: 40,
                    bottom: 40,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Current city/location display
                      BlocBuilder<WeatherBloc, WeatherState>(
                        builder: (context, state) {
                          return Text(
                            "📍 ${state is WeatherSuccess ? state.cityName : "Fetching city"}",
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w300,
                            ),
                          );
                        },
                      ),

                      // Dynamic weather image based on current weather code and day/night
                      Center(
                        child: BlocSelector<WeatherBloc, WeatherState, List?>(
                          selector: (state) {
                            if (state is WeatherSuccess) {
                              return [
                                state.weatherData['current']['weather_code'],
                                state.weatherData['current']['is_day'],
                              ];
                            }
                            return [0, 1];
                          },
                          builder: (context, weatherCode) {
                            String imagePath = getWeatherImagePath(
                              weatherCode?[0].toInt(),
                              weatherCode?[1].toInt(),
                            );
                            return Image.asset(
                              imagePath,
                              height: 200,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) =>
                                  const SizedBox(
                                    height: 150,
                                    child: Icon(
                                      Icons.cloud,
                                      color: Colors.white,
                                      size: 100,
                                    ),
                                  ),
                            );
                          },
                        ),
                      ),

                      // Current temperature display
                      Center(
                        child: BlocSelector<WeatherBloc, WeatherState, String>(
                          selector: (state) {
                            if (state is WeatherSuccess) {
                              return "${state.weatherData['current']?['temperature_2m'] ?? '--'}$currentUnit";
                            }
                            return "--";
                          },
                          builder: (context, temp) {
                            return Text(
                              temp,
                              style: const TextStyle(
                                fontSize: 55,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            );
                          },
                        ),
                      ),

                      // Current date and time - updates every minute
                      StreamBuilder<DateTime>(
                        stream: Stream.periodic(
                          const Duration(minutes: 1),
                          (_) => DateTime.now(),
                        ),
                        initialData: DateTime.now(),
                        builder: (context, snap) {
                          String formattedDate = DateFormat(
                            'EEEE d MMMM - h:mm a',
                          ).format(DateTime.now());
                          return Center(
                            child: Text(
                              formattedDate,
                              style: const TextStyle(
                                color: Colors.grey,
                                fontWeight: FontWeight.w300,
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 20),
                      // Hourly forecast section
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: EdgeInsets.only(left: 10, bottom: 10),
                          child: Text(
                            "Hourly Forecast",
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      BlocBuilder<WeatherBloc, WeatherState>(
                        builder: (context, state) {
                          if (state is WeatherSuccess) {
                            return hourlyForecast(state);
                          }
                          // Skeleton loader while fetching data
                          return SizedBox(
                            height: 120,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: 5,
                              itemBuilder: (context, index) {
                                return Container(
                                  width: 75,
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(
                                      0.08,
                                    ),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: Colors.white.withOpacity(0.1),
                                    ),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 15),
                      // Sunrise and Sunset times
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          WeatherDetailBlock('assets/images/11.png', "Sunrise", (
                            state,
                          ) {
                            if (state is WeatherSuccess) {
                              final time =
                                  state.weatherData['daily']?['sunrise']?[0];
                              if (time == null) return "--:--";
                              final date = DateTime.parse(time);
                              return "${date.hour}:${date.minute.toString().padLeft(2, "0")}";
                            }
                            return "Loading...";
                          }),
                          WeatherDetailBlock('assets/images/12.png', "Sunset", (
                            state,
                          ) {
                            if (state is WeatherSuccess) {
                              final time =
                                  state.weatherData['daily']?['sunset']?[0];
                              if (time == null) return "--:--";
                              final date = DateTime.parse(time);
                              return "${date.hour}:${date.minute.toString().padLeft(2, "0")}";
                            }
                            return "Loading...";
                          }),
                        ],
                      ),

                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 5),
                        child: Divider(color: Colors.grey),
                      ),
                      // Max and Min temperatures
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          WeatherDetailBlock('assets/images/13.png', "Temp Max", (
                            state,
                          ) {
                            if (state is WeatherSuccess) {
                              return "${state.weatherData['daily']?['temperature_2m_max']?[0] ?? '--'}$currentUnit";
                            }
                            return "Loading...";
                          }),
                          WeatherDetailBlock('assets/images/14.png', "Temp Min", (
                            state,
                          ) {
                            if (state is WeatherSuccess) {
                              return "${state.weatherData['daily']?['temperature_2m_min']?[0] ?? '--'}$currentUnit";
                            }
                            return "Loading...";
                          }),
                        ],
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 5),
                        child: Divider(color: Colors.grey),
                      ),
                      // Humidity display
                      Row(
                        mainAxisAlignment: MainAxisAlignment
                            .center,
                        children: [
                          WeatherDetailBlock('assets/images/1.png', "Humidity", (
                            state,
                          ) {
                            if (state is WeatherSuccess) {
                              return "${state.weatherData['current']?['relative_humidity_2m'] ?? '--'}%";
                            }
                            return "Loading...";
                          }),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
