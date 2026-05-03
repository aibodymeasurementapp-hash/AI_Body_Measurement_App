enum Gender { male, female }

enum BuildType { lean, average, heavy, obese }

class UserProfile {
  final String id;
  final String fullName;
  final String email;
  final String phone;
  final Gender gender;
  final double heightCm;
  final double weightKg;
  final int age;
  final BuildType buildType; // ← added

  UserProfile({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.gender,
    required this.heightCm,
    required this.weightKg,
    required this.age,
    this.buildType = BuildType.average, // ← optional, defaults to average
  });

  factory UserProfile.fromMap(Map<String, dynamic> map, String id) {
    return UserProfile(
      id: id,
      fullName: map['fullName'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      gender: map['gender'] == 'female' ? Gender.female : Gender.male,
      heightCm: (map['heightCm'] ?? 170).toDouble(),
      weightKg: (map['weightKg'] ?? 0).toDouble(),
      age: map['age'] ?? 25,
      buildType: _buildTypeFromString(map['buildType']), // ← added
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'fullName': fullName,
      'email': email,
      'phone': phone,
      'gender': gender.name,
      'heightCm': heightCm,
      'weightKg': weightKg,
      'age': age,
      'buildType': buildType.name, // ← added
    };
  }

  // ── Helper to safely parse buildType from Firestore string ──
  static BuildType _buildTypeFromString(String? value) {
    switch (value) {
      case 'lean':    return BuildType.lean;
      case 'heavy':   return BuildType.heavy;
      case 'obese':   return BuildType.obese;
      default:        return BuildType.average;
    }
  }
}