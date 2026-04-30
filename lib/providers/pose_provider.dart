// lib/providers/pose_provider.dart
//
// Unchanged from original EXCEPT:
//   - imports MlKitPoseService instead of MoveNetService
//   - calls detectFromPath() instead of the MoveNet pipeline

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/pose.dart';
import '../services/mlkit_pose_service.dart'; // ← only change

// ── Static last-pose reference (used by LiveCameraScreen) ─────────────────
// Keep this so LiveCameraScreen compile stays unchanged.
class PoseNotifier extends StateNotifier<Pose?> {
  static Pose? lastPose; // written by LiveCameraScreen directly

  final MlKitPoseService _service = MlKitPoseService();

  PoseNotifier() : super(null);

  Future<void> detectPose(String imagePath) async {
    try {
      final pose = await _service.detectFromPath(imagePath);
      state = pose;
    } catch (e) {
      state = null;
      rethrow; // let the UI layer handle / show the error
    }
  }

  void clearPose() => state = null;
}

final poseProvider = StateNotifierProvider<PoseNotifier, Pose?>(
      (ref) => PoseNotifier(),
);