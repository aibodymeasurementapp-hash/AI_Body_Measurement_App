import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_profile.dart';
<<<<<<< HEAD
// RevenueCat removed — no payment imports needed in auth service
=======
import 'revenuecat_service.dart'; // ← single import, removed duplicate firebase_auth
>>>>>>> 545a1120d8ac65c628454bf89699a4ff8fd55a89

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<UserProfile> login(String email, String password) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    final uid = credential.user!.uid;

<<<<<<< HEAD
=======
    // ✅ Tie RevenueCat identity to Firebase UID after login
    await RevenueCatService.loginUser(uid);

>>>>>>> 545a1120d8ac65c628454bf89699a4ff8fd55a89
    // Fetch profile from Firestore
    final doc = await _firestore.collection('users').doc(uid).get();
    return UserProfile.fromMap(doc.data()!, uid);
  }

  Future<UserProfile> register(UserProfile userProfile, String password) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: userProfile.email,
      password: password,
    );
    final uid = credential.user!.uid;

<<<<<<< HEAD
=======
    // Save profile to Firestore
>>>>>>> 545a1120d8ac65c628454bf89699a4ff8fd55a89
    final profileWithId = UserProfile(
      id: uid,
      fullName: userProfile.fullName,
      email: userProfile.email,
      phone: userProfile.phone,
      gender: userProfile.gender,
      heightCm: userProfile.heightCm,
      weightKg: userProfile.weightKg,
      age: userProfile.age,
    );

    await _firestore.collection('users').doc(uid).set(profileWithId.toMap());

<<<<<<< HEAD
=======
    // ✅ Tie RevenueCat identity to Firebase UID after registration
    await RevenueCatService.loginUser(uid);

>>>>>>> 545a1120d8ac65c628454bf89699a4ff8fd55a89
    return profileWithId;
  }

  Future<void> logout() async {
<<<<<<< HEAD
=======
    // ✅ Clear RevenueCat identity BEFORE Firebase sign-out
    await RevenueCatService.logoutUser();
>>>>>>> 545a1120d8ac65c628454bf89699a4ff8fd55a89
    await _auth.signOut();
  }
}