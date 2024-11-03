import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:sproutscout/pages/home.dart';

import 'models/plant.dart';
import 'models/plant_type.dart'; // Import the library that defines PlantTypeAdapter

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(PlantAdapter());
  Hive.registerAdapter(PlantTypeAdapter());
  await Hive.openBox<Plant>('plants');
  var plantTypesBox = await Hive.openBox<PlantType>('plant_types');

  if (plantTypesBox.isEmpty) {
    await plantTypesBox.add(PlantType(name: 'Cactus', wateringFrequencySeconds: 60 * 60 * 24 * 7));
    await plantTypesBox.add(PlantType(name: 'Fern', wateringFrequencySeconds: 60 * 60 * 24 * 3));
    await plantTypesBox.add(PlantType(name: 'Pothos', wateringFrequencySeconds: 60 * 60 * 24 * 5));
  }

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
