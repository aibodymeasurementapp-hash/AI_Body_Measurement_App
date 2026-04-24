import '../models/pose.dart';

/// Holds validation result — either passed or failed with a reason
class PoseValidationResult {
  final bool isValid;
  final String? failureReason;

  const PoseValidationResult.valid()
      : isValid = true,
        failureReason = null;

  const PoseValidationResult.invalid(this.failureReason) : isValid = false;
}

class PoseValidationService {

  static PoseValidationResult validate(
      Pose pose, {
        double minConfidence = 0.25, // ✅ NEW
      }) {

    final p = pose.keypoints;

    final nose         = p[0];
    final leftShoulder = p[5];  final rightShoulder = p[6];
    final leftElbow    = p[7];  final rightElbow    = p[8];
    final leftWrist    = p[9];  final rightWrist    = p[10];
    final leftHip      = p[11]; final rightHip      = p[12];
    final leftKnee     = p[13]; final rightKnee     = p[14];
    final leftAnkle    = p[15]; final rightAnkle    = p[16];

    // DEBUG — remove after testing
    print("=== POSE VALIDATION DEBUG ===");
    print("threshold: ${minConfidence.toStringAsFixed(2)}");
    print("nose: ${nose.score.toStringAsFixed(2)}");
    print("leftShoulder: ${leftShoulder.score.toStringAsFixed(2)}  rightShoulder: ${rightShoulder.score.toStringAsFixed(2)}");
    print("leftHip: ${leftHip.score.toStringAsFixed(2)}  rightHip: ${rightHip.score.toStringAsFixed(2)}");
    print("leftAnkle: ${leftAnkle.score.toStringAsFixed(2)}  rightAnkle: ${rightAnkle.score.toStringAsFixed(2)}");
    print("=============================");

    // ── 1. Full body visible ─────────────────────────────────────────
    if (nose.score < minConfidence ||
        leftAnkle.score < minConfidence || rightAnkle.score < minConfidence ||
        leftKnee.score < minConfidence  || rightKnee.score < minConfidence) {
      return const PoseValidationResult.invalid(
        "❌ Full body not visible\n"
            "→ Step back so head to toe is in the frame",
      );
    }

    // ── 2. Core body detection (IMPORTANT) ───────────────────────────
    if (leftShoulder.score < minConfidence || rightShoulder.score < minConfidence) {
      return const PoseValidationResult.invalid(
        "❌ Shoulders not detected clearly\n"
            "→ Face the camera directly",
      );
    }

    if (leftHip.score < minConfidence || rightHip.score < minConfidence) {
      return const PoseValidationResult.invalid(
        "❌ Hips not detected clearly\n"
            "→ Ensure full body visibility",
      );
    }

    // ── 3. Facing camera (shoulders horizontal) ───────────────────────
    double shoulderHeightDiff = (leftShoulder.y - rightShoulder.y).abs();
    if (shoulderHeightDiff > 0.12) {
      return const PoseValidationResult.invalid(
        "❌ Not facing camera directly\n"
            "→ Stand straight and face forward",
      );
    }

    // ── 4. Distance check (shoulder width) ────────────────────────────
    double shoulderWidth = (leftShoulder.x - rightShoulder.x).abs();
    if (shoulderWidth < 0.10) {
      return const PoseValidationResult.invalid(
        "❌ Too far from camera\n"
            "→ Move closer (2–3 meters ideal)",
      );
    }

    // ── 5. Vertical alignment ─────────────────────────────────────────
    double shoulderCenterX = (leftShoulder.x + rightShoulder.x) / 2;
    double hipCenterX      = (leftHip.x + rightHip.x) / 2;
    if ((shoulderCenterX - hipCenterX).abs() > 0.1) {
      return const PoseValidationResult.invalid(
        "❌ Body not aligned\n"
            "→ Stand straight vertically",
      );
    }

    // ── 6. Arms away from body ────────────────────────────────────────
    double leftArmDist  = (leftWrist.x  - leftHip.x).abs();
    double rightArmDist = (rightWrist.x - rightHip.x).abs();
    if (leftArmDist < 0.02 || rightArmDist < 0.02) {
      return const PoseValidationResult.invalid(
        "❌ Arms too close\n"
            "→ Keep arms slightly away from body",
      );
    }

    // ── 7. Elbows separation ─────────────────────────────────────────
    double leftElbowDist  = (leftElbow.x  - leftShoulder.x).abs();
    double rightElbowDist = (rightElbow.x - rightShoulder.x).abs();
    if (leftElbowDist < 0.01 || rightElbowDist < 0.01) {
      return const PoseValidationResult.invalid(
        "❌ Arms not extended\n"
            "→ Slightly extend arms outward",
      );
    }

    // ── PASSED ───────────────────────────────────────────────────────
    return const PoseValidationResult.valid();
  }

  /// Backward compatibility
  static bool isValidPose(Pose pose) =>
      validate(pose).isValid;
}