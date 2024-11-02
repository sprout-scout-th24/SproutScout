import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:sproutscout/models/plant.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(PlantAdapter()); // Register your Plant adapter
  await Hive.openBox<Plant>('plants'); // Open a box to store Plant objects
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Moisture Monitor',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MoistureMonitor(),
    );
  }
}

class MoistureMonitor extends StatefulWidget {
  @override
  _MoistureMonitorState createState() => _MoistureMonitorState();
}

class _MoistureMonitorState extends State<MoistureMonitor> {
  String moistureStatus = 'Unknown';
  final Box<Plant> plantBox = Hive.box<Plant>('plants');

  Future<void> fetchMoisture() async {
    final response = await http.get(Uri.parse('http://192.168.187.57:5000/moisture'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      bool isMoistureHigh = data['moisture_status'] == 'high'; // Adjust based on your API response

      // Update the moisture status
      setState(() {
        moistureStatus = data['moisture_status'];
      });

      // Save or update the plant information
      final plantName = 'Your Plant Name'; // Replace with the actual plant name or fetch it dynamically
      final currentTime = DateTime.now();

      // Check if plant already exists
      if (plantBox.isNotEmpty) {
        Plant existingPlant = plantBox.getAt(0)!; // Get the first plant (assuming one for simplicity)
        existingPlant.lastWetTime = currentTime;
        existingPlant.isMoistureHigh = isMoistureHigh;
        plantBox.putAt(0, existingPlant);
      } else {
        // Create a new plant
        Plant newPlant = Plant(
          name: plantName,
          lastWetTime: currentTime,
          isMoistureHigh: isMoistureHigh,
        );
        await plantBox.add(newPlant); // Add new plant to the box
      }
    } else {
      throw Exception('Failed to load moisture data');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchMoisture(); // Fetch data initially
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Soil Moisture Monitor')),
      body: Center(
        child: Text(
          'Moisture Status: $moistureStatus',
          style: TextStyle(fontSize: 24),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: fetchMoisture,  // Fetch data when button is pressed
        tooltip: 'Refresh',
        child: Icon(Icons.refresh),
      ),
    );
  }
}