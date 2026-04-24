import '../models/user_profile.dart';

class AuthService {

  Future<void> _simulateNetworkDelay() async {
    await Future.delayed(const Duration(seconds: 2));
  }

  Future<UserProfile> login(String emailOrPhone, String password) async {
    await _simulateNetworkDelay();

    if (password.length < 6) {
      throw Exception('Invalid credentials');
    }

    return UserProfile(
      id:       'user_123',
      fullName: 'John Doe',
      email:    emailOrPhone.contains('@') ? emailOrPhone : 'john@example.com',
      phone:    emailOrPhone.contains('@') ? '+1234567890' : emailOrPhone,
      gender:   Gender.male,
      heightCm: 175,
      weightKg: 70,
      age:      28, // ← NEW: default mock age
    );
  }

  Future<UserProfile> register(
      UserProfile userProfile, String password) async {
    await _simulateNetworkDelay();

    if (password.length < 6) {
      throw Exception('Password must be at least 6 characters');
    }

    return userProfile.copyWith(
      id: 'user_${DateTime.now().millisecondsSinceEpoch}',
    );
  }

  Future<void> logout() async {
    await _simulateNetworkDelay();
  }
}