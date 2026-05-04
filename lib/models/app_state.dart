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
<<<<<<< HEAD
  final bool isPremium; // ← NEW
=======
>>>>>>> 545a1120d8ac65c628454bf89699a4ff8fd55a89

  AppState({
    this.userProfile,
    this.selectedCategory,
    this.selectedDressType,
    this.currentMeasurement,
    this.latestResult,
    this.savedResults = const [],
<<<<<<< HEAD
    this.isPremium = false, // ← NEW
=======
>>>>>>> 545a1120d8ac65c628454bf89699a4ff8fd55a89
  });

  AppState copyWith({
    UserProfile? userProfile,
    DressCategory? selectedCategory,
    DressType? selectedDressType,
    Measurement? currentMeasurement,
    MeasurementResult? latestResult,
    List<MeasurementResult>? savedResults,
<<<<<<< HEAD
    bool? isPremium, // ← NEW
=======
>>>>>>> 545a1120d8ac65c628454bf89699a4ff8fd55a89
  }) {
    return AppState(
      userProfile: userProfile ?? this.userProfile,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      selectedDressType: selectedDressType ?? this.selectedDressType,
      currentMeasurement: currentMeasurement ?? this.currentMeasurement,
      latestResult: latestResult ?? this.latestResult,
      savedResults: savedResults ?? this.savedResults,
<<<<<<< HEAD
      isPremium: isPremium ?? this.isPremium, // ← NEW
    );
  }
}
=======
    );
  }
}
>>>>>>> 545a1120d8ac65c628454bf89699a4ff8fd55a89
