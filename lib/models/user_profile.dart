import 'dart:math';

class UserProfile {
  final String id;
  final String fullName;
  final String email;
  final String phone;
  final Gender gender;
  final double heightCm;
  final double weightKg;
  final int age; // ← NEW: required for circumference depth estimation

  UserProfile({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.gender,
    required this.heightCm,
    required this.weightKg,
    required this.age, // ← NEW
  });

  // ── Derived helpers ──────────────────────────────────────────────

  /// Body Mass Index
  double get bmi => weightKg / pow(heightCm / 100.0, 2);

  /// Build classification based on BMI — used in circumference estimation.
  /// BMI is more reliable than age alone for depth ratios.
  BuildType get buildType {
    if (bmi < 18.5) return BuildType.lean;
    if (bmi < 25.0) return BuildType.average;
    if (bmi < 30.0) return BuildType.heavy;
    return BuildType.obese;
  }

  UserProfile copyWith({
    String? id,
    String? fullName,
    String? email,
    String? phone,
    Gender? gender,
    double? heightCm,
    double? weightKg,
    int? age,
  }) {
    return UserProfile(
      id:        id        ?? this.id,
      fullName:  fullName  ?? this.fullName,
      email:     email     ?? this.email,
      phone:     phone     ?? this.phone,
      gender:    gender    ?? this.gender,
      heightCm:  heightCm  ?? this.heightCm,
      weightKg:  weightKg  ?? this.weightKg,
      age:       age       ?? this.age,
    );
  }
}

enum Gender { male, female, other }

/// Body build classification derived from BMI.
/// Controls depth ratios in MeasurementCalculator.
enum BuildType {
  lean,    // BMI < 18.5  → shallow depth
  average, // BMI 18.5–25 → normal depth
  heavy,   // BMI 25–30   → deeper torso
  obese,   // BMI ≥ 30    → significantly deeper torso
}