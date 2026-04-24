import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/pose.dart';
import '../services/movenet_service.dart';
import '../services/image_processing_service.dart';

final moveNetServiceProvider = Provider<MoveNetService>((ref) => MoveNetService());

final poseProvider = StateNotifierProvider<PoseNotifier, Pose?>((ref) {
  return PoseNotifier(ref.read(moveNetServiceProvider));
});

class PoseNotifier extends StateNotifier<Pose?> {
  final MoveNetService         _movenet;
  final ImageProcessingService _imgProc = ImageProcessingService();

  static Pose? lastPose;
  bool _modelLoaded = false;

  PoseNotifier(this._movenet) : super(null);

  Future<void> detectPose(String imagePath) async {
    try {
      if (!_modelLoaded) {
        await _movenet.loadModel();
        _modelLoaded = true;
      }

      final input = await _imgProc.processImage(File(imagePath));
      // aspect ratio is now stored in _imgProc after processImage()
      final output = _movenet.runModel(input);
      final pose   = _movenet.parsePose(
        output,
        aspectRatio: _imgProc.lastAspectRatio,
      );

      print('[PoseNotifier] ar=${_imgProc.lastAspectRatio.toStringAsFixed(3)} '
          '(${_imgProc.lastOriginalWidth}×${_imgProc.lastOriginalHeight})');

      state    = pose;
      lastPose = pose;
    } catch (e) {
      print('[PoseNotifier] Error: $e');
      state    = null;
      lastPose = null;
    }
  }

  void clearPose() {
    state    = null;
    lastPose = null;
  }
}