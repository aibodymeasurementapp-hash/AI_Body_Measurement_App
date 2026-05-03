import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MeasurementHistoryItem {
  final String id;
  final String source;
  final DateTime createdAt;
  final double height;
  final double shoulderWidth;
  final double chest;
  final double waist;
  final double leftArmLength;
  final double rightArmLength;
  final double leftLegLength;
  final double rightLegLength;

  const MeasurementHistoryItem({
    required this.id,
    required this.source,
    required this.createdAt,
    required this.height,
    required this.shoulderWidth,
    required this.chest,
    required this.waist,
    required this.leftArmLength,
    required this.rightArmLength,
    required this.leftLegLength,
    required this.rightLegLength,
  });

  factory MeasurementHistoryItem.fromDoc(
      QueryDocumentSnapshot<Map<String, dynamic>> doc,
      ) {
    final data = doc.data();

    return MeasurementHistoryItem(
      id: doc.id,
      source: data['source']?.toString() ?? 'unknown',
      createdAt: _readDate(data['createdAt']),
      height: _readDouble(data['height']),
      shoulderWidth: _readDouble(data['shoulderWidth']),
      chest: _readDouble(data['chest']),
      waist: _readDouble(data['waist']),
      leftArmLength: _readDouble(data['leftArmLength']),
      rightArmLength: _readDouble(data['rightArmLength']),
      leftLegLength: _readDouble(data['leftLegLength']),
      rightLegLength: _readDouble(data['rightLegLength']),
    );
  }

  static double _readDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0.0;
  }

  static DateTime _readDate(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
    return DateTime.now();
  }
}

class MeasurementHistoryService {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  MeasurementHistoryService({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  String get _uid {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('No logged-in user found.');
    }
    return user.uid;
  }

  CollectionReference<Map<String, dynamic>> get _historyCollection {
    return _firestore
        .collection('users')
        .doc(_uid)
        .collection('measurement_history');
  }

  Future<void> saveMeasurementResult({
    required String source,
    required DateTime createdAt,
    required double height,
    required double shoulderWidth,
    required double chest,
    required double waist,
    required double leftArmLength,
    required double rightArmLength,
    required double leftLegLength,
    required double rightLegLength,
  }) async {
    await _historyCollection.add({
      'userId': _uid,
      'source': source,
      'createdAt': Timestamp.fromDate(createdAt),
      'savedAt': FieldValue.serverTimestamp(),
      'height': height,
      'shoulderWidth': shoulderWidth,
      'chest': chest,
      'waist': waist,
      'leftArmLength': leftArmLength,
      'rightArmLength': rightArmLength,
      'leftLegLength': leftLegLength,
      'rightLegLength': rightLegLength,
    });
  }

  Stream<List<MeasurementHistoryItem>> watchUserHistory() {
    return _historyCollection
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
          .map((doc) => MeasurementHistoryItem.fromDoc(doc))
          .toList(),
    );
  }
}

final measurementHistoryServiceProvider =
Provider<MeasurementHistoryService>((ref) {
  return MeasurementHistoryService();
});

final measurementHistoryProvider =
StreamProvider.autoDispose<List<MeasurementHistoryItem>>((ref) {
  final service = ref.watch(measurementHistoryServiceProvider);
  return service.watchUserHistory();
});