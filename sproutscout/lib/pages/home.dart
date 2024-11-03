import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:sproutscout/helpers/boxes.dart';
import 'package:sproutscout/main.dart';
import 'package:sproutscout/models/plant.dart';
import 'package:sproutscout/models/plant_type.dart';
import 'package:sproutscout/pages/plant_details.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  String moistureStatus = 'Unknown';
  Map<int, Timer?> plantTimers = {};

  Future<void> fetchMoisture() async {
    scheduleNotification();
    // final response =
    //     await http.get(Uri.parse('http://raspberrypi.local:5000/moisture'));
    // if (response.statusCode == 200) {
    //   final data = json.decode(response.body);
    //   bool isMoistureHigh = data['moisture_status'] == 'Moist soil detected!';

    //   setState(() {
    //     moistureStatus = data['moisture_status'];
    //   });

    //   final plantBox = Boxes.getPlants();
    //   final currentTime = DateTime.now();

    //   if (plantBox.isNotEmpty) {
    //     for (int i = 0; i < plantBox.length; i++) {
    //       Plant existingPlant = plantBox.getAt(i)!;
    //       existingPlant.lastWetTime = currentTime;
    //       existingPlant.isMoistureHigh = isMoistureHigh;

    //       // If moisture status changes from low to high, start a timer for notifications
    //       if (existingPlant.isMoistureHigh) {
    //         requestNotificationPermission();

    //         Duration wateringDuration = const Duration(
    //             seconds: 10); // Replace with your plant type duration logic
    //         await scheduleNotification();
    //       }
    //     }
    //   }
    // } else {
    //   throw Exception('Failed to load moisture data');
    // }
  }

  @override
  void initState() {
    super.initState();

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android:
          AndroidInitializationSettings('@mipmap/ic_launcher'), // your app icon
    );
    flutterLocalNotificationsPlugin.initialize(initializationSettings);
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

  Future<void> _addPlant(String name, int selectedPlantTypeIndex) async {
    final newPlant = Plant(
      name: name,
      lastWetTime: DateTime.now(),
      isMoistureHigh: false,
      plantTypeIndex: selectedPlantTypeIndex,
    );
    await Boxes.getPlants().add(newPlant);
    setState(() {}); // Refreshes the UI to display the new plant
  }

  void _showAddPlantDialog() {
    final plantNameController = TextEditingController();

    // Retrieve plant types from the box
    List<String> plantTypes = Boxes.getPlantTypes()
        .values
        .map((plantType) => plantType.name)
        .toList();
    int selectedPlantTypeIndex = 0; // Default to the first type

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Plant'),
          content: StatefulBuilder(
            builder: (context, setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
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
                  const SizedBox(height: 20),
                  DropdownButtonFormField<int>(
                    value: selectedPlantTypeIndex,
                    items: List<DropdownMenuItem<int>>.generate(
                      plantTypes.length + 1, // Adding +1 for custom option
                      (index) {
                        if (index < plantTypes.length) {
                          return DropdownMenuItem<int>(
                            value: index,
                            child: Text(plantTypes[index]),
                          );
                        } else {
                          return const DropdownMenuItem<int>(
                            value: -1, // Custom option value
                            child: Text('Add Custom Plant Type'),
                          );
                        }
                      },
                    ),
                    onChanged: (newIndex) {
                      if (newIndex == -1) {
                        // Show dialog for adding custom plant type
                        _showAddCustomPlantTypeDialog(context,
                            (customPlantType) {
                          setState(() {
                            // Update the plant types list and selected index
                            plantTypes.add(customPlantType);
                            selectedPlantTypeIndex = plantTypes.length -
                                1; // Select the new plant type
                          });
                        });
                      } else {
                        selectedPlantTypeIndex = newIndex!;
                      }
                    },
                    decoration: const InputDecoration(
                      labelText: 'Select Plant Type',
                      labelStyle: TextStyle(color: Colors.grey),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.green),
                      ),
                    ),
                  ),
                ],
              );
            },
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
                  _addPlant(
                      plantName, selectedPlantTypeIndex); // Pass name and index
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

  void _showAddCustomPlantTypeDialog(
      BuildContext context, Function(String) onPlantTypeAdded) {
    final nameController = TextEditingController();
    final frequencyController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Custom Plant Type'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Enter custom plant type',
                  labelStyle: TextStyle(color: Colors.grey),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.green),
                  ),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                ),
              ),
              TextField(
                keyboardType: TextInputType.number,
                controller: frequencyController,
                decoration: const InputDecoration(
                  labelText: 'Enter the watering frequency (in seconds)',
                  labelStyle: TextStyle(color: Colors.grey),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.green),
                  ),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                ),
              ),
              const SizedBox(height: 10),
            ],
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
                final customPlantType = nameController.text;
                if (customPlantType.isNotEmpty) {
                  // Add the custom plant type to the list
                  Boxes.getPlantTypes().add(PlantType(
                    name: customPlantType,
                    wateringFrequencySeconds:
                        double.parse(frequencyController.text),
                  ));

                  // Call the callback function to update the main dialog
                  onPlantTypeAdded(customPlantType);
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

Future<void> scheduleNotification() async {
  const AndroidNotificationDetails androidPlatformChannelSpecifics =
      AndroidNotificationDetails(
    'your_channel_id', // Your channel ID
    'Your Channel Name',
    channelDescription: 'Description of your channel',
    importance: Importance.high,
    priority: Priority.high,
    showWhen: false,
  );

  const NotificationDetails platformChannelSpecifics =
      NotificationDetails(android: androidPlatformChannelSpecifics);

  var time = tz.TZDateTime.now(tz.local).add(Duration(seconds: 10));
  print(time);

  // Schedule the notification to trigger after a certain duration
  await flutterLocalNotificationsPlugin.zonedSchedule(
    0, // Notification ID
    'Scheduled Notification Title', // Notification Title
    'This is a scheduled notification body.', // Notification Body
    time, // Scheduled time
    platformChannelSpecifics,
    uiLocalNotificationDateInterpretation:
        UILocalNotificationDateInterpretation.absoluteTime, androidScheduleMode: AndroidScheduleMode.exact,
  );

  print("Notification scheduled");
}


Future<void> requestNotificationPermission() async {
  var status = await Permission.notification.request();
  if (status.isGranted) {
    print("Notification permission granted");
  } else {
    print("Notification permission denied");
  }
}

Future<void> requestExactAlarmPermission() async {
  // Request permission
  var status = await Permission.notification.request();

  if (status.isGranted) {
    print("Exact alarm permission granted");
  } else {
    print("Exact alarm permission denied");
  }
}
