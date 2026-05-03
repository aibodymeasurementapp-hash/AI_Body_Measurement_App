import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/measurement_service.dart';
import '../services/size_recommendation_service.dart';
import '../models/measurement.dart';
import '../models/dress.dart';
import '../models/pose.dart';
import '../models/user_profile.dart';
import '../services/measurement_calculator.dart';
import '../data/men_dresses.dart';

final measurementServiceProvider = Provider<MeasurementService>(
      (ref) => MeasurementService(),
);

final measurementStateProvider =
StateNotifierProvider<MeasurementStateNotifier, MeasurementState>((ref) {
  return MeasurementStateNotifier(ref.read(measurementServiceProvider));
});

final recommendationProvider =
Provider.family<List<Dress>, MeasurementResult>((ref, measurement) {
  return SizeRecommendationService.recommendedDresses(measurement, menDresses);
});

class MeasurementStateNotifier extends StateNotifier<MeasurementState> {
  final MeasurementService _measurementService;

  MeasurementStateNotifier(this._measurementService)
      : super(const MeasurementState.initial());

  Future<void> processManualMeasurements(Measurement measurement) async {
    state = const MeasurementState.loading();
    try {
      final result =
      await _measurementService.processManualMeasurements(measurement);
      state = MeasurementState.success(result);
    } catch (e) {
      state = MeasurementState.error(e.toString());
    }
  }

  // ✅ pose is now a required named parameter — forwarded to service
  Future<void> processCameraMeasurements(
      String imagePath,
      double userHeightCm, {
        required Pose pose,
        UserProfile? userProfile,
        double gyroCorrectionFactor = 1.0,
      }) async {
    state = const MeasurementState.loading();
    try {
      final result = await _measurementService.processCameraMeasurements(
        imagePath,
        userHeightCm,
        pose:                pose,
        userProfile:         userProfile,
        gyroCorrectionFactor: gyroCorrectionFactor,
      );
      state = MeasurementState.success(result);
    } catch (e) {
      state = MeasurementState.error(e.toString());
    }
  }

  Future<void> processPoseMeasurements(
      Pose pose, {
        double userHeightCm = 170.0,
        UserProfile? userProfile,
        double gyroCorrectionFactor = 1.0,
      }) async {
    state = const MeasurementState.loading();
    try {
      final result = MeasurementCalculator.calculate(
        pose,
        userHeightCm:         userHeightCm,
        userProfile:          userProfile,
        gyroCorrectionFactor: gyroCorrectionFactor,
      );
      state = MeasurementState.success(result);
    } catch (e) {
      state = MeasurementState.error(e.toString());
    }
  }

  // ✅ Clears stale result before new processing
  void clearResult() => state = const MeasurementState.initial();

  void reset() => state = const MeasurementState.initial();
}

class MeasurementState {
  final bool isLoading;
  final MeasurementResult? result;
  final String? error;

  const MeasurementState._({required this.isLoading, this.result, this.error});

  const MeasurementState.initial()
      : this._(isLoading: false, result: null, error: null);
  const MeasurementState.loading()
      : this._(isLoading: true, result: null, error: null);
  const MeasurementState.success(MeasurementResult r)
      : this._(isLoading: false, result: r, error: null);
  const MeasurementState.error(String e)
      : this._(isLoading: false, result: null, error: e);
}