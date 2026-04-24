import 'package:flutter/material.dart';
import '../models/pose.dart';

class SkeletonPainter extends CustomPainter {

  final Pose pose;
  final Size imageSize;
  final bool isValidPose;

  SkeletonPainter(
      this.pose, {
        required this.imageSize,
        required this.isValidPose,
      });

  @override
  void paint(Canvas canvas, Size size) {

    final paint = Paint()
      ..color = isValidPose ? Colors.green : Colors.red
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final pointPaint = Paint()
      ..color = isValidPose ? Colors.green : Colors.red
      ..style = PaintingStyle.fill;

    double scaleX = size.width / imageSize.width;
    double scaleY = size.height / imageSize.height;

    Offset toOffset(KeyPoint p) {
      return Offset(
        p.x * imageSize.width * scaleX,
        p.y * imageSize.height * scaleY,
      );
    }

    final points = pose.keypoints;

    /// Draw keypoints
    for (int i = 5; i < points.length; i++) {

      final p = points[i];

      if (p.score < 0.3) continue;

      final offset = toOffset(p);

      canvas.drawCircle(offset, 4, pointPaint);
    }

    /// Skeleton connections
    final connections = [

      [5, 6], // shoulders
      [5, 7],
      [7, 9],
      [6, 8],
      [8, 10],

      [5, 11],
      [6, 12],

      [11, 12],

      [11, 13],
      [13, 15],

      [12, 14],
      [14, 16],
    ];

    for (var c in connections) {

      final p1 = points[c[0]];
      final p2 = points[c[1]];

      if (p1.score < 0.3 || p2.score < 0.3) continue;

      final o1 = toOffset(p1);
      final o2 = toOffset(p2);

      canvas.drawLine(o1, o2, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}