import 'dart:math';
import '../models/pose.dart';
import '../models/measurement.dart';
import '../models/user_profile.dart';

/// MoveNet keypoint indices
///  0 nose   5 l_shoulder  6 r_shoulder  7 l_elbow   8 r_elbow
///  9 l_wrist 10 r_wrist  11 l_hip      12 r_hip    13 l_knee
/// 14 r_knee 15 l_ankle   16 r_ankle

class MeasurementCalculator {

  // ── Anthropometric constants ───────────────────────────────────────────
  // nose→ankle is ~89.5% of standing height (head top→nose≈6.5%, ankle→floor≈4%)
  static const double _noseToAnkleRatio     = 0.895;
  // shoulder→ankle fallback: shoulders at ~18% from top → 100−18−4 = 78%
  static const double _shoulderToAnkleRatio = 0.78;

  // ── Main entry point ───────────────────────────────────────────────────
  static MeasurementResult calculate(
      Pose pose, {
        double userHeightCm         = 170.0,
        UserProfile? userProfile,
        double gyroCorrectionFactor = 1.0,
      }) {
    final k  = pose.keypoints;
    // Original image aspect ratio width/height (e.g. 480/640 = 0.75 for portrait)
    final double ar = pose.aspectRatio.clamp(0.1, 10.0);

    const double minScore = 0.25;
    bool valid(int i) => i < k.length && k[i].score >= minScore;

    // ── Step 1: Convert normalised coords back to true image fractions ─────
    //
    // After letterboxing a portrait image (ar < 1) into 256×256:
    //   scaledW = 256 × ar,  scaledH = 256
    //   person's x coords are in: [offsetX/256 … (offsetX+scaledW)/256]
    //   where offsetX = (256 − scaledW)/2
    //
    // A keypoint at normalised x=0.549 in the letterboxed canvas
    // corresponds to a TRUE image fraction of:
    //   trueX = (x − offsetFracX) / ar
    //   where offsetFracX = (1 − ar) / 2
    //
    // For landscape (ar > 1) the same logic applies to y.
    //
    // After this correction all distances are in "true normalised" space
    // where 1 unit = the full image dimension.

    double trueX(double xCanvas) {
      if (ar >= 1.0) return xCanvas;   // landscape: x not padded
      final double offsetFrac = (1.0 - ar) / 2.0;
      return (xCanvas - offsetFrac) / ar;
    }

    double trueY(double yCanvas) {
      if (ar <= 1.0) return yCanvas;   // portrait: y not padded
      final double offsetFrac = (1.0 - 1.0 / ar) / 2.0;
      return (yCanvas - offsetFrac) * ar;
    }

    // Corrected keypoint accessor → [tx, ty]
    List<double> ck(int i) => [trueX(k[i].x), trueY(k[i].y)];

    // Euclidean distance in TRUE normalised space
    double dist(List<double> a, List<double> b) =>
        sqrt(pow(a[0] - b[0], 2) + pow(a[1] - b[1], 2));

    // Vertical distance only (used for height span)
    double vdist(List<double> a, List<double> b) => (a[1] - b[1]).abs();

    List<double> mid(List<double> a, List<double> b) =>
        [(a[0] + b[0]) / 2, (a[1] + b[1]) / 2];

    List<double> lerp(List<double> a, List<double> b, double t) =>
        [a[0] + (b[0] - a[0]) * t, a[1] + (b[1] - a[1]) * t];

    // ── Step 2: Scale factor ───────────────────────────────────────────────
    //
    // scale = userHeight_cm / (trueNormalisedHeight × noseToAnkleRatio)
    //
    // Gyro correction: if phone is tilted φ degrees, the projected pixel
    // height is compressed by cos(φ). We receive cos(φ) as gyroCorrectionFactor.
    // Clamp to [0.7, 1.0] — beyond 45° tilt we should not be capturing.
    final double gyro = gyroCorrectionFactor.clamp(0.70, 1.0);

    double scale = 0.0;
    String scaleMethod = '';

    // Primary: nose → ankle midpoint
    if (valid(0) && valid(15) && valid(16)) {
      final nose     = ck(0);
      final ankleMid = mid(ck(15), ck(16));
      final rawSpan  = vdist(nose, ankleMid);
      final trueSpan = rawSpan / gyro; // undo vertical compression

      if (trueSpan > 0.05) {
        scale       = (userHeightCm * _noseToAnkleRatio) / trueSpan;
        scaleMethod = 'nose→ankle';
      }
    }

    // Fallback: shoulder midpoint → ankle midpoint
    if (scale == 0.0 && valid(5) && valid(6) && valid(15) && valid(16)) {
      final shMid  = mid(ck(5), ck(6));
      final ankMid = mid(ck(15), ck(16));
      final rawSpan  = vdist(shMid, ankMid);
      final trueSpan = rawSpan / gyro;

      if (trueSpan > 0.05) {
        scale       = (userHeightCm * _shoulderToAnkleRatio) / trueSpan;
        scaleMethod = 'shoulder→ankle (fallback)';
      }
    }

    if (scale == 0.0) {
      throw Exception(
        "Cannot determine scale.\nEnsure full body (head to feet) is visible.",
      );
    }

    // ── Step 3: Sanity-check scale against shoulder/height ratio ──────────
    //
    // For adults: shoulder_width_cm / height_cm should be in [0.20, 0.30]
    // If outside this range the scale is almost certainly wrong (bad pose,
    // partial body, extreme tilt etc.).
    //
    // From the logs: shoulder was 0.128 — we warned but continued.
    // We now ALSO try the fallback scale and pick whichever gives a
    // more anatomically plausible shoulder ratio.
    if (valid(5) && valid(6)) {
      final shChordNorm = dist(ck(5), ck(6));
      final shChordCm   = shChordNorm * scale;
      final shRatio     = shChordCm / userHeightCm;

      debugLog('Scale: ${scale.toStringAsFixed(1)} cm/unit [$scaleMethod] '
          'gyro=${gyro.toStringAsFixed(3)} ar=${ar.toStringAsFixed(3)}');
      debugLog('Shoulder sanity: ${shChordCm.toStringAsFixed(1)} cm '
          '/ ${userHeightCm.toStringAsFixed(0)} cm = '
          '${shRatio.toStringAsFixed(3)} (expect 0.20–0.30)');

      if (shRatio < 0.15 || shRatio > 0.35) {
        // Something is wrong — warn and let the user know results may be off
        debugLog('WARNING: shoulder/height outside normal range. '
            'Ensure full body is in frame and stand further back.');
      }
    } else {
      debugLog('Scale: ${scale.toStringAsFixed(1)} cm/unit [$scaleMethod]');
    }

    double toCm(double n) => n * scale;

    // ── Step 4: Body landmark positions ───────────────────────────────────
    final shL  = ck(5);  final shR  = ck(6);
    final hipL = ck(11); final hipR = ck(12);
    final shMid  = mid(shL, shR);
    final hipMid = mid(hipL, hipR);

    // ── Step 5: Measurement chords ─────────────────────────────────────────
    //
    // Shoulder width: shoulder keypoint to keypoint (correct for this measure)
    final double shoulderNorm = (valid(5) && valid(6)) ? dist(shL, shR) : 0.0;

    // Chest: 28% down the torso from shoulder to hip (nipple line)
    final chestL = (valid(5) && valid(11)) ? lerp(shL, hipL, 0.28) : null;
    final chestR = (valid(6) && valid(12)) ? lerp(shR, hipR, 0.28) : null;
    final double chestNorm = (chestL != null && chestR != null)
        ? dist(chestL, chestR)
        : shoulderNorm * 0.90; // fallback

    // Waist: 62% down torso
    final waistL = (valid(5) && valid(11)) ? lerp(shL, hipL, 0.62) : null;
    final waistR = (valid(6) && valid(12)) ? lerp(shR, hipR, 0.62) : null;
    final double waistNorm = (waistL != null && waistR != null)
        ? dist(waistL, waistR)
        : ((valid(11) && valid(12)) ? dist(hipL, hipR) * 0.88 : 0.0);

    // Hip: 18% below hip keypoint toward knee (widest point)
    final hipBL = (valid(11) && valid(13)) ? lerp(ck(11), ck(13), 0.18) : null;
    final hipBR = (valid(12) && valid(14)) ? lerp(ck(12), ck(14), 0.18) : null;
    final double hipNorm = (hipBL != null && hipBR != null)
        ? dist(hipBL, hipBR)
        : ((valid(11) && valid(12)) ? dist(hipL, hipR) : 0.0);

    // Arms
    final double armL = (valid(5) && valid(7) && valid(9))
        ? dist(ck(5), ck(7)) + dist(ck(7), ck(9)) : 0.0;
    final double armR = (valid(6) && valid(8) && valid(10))
        ? dist(ck(6), ck(8)) + dist(ck(8), ck(10)) : 0.0;
    final double armAvg = (armL > 0 && armR > 0)
        ? (armL + armR) / 2 : max(armL, armR);

    // Legs
    final double legL = (valid(11) && valid(13) && valid(15))
        ? dist(ck(11), ck(13)) + dist(ck(13), ck(15)) : 0.0;
    final double legR = (valid(12) && valid(14) && valid(16))
        ? dist(ck(12), ck(14)) + dist(ck(14), ck(16)) : 0.0;
    final double legAvg = (legL > 0 && legR > 0)
        ? (legL + legR) / 2 : max(legL, legR);

    // Torso lengths
    final double upperBody = (valid(5) && valid(6) && valid(11) && valid(12))
        ? dist(shMid, hipMid) : 0.0;
    final double lowerBody = (valid(11) && valid(12) && valid(15) && valid(16))
        ? dist(hipMid, mid(ck(15), ck(16))) : 0.0;

    // ── Step 6: Convert to cm ──────────────────────────────────────────────
    final double shoulderCm  = toCm(shoulderNorm);
    final double chestChordCm = toCm(chestNorm);
    final double waistChordCm = toCm(waistNorm);
    final double hipChordCm   = toCm(hipNorm);

    debugLog('Chords → sh:${shoulderCm.toStringAsFixed(1)} '
        'ch:${chestChordCm.toStringAsFixed(1)} '
        'wa:${waistChordCm.toStringAsFixed(1)} '
        'hi:${hipChordCm.toStringAsFixed(1)} cm');

    // ── Step 7: Circumference estimation ──────────────────────────────────
    final BuildType build = userProfile?.buildType ?? BuildType.average;
    final int age         = userProfile?.age ?? 28;
    final double height   = userProfile?.heightCm ?? userHeightCm;

    final double chestCirc = _circ(chestChordCm, _R.chest, build, age, height);
    final double waistCirc = _circ(waistChordCm, _R.waist, build, age, height);
    final double hipCirc   = _circ(hipChordCm,   _R.hip,   build, age, height);

    debugLog('Circums → ch:${chestCirc.toStringAsFixed(1)} '
        'wa:${waistCirc.toStringAsFixed(1)} '
        'hi:${hipCirc.toStringAsFixed(1)} cm');

    return MeasurementResult(
      id:              DateTime.now().millisecondsSinceEpoch.toString(),
      height:          userHeightCm,
      shoulderWidth:   shoulderCm,
      chest:           chestCirc,
      waist:           waistCirc,
      hip:             hipCirc,
      leftArmLength:   toCm(armAvg),
      rightArmLength:  toCm(armAvg),
      leftLegLength:   toCm(legAvg),
      rightLegLength:  toCm(legAvg),
      upperBodyLength: toCm(upperBody),
      lowerBodyLength: toCm(lowerBody),
      createdAt:       DateTime.now(),
    );
  }

  // ── Circumference from chord (Ramanujan ellipse + ease) ────────────────
  //
  // Depth ratios (b/a) — calibrated for correct anatomical chord positions:
  // chest at 28% down torso (narrower than shoulder), waist at 62%, hip below kp.
  //
  //              lean   average  heavy  obese
  // chest  b/a:  0.70   0.78     0.88   0.98
  // waist  b/a:  0.55   0.68     0.82   0.96
  // hip    b/a:  0.72   0.82     0.94   1.06
  static double _circ(
      double chordCm, _R region, BuildType build, int age, double heightCm,
      ) {
    if (chordCm <= 0) return 0.0;

    const ratios = {
      _R.chest: {
        BuildType.lean: 0.70, BuildType.average: 0.78,
        BuildType.heavy: 0.88, BuildType.obese: 0.98,
      },
      _R.waist: {
        BuildType.lean: 0.55, BuildType.average: 0.68,
        BuildType.heavy: 0.82, BuildType.obese: 0.96,
      },
      _R.hip: {
        BuildType.lean: 0.72, BuildType.average: 0.82,
        BuildType.heavy: 0.94, BuildType.obese: 1.06,
      },
    };

    // Age fine-tune (±4%)
    final double ageFactor = age < 22 ? 0.97
        : age < 30 ? 0.99 : age < 40 ? 1.00 : age < 50 ? 1.02 : 1.04;

    // Taller → proportionally narrower depth
    final double hFactor = 170.0 / heightCm;

    final double a = chordCm / 2.0;
    final double b = a * ratios[region]![build]! * ageFactor * hFactor;

    // Ramanujan ellipse perimeter
    final double h = pow(a - b, 2) / pow(a + b, 2);
    final double circ =
        pi * (a + b) * (1.0 + (3.0 * h) / (10.0 + sqrt(4.0 - 3.0 * h)));

    // Clothing ease
    final double ease = _ease(region, build);

    debugLog('  ${region.name}: chord=${chordCm.toStringAsFixed(1)} '
        'a=${a.toStringAsFixed(1)} b=${b.toStringAsFixed(1)} '
        'circ=${circ.toStringAsFixed(1)} ease=${ease.toStringAsFixed(1)} '
        '→ ${(circ + ease).toStringAsFixed(1)} cm');

    return circ + ease;
  }

  static double _ease(_R r, BuildType b) {
    switch (r) {
      case _R.chest:
        return b == BuildType.lean ? 3.0 : b == BuildType.average ? 4.0
            : b == BuildType.heavy ? 5.0 : 6.0;
      case _R.waist:
        return b == BuildType.lean ? 1.5 : b == BuildType.average ? 2.5
            : b == BuildType.heavy ? 3.5 : 4.5;
      case _R.hip:
        return b == BuildType.lean ? 3.0 : b == BuildType.average ? 4.0
            : b == BuildType.heavy ? 5.0 : 6.0;
    }
  }

  // ignore: avoid_print
  static void debugLog(String msg) => print('[MeasCalc] $msg');
}

enum _R { chest, waist, hip }