// lib/services/measurement_calculator.dart
import 'dart:math';
import '../models/pose.dart';
import '../models/measurement.dart';
import '../models/user_profile.dart';

/// MoveNet / ML Kit keypoint indices (for reference)
///  0 nose        5 l_shoulder   6 r_shoulder
///  7 l_elbow     8 r_elbow      9 l_wrist   10 r_wrist
/// 11 l_hip      12 r_hip       13 l_knee    14 r_knee
/// 15 l_ankle    16 r_ankle

class MeasurementCalculator {

  // ── Confidence threshold ───────────────────────────────────────────────────
  static const double _minScore = 0.25;

  // ── Anthropometric correction constants ────────────────────────────────────
  static const double _noseToEarMultiplier = 1.10;
  static const double _ankleToHeelFraction = 0.039;

  // ── Calibration offsets (cm) ───────────────────────────────────────────────
  // These fixed offsets are added to the raw detected measurements to correct
  // for systematic underestimation in 2D pose-based estimation.
  // Adjust these values as needed based on ground-truth measurements.
  static const double _calShoulder = 19.5; // Shoulder width offset
  static const double _calChest    = 28.5; // Chest circumference offset
  static const double _calWaist    = 30.5; // Waist circumference offset
  static const double _calSleeve   = 16.9; // Sleeve / arm length offset
  static const double _calLeg      = 33.5; // Leg length offset

  // ── Main entry point ───────────────────────────────────────────────────────
  static MeasurementResult calculate(
      Pose pose, {
        double userHeightCm         = 170.0,
        UserProfile? userProfile,
        double gyroCorrectionFactor = 1.0,
      }) {
    final k       = pose.keypoints;
    final double imgW = pose.imageWidth;
    final double imgH = pose.imageHeight;

    // ── Validity helper ──────────────────────────────────────────────────────
    bool valid(int i) => i < k.length && k[i].score >= _minScore;

    // ── Pixel-space coordinate helpers ───────────────────────────────────────
    double px(int i) => k[i].x * imgW;
    double py(int i) => k[i].y * imgH;

    double dist2d(double x1, double y1, double x2, double y2) =>
        sqrt(pow(x1 - x2, 2) + pow(y1 - y2, 2));

    double distKp(int a, int b) => dist2d(px(a), py(a), px(b), py(b));

    (double, double) wmid(int iA, int iB) {
      final double sA = k[iA].score, sB = k[iB].score;
      final double t  = sA + sB;
      if (t <= 0) return ((px(iA) + px(iB)) / 2, (py(iA) + py(iB)) / 2);
      return (
      (px(iA) * sA + px(iB) * sB) / t,
      (py(iA) * sA + py(iB) * sB) / t,
      );
    }

    (double, double) lerpKp(int a, int b, double t) => (
    px(a) + (px(b) - px(a)) * t,
    py(a) + (py(b) - py(a)) * t,
    );

    // ── Gyro correction ──────────────────────────────────────────────────────
    final double gyro = gyroCorrectionFactor.clamp(0.70, 1.0);

    // ════════════════════════════════════════════════════════════════════════
    // HEAD-TOP ESTIMATION
    // ════════════════════════════════════════════════════════════════════════
    double headTopPy;
    {
      final double noseY = py(0);

      final bool lEarOk      = valid(3);
      final bool rEarOk      = valid(4);
      final double lEarScore = lEarOk ? k[3].score : 0;
      final double rEarScore = rEarOk ? k[4].score : 0;
      final int bestEarIdx   = lEarScore >= rEarScore ? 3 : 4;
      final bool anyEarOk    = lEarOk || rEarOk;

      if (anyEarOk && k[bestEarIdx].score >= 0.30) {
        final double earY      = py(bestEarIdx);
        final double noseToEar = (noseY - earY).abs();
        headTopPy = noseY - (noseToEar * _noseToEarMultiplier);
        debugLog('HeadTop: ear-based  noseY=${noseY.toStringAsFixed(1)} '
            'earY=${earY.toStringAsFixed(1)} '
            'headTopPy=${headTopPy.toStringAsFixed(1)}');
      } else if (valid(1) && valid(2)) {
        final double eyeMidY   = (py(1) + py(2)) / 2;
        final double noseToEye = (noseY - eyeMidY).abs();
        headTopPy = noseY - (noseToEye * 2.5);
        debugLog('HeadTop: eye-based  headTopPy=${headTopPy.toStringAsFixed(1)}');
      } else {
        headTopPy = noseY - imgH * 0.06;
        debugLog('HeadTop: fallback   headTopPy=${headTopPy.toStringAsFixed(1)}');
      }
    }

    // ════════════════════════════════════════════════════════════════════════
    // HEEL ESTIMATION
    // ════════════════════════════════════════════════════════════════════════
    double heelPy;
    {
      final bool lAnkOk = valid(15);
      final bool rAnkOk = valid(16);

      double ankleY = 0;
      if (lAnkOk && rAnkOk) {
        ankleY = max(py(15), py(16));
      } else if (lAnkOk) {
        ankleY = py(15);
      } else if (rAnkOk) {
        ankleY = py(16);
      }

      if (ankleY > 0) {
        final double rawSpan    = ankleY - headTopPy;
        final double heelOffset = rawSpan * _ankleToHeelFraction;
        heelPy = ankleY + heelOffset;
        debugLog('Heel: ankle-based  ankleY=${ankleY.toStringAsFixed(1)} '
            'offset=${heelOffset.toStringAsFixed(1)} '
            'heelPy=${heelPy.toStringAsFixed(1)}');
      } else {
        final bool lKneeOk = valid(13);
        final bool rKneeOk = valid(14);
        double kneeY = 0;
        if (lKneeOk && rKneeOk) {
          kneeY = max(py(13), py(14));
        } else if (lKneeOk) {
          kneeY = py(13);
        } else if (rKneeOk) {
          kneeY = py(14);
        }
        if (kneeY > 0) {
          final double estimatedHeight = (kneeY - headTopPy) / 0.47;
          heelPy = headTopPy + estimatedHeight;
          debugLog('Heel: knee-extrapolated  heelPy=${heelPy.toStringAsFixed(1)}');
        } else {
          heelPy = headTopPy + imgH * 0.80;
          debugLog('Heel: fallback  heelPy=${heelPy.toStringAsFixed(1)}');
        }
      }
    }

    // ════════════════════════════════════════════════════════════════════════
    // SCALE FACTOR
    // ════════════════════════════════════════════════════════════════════════
    double scale       = 0.0;
    String scaleMethod = '';

    final double fullSpanPx = (heelPy - headTopPy) / gyro;
    if (fullSpanPx > 20) {
      scale       = userHeightCm / fullSpanPx;
      scaleMethod = 'head-top→heel (corrected)';
    }

    // Fallback 1: shoulder-mid → ankle-mid
    if (scale == 0.0 && valid(5) && valid(6) && valid(15) && valid(16)) {
      final (_, shY)  = wmid(5, 6);
      final (_, ankY) = wmid(15, 16);
      final double pixelSpan = (ankY - shY).abs() / gyro;
      if (pixelSpan > 10) {
        scale       = (userHeightCm * 0.78) / pixelSpan;
        scaleMethod = 'shoulder→ankle (fallback-1)';
      }
    }

    // Fallback 2: nose → ankle
    if (scale == 0.0 && valid(0) && valid(15) && valid(16)) {
      final (_, ankY) = wmid(15, 16);
      final double pixelSpan = (ankY - py(0)).abs() / gyro;
      if (pixelSpan > 10) {
        scale       = (userHeightCm * 0.895) / pixelSpan;
        scaleMethod = 'nose→ankle (fallback-2)';
      }
    }

    // Fallback 3: hip → ankle
    if (scale == 0.0) {
      final int hipIdx = valid(11) ? 11 : (valid(12) ? 12 : -1);
      final int ankIdx = valid(15) ? 15 : (valid(16) ? 16 : -1);
      if (hipIdx >= 0 && ankIdx >= 0) {
        final double pixelSpan = (py(ankIdx) - py(hipIdx)).abs() / gyro;
        if (pixelSpan > 10) {
          scale       = (userHeightCm * 0.53) / pixelSpan;
          scaleMethod = 'hip→ankle (fallback-3)';
        }
      }
    }

    if (scale == 0.0) {
      throw Exception(
        "Cannot determine scale.\nEnsure full body (head to feet) is visible.",
      );
    }

    debugLog('Scale: ${scale.toStringAsFixed(4)} cm/px [$scaleMethod] '
        'gyro=${gyro.toStringAsFixed(3)}');

    // Convert pixel distance → cm
    double toCm(double pixels) => pixels * scale;

    // ── Shoulder sanity check ─────────────────────────────────────────────────
    if (valid(5) && valid(6)) {
      final double shChordCm = toCm(distKp(5, 6));
      final double shRatio   = shChordCm / userHeightCm;
      debugLog('Shoulder sanity: ${shChordCm.toStringAsFixed(1)} cm '
          '/ ${userHeightCm.toStringAsFixed(0)} cm = '
          '${shRatio.toStringAsFixed(3)} (expect 0.18–0.28)');
      if (shRatio < 0.18 || shRatio > 0.28) {
        debugLog('WARNING: shoulder/height ratio outside normal range. '
            'Ensure full body is in frame and person faces camera.');
      }
    }

    // ── Shoulder width ────────────────────────────────────────────────────────
    final double shoulderPx = (valid(5) && valid(6)) ? distKp(5, 6) : 0.0;
    // Raw shoulder width in cm (before calibration)
    final double shoulderCmRaw = toCm(shoulderPx);

    // ── Chord helper (bilateral: left half + right half) ──────────────────────
    double _chord({
      required bool hasL,
      required bool hasR,
      required (double, double) Function() getL,
      required (double, double) Function() getR,
      required double fallback,
    }) {
      if (!hasL || !hasR) return fallback;
      final (lx, ly) = getL();
      final (rx, ry) = getR();
      final double mx    = (lx + rx) / 2;
      final double my    = (ly + ry) / 2;
      final double halfL = dist2d(mx, my, lx, ly);
      final double halfR = dist2d(mx, my, rx, ry);
      return halfL + halfR;
    }

    // ── Chest (30 % torso) ────────────────────────────────────────────────────
    final bool chestOk = valid(5) && valid(6) && valid(11) && valid(12);
    final double chestPx = _chord(
      hasL: chestOk, hasR: chestOk,
      getL: () => lerpKp(5, 11, 0.30),
      getR: () => lerpKp(6, 12, 0.30),
      fallback: shoulderPx * 0.90,
    );

    // ── Waist (58 % torso) ────────────────────────────────────────────────────
    final bool waistOk = valid(5) && valid(6) && valid(11) && valid(12);
    final double waistFallback =
    (valid(11) && valid(12)) ? distKp(11, 12) * 0.88 : 0.0;
    final double waistPx = _chord(
      hasL: waistOk, hasR: waistOk,
      getL: () => lerpKp(5, 11, 0.58),
      getR: () => lerpKp(6, 12, 0.58),
      fallback: waistFallback,
    );

    final double chestChordCm = toCm(chestPx);
    final double waistChordCm = toCm(waistPx);

    debugLog('Chords (bilateral px→cm) '
        'sh:${shoulderCmRaw.toStringAsFixed(1)} '
        'ch:${chestChordCm.toStringAsFixed(1)} '
        'wa:${waistChordCm.toStringAsFixed(1)} cm');

    // ── Arm lengths (shoulder→elbow→wrist) ───────────────────────────────────
    double armLpx = 0.0, armRpx = 0.0;
    if (valid(5) && valid(7) && valid(9))  armLpx = distKp(5, 7) + distKp(7, 9);
    if (valid(6) && valid(8) && valid(10)) armRpx = distKp(6, 8) + distKp(8, 10);
    // Raw arm (sleeve) length in cm (before calibration)
    final double armAvgCmRaw = toCm(
      (armLpx > 0 && armRpx > 0) ? (armLpx + armRpx) / 2 : max(armLpx, armRpx),
    );

    // ── Leg lengths (hip→knee→ankle) ─────────────────────────────────────────
    double legLpx = 0.0, legRpx = 0.0;
    if (valid(11) && valid(13) && valid(15)) legLpx = distKp(11, 13) + distKp(13, 15);
    if (valid(12) && valid(14) && valid(16)) legRpx = distKp(12, 14) + distKp(14, 16);
    // Raw leg length in cm (before calibration)
    final double legAvgCmRaw = toCm(
      (legLpx > 0 && legRpx > 0) ? (legLpx + legRpx) / 2 : max(legLpx, legRpx),
    );

    // ── Torso lengths ─────────────────────────────────────────────────────────
    double upperBodyCm = 0.0, lowerBodyCm = 0.0;
    if (valid(5) && valid(6) && valid(11) && valid(12)) {
      final (shMx, shMy)   = wmid(5, 6);
      final (hipMx, hipMy) = wmid(11, 12);
      upperBodyCm = toCm(dist2d(shMx, shMy, hipMx, hipMy));
      if (valid(15) && valid(16)) {
        final (ankMx, ankMy) = wmid(15, 16);
        lowerBodyCm = toCm(dist2d(hipMx, hipMy, ankMx, ankMy));
      }
    }

    // ── Circumference estimation ──────────────────────────────────────────────
    final BuildType build = userProfile?.buildType ?? BuildType.average;
    final int age         = userProfile?.age ?? 28;
    final double height   = userProfile?.heightCm ?? userHeightCm;

    // Raw circumferences (before calibration)
    final double chestCircRaw = _circ(chestChordCm, _R.chest, build, age, height);
    final double waistCircRaw = _circ(waistChordCm, _R.waist, build, age, height);

    debugLog('Circums (raw) → ch:${chestCircRaw.toStringAsFixed(1)} '
        'wa:${waistCircRaw.toStringAsFixed(1)} cm');

    // ════════════════════════════════════════════════════════════════════════
    // CALIBRATION OFFSETS
    // Fixed offsets are added here, after all raw measurements are computed.
    // To re-tune, update the constants at the top of this class.
    // ════════════════════════════════════════════════════════════════════════
    final double shoulderCm = shoulderCmRaw + _calShoulder;
    final double chestCirc  = chestCircRaw  + _calChest;
    final double waistCirc  = waistCircRaw  + _calWaist;
    final double armAvgCm   = armAvgCmRaw   + _calSleeve;
    final double legAvgCm   = legAvgCmRaw   + _calLeg;

    debugLog('Calibrated → '
        'sh:${shoulderCm.toStringAsFixed(1)} '
        'ch:${chestCirc.toStringAsFixed(1)} '
        'wa:${waistCirc.toStringAsFixed(1)} '
        'arm:${armAvgCm.toStringAsFixed(1)} '
        'leg:${legAvgCm.toStringAsFixed(1)} cm');

    return MeasurementResult(
      id:              DateTime.now().millisecondsSinceEpoch.toString(),
      height:          userHeightCm,
      shoulderWidth:   shoulderCm,   // calibrated
      chest:           chestCirc,    // calibrated
      waist:           waistCirc,    // calibrated
      leftArmLength:   armAvgCm,     // calibrated
      rightArmLength:  armAvgCm,     // calibrated
      leftLegLength:   legAvgCm,     // calibrated
      rightLegLength:  legAvgCm,     // calibrated
      upperBodyLength: upperBodyCm,  // no offset defined — unchanged
      lowerBodyLength: lowerBodyCm,  // no offset defined — unchanged
      createdAt:       DateTime.now(),
    );
  }

  // ── Circumference from chord (Ramanujan ellipse + clothing ease) ──────────
  static double _circ(
      double chordCm,
      _R region,
      BuildType build,
      int age,
      double heightCm,
      ) {
    if (chordCm <= 0) return 0.0;

    const ratios = {
      _R.chest: {
        BuildType.lean: 0.68, BuildType.average: 0.76,
        BuildType.heavy: 0.86, BuildType.obese: 0.96,
      },
      _R.waist: {
        BuildType.lean: 0.52, BuildType.average: 0.65,
        BuildType.heavy: 0.80, BuildType.obese: 0.94,
      },
    };

    final double ageFactor = age < 22 ? 0.97
        : age < 30 ? 0.99
        : age < 40 ? 1.00
        : age < 50 ? 1.02
        : 1.04;

    final double hFactor = 170.0 / heightCm;

    final double a = chordCm / 2.0;
    final double b = a * ratios[region]![build]! * ageFactor * hFactor;

    final double h    = pow(a - b, 2) / pow(a + b, 2);
    final double circ = pi * (a + b) *
        (1.0 + (3.0 * h) / (10.0 + sqrt(4.0 - 3.0 * h)));

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
        return b == BuildType.lean    ? 3.0
            : b == BuildType.average ? 4.0
            : b == BuildType.heavy   ? 5.0
            : 6.0;
      case _R.waist:
        return b == BuildType.lean    ? 1.5
            : b == BuildType.average ? 2.5
            : b == BuildType.heavy   ? 3.5
            : 4.5;
    }
  }

  // ignore: avoid_print
  static void debugLog(String msg) => print('[MeasCalc] $msg');
}

enum _R { chest, waist }