import '../models/measurement.dart';
import '../models/pose.dart';
import '../models/user_profile.dart';
import 'measurement_calculator.dart';

class MeasurementService {

  Future<void> _simulateProcessing() async {
    await Future.delayed(const Duration(seconds: 1));
  }

  Future<MeasurementResult> processManualMeasurements(
      Measurement measurement,
      ) async {
    await _simulateProcessing();

    return MeasurementResult(
      id:              'result_${DateTime.now().millisecondsSinceEpoch}',
      height:          measurement.height,
      shoulderWidth:   measurement.shoulder,
      chest:           measurement.chest,
      waist:           measurement.waist,
      upperBodyLength: measurement.shirtLength,
      lowerBodyLength: measurement.inseam,
      leftArmLength:   measurement.sleevesLength,
      rightArmLength:  measurement.sleevesLength,
      leftLegLength:   measurement.inseam,
      rightLegLength:  measurement.inseam,
      createdAt:       DateTime.now(),
    );
  }

  // ✅ pose is now passed in directly — no static lookup
  Future<MeasurementResult> processCameraMeasurements(
      String imagePath,
      double userHeightCm, {
        required Pose pose,
        UserProfile? userProfile,
        double gyroCorrectionFactor = 1.0,
      }) async {
    await _simulateProcessing();

    if (!pose.hasValidKeypoints()) {
      throw Exception(
          "Some keypoints are not clear. "
              "Please retake the photo with proper pose.");
    }

    return MeasurementCalculator.calculate(
      pose,
      userHeightCm:         userHeightCm,
      userProfile:          userProfile,
      gyroCorrectionFactor: gyroCorrectionFactor,
    );
  }
}