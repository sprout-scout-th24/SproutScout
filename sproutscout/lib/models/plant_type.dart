import 'package:hive/hive.dart';

part 'plant_type.g.dart';

@HiveType(typeId: 1) // Unique ID for the adapter
class PlantType {
  @HiveField(0)
  late String name;

  @HiveField(1)
  double wateringFrequencySeconds;

  PlantType({
    required this.name,
    required this.wateringFrequencySeconds,
  });
}
