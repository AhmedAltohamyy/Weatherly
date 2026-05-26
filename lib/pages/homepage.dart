// مسار الملف: lib/pages/homepage.dart

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:weatherly/bloc/weather_bloc.dart';
import 'package:weatherly/bloc/weather_event.dart';
import 'package:weatherly/bloc/weather_state.dart';
import 'package:weatherly/components/weather_detail_block.dart';
import 'package:weatherly/pages/days_weather_page.dart';
import 'package:weatherly/pages/settings_page.dart';
import 'package:weatherly/utils/weather_helper.dart'; // استدعاء الهيلبر

class Homepage extends StatefulWidget {
  final Position position; 
  const Homepage({super.key, required this.position});

  @override
  HomepageState createState() => HomepageState();
}

class HomepageState extends State<Homepage> {
  @override
  void initState() {
    super.initState();
    context.read<WeatherBloc>().add(FetchWeather(position: widget.position));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        // زر الانتقال لصفحة الأيام (Forecast)
        leading: IconButton(
          icon: const Icon(Icons.calendar_month, color: Colors.white),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ForecastPage(position: widget.position)),
            );
          },
        ),
        // زر الانتقال لصفحة الإعدادات
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsPage()),
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        color: Colors.blueAccent,
        backgroundColor: Colors.white,
        onRefresh: () async {
          context.read<WeatherBloc>().add(
            FetchWeather(position: widget.position, update: true),
          );
          await Future.delayed(const Duration(seconds: 1));
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(), // ضروري ليعمل التحديث بالسحب
          child: SizedBox(
            // لضمان ملء الشاشة وتفعيل الـ Stack
            height: MediaQuery.of(context).size.height,
            child: Stack(
              children: [
                Align(
                  alignment: const AlignmentDirectional(2.5, -0.5),
                  child: Container(
                    height: 500, width: 300,
                    decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.deepPurple),
                  ),
                ),
                Align(
                  alignment: const AlignmentDirectional(-2.5, -0.5),
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
                Padding(
                  padding: const EdgeInsets.only(top: 100.0, left: 40, right: 40, bottom: 40),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      BlocBuilder<WeatherBloc, WeatherState>(
                        builder: (context, state) {
                          return Text(
                            "📍 ${state is WeatherSuccess ? state.cityName : "Fetching city"}",
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w300),
                          );
                        },
                      ),
                      
                      // الصورة تتغير ديناميكياً بناءً على كود الطقس
                      Center(
                        child: BlocSelector<WeatherBloc, WeatherState, int?>(
                          selector: (state) {
                            if (state is WeatherSuccess) {
                              return state.weatherData['current']['weather_code'];
                            }
                            return 0;
                          },
                          builder: (context, weatherCode) {
                            // استخدام الدالة الجديدة لجلب مسار الصورة
                            String imagePath = getWeatherImagePath(weatherCode!.toInt());
                            return Image.asset(
                              imagePath,
                              height: 200,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) =>
                                  const SizedBox(
                                    height: 150,
                                    child: Icon(Icons.cloud, color: Colors.white, size: 100),
                                  ),
                            );
                          },
                        ),
                      ),
                      
                      Center(
                        child: BlocSelector<WeatherBloc, WeatherState, String>(
                          selector: (state) {
                            if (state is WeatherSuccess) {
                              return "${state.weatherData['current']?['temperature_2m'] ?? '--'}";
                            }
                            return "--";
                          },
                          builder: (context, temp) {
                            return Text(
                              "$temp°C",
                              style: const TextStyle(fontSize: 55, fontWeight: FontWeight.bold, color: Colors.white),
                            );
                          },
                        ),
                      ),
                      
                      StreamBuilder<DateTime>(
                        stream: Stream.periodic(const Duration(minutes: 1), (_) => DateTime.now()),
                        initialData: DateTime.now(),
                        builder: (context, snap) {
                          String formattedDate = DateFormat('EEEE d MMMM - h:mm a').format(DateTime.now());
                          return Center(
                            child: Text(
                              formattedDate,
                              style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.w300),
                            ),
                          );
                        }
                      ),
                      const Spacer(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          WeatherDetailBlock('assets/images/11.png', "Sunrise", (state) {
                            if (state is WeatherSuccess) {
                              final time = state.weatherData['daily']?['sunrise']?[0];
                              if (time == null) return "--:--";
                              final date = DateTime.parse(time);
                              return "${date.hour}:${date.minute.toString().padLeft(2, "0")}";
                            }
                            return "Loading...";
                          }),
                          WeatherDetailBlock('assets/images/12.png', "Sunset", (state) {
                            if (state is WeatherSuccess) {
                              final time = state.weatherData['daily']?['sunset']?[0];
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          WeatherDetailBlock('assets/images/13.png', "Temp Max", (state) {
                            if (state is WeatherSuccess) {
                              return "${state.weatherData['daily']?['temperature_2m_max']?[0] ?? '--'}°C";
                            }
                            return "Loading...";
                          }),
                          WeatherDetailBlock('assets/images/14.png', "Temp Min", (state) {
                            if (state is WeatherSuccess) {
                              return "${state.weatherData['daily']?['temperature_2m_min']?[0] ?? '--'}°C";
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