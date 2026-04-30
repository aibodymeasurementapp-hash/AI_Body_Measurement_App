// lib/services/mlkit_pose_service.dart
//
// Drop-in replacement for MoveNetService.
// Provides the same detectPose(imagePath) interface used by PoseProvider,
// but runs Google ML Kit's PoseDetector instead of TFLite MoveNet.

import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import '../models/pose.dart' as app_models;

class MlKitPoseService {
  // ── Singleton ─────────────────────────────────────────────────────────────
  static final MlKitPoseService _instance = MlKitPoseService._internal();
  factory MlKitPoseService() => _instance;
  MlKitPoseService._internal();

  // ── ML Kit detector ───────────────────────────────────────────────────────
  final PoseDetector _detector = PoseDetector(
    options: PoseDetectorOptions(
      mode: PoseDetectionMode.single, // still images
    ),
  );

  bool _isDisposed = false;

  // ── Helper: get image dimensions using dart:ui (no extra package needed) ──
  Future<ui.Size> _getImageSize(Uint8List bytes) async {
    final codec      = await ui.instantiateImageCodec(bytes);
    final frameInfo  = await codec.getNextFrame();
    final image      = frameInfo.image;
    final size       = ui.Size(image.width.toDouble(), image.height.toDouble());
    image.dispose();
    codec.dispose();
    return size;
  }

  // ── Main method: detect pose from an image file path ─────────────────────
  /// Returns an [app_models.Pose] in MoveNet-index order (17 keypoints, 0-1 normalised).
  /// Returns null if no person was detected.
  Future<app_models.Pose?> detectFromPath(String imagePath) async {
    if (_isDisposed) throw StateError('MlKitPoseService has been disposed.');

    final file = File(imagePath);
    if (!await file.exists()) {
      throw FileSystemException('Image file not found', imagePath);
    }

    // Read bytes once — reused for both dimension check and ML Kit
    final Uint8List bytes = await file.readAsBytes();

    // Get pixel dimensions via dart:ui (no import conflicts)
    final ui.Size imgSize = await _getImageSize(bytes);
    final double imgW = imgSize.width;
    final double imgH = imgSize.height;

    // Run ML Kit detection
    final inputImage        = InputImage.fromFile(file);
    final List<Pose> mlPoses = await _detector.processImage(inputImage);

    if (mlPoses.isEmpty) {
      debugPrint('[MlKitPoseService] No pose detected in $imagePath');
      return null;
    }

    // Use the first (highest-confidence) detected pose
    final mlPose = mlPoses.first;

    // Convert to app model (normalised KeyPoint list in MoveNet index order)
    final pose = app_models.Pose.fromMlKit(
      mlPose,
      imageWidth:  imgW,
      imageHeight: imgH,
    );

    debugPrint('[MlKitPoseService] Detected pose — '
        'valid: ${pose.hasValidKeypoints()}  '
        'image: ${imgW.toInt()}×${imgH.toInt()}');

    return pose;
  }

  // ── Dispose ───────────────────────────────────────────────────────────────
  Future<void> dispose() async {
    if (_isDisposed) return;
    _isDisposed = true;
    await _detector.close();
  }
}