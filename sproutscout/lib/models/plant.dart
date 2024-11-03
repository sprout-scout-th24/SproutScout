import 'package:hive/hive.dart';

part 'plant.g.dart';

@HiveType(typeId: 0) // Unique ID for the adapter
class Plant {
  @HiveField(0)
  late String name;

  @HiveField(1)
  DateTime lastWetTime;

  @HiveField(2)
  bool isMoistureHigh;

  @HiveField(3)
  int? plantTypeIndex = 0;

  Plant({
    required this.name,
    required this.lastWetTime,
    required this.isMoistureHigh,
    required this.plantTypeIndex,
  });
}
