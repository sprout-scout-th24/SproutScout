// Hive Data Base
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
// Model types
import '../models/plant.dart';

class Boxes {
  static Box<Plant> getPlants() => Hive.box<Plant>('plants');
}