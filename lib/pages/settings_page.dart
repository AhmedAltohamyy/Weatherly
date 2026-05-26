import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  SettingsPageState createState() => SettingsPageState();
}

class SettingsPageState extends State<SettingsPage> {
  // Access the Hive boxes for settings and data management
  final Box settings = Hive.box('settings');

  bool notf = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
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
            const Text(
              " Appearance",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Card(
              child: ListTile(
                title: const Text('Theme'),
                subtitle: const Text('Light or Dark Theme'),
                // Update icon dynamically based on current theme status
                leading: settings.get('darkMode', defaultValue: false)
                    ? const Icon(Icons.dark_mode)
                    : const Icon(Icons.light_mode),
                trailing: Switch(
                  value: settings.get('darkMode', defaultValue: false),
                  onChanged: (value) {
                    setState(() {
                      // Save theme preference to Hive
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
            const Text(
              " Degree",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const Card(
              child: ListTile(
                leading: Icon(Icons.thermostat_auto_outlined),
                title: Text('Degree'),
                trailing: Text('Celisius'),
              ),
            ),
            const SizedBox(height: 25),
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