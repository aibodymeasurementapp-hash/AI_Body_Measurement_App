import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_profile.dart';
// RevenueCat removed — no payment imports needed in auth service

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<UserProfile> login(String email, String password) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    final uid = credential.user!.uid;

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

    return profileWithId;
  }

  Future<void> logout() async {
    await _auth.signOut();
  }
}