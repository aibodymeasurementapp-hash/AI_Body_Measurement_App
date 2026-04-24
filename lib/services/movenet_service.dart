import 'package:tflite_flutter/tflite_flutter.dart';
import '../models/pose.dart';

/// MoveNet Thunder wrapper.
///
/// Output tensor shape confirmed from logs: [1, 1, 17, 3]
/// → output[0][0][i] = [y_norm, x_norm, score] for keypoint i
class MoveNetService {
  static final MoveNetService _instance = MoveNetService._internal();
  factory MoveNetService() => _instance;
  MoveNetService._internal();

  Interpreter? _interpreter;
  bool _modelLoaded = false;

  Future<void> loadModel() async {
    if (_modelLoaded) return;
    try {
      _interpreter = await Interpreter.fromAsset(
        'assets/models/movenet_thunder.tflite',
      );
      _modelLoaded = true;

      final inShape  = _interpreter!.getInputTensor(0).shape;
      final outShape = _interpreter!.getOutputTensor(0).shape;
      print('[MoveNet] Input  shape: $inShape');   // expect [1,256,256,3]
      print('[MoveNet] Output shape: $outShape');  // expect [1,1,17,3]
      print('[MoveNet] Model loaded ✓');
    } catch (e) {
      print('[MoveNet] Load error: $e');
    }
  }

  List<List<List<List<double>>>> runModel(List input) {
    if (_interpreter == null) throw Exception("Interpreter not initialized");

    final inputTensor = input.reshape([1, 256, 256, 3]);

    // Output buffer matches confirmed shape [1][1][17][3]
    final output = List.generate(
      1, (_) => List.generate(
      1, (_) => List.generate(
      17, (_) => List.filled(3, 0.0),
    ),
    ),
    );

    _interpreter!.run(inputTensor, output);

    // Quick sanity log — nose should be near centre if person is centred
    final nose = output[0][0][0];
    print('[MoveNet] nose → y=${nose[0].toStringAsFixed(3)} '
        'x=${nose[1].toStringAsFixed(3)} '
        'score=${nose[2].toStringAsFixed(3)}');

    return output;
  }

  /// Parse output tensor into a Pose.
  /// [aspectRatio] = originalImageWidth / originalImageHeight (from ImageProcessingService)
  Pose parsePose(
      List<List<List<List<double>>>> output, {
        double aspectRatio = 1.0,
      }) {
    final raw = output[0][0]; // [17][3]

    final keypoints = List.generate(17, (i) {
      // MoveNet order: [y, x, score]
      return KeyPoint(
        x:     raw[i][1].clamp(0.0, 1.0),
        y:     raw[i][0].clamp(0.0, 1.0),
        score: raw[i][2].clamp(0.0, 1.0),
      );
    });

    return Pose(keypoints, aspectRatio: aspectRatio);
  }
}