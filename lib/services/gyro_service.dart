import 'dart:async';
import 'dart:math';
import 'package:sensors_plus/sensors_plus.dart';

/// Reads the device accelerometer to measure phone tilt and compute a
/// correction factor for the pixel→cm scale in MeasurementCalculator.
///
/// ── Graceful degradation ──────────────────────────────────────────────────
/// • If the device has no accelerometer sensor, the service silently falls
///   back to correctionFactor = 1.0 and isGyroAvailable = false.
///   The app continues to work normally — gyro is treated as optional.
/// • The service NEVER throws or blocks the capture flow.
///
/// ── Relaxed tilt thresholds ───────────────────────────────────────────────
/// We warn the user when tilt is significant but NEVER hard-block capture.
/// The user can always take a photo; we just show a colour-coded hint.
/// The correction factor is applied automatically regardless.
///
///   |tilt| ≤ 15°  → green   "Camera level ✅"
///   |tilt| ≤ 25°  → orange  "Slight tilt — results may vary"
///   |tilt| > 25°  → red     "Large tilt — please straighten"
///
/// At 25° the cos correction (0.906) keeps error within ~10%, which is
/// acceptable for clothing size recommendation (S/M/L/XL bands are ~10 cm).

class GyroService {
  // ── Singleton ──────────────────────────────────────────────────────────
  static final GyroService _instance = GyroService._internal();
  factory GyroService() => _instance;
  GyroService._internal();

  // ── Internal state ─────────────────────────────────────────────────────
  double _tiltAngleDeg     = 0.0;
  double _rollAngleDeg     = 0.0;
  double _correctionFactor = 1.0;
  bool   _gyroAvailable    = false;
  bool   _isListening      = false;

  StreamSubscription<AccelerometerEvent>? _sub;

  // ── Relaxed warning thresholds (degrees) ───────────────────────────────
  // These are WARNINGS only — never used to block capture.
  static const double _warnTiltDeg = 15.0;
  static const double _warnRollDeg = 10.0;

  // ── Public getters ──────────────────────────────────────────────────────

  bool   get isGyroAvailable  => _gyroAvailable;
  double get tiltAngleDeg     => _tiltAngleDeg;
  double get rollAngleDeg     => _rollAngleDeg;

  /// cos(tilt) — always in [0.5, 1.0].
  /// Multiply pixel span by this to correct for forward/backward phone tilt.
  double get correctionFactor => _correctionFactor;

  /// Colour-coded tilt severity for UI.
  TiltLevel get tiltLevel {
    if (!_gyroAvailable) return TiltLevel.unknown;
    final double tilt = _tiltAngleDeg.abs();
    final double roll = _rollAngleDeg.abs();
    if (tilt <= _warnTiltDeg && roll <= _warnRollDeg) return TiltLevel.good;
    if (tilt <= 25.0) return TiltLevel.warn;
    return TiltLevel.bad;
  }

  /// Human-readable status string for the UI overlay.
  String get statusMessage {
    if (!_gyroAvailable) return "📱 Hold phone steady";
    switch (tiltLevel) {
      case TiltLevel.good:
        return "📱 Camera level ✅";
      case TiltLevel.warn:
        return "📐 Tilt ${_tiltAngleDeg.abs().toStringAsFixed(1)}° "
            "— slight accuracy impact";
      case TiltLevel.bad:
        return "⚠️ Tilt ${_tiltAngleDeg.abs().toStringAsFixed(1)}° "
            "— straighten for best results";
      case TiltLevel.unknown:
        return "📱 Hold phone steady";
    }
  }

  // ── Start listening ─────────────────────────────────────────────────────

  void startListening() {
    if (_isListening) return;
    _isListening = true;

    try {
      _sub = accelerometerEventStream(
        samplingPeriod: const Duration(milliseconds: 150),
      ).listen(
        _onAccelerometer,
        onError: (_) {
          // Sensor unavailable or permission denied — silent fallback
          _gyroAvailable    = false;
          _correctionFactor = 1.0;
        },
        cancelOnError: false,
      );
    } catch (_) {
      // accelerometerEventStream() itself threw (simulator / old device)
      _gyroAvailable    = false;
      _correctionFactor = 1.0;
    }
  }

  void stopListening() {
    _sub?.cancel();
    _sub         = null;
    _isListening = false;
  }

  // ── Sensor callback ─────────────────────────────────────────────────────

  void _onAccelerometer(AccelerometerEvent e) {
    _gyroAvailable = true;

    // Pitch (forward / backward tilt of the top of the phone)
    // Perfectly upright portrait: y ≈ −9.8, z ≈ 0
    final double tiltRad = atan2(e.z, -e.y);
    _tiltAngleDeg = tiltRad * (180.0 / pi);

    // Roll (left / right lean)
    final double rollRad = atan2(e.x, -e.y);
    _rollAngleDeg = rollRad * (180.0 / pi);

    // Correction: cos(tilt), clamped to [0.5, 1.0] for safety
    _correctionFactor = cos(tiltRad).clamp(0.5, 1.0);
  }

  /// Call this at capture time to store tilt metadata alongside the result.
  Map<String, dynamic> snapshot() => {
    'gyroAvailable':    _gyroAvailable,
    'tiltAngleDeg':     _tiltAngleDeg,
    'rollAngleDeg':     _rollAngleDeg,
    'correctionFactor': _correctionFactor,
    'tiltLevel':        tiltLevel.name,
  };
}

/// Colour-coded severity of the current phone tilt.
enum TiltLevel { good, warn, bad, unknown }