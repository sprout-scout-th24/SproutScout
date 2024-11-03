// pages/plant_detail_page.dart
import 'package:flutter/material.dart';
import '../models/plant.dart'; // Adjust the import according to your file structure
import 'package:hive/hive.dart';

class PlantDetailPage extends StatelessWidget {
  final Plant plant;
  final Box<Plant> plantBox;
  final int index;

  PlantDetailPage({required this.plant, required this.plantBox, required this.index});

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
            SizedBox(height: 16),
            Text('Last Watered: ${plant.lastWetTime}',
                style: TextStyle(fontSize: 18)),
            SizedBox(height: 16),
            Text('Moisture Status: ${plant.isMoistureHigh ? "High" : "Low"}',
                style: TextStyle(fontSize: 18)),
            ElevatedButton(
              onPressed: () {
                // Delete the plant from the box
                plantBox.deleteAt(index);
                Navigator.of(context).pop();
              },
              child: Icon(Icons.delete),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            )
          ],
        ),
      ),
    );
  }
}
