// lib/models/pose.dart
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart'
as mlkit;

// ── KeyPoint ──────────────────────────────────────────────────────────────────
class KeyPoint {
  final double x;     // normalised [0,1]
  final double y;     // normalised [0,1]
  final double score; // confidence [0,1]
  const KeyPoint({required this.x, required this.y, required this.score});
}

// ── Pose ──────────────────────────────────────────────────────────────────────
class Pose {
  final List<KeyPoint> keypoints; // 17 kps in MoveNet index order
  final double aspectRatio;       // width / height (for overlay painters)
  final double imageWidth;        // actual pixel width
  final double imageHeight;       // actual pixel height

  const Pose({
    required this.keypoints,
    this.aspectRatio = 1.0,
    this.imageWidth  = 1.0,
    this.imageHeight = 1.0,
  });

  // MoveNet index → ML Kit landmark type
  static const List<mlkit.PoseLandmarkType> _indexToType = [
    mlkit.PoseLandmarkType.nose,           //  0
    mlkit.PoseLandmarkType.leftEye,        //  1
    mlkit.PoseLandmarkType.rightEye,       //  2
    mlkit.PoseLandmarkType.leftEar,        //  3
    mlkit.PoseLandmarkType.rightEar,       //  4
    mlkit.PoseLandmarkType.leftShoulder,   //  5
    mlkit.PoseLandmarkType.rightShoulder,  //  6
    mlkit.PoseLandmarkType.leftElbow,      //  7
    mlkit.PoseLandmarkType.rightElbow,     //  8
    mlkit.PoseLandmarkType.leftWrist,      //  9
    mlkit.PoseLandmarkType.rightWrist,     // 10
    mlkit.PoseLandmarkType.leftHip,        // 11
    mlkit.PoseLandmarkType.rightHip,       // 12
    mlkit.PoseLandmarkType.leftKnee,       // 13
    mlkit.PoseLandmarkType.rightKnee,      // 14
    mlkit.PoseLandmarkType.leftAnkle,      // 15
    mlkit.PoseLandmarkType.rightAnkle,     // 16
  ];

  factory Pose.fromMlKit(
      mlkit.Pose mlPose, {
        required double imageWidth,
        required double imageHeight,
      }) {
    final keypoints = List.generate(_indexToType.length, (i) {
      final landmark = mlPose.landmarks[_indexToType[i]];
      if (landmark == null) return const KeyPoint(x: 0, y: 0, score: 0);
      return KeyPoint(
        x:     landmark.x / imageWidth,
        y:     landmark.y / imageHeight,
        score: landmark.likelihood,
      );
    });
    return Pose(
      keypoints:   keypoints,
      aspectRatio: imageWidth / imageHeight,
      imageWidth:  imageWidth,
      imageHeight: imageHeight,
    );
  }

  // ── Convenience accessors ─────────────────────────────────────────────────
  KeyPoint get nose          => keypoints[0];
  KeyPoint get leftEye       => keypoints[1];
  KeyPoint get rightEye      => keypoints[2];
  KeyPoint get leftEar       => keypoints[3];
  KeyPoint get rightEar      => keypoints[4];
  KeyPoint get leftShoulder  => keypoints[5];
  KeyPoint get rightShoulder => keypoints[6];
  KeyPoint get leftElbow     => keypoints[7];
  KeyPoint get rightElbow    => keypoints[8];
  KeyPoint get leftWrist     => keypoints[9];
  KeyPoint get rightWrist    => keypoints[10];
  KeyPoint get leftHip       => keypoints[11];
  KeyPoint get rightHip      => keypoints[12];
  KeyPoint get leftKnee      => keypoints[13];
  KeyPoint get rightKnee     => keypoints[14];
  KeyPoint get leftAnkle     => keypoints[15];
  KeyPoint get rightAnkle    => keypoints[16];

  // ── Basic validity (used by camera overlay, existing callers) ─────────────
  bool hasValidKeypoints({double minScore = 0.25}) {
    const core = [5, 6, 11, 12]; // shoulders + hips
    return core.every((i) => i < keypoints.length && keypoints[i].score >= minScore);
  }

  // ── Strict validity for height measurement ────────────────────────────────
  /// Returns true only when the pose is reliable enough for height/measurement.
  /// Requires nose, ears, shoulders, hips, and ankles all above [minScore],
  /// person upright, and shoulders/hips roughly level.
  bool isValidForMeasurement({double minScore = 0.35}) {
    const required = [0, 3, 4, 5, 6, 11, 12, 15, 16];
    for (final i in required) {
      if (i >= keypoints.length || keypoints[i].score < minScore) return false;
    }
    // Nose must be above hip midpoint (upright check)
    final hipMidY = (leftHip.y + rightHip.y) / 2;
    if (nose.y >= hipMidY) return false;
    // Shoulders roughly level
    if ((leftShoulder.y - rightShoulder.y).abs() > 0.08) return false;
    // Hips roughly level
    if ((leftHip.y - rightHip.y).abs() > 0.08) return false;
    return true;
  }

  /// True when the person is not laterally leaning (shoulder-mid ≈ hip-mid X).
  bool isLaterallyUpright() {
    final sMidX = (leftShoulder.x + rightShoulder.x) / 2;
    final hMidX = (leftHip.x + rightHip.x) / 2;
    return (sMidX - hMidX).abs() < 0.05;
  }
}