import 'dart:async';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/app_state_provider.dart';
import '../../providers/measurement_provider.dart';
import '../../services/image_processing_service.dart';
import '../../services/movenet_service.dart';
import '../../services/pose_validation_service.dart';
import '../../services/gyro_service.dart';
import '../../widgets/skeleton_painter.dart';
import '../../models/pose.dart';
import '../../providers/pose_provider.dart';

class LiveCameraScreen extends ConsumerStatefulWidget {
  const LiveCameraScreen({super.key});

  @override
  ConsumerState<LiveCameraScreen> createState() => _LiveCameraScreenState();
}

class _LiveCameraScreenState extends ConsumerState<LiveCameraScreen>
    with WidgetsBindingObserver {

  CameraController?     _controller;
  bool                  _isProcessingFrame = false;
  bool                  _isInitializing    = false;
  Pose?                 _livePose;
  PoseValidationResult? _liveValidation;
  bool                  _isCapturing       = false;
  Size?                 _previewSize;       // widget render size for skeleton
  bool                  _showGuide         = true;

  // Gyro
  final GyroService _gyro      = GyroService();
  double            _tiltDeg   = 0.0;
  double            _rollDeg   = 0.0;
  TiltLevel         _tiltLevel = TiltLevel.unknown;
  StreamSubscription<void>? _gyroUiSub;

  final MoveNetService         _movenet = MoveNetService();
  final ImageProcessingService _imgProc = ImageProcessingService();
  DateTime _lastInference = DateTime.fromMillisecondsSinceEpoch(0);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _gyro.startListening();
    _gyroUiSub = Stream.periodic(const Duration(milliseconds: 100)).listen((_) {
      if (!mounted) return;
      setState(() {
        _tiltDeg   = _gyro.tiltAngleDeg;
        _rollDeg   = _gyro.rollAngleDeg;
        _tiltLevel = _gyro.tiltLevel;
      });
    });
    _initCamera();
    Future.delayed(const Duration(seconds: 25),
            () { if (mounted) setState(() => _showGuide = false); });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_isInitializing) return;
    if (_controller == null || !_controller!.value.isInitialized) return;
    if (state == AppLifecycleState.inactive) {
      _stopCamera(); _gyro.stopListening();
    } else if (state == AppLifecycleState.resumed) {
      _gyro.startListening(); _initCamera();
    }
  }

  Future<void> _initCamera() async {
    if (_isInitializing) return;
    _isInitializing = true;
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) { _showError("No camera found."); return; }

      final camera = cameras.firstWhere(
            (c) => c.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );

      _controller = CameraController(
        camera,
        // FIX: Use medium resolution — low (240p) makes the person too small
        // in the frame, causing keypoints to cluster together and produce
        // shoulder chords of only 0.11 normalised units instead of ~0.25.
        ResolutionPreset.medium,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.yuv420,
      );
      await _controller!.initialize();
      await _movenet.loadModel();

      if (!mounted) return;

      // After rotation, portrait frame: width = camera height, height = camera width
      final camSize = _controller!.value.previewSize!;
      setState(() {
        _previewSize = Size(camSize.height, camSize.width);
      });
      _controller!.startImageStream(_onFrame);
    } catch (e) {
      _showError("Camera init failed: $e");
    } finally {
      _isInitializing = false;
    }
  }

  Future<void> _onFrame(CameraImage frame) async {
    if (_isProcessingFrame || _isCapturing) return;
    if (_controller == null || !_controller!.value.isInitialized) return;

    final now = DateTime.now();
    if (now.difference(_lastInference).inMilliseconds < 600) return;
    _lastInference = now;
    _isProcessingFrame = true;

    try {
      // processCameraImage stores aspect ratio internally
      final input  = await _imgProc.processCameraImage(frame);
      final output = _movenet.runModel(input);
      final pose   = _movenet.parsePose(
        output,
        aspectRatio: _imgProc.lastAspectRatio,
      );
      final validation = PoseValidationService.validate(pose);
      PoseNotifier.lastPose = pose;

      if (mounted) setState(() { _livePose = pose; _liveValidation = validation; });
    } catch (e) {
      debugPrint("Frame error: $e");
    } finally {
      _isProcessingFrame = false;
    }
  }

  Future<void> _captureAndMeasure() async {
    if (_isCapturing) return;
    setState(() => _isCapturing = true);

    try {
      if (_controller!.value.isStreamingImages) {
        await _controller!.stopImageStream();
      }
      final XFile photo = await _controller!.takePicture();

      final userProfile  = ref.read(appStateProvider).userProfile;
      final double height = userProfile?.heightCm ?? 170.0;
      // Gyro factor — clamp to [0.70, 1.0] for sensible corrections only
      final double gyro  = _gyro.correctionFactor.clamp(0.70, 1.0);

      debugPrint('[LiveCamera] capture gyro=${gyro.toStringAsFixed(3)} '
          'tilt=${_tiltDeg.toStringAsFixed(1)}°');

      await ref.read(measurementStateProvider.notifier)
          .processCameraMeasurements(
        photo.path, height,
        userProfile:          userProfile,
        gyroCorrectionFactor: gyro,
      );
    } catch (e) {
      _showError("Capture failed: $e");
      setState(() => _isCapturing = false);
      if (_controller != null && _controller!.value.isInitialized) {
        _controller!.startImageStream(_onFrame);
      }
    }
  }

  Future<void> _stopCamera() async {
    try {
      if (_controller != null && _controller!.value.isInitialized) {
        if (_controller!.value.isStreamingImages) {
          await _controller!.stopImageStream();
        }
        await _controller!.dispose();
      }
    } catch (e) { debugPrint("Camera dispose: $e"); }
    _controller = null;
  }

  Future<void> _navigateBack() async {
    await _stopCamera();
    if (mounted) context.canPop() ? context.pop() : context.goNamed('camera-measurement');
  }

  void _showError(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _gyroUiSub?.cancel();
    _gyro.stopListening();
    _stopCamera();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool validPose  = _liveValidation?.isValid ?? false;
    final bool canCapture = validPose && !_isCapturing;

    ref.listen(measurementStateProvider, (previous, next) {
      if (next.result != null && !next.isLoading) {
        ref.read(appStateProvider.notifier).setLatestResult(next.result!);
        context.goNamed('result');
      }
      if (next.error != null) {
        _showError(next.error!);
        setState(() => _isCapturing = false);
        if (_controller != null && _controller!.value.isInitialized) {
          _controller!.startImageStream(_onFrame);
        }
      }
    });

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          fit: StackFit.expand,
          children: [

            // Camera preview
            if (_controller != null && _controller!.value.isInitialized)
              CameraPreview(_controller!)
            else
              const Center(child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Colors.white),
                  SizedBox(height: 16),
                  Text("Initializing…", style: TextStyle(color: Colors.white)),
                ],
              )),

            // Body guide silhouette
            Positioned(
              top: 120, left: 60, right: 60, bottom: 160,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 500),
                opacity: _showGuide ? 1.0 : 0.0,
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white.withOpacity(0.4), width: 2),
                    borderRadius: BorderRadius.circular(120),
                  ),
                  child: const Center(child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.accessibility_new, color: Colors.white38, size: 56),
                      SizedBox(height: 8),
                      Text("Stand here — full body", style: TextStyle(color: Colors.white38, fontSize: 13)),
                    ],
                  )),
                ),
              ),
            ),

            // Skeleton overlay
            if (_livePose != null && _previewSize != null)
              Positioned.fill(
                child: CustomPaint(
                  painter: SkeletonPainter(
                    _livePose!,
                    imageSize: _previewSize!,
                    isValidPose: validPose,
                  ),
                ),
              ),

            // Border
            Positioned.fill(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: _livePose == null ? Colors.transparent
                        : canCapture ? Colors.green : Colors.red,
                    width: 5,
                  ),
                ),
              ),
            ),

            // Top bar
            Positioned(top: 0, left: 0, right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                color: Colors.black54,
                child: Row(children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: _navigateBack,
                  ),
                  const Text("Live Measurement",
                      style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                ]),
              ),
            ),

            // Instructions
            Positioned(top: 68, left: 16, right: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(8)),
                child: const Text(
                  "Stand 2–3m away  •  Full body visible\nArms slightly away  •  Face camera directly",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white, fontSize: 13),
                ),
              ),
            ),

            // Gyro indicator
            Positioned(top: 128, right: 12,
              child: _TiltBadge(
                tiltDeg: _tiltDeg, rollDeg: _rollDeg,
                level: _tiltLevel, statusMsg: _gyro.statusMessage,
                available: _gyro.isGyroAvailable,
              ),
            ),

            // Pose status
            if (_liveValidation != null)
              Positioned(bottom: 175, left: 16, right: 16,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: (validPose ? Colors.green : Colors.red).withOpacity(0.85),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    validPose ? "✅ Perfect pose! Tap capture"
                        : _liveValidation!.failureReason ?? "Adjust your position",
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                ),
              ),

            // Tilt warning (info only — never blocks)
            if (validPose && _tiltLevel == TiltLevel.bad)
              Positioned(bottom: 138, left: 16, right: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.88),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(_gyro.statusMessage,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.white, fontSize: 12)),
                ),
              ),

            // Capture button — pose only gates it
            Positioned(bottom: 48, left: 0, right: 0,
              child: Center(
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 300),
                  opacity: canCapture ? 1.0 : 0.35,
                  child: GestureDetector(
                    onTap: canCapture ? _captureAndMeasure : null,
                    child: Container(
                      width: 80, height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle, color: Colors.white,
                        border: Border.all(color: canCapture ? Colors.green : Colors.grey, width: 4),
                      ),
                      child: _isCapturing
                          ? const Padding(padding: EdgeInsets.all(20),
                          child: CircularProgressIndicator(color: Colors.green, strokeWidth: 3))
                          : Icon(Icons.camera_alt, size: 36,
                          color: canCapture ? Colors.green : Colors.grey.shade400),
                    ),
                  ),
                ),
              ),
            ),

            // Gyro debug readout
            if (_gyro.isGyroAvailable)
              Positioned(bottom: 8, right: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: Colors.black45, borderRadius: BorderRadius.circular(6)),
                  child: Text("T:${_tiltDeg.toStringAsFixed(1)}° R:${_rollDeg.toStringAsFixed(1)}°",
                      style: const TextStyle(color: Colors.white70, fontSize: 11)),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ── Tilt badge ────────────────────────────────────────────────────────────

class _TiltBadge extends StatelessWidget {
  final double tiltDeg, rollDeg;
  final TiltLevel level;
  final String statusMsg;
  final bool available;
  const _TiltBadge({required this.tiltDeg, required this.rollDeg,
    required this.level, required this.statusMsg, required this.available});

  Color get _bg => switch (level) {
    TiltLevel.good    => Colors.green.withOpacity(0.80),
    TiltLevel.warn    => Colors.orange.withOpacity(0.80),
    TiltLevel.bad     => Colors.red.withOpacity(0.80),
    TiltLevel.unknown => Colors.blueGrey.withOpacity(0.70),
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(color: _bg, borderRadius: BorderRadius.circular(20)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        if (available) SizedBox(width: 28, height: 28,
            child: CustomPaint(painter: _BubblePainter(
              dx: (rollDeg.clamp(-15.0, 15.0) / 15.0) * 10.0,
              dy: (tiltDeg.clamp(-15.0, 15.0) / 15.0) * 10.0,
              good: level == TiltLevel.good,
            ))),
        if (available) const SizedBox(width: 6),
        Flexible(child: Text(statusMsg,
            style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w500))),
      ]),
    );
  }
}

class _BubblePainter extends CustomPainter {
  final double dx, dy; final bool good;
  const _BubblePainter({required this.dx, required this.dy, required this.good});
  @override
  void paint(Canvas c, Size s) {
    final cx = s.width/2; final cy = s.height/2; final r = s.width/2 - 1;
    c.drawCircle(Offset(cx,cy), r, Paint()..color=Colors.white38..style=PaintingStyle.stroke..strokeWidth=1);
    final cp = Paint()..color=Colors.white30..strokeWidth=0.8;
    c.drawLine(Offset(cx-4,cy),Offset(cx+4,cy),cp);
    c.drawLine(Offset(cx,cy-4),Offset(cx,cy+4),cp);
    c.drawCircle(Offset((cx+dx).clamp(3.0,s.width-3),(cy+dy).clamp(3.0,s.height-3)), 5,
        Paint()..color=good?Colors.greenAccent:Colors.orangeAccent);
  }
  @override bool shouldRepaint(covariant _BubblePainter o) =>
      o.dx!=dx||o.dy!=dy||o.good!=good;
}