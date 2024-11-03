// pages/plant_detail_page.dart
import 'package:flutter/material.dart';
import 'package:sproutscout/helpers/boxes.dart';
import '../models/plant.dart'; // Adjust the import according to your file structure


class PlantDetailPage extends StatelessWidget {
  final Plant plant;
  final int index;
  final Function onDelete; // Callback for deletion
  final plantBox = Boxes.getPlants();

  PlantDetailPage({required this.plant, required this.index, required this.onDelete});

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
              onPressed: () async {
                // Delete the plant from the box
                await deletePlantAtIndex(index);
                onDelete(); // Notify the parent about the deletion
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

Future deletePlantAtIndex(int index) async {
  var box = Boxes.getPlants();
  if (index >= 0 && index < box.length) { // Check if the index is valid
    await box.deleteAt(index); // Deletes the plant at the specified index
  }
}
