class KeyPoint {
  final double x;     // normalised 0–1
  final double y;     // normalised 0–1
  final double score; // confidence 0–1

  const KeyPoint({required this.x, required this.y, required this.score});
}

class Pose {
  final List<KeyPoint> keypoints;

  /// originalWidth / originalHeight of the image BEFORE letterboxing.
  /// Used in MeasurementCalculator to recover true horizontal distances.
  final double aspectRatio;

  Pose(this.keypoints, {this.aspectRatio = 1.0});

  bool hasValidKeypoints() {
    const double minScore = 0.25;
    const List<int> required = [5, 6, 11, 12, 15, 16];
    return required.every(
          (i) => i < keypoints.length && keypoints[i].score >= minScore,
    );
  }
}