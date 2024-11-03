// pages/plant_detail_page.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sproutscout/helpers/boxes.dart';
import '../models/plant.dart'; // Adjust the import according to your file structure

class PlantDetailPage extends StatelessWidget {
  final Plant plant;
  final int index;
  final Function onDelete; // Callback for deletion
  final plantBox = Boxes.getPlants();
  final TextEditingController nameController; // Controller for editing name

  PlantDetailPage(
      {required this.plant, required this.index, required this.onDelete})
      : nameController = TextEditingController(text: plant.name);

  @override
  Widget build(BuildContext context) {
    final DateFormat dateFormat = DateFormat('MM/d/y').add_jm();

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
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: 'Plant Name'),
            ),
            SizedBox(height: 16),
            Text(
              'Last Watered on ${dateFormat.format(plant.lastWetTime)}',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 16),
            Text(
              'Soil Moisture: ${plant.isMoistureHigh ? "High" : "Low"}',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment
                  .start, // Align buttons to the start of the row
              children: [
                ElevatedButton(
                  onPressed: () async {
                    // Update the plant name in the box
                    plant.name = nameController.text; // Update the plant's name
                    await plantBox.putAt(
                        index, plant); // Save the updated plant
                    onDelete(); // Notify the parent about the change
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[50],
                    foregroundColor: Colors.green,
                  ),
                  child: Text('Save Changes'),
                ),
                SizedBox(width: 8), // Space between the buttons
                ElevatedButton(
                  onPressed: () async {
                    // Show a confirmation dialog
                    final shouldDelete = await showDialog<bool>(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text('Confirm Delete'),
                          content: Text(
                              'Are you sure you want to delete this plant?'),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context)
                                    .pop(false); // Return false when canceled
                              },
                              child: Text('Cancel',
                              style: TextStyle(color: Colors.grey)),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.of(context)
                                    .pop(true); // Return true to confirm delete
                              },
                              child: Text('Confirm',
                                  style: TextStyle(color: Colors.red)),
                            ),
                          ],
                        );
                      },
                    );

                    // If the user confirmed, delete the plant
                    if (shouldDelete == true) {
                      await deletePlantAtIndex(index); // Delete the plant
                      onDelete(); // Notify the parent about the deletion
                      Navigator.of(context).pop(); // Close the main screen
                    }
                  },
                  style:
                      ElevatedButton.styleFrom(backgroundColor: Colors.red[50]),
                  child: Icon(Icons.delete, color: Colors.red),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

Future deletePlantAtIndex(int index) async {
  var box = Boxes.getPlants();
  if (index >= 0 && index < box.length) {
    // Check if the index is valid
    await box.deleteAt(index); // Deletes the plant at the specified index
  }
}
