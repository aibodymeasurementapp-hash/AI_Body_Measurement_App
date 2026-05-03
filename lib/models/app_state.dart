import 'user_profile.dart';
import 'measurement.dart';
import 'dress.dart';

class AppState {
  final UserProfile? userProfile;
  final DressCategory? selectedCategory;
  final DressType? selectedDressType;
  final Measurement? currentMeasurement;
  final MeasurementResult? latestResult;
  final List<MeasurementResult> savedResults;
  final bool isPremium; // ← NEW

  AppState({
    this.userProfile,
    this.selectedCategory,
    this.selectedDressType,
    this.currentMeasurement,
    this.latestResult,
    this.savedResults = const [],
    this.isPremium = false, // ← NEW
  });

  AppState copyWith({
    UserProfile? userProfile,
    DressCategory? selectedCategory,
    DressType? selectedDressType,
    Measurement? currentMeasurement,
    MeasurementResult? latestResult,
    List<MeasurementResult>? savedResults,
    bool? isPremium, // ← NEW
  }) {
    return AppState(
      userProfile: userProfile ?? this.userProfile,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      selectedDressType: selectedDressType ?? this.selectedDressType,
      currentMeasurement: currentMeasurement ?? this.currentMeasurement,
      latestResult: latestResult ?? this.latestResult,
      savedResults: savedResults ?? this.savedResults,
      isPremium: isPremium ?? this.isPremium, // ← NEW
    );
  }
}