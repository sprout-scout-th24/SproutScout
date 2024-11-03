import 'package:hive/hive.dart';

part 'plant_type.g.dart';

@HiveType(typeId: 0) // Unique ID for the adapter
class PlantType {
  @HiveField(0)
  late String name;

  @HiveField(1)
  Duration wateringFrequency;

  PlantType({
    required this.name,
    required this.wateringFrequency,
  });
}
