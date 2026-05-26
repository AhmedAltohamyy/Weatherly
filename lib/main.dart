// lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:weatherly/bloc/weather_bloc.dart';
import 'package:weatherly/data/location_data.dart';
import 'package:weatherly/pages/days_weather_page.dart';
import 'package:weatherly/pages/homepage.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:weatherly/utils/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox("settings");
  await Hive.openBox("weatherBox");
  await Hive.openBox("lastCity");

  runApp(
    // نقوم بتغليف التطبيق بالكامل بالـ BlocProvider هنا
    BlocProvider(create: (context) => WeatherBloc(), child: const MyApp()),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late Future<Position> _locationFuture;

  @override
  void initState() {
    super.initState();
    _locationFuture = determinePosition();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Box>(
      valueListenable: Hive.box('settings').listenable(),
      builder: (context, value, child) {
        final isDarkMode = Hive.box(
          "settings",
        ).get("darkMode", defaultValue: false);

        return MaterialApp(
          theme: lightTheme,
          darkTheme: darkTheme,
          themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
          debugShowCheckedModeBanner: false,
          title: 'Weatherly',
          // الآن أي صفحة داخل MaterialApp ستتمكن من الوصول لـ WeatherBloc
          home: FutureBuilder<Position>(
            future: _locationFuture,
            builder: (context, snap) {
              if (snap.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  backgroundColor: Colors.black,
                  body: Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  ),
                );
              } else if (snap.hasError) {
                return Scaffold(
                  backgroundColor: Colors.black,
                  body: Center(
                    child: Text(
                      'Error: ${snap.error}',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                );
              } else if (snap.hasData) {
                // أعدنا الـ Homepage لتكون هي الأساسية كما طلبت سابقاً
                return Homepage(position: snap.data!);
              }
              return const Scaffold(
                body: Center(child: Text('Something went wrong')),
              );
            },
          ),
        );
      },
    );
  }
}
