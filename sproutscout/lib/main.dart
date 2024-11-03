import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:sproutscout/models/plant.dart';
import 'package:sproutscout/pages/plant_details.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(PlantAdapter()); // Register your Plant adapter
  await Hive.openBox<Plant>('plants'); // Open a box to store Plant objects
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Moisture Monitor',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: const MoistureMonitor(),
    );
  }
}

class MoistureMonitor extends StatefulWidget {
  const MoistureMonitor({super.key});

  @override
  MoistureMonitorState createState() => MoistureMonitorState();
}

class MoistureMonitorState extends State<MoistureMonitor> {
  String moistureStatus = 'Unknown';
  final Box<Plant> plantBox = Hive.box<Plant>('plants');

  Future<void> fetchMoisture() async {
    final response =
        await http.get(Uri.parse('http://192.168.187.57:5000/moisture'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      bool isMoistureHigh = data['moisture_status'] ==
          'high'; // Adjust based on your API response

      // Update the moisture status
      setState(() {
        moistureStatus = data['moisture_status'];
      });

      // Save or update the plant information
      const plantName =
          'Your Plant Name'; // Replace with the actual plant name or fetch it dynamically
      final currentTime = DateTime.now();

      // Check if plant already exists
      if (plantBox.isNotEmpty) {
        Plant existingPlant = plantBox
            .getAt(0)!; // Get the first plant (assuming one for simplicity)
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

  Future<void> _addPlant(String name) async {
    final newPlant = Plant(
      name: name,
      lastWetTime: DateTime.now(),
      isMoistureHigh: false,
    );
    await plantBox.add(newPlant);
    setState(() {}); // Refreshes the UI to display the new plant
  }

  void _showAddPlantDialog() {
    final plantNameController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Plant'),
          content: TextField(
            controller: plantNameController,
            decoration: const InputDecoration(labelText: 'Name your plant!'),
          ),
          actions: [
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: Colors.red[900],
              ),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: Colors.green[900],
              ),
              onPressed: () {
                final plantName = plantNameController.text;
                if (plantName.isNotEmpty) {
                  _addPlant(plantName); // Add plant to box
                  Navigator.of(context).pop(); // Close the dialog
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    fetchMoisture(); // Fetch data initially
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sprout Scout')),
      body: FutureBuilder<Box<Plant>>(
        future: Hive.openBox<Plant>('plants'),
        builder: (context, AsyncSnapshot<Box<Plant>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No plants added yet!'));
          }

          final box = snapshot.data!;
          final plants = box.values.toList();

          return ListView.builder(
            itemCount: plants.length,
            itemBuilder: (context, index) {
              return ListTile(
                  title: Text(plants[index].name),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            PlantDetailPage(plant: plants[index]),
                      ),
                    );
                  });
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddPlantDialog,
        tooltip: 'Add Plant',
        backgroundColor: Colors.green[100],
        foregroundColor: Colors.green[900],
        child: const Icon(Icons.add),
      ),
    );
  }
}
