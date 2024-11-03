import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:sproutscout/pages/home.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;

import 'models/plant.dart';
import 'models/plant_type.dart'; // Import the library that defines PlantTypeAdapter

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(PlantAdapter());
  Hive.registerAdapter(PlantTypeAdapter());
  await Hive.openBox<Plant>('plants');
  var plantTypesBox = await Hive.openBox<PlantType>('plant_types');

  if (plantTypesBox.isEmpty) {
    await plantTypesBox.add(
        PlantType(name: 'Cactus', wateringFrequencySeconds: 60 * 60 * 24 * 7));
    await plantTypesBox.add(
        PlantType(name: 'Fern', wateringFrequencySeconds: 60 * 60 * 24 * 3));
    await plantTypesBox.add(
        PlantType(name: 'Pothos', wateringFrequencySeconds: 60 * 60 * 24 * 5));
  }

  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  const InitializationSettings initializationSettings =
      InitializationSettings(android: initializationSettingsAndroid);

  await flutterLocalNotificationsPlugin.initialize(initializationSettings);

  tz.initializeTimeZones();
  await createNotificationChannel();

  runApp(const MyApp());
}

Future<void> createNotificationChannel() async {
  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'your_channel_id', // Replace with your channel id
    'Your Channel Name', // Replace with your channel name
    description: 'Description of your channel',
    importance: Importance.high,
  );

  await flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.createNotificationChannel(channel);
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SproutScout',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: const HomePage(),
    );
  }
}
