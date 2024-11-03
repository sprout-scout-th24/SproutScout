import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:sproutscout/helpers/boxes.dart';
import 'package:sproutscout/pages/home.dart';

import 'models/plant.dart';
import 'models/plant_type.dart'; // Import the library that defines PlantTypeAdapter

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(PlantAdapter());
  Hive.registerAdapter(PlantTypeAdapter());
  var plantBox = await Hive.openBox<Plant>('plants');
  await plantBox.clear(); // Clear the box to reset any mismatched data
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sprout Scout',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: const HomePage(),
    );
  }
}
