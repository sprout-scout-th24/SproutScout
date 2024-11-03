import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sproutscout/models/plant.dart';
import 'package:sproutscout/pages/plant_details.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  String moistureStatus = 'Unknown';
  final Box<Plant> plantBox = Hive.box<Plant>('plants');

  Future<void> fetchMoisture() async {
    final response =
        await http.get(Uri.parse('http://raspberrypi.local:5000/moisture'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      bool isMoistureHigh = data['moisture_status'] == 'high';

      setState(() {
        moistureStatus = data['moisture_status'];
      });

      const plantName = 'Your Plant Name';
      final currentTime = DateTime.now();

      if (plantBox.isNotEmpty) {
        Plant existingPlant = plantBox.getAt(0)!;
        existingPlant.lastWetTime = currentTime;
        existingPlant.isMoistureHigh = isMoistureHigh;
        plantBox.putAt(0, existingPlant);
      } else {
        Plant newPlant = Plant(
          name: plantName,
          lastWetTime: currentTime,
          isMoistureHigh: isMoistureHigh,
        );
        await plantBox.add(newPlant);
      }
    } else {
      throw Exception('Failed to load moisture data');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchMoisture(); // Initial fetch on start
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sprout Scout'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: fetchMoisture, // Call fetchMoisture on button press
            tooltip: 'Refresh Moisture Data',
          ),
        ],
      ),
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
                      builder: (context) => PlantDetailPage(
                        plant: plants[index],
                        index: index,
                        onDelete: () {
                          setState(() {}); // Refresh the ListView
                        },
                      ),
                    ),
                  );
                },
              );
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
            decoration: const InputDecoration(
              labelText: 'Name your plant!',
              labelStyle: TextStyle(color: Colors.grey),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.green),
              ),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.grey),
              ),
              floatingLabelStyle: TextStyle(color: Colors.green),
            ),
            style: const TextStyle(color: Colors.black),
          ),
          actions: [
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: Colors.red[600],
              ),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: Colors.green[600],
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
}
