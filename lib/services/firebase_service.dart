import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ─────────────────────────────
  // USER PROFILE
  // ─────────────────────────────

  Future<void> createUserProfile(String uid, Map<String, dynamic> data) async {
    await _db.collection('users').doc(uid).set(data);
  }

  Future<DocumentSnapshot> getUserProfile(String uid) async {
    return await _db.collection('users').doc(uid).get();
  }

  // ─────────────────────────────
  // SUBSCRIPTION
  // ─────────────────────────────

  Future<bool> hasActiveSubscription(String userId) async {
    try {
      final doc = await _db
          .collection('subscriptions')
          .doc(userId)
          .get();

      if (!doc.exists) return false;

      final data = doc.data()!;
      final status = data['status'] as String?;
      final expiryTimestamp = data['expiresAt'] as Timestamp?;

      if (status != 'active') return false;
      if (expiryTimestamp == null) return false;

      return expiryTimestamp.toDate().isAfter(DateTime.now());
    } catch (e) {
      return false;
    }
  }

  Future<void> saveSubscription({
    required String userId,
    required String plan,        // matches PaymentScreen call
    required String orderId,     // matches PaymentScreen call
    required String token,       // matches PaymentScreen call
    required int amountPKR,
  }) async {
    final duration = plan == 'pro_yearly'
        ? const Duration(days: 365)
        : const Duration(days: 30);

    await _db.collection('subscriptions').doc(userId).set({
      'status'    : 'active',
      'planName'  : plan,
      'orderId'   : orderId,
      'token'     : token,
      'amountPKR' : amountPKR,
      'startedAt' : Timestamp.now(),
      'expiresAt' : Timestamp.fromDate(DateTime.now().add(duration)),
    });
  }

  Future<void> cancelSubscription(String userId) async {
    await _db.collection('subscriptions').doc(userId).update({
      'status': 'cancelled',
    });
  }

  Future<Map<String, dynamic>?> getSubscription(String userId) async {
    try {
      final doc = await _db
          .collection('subscriptions')
          .doc(userId)
          .get();

      if (!doc.exists) return null;
      return doc.data();
    } catch (e) {
      return null;
    }
  }
}