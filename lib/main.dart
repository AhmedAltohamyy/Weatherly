import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:weatherly/bloc/weather_bloc.dart';
import 'package:weatherly/data/location_data.dart';
import 'package:weatherly/pages/days_weather_page.dart';
import 'package:weatherly/pages/homepage.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:weatherly/utils/theme.dart';

/// Entry point of the application. Initializes Hive database boxes and sets up the BLoC.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  // Initialize Hive boxes for persistent data storage
  await Hive.openBox("settings"); // Stores user preferences (theme, temperature unit)
  await Hive.openBox("weatherBox"); // Caches weather data to reduce API calls
  await Hive.openBox("lastCity"); // Stores last known location coordinates

  runApp(
    BlocProvider(create: (context) => WeatherBloc(), child: const MyApp()),
  );
}

/// Root widget of the application that manages theme and location initialization
class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Position? _currentPosition; // Stores the device's current geographic position

  @override
  void initState() {
    super.initState();
    _fetchLocationInBackground();
  }

  /// Asynchronously fetches device location without blocking the UI
  void _fetchLocationInBackground() {
    determinePosition().then((position) {
      if (mounted) {
        setState(() {
          _currentPosition = position;
        });
      }
    }).catchError((e) {
      if (mounted) {
        print('Error fetching location: $e');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Use ValueListenableBuilder to reactively update theme when settings change
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
          home: Homepage(position: _currentPosition),
        );
      },
    );
  }
}
