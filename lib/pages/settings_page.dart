import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hive/hive.dart';
import 'package:weatherly/bloc/weather_bloc.dart';
import 'package:weatherly/bloc/weather_event.dart';

/// Settings page for user preferences including theme, temperature unit, and notifications
class SettingsPage extends StatefulWidget {
  final Position position;
  const SettingsPage({super.key, required this.position});

  @override
  SettingsPageState createState() => SettingsPageState();
}

class SettingsPageState extends State<SettingsPage> {
  // Hive box for persisting user settings across app sessions
  final Box settings = Hive.box('settings');

  bool notf = false; // Notification preference toggle

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // Get current temperature unit setting from Hive storage
    final String Degree = settings.get('degree', defaultValue: "celsius");
    final String currentUnit = Degree == "celsius" ? "Celsius" : "Fahrenheit";

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Settings",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(5),
        child: ListView(
          children: [
            const SizedBox(height: 10),
            // === APPEARANCE SECTION ===
            const Text(
              " Appearance",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Card(
              child: ListTile(
                title: const Text('Theme'),
                subtitle: const Text('Light or Dark Theme'),
                leading: settings.get('darkMode', defaultValue: false)
                    ? const Icon(Icons.dark_mode)
                    : const Icon(Icons.light_mode),
                // Toggle between light and dark themes
                trailing: Switch(
                  value: settings.get('darkMode', defaultValue: false),
                  onChanged: (value) {
                    setState(() {
                      settings.put('darkMode', value);
                    });
                  },
                  activeColor: Colors.white,
                  inactiveThumbColor: Colors.white,
                  inactiveTrackColor: Colors.grey[200],
                ),
              ),
            ),
            const SizedBox(height: 25),

            // === TEMPERATURE UNIT SECTION ===
            const Text(
              " Degree",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Card(
              child: ListTile(
                leading: const Icon(Icons.thermostat_auto_outlined),
                title: const Text('Degree'),
                subtitle: Text('Current: $currentUnit'),

                // Popup menu to select temperature unit (Celsius or Fahrenheit)
                trailing: PopupMenuButton<String>(
                  initialValue: Degree,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        currentUnit,
                        style: const TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Icon(Icons.arrow_drop_down, color: Colors.blue),
                    ],
                  ),
                  onSelected: (String value) {
                    // Refresh weather data when temperature unit changes
                    context.read<WeatherBloc>().add(
                      FetchWeather(position: widget.position, update: true),
                    );

                    setState(() {
                      settings.put('degree', value);
                    });
                  },
                  itemBuilder: (BuildContext context) =>
                      <PopupMenuEntry<String>>[
                        const PopupMenuItem<String>(
                          value: "celsius",
                          child: Text('Celsius (°C)'),
                        ),
                        const PopupMenuItem<String>(
                          value: "fahrenheit",
                          child: Text('Fahrenheit (°F)'),
                        ),
                      ],
                ),
              ),
            ),

            const SizedBox(height: 25),
            // === NOTIFICATIONS SECTION ===
            const Text(
              " Notifications",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Card(
              child: ListTile(
                leading: const Icon(Icons.notifications),
                title: const Text('Notifications'),
                subtitle: const Text('Allow notifications'),
                trailing: Switch(
                  value: notf,
                  onChanged: (value) {
                    setState(() {
                      notf = value;
                    });
                  },
                  activeColor: Colors.blue,
                  inactiveThumbColor: Colors.grey,
                  inactiveTrackColor: Colors.grey[300],
                ),
              ),
            ),
            const SizedBox(height: 25),
            // === ABOUT SECTION ===
            const Text(
              " About",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Card(
              child: ListTile(
                leading: const Icon(Icons.help_outline),
                title: const Text('Help & Support'),
                onTap: () {},
              ),
            ),
            Card(
              child: ListTile(
                leading: const Icon(Icons.privacy_tip_outlined),
                title: const Text('Privacy Policy'),
                onTap: () {},
              ),
            ),
            const Card(
              child: ListTile(
                leading: Icon(Icons.info_outline),
                title: Text('App Version'),
                trailing: Text('1.1.3'),
              ),
            ),
            const Card(
              child: ListTile(
                leading: Icon(Icons.person_outline),
                title: Text('Developer'),
                subtitle: Text('Ahmed Khaled'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
