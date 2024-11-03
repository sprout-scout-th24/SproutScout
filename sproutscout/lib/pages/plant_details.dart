// pages/plant_detail_page.dart
import 'package:flutter/material.dart';
import '../models/plant.dart'; // Adjust the import according to your file structure

class PlantDetailPage extends StatelessWidget {
  final Plant plant;

  PlantDetailPage({required this.plant});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(plant.name),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Plant Name: ${plant.name}', style: TextStyle(fontSize: 24)),
            SizedBox(height: 16),
            Text('Last Watered: ${plant.lastWetTime}', style: TextStyle(fontSize: 18)),
            SizedBox(height: 16),
            Text('Moisture Status: ${plant.isMoistureHigh ? "High" : "Low"}', style: TextStyle(fontSize: 18)),
          ],
        ),
      ),
    );
  }
}