import 'dart:io';
import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:image/image.dart' as img;

/// Prepares images for MoveNet inference.
///
/// KEY FIX: We letterbox instead of squash.
/// The image is fit inside 256×256 with black padding on the short sides,
/// preserving true aspect ratio. This means MoveNet keypoint coordinates
/// (normalised 0–1) remain proportional to the ORIGINAL image geometry.
///
/// We also store the original pixel dimensions so the calculator can
/// recover true cm distances from normalised coords.
class ImageProcessingService {
  static const int inputSize = 256;

  /// Original width of the last processed image (before any transformation).
  int lastOriginalWidth  = 256;
  /// Original height of the last processed image.
  int lastOriginalHeight = 256;
  /// lastOriginalWidth / lastOriginalHeight
  double get lastAspectRatio =>
      lastOriginalWidth / lastOriginalHeight.toDouble();

  // ── Still image (gallery / camera capture) ────────────────────────────
  Future<Uint8List> processImage(File imageFile) async {
    final bytes = await imageFile.readAsBytes();
    img.Image? image = img.decodeImage(bytes);
    if (image == null) throw Exception("Image decode failed");

    lastOriginalWidth  = image.width;
    lastOriginalHeight = image.height;

    return _letterboxToInput(image);
  }

  // ── Live camera frame ──────────────────────────────────────────────────
  Future<Uint8List> processCameraImage(CameraImage cameraImage) async {
    img.Image image;

    if (cameraImage.format.group == ImageFormatGroup.yuv420) {
      image = _convertYUV420(cameraImage);
    } else if (cameraImage.format.group == ImageFormatGroup.bgra8888) {
      image = _convertBGRA8888(cameraImage);
    } else {
      throw Exception("Unsupported format: ${cameraImage.format.group}");
    }

    // Android delivers landscape frames — rotate to portrait
    image = img.copyRotate(image, angle: 90);

    lastOriginalWidth  = image.width;
    lastOriginalHeight = image.height;

    return _letterboxToInput(image);
  }

  // ── Letterbox resize ───────────────────────────────────────────────────
  //
  // Fit the image inside 256×256 while preserving aspect ratio.
  // Black padding fills the remaining space.
  //
  // Example: 480×640 portrait image (AR=0.75)
  //   scaledW = 256 × 0.75 = 192,  scaledH = 256
  //   offsetX = (256−192)/2 = 32   (32px black left & right)
  //
  // MoveNet normalised coords are then in:
  //   x ∈ [32/256, 224/256] = [0.125, 0.875]
  //
  // The MeasurementCalculator accounts for these offsets via the
  // aspect ratio stored here.
  Uint8List _letterboxToInput(img.Image image) {
    final int origW = image.width;
    final int origH = image.height;

    final double scale = inputSize / (origW > origH ? origW : origH).toDouble();
    final int scaledW = (origW * scale).round().clamp(1, inputSize);
    final int scaledH = (origH * scale).round().clamp(1, inputSize);

    final img.Image resized = img.copyResize(
      image,
      width: scaledW,
      height: scaledH,
      interpolation: img.Interpolation.linear,
    );

    // Black canvas
    final img.Image canvas = img.Image(width: inputSize, height: inputSize);
    img.fill(canvas, color: img.ColorRgb8(0, 0, 0));

    final int offsetX = (inputSize - scaledW) ~/ 2;
    final int offsetY = (inputSize - scaledH) ~/ 2;
    img.compositeImage(canvas, resized, dstX: offsetX, dstY: offsetY);

    final Uint8List input = Uint8List(inputSize * inputSize * 3);
    int idx = 0;
    for (int y = 0; y < inputSize; y++) {
      for (int x = 0; x < inputSize; x++) {
        final pixel = canvas.getPixel(x, y);
        input[idx++] = pixel.r.toInt();
        input[idx++] = pixel.g.toInt();
        input[idx++] = pixel.b.toInt();
      }
    }
    return input;
  }

  // ── YUV420 → RGB ────────────────────────────────────────────────────────
  img.Image _convertYUV420(CameraImage image) {
    final int width  = image.width;
    final int height = image.height;

    final yBytes  = image.planes[0].bytes;
    final uBytes  = image.planes[1].bytes;
    final vBytes  = image.planes[2].bytes;

    final int yRowStride    = image.planes[0].bytesPerRow;
    final int uvRowStride   = image.planes[1].bytesPerRow;
    final int uvPixelStride = image.planes[1].bytesPerPixel ?? 1;

    final result = img.Image(width: width, height: height);

    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        final int yIdx  = y * yRowStride + x;
        final int uvIdx = (y ~/ 2) * uvRowStride + (x ~/ 2) * uvPixelStride;

        final int yVal = yBytes[yIdx]  & 0xFF;
        final int uVal = (uBytes[uvIdx] & 0xFF) - 128;
        final int vVal = (vBytes[uvIdx] & 0xFF) - 128;

        final int r = (yVal + 1.402    * vVal).round().clamp(0, 255);
        final int g = (yVal - 0.344136 * uVal - 0.714136 * vVal).round().clamp(0, 255);
        final int b = (yVal + 1.772    * uVal).round().clamp(0, 255);

        result.setPixelRgb(x, y, r, g, b);
      }
    }
    return result;
  }

  // ── BGRA8888 → RGB (iOS) ─────────────────────────────────────────────────
  img.Image _convertBGRA8888(CameraImage image) {
    final bytes  = image.planes[0].bytes;
    final result = img.Image(width: image.width, height: image.height);

    for (int i = 0; i < bytes.length; i += 4) {
      final int pixelIndex = i ~/ 4;
      final int x = pixelIndex % image.width;
      final int y = pixelIndex ~/ image.width;
      result.setPixelRgb(x, y, bytes[i + 2], bytes[i + 1], bytes[i]);
    }
    return result;
  }
}