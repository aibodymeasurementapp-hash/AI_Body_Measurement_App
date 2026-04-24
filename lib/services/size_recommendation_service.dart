import '../models/dress.dart';
import '../models/measurement.dart';

class SizeRecommendationService {

  /// Pakistani men's standard size chart based on chest circumference (cm):
  ///
  ///   S  → chest < 91 cm
  ///   M  → chest 91–101 cm
  ///   L  → chest 101–111 cm
  ///   XL → chest > 111 cm
  static DressSize recommendSize(MeasurementResult measurement) {
    final chest = measurement.chest;
    if (chest < 91)  return DressSize.s;
    if (chest < 101) return DressSize.m;
    if (chest < 111) return DressSize.l;
    return                  DressSize.xl;
  }

  /// Returns dresses filtered by the user's recommended size
  static List<Dress> recommendedDresses(
      MeasurementResult measurement,
      List<Dress> allDresses,
      ) {
    final size = recommendSize(measurement);
    return allDresses.where((d) => d.size == size).toList();
  }

  /// Returns dresses filtered by size AND type
  static List<Dress> recommendedByType(
      MeasurementResult measurement,
      List<Dress> allDresses,
      DressType type,
      ) {
    final size = recommendSize(measurement);
    return allDresses
        .where((d) => d.size == size && d.type == type)
        .toList();
  }
}