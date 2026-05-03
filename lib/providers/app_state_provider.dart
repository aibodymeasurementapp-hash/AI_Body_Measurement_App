import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/app_state.dart';
import '../models/user_profile.dart';
import '../models/measurement.dart';
import '../models/dress.dart';

final appStateProvider = StateNotifierProvider<AppStateNotifier, AppState>((ref) {
  return AppStateNotifier();
});

class AppStateNotifier extends StateNotifier<AppState> {
  AppStateNotifier() : super(AppState());

  void setUserProfile(UserProfile userProfile) {
    state = state.copyWith(userProfile: userProfile);
  }

  void setSelectedCategory(DressCategory category) {
    state = state.copyWith(selectedCategory: category);
  }

  void setSelectedDressType(DressType dressType) {
    state = state.copyWith(selectedDressType: dressType);
  }

  void setCurrentMeasurement(Measurement measurement) {
    state = state.copyWith(currentMeasurement: measurement);
  }

  void setLatestResult(MeasurementResult result) {
    state = state.copyWith(latestResult: result);
  }

  void saveResult(MeasurementResult result) {
    final updatedResults = [...state.savedResults, result];
    state = state.copyWith(
      latestResult: result,
      savedResults: updatedResults,
    );
  }

  // ← NEW
  void setPremium(bool value) {
    state = state.copyWith(isPremium: value);
  }

  void clearState() {
    state = AppState();
  }
}