import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../services/mlkit_pose_service.dart';   // ← was MoveNetService
import '../../services/pose_validation_service.dart';
import '../../models/pose.dart';

// ─────────────────────────────────────────────────────────────────────────────
// DATA MODEL
// ─────────────────────────────────────────────────────────────────────────────

class _Reading {
  final int    index;
  final double noseY, noseScore;
  final double lShoulderX, lShoulderY, lShoulderScore;
  final double rShoulderX, rShoulderY, rShoulderScore;
  final double lHipX, lHipY, lHipScore;
  final double rHipX, rHipY, rHipScore;
  final double lAnkleX, lAnkleY, lAnkleScore;
  final double rAnkleX, rAnkleY, rAnkleScore;
  final double lElbowX, lElbowY, lElbowScore;
  final double rElbowX, rElbowY, rElbowScore;
  final double lWristX, lWristY, lWristScore;
  final double rWristX, rWristY, rWristScore;
  final double lKneeX,  lKneeY,  lKneeScore;
  final double rKneeX,  rKneeY,  rKneeScore;

  final double shoulderSpanNorm;
  final double hipSpanNorm;
  final double noseToAnkleNorm;
  final double shoulderToAnkleNorm;
  final double upperBodyNorm;
  final double lArmNorm;
  final double rArmNorm;
  final double lLegNorm;
  final double rLegNorm;
  final double lHipToAnkleNorm;
  final double rHipToAnkleNorm;

  final double aspectRatio;

  _Reading({
    required this.index,
    required this.noseY,            required this.noseScore,
    required this.lShoulderX,       required this.lShoulderY,  required this.lShoulderScore,
    required this.rShoulderX,       required this.rShoulderY,  required this.rShoulderScore,
    required this.lHipX,            required this.lHipY,       required this.lHipScore,
    required this.rHipX,            required this.rHipY,       required this.rHipScore,
    required this.lAnkleX,          required this.lAnkleY,     required this.lAnkleScore,
    required this.rAnkleX,          required this.rAnkleY,     required this.rAnkleScore,
    required this.lElbowX,          required this.lElbowY,     required this.lElbowScore,
    required this.rElbowX,          required this.rElbowY,     required this.rElbowScore,
    required this.lWristX,          required this.lWristY,     required this.lWristScore,
    required this.rWristX,          required this.rWristY,     required this.rWristScore,
    required this.lKneeX,           required this.lKneeY,      required this.lKneeScore,
    required this.rKneeX,           required this.rKneeY,      required this.rKneeScore,
    required this.shoulderSpanNorm,
    required this.hipSpanNorm,
    required this.noseToAnkleNorm,
    required this.shoulderToAnkleNorm,
    required this.upperBodyNorm,
    required this.lArmNorm,         required this.rArmNorm,
    required this.lLegNorm,         required this.rLegNorm,
    required this.lHipToAnkleNorm,  required this.rHipToAnkleNorm,
    required this.aspectRatio,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// SCREEN
// ─────────────────────────────────────────────────────────────────────────────

class PoseCalibrationScreen extends ConsumerStatefulWidget {
  final double actualHeightCm;
  final double actualShoulderCm;
  final double actualChestCm;
  final double actualWaistCm;
  final double actualHipCm;
  final double actualLeftSleeveCm;
  final double actualRightSleeveCm;
  final double actualLeftLegCm;
  final double actualRightLegCm;

  const PoseCalibrationScreen({
    super.key,
    this.actualHeightCm      = 172.0,
    this.actualShoulderCm    = 45.0,
    this.actualChestCm       = 82.0,
    this.actualWaistCm       = 82.0,
    this.actualHipCm         = 90.0,
    this.actualLeftSleeveCm  = 60.0,
    this.actualRightSleeveCm = 60.0,
    this.actualLeftLegCm     = 80.0,
    this.actualRightLegCm    = 80.0,
  });

  @override
  ConsumerState<PoseCalibrationScreen> createState() =>
      _PoseCalibrationScreenState();
}

class _PoseCalibrationScreenState
    extends ConsumerState<PoseCalibrationScreen> {

  CameraController?     _controller;
  bool                  _isInitializing    = false;
  bool                  _isCapturing       = false;

  // ── ML Kit replaces MoveNetService + ImageProcessingService ──────────────
  final MlKitPoseService _poseService = MlKitPoseService();

  Pose?                 _livePose;
  PoseValidationResult? _liveValidation;

  final List<_Reading>  _readings = [];

  static const int maxReadings = 5;

  // ── Helpers ───────────────────────────────────────────────────────────────

  static double _dist(double x1, double y1, double x2, double y2) =>
      sqrt(pow(x1 - x2, 2) + pow(y1 - y2, 2));

  static double _vdist(double y1, double y2) => (y1 - y2).abs();

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    if (_isInitializing) return;
    _isInitializing = true;
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) return;

      final camera = cameras.firstWhere(
            (c) => c.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );

      _controller = CameraController(
        camera,
        ResolutionPreset.medium,
        enableAudio: false,
        // No imageFormatGroup needed — ML Kit uses still photos, not YUV stream
      );
      await _controller!.initialize();

      if (mounted) setState(() {});
    } catch (e) {
      debugPrint('Cam init error: $e');
    } finally {
      _isInitializing = false;
    }
  }

  // ── Capture one reading (ML Kit detects from still photo) ────────────────

  Future<void> _captureReading() async {
    if (_isCapturing || _readings.length >= maxReadings) return;
    if (_controller == null || !_controller!.value.isInitialized) return;

    setState(() => _isCapturing = true);

    try {
      final XFile photo = await _controller!.takePicture();

      final Pose? pose = await _poseService.detectFromPath(photo.path);

      if (pose == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No pose detected — try again'),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return;
      }

      final validation = PoseValidationService.validate(pose);

      // Update live preview state with the photo result
      if (mounted) {
        setState(() {
          _livePose       = pose;
          _liveValidation = validation;
        });
      }

      final k = pose.keypoints;
      final r = _buildReading(_readings.length + 1, k, pose.aspectRatio);

      if (mounted) setState(() => _readings.add(r));

      // Clean up temp photo
      try { await File(photo.path).delete(); } catch (_) {}

    } catch (e) {
      debugPrint('Capture error: $e');
    } finally {
      if (mounted) setState(() => _isCapturing = false);
    }
  }

  // ── Preview button: snap photo and run pose detection for live feedback ───

  Future<void> _previewPose() async {
    if (_isCapturing) return;
    if (_controller == null || !_controller!.value.isInitialized) return;

    setState(() => _isCapturing = true);
    try {
      final XFile photo = await _controller!.takePicture();
      final Pose? pose  = await _poseService.detectFromPath(photo.path);

      if (mounted) {
        setState(() {
          _livePose       = pose;
          _liveValidation = pose != null
              ? PoseValidationService.validate(pose)
              : null;
        });
      }
      try { await File(photo.path).delete(); } catch (_) {}
    } catch (e) {
      debugPrint('Preview error: $e');
    } finally {
      if (mounted) setState(() => _isCapturing = false);
    }
  }

  _Reading _buildReading(int idx, List<KeyPoint> k, double ar) {
    double cx(int i) {
      if (ar >= 1.0) return k[i].x;
      final offsetFrac = (1.0 - ar) / 2.0;
      return (k[i].x - offsetFrac) / ar;
    }

    double cy(int i) {
      if (ar <= 1.0) return k[i].y;
      final offsetFrac = (1.0 - 1.0 / ar) / 2.0;
      return (k[i].y - offsetFrac) * ar;
    }

    final shSpan    = _dist(cx(5), cy(5), cx(6), cy(6));
    final hiSpan    = _dist(cx(11), cy(11), cx(12), cy(12));
    final ankMidY   = (cy(15) + cy(16)) / 2;
    final n2a       = _vdist(cy(0), ankMidY);
    final shMidY    = (cy(5) + cy(6)) / 2;
    final s2a       = _vdist(shMidY, ankMidY);
    final shMidX    = (cx(5) + cx(6)) / 2;
    final hiMidX    = (cx(11) + cx(12)) / 2;
    final hiMidY    = (cy(11) + cy(12)) / 2;
    final upperBody = _dist(shMidX, shMidY, hiMidX, hiMidY);

    final lArm = _dist(cx(5), cy(5), cx(7), cy(7)) + _dist(cx(7), cy(7), cx(9), cy(9));
    final rArm = _dist(cx(6), cy(6), cx(8), cy(8)) + _dist(cx(8), cy(8), cx(10), cy(10));
    final lLeg = _dist(cx(11), cy(11), cx(13), cy(13)) + _dist(cx(13), cy(13), cx(15), cy(15));
    final rLeg = _dist(cx(12), cy(12), cx(14), cy(14)) + _dist(cx(14), cy(14), cx(16), cy(16));
    final lHipToAnkle = _vdist(cy(11), cy(15));
    final rHipToAnkle = _vdist(cy(12), cy(16));

    return _Reading(
      index: idx,
      noseY: cy(0), noseScore: k[0].score,
      lShoulderX: cx(5), lShoulderY: cy(5), lShoulderScore: k[5].score,
      rShoulderX: cx(6), rShoulderY: cy(6), rShoulderScore: k[6].score,
      lHipX: cx(11), lHipY: cy(11), lHipScore: k[11].score,
      rHipX: cx(12), rHipY: cy(12), rHipScore: k[12].score,
      lAnkleX: cx(15), lAnkleY: cy(15), lAnkleScore: k[15].score,
      rAnkleX: cx(16), rAnkleY: cy(16), rAnkleScore: k[16].score,
      lElbowX: cx(7),  lElbowY: cy(7),  lElbowScore: k[7].score,
      rElbowX: cx(8),  rElbowY: cy(8),  rElbowScore: k[8].score,
      lWristX: cx(9),  lWristY: cy(9),  lWristScore: k[9].score,
      rWristX: cx(10), rWristY: cy(10), rWristScore: k[10].score,
      lKneeX:  cx(13), lKneeY: cy(13),  lKneeScore: k[13].score,
      rKneeX:  cx(14), rKneeY: cy(14),  rKneeScore: k[14].score,
      shoulderSpanNorm:    shSpan,
      hipSpanNorm:         hiSpan,
      noseToAnkleNorm:     n2a,
      shoulderToAnkleNorm: s2a,
      upperBodyNorm:       upperBody,
      lArmNorm: lArm, rArmNorm: rArm,
      lLegNorm: lLeg, rLegNorm: rLeg,
      lHipToAnkleNorm: lHipToAnkle, rHipToAnkleNorm: rHipToAnkle,
      aspectRatio: ar,
    );
  }

  // ── Analysis ──────────────────────────────────────────────────────────────

  Map<String, double> _analyse() {
    if (_readings.isEmpty) return {};

    double avg(List<double> vals) =>
        vals.reduce((a, b) => a + b) / vals.length;

    final avgShoulderNorm  = avg(_readings.map((r) => r.shoulderSpanNorm).toList());
    final avgHipNorm       = avg(_readings.map((r) => r.hipSpanNorm).toList());
    final avgN2A           = avg(_readings.map((r) => r.noseToAnkleNorm).toList());
    final avgS2A           = avg(_readings.map((r) => r.shoulderToAnkleNorm).toList());
    final avgUpperBody     = avg(_readings.map((r) => r.upperBodyNorm).toList());
    final avgArmL          = avg(_readings.map((r) => r.lArmNorm).toList());
    final avgArmR          = avg(_readings.map((r) => r.rArmNorm).toList());
    final avgLegL          = avg(_readings.map((r) => r.lLegNorm).toList());
    final avgLegR          = avg(_readings.map((r) => r.rLegNorm).toList());
    final avgHipToAnkleL   = avg(_readings.map((r) => r.lHipToAnkleNorm).toList());
    final avgHipToAnkleR   = avg(_readings.map((r) => r.rHipToAnkleNorm).toList());

    final scaleN2A = (widget.actualHeightCm * 0.895) / avgN2A;
    final scaleS2A = (widget.actualHeightCm * 0.780) / avgS2A;

    final correctScaleForShoulder    = widget.actualShoulderCm / avgShoulderNorm;
    final personalShoulderMultiplier = widget.actualShoulderCm / avgShoulderNorm;

    final avgChestChordNorm      = avgShoulderNorm * 0.90;
    final chestChordCm           = avgChestChordNorm * scaleN2A;
    final personalChestMultiplier = widget.actualChestCm / chestChordCm;

    final avgWaistChordNorm      = avgHipNorm * 0.88;
    final waistChordCm           = avgWaistChordNorm * scaleN2A;
    final personalWaistMultiplier = widget.actualWaistCm / waistChordCm;

    final hipChordCm             = avgHipNorm * scaleN2A;
    final hipCircCm              = hipChordCm * 3.0;
    final personalHipMultiplier  = widget.actualHipCm / hipCircCm;

    final leftSleeveCm                  = avgArmL * scaleN2A;
    final rightSleeveCm                 = avgArmR * scaleN2A;
    final personalLeftSleeveMultiplier  = widget.actualLeftSleeveCm  / leftSleeveCm;
    final personalRightSleeveMultiplier = widget.actualRightSleeveCm / rightSleeveCm;

    final leftLegCm                  = avgHipToAnkleL * scaleN2A;
    final rightLegCm                 = avgHipToAnkleR * scaleN2A;
    final personalLeftLegMultiplier  = widget.actualLeftLegCm  / leftLegCm;
    final personalRightLegMultiplier = widget.actualRightLegCm / rightLegCm;

    final shVals   = _readings.map((r) => r.shoulderSpanNorm).toList();
    final shMean   = avgShoulderNorm;
    final shStdDev = sqrt(
      shVals.map((v) => pow(v - shMean, 2)).reduce((a, b) => a + b) / shVals.length,
    );

    return {
      'readings':                     _readings.length.toDouble(),
      'avgNoseToAnkleNorm':           avgN2A,
      'avgShoulderToAnkleNorm':       avgS2A,
      'avgShoulderSpanNorm':          avgShoulderNorm,
      'avgHipSpanNorm':               avgHipNorm,
      'avgUpperBodyNorm':             avgUpperBody,
      'avgArmLNorm':                  avgArmL,
      'avgArmRNorm':                  avgArmR,
      'avgLegLNorm':                  avgLegL,
      'avgLegRNorm':                  avgLegR,
      'avgHipToAnkleLNorm':           avgHipToAnkleL,
      'avgHipToAnkleRNorm':           avgHipToAnkleR,
      'scaleFromHeight_N2A':          scaleN2A,
      'scaleFromHeight_S2A':          scaleS2A,
      'scaleForCorrectShoulder':      correctScaleForShoulder,
      'shoulderSpanStdDev':           shStdDev,
      'shoulderCm_atN2Ascale':        avgShoulderNorm * scaleN2A,
      'chestChordCm_atN2Ascale':      chestChordCm,
      'waistChordCm_atN2Ascale':      waistChordCm,
      'hipChordCm_atN2Ascale':        hipChordCm,
      'hipCircCm_atN2Ascale':         hipCircCm,
      'leftSleeveCm_atN2Ascale':      leftSleeveCm,
      'rightSleeveCm_atN2Ascale':     rightSleeveCm,
      'leftLegCm_atN2Ascale':         leftLegCm,
      'rightLegCm_atN2Ascale':        rightLegCm,
      'upperBodyCm_atN2Ascale':       avgUpperBody * scaleN2A,
      'personalShoulderMultiplier':   personalShoulderMultiplier,
      'personalChestMultiplier':      personalChestMultiplier,
      'personalWaistMultiplier':      personalWaistMultiplier,
      'personalHipMultiplier':        personalHipMultiplier,
      'personalLeftSleeveMultiplier': personalLeftSleeveMultiplier,
      'personalRightSleeveMultiplier':personalRightSleeveMultiplier,
      'personalLeftLegMultiplier':    personalLeftLegMultiplier,
      'personalRightLegMultiplier':   personalRightLegMultiplier,
    };
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final bool validPose  = _liveValidation?.isValid ?? false;
    final bool canCapture = !_isCapturing && _readings.length < maxReadings;
    final analysis        = _readings.length >= 2 ? _analyse() : <String, double>{};

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [

            // ── Camera preview ────────────────────────────────────────────
            Expanded(
              flex: 5,
              child: Stack(
                fit: StackFit.expand,
                children: [

                  if (_controller != null && _controller!.value.isInitialized)
                    CameraPreview(_controller!)
                  else
                    const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    ),

                  // Animated border: green = valid pose, orange = invalid
                  Positioned.fill(
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: _livePose == null
                              ? Colors.transparent
                              : validPose ? Colors.green : Colors.orange,
                          width: 4,
                        ),
                      ),
                    ),
                  ),

                  // Status bar bottom
                  Positioned(
                    bottom: 8, left: 8, right: 8,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(children: [
                        Text(
                          _livePose == null
                              ? 'Tap PREVIEW to check pose, then CAPTURE to record'
                              : validPose
                              ? '✅ Pose OK — Tap CAPTURE to record reading '
                              '${_readings.length + 1}/$maxReadings'
                              : (_liveValidation?.failureReason ?? 'Pose not valid'),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: validPose ? Colors.greenAccent : Colors.orangeAccent,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (_isCapturing)
                          const Padding(
                            padding: EdgeInsets.only(top: 4),
                            child: LinearProgressIndicator(color: Colors.greenAccent),
                          ),
                      ]),
                    ),
                  ),

                  // Top info bar
                  Positioned(
                    top: 8, left: 8, right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'CALIBRATION MODE  •  ${_readings.length}/$maxReadings readings\n'
                            'Stand 2–3m away  •  Full body visible  •  Arms slightly out',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            color: Colors.white70, fontSize: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── Button row ────────────────────────────────────────────────
            Container(
              color: Colors.black,
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [

                  // PREVIEW — snap photo and check pose (no reading saved)
                  ElevatedButton.icon(
                    onPressed: _isCapturing ? null : _previewPose,
                    icon: const Icon(Icons.visibility),
                    label: const Text('PREVIEW'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueGrey,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                    ),
                  ),

                  // CAPTURE — save reading
                  ElevatedButton.icon(
                    onPressed: canCapture ? _captureReading : null,
                    icon: const Icon(Icons.camera_alt),
                    label: Text(_readings.length >= maxReadings
                        ? 'Done ($maxReadings readings)'
                        : 'CAPTURE'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: canCapture ? Colors.green : Colors.grey,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                    ),
                  ),

                  if (_readings.isNotEmpty)
                    ElevatedButton.icon(
                      onPressed: () =>
                          setState(() => _readings.removeLast()),
                      icon: const Icon(Icons.undo),
                      label: const Text('Undo'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                      ),
                    ),
                ],
              ),
            ),

            // ── Results panel ─────────────────────────────────────────────
            Expanded(
              flex: 6,
              child: Container(
                color: const Color(0xFF0A0A1A),
                child: _readings.isEmpty
                    ? const Center(
                  child: Text(
                    'Take at least 2 readings\nto see analysis',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Colors.white38, fontSize: 14),
                  ),
                )
                    : DefaultTabController(
                  length: 3,
                  child: Column(
                    children: [
                      const TabBar(
                        indicatorColor: Colors.greenAccent,
                        labelColor: Colors.greenAccent,
                        unselectedLabelColor: Colors.white38,
                        tabs: [
                          Tab(text: 'RAW POINTS'),
                          Tab(text: 'ANALYSIS'),
                          Tab(text: 'MY FORMULA'),
                        ],
                      ),
                      Expanded(
                        child: TabBarView(children: [
                          _buildRawTab(),
                          _buildAnalysisTab(analysis),
                          _buildFormulaTab(analysis),
                        ]),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── TAB 1: Raw keypoint values ────────────────────────────────────────────

  Widget _buildRawTab() {
    return ListView(
      padding: const EdgeInsets.all(8),
      children: _readings.map((r) {
        return Card(
          color: const Color(0xFF111122),
          margin: const EdgeInsets.only(bottom: 8),
          child: ExpansionTile(
            title: Text(
              'Reading #${r.index}  (ar=${r.aspectRatio.toStringAsFixed(2)})',
              style: const TextStyle(
                  color: Colors.greenAccent, fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              'Shoulder: ${r.shoulderSpanNorm.toStringAsFixed(4)}  '
                  'N→Ankle: ${r.noseToAnkleNorm.toStringAsFixed(4)}',
              style: const TextStyle(color: Colors.white54, fontSize: 11),
            ),
            children: [
              _kpTable(r),
              _distTable(r),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _kpTable(_Reading r) {
    final rows = [
      ['nose',       r.noseY.toStringAsFixed(4), '—',                                  r.noseScore.toStringAsFixed(3)],
      ['l_shoulder', r.lShoulderY.toStringAsFixed(4), r.lShoulderX.toStringAsFixed(4), r.lShoulderScore.toStringAsFixed(3)],
      ['r_shoulder', r.rShoulderY.toStringAsFixed(4), r.rShoulderX.toStringAsFixed(4), r.rShoulderScore.toStringAsFixed(3)],
      ['l_elbow',    r.lElbowY.toStringAsFixed(4),    r.lElbowX.toStringAsFixed(4),    r.lElbowScore.toStringAsFixed(3)],
      ['r_elbow',    r.rElbowY.toStringAsFixed(4),    r.rElbowX.toStringAsFixed(4),    r.rElbowScore.toStringAsFixed(3)],
      ['l_wrist',    r.lWristY.toStringAsFixed(4),    r.lWristX.toStringAsFixed(4),    r.lWristScore.toStringAsFixed(3)],
      ['r_wrist',    r.rWristY.toStringAsFixed(4),    r.rWristX.toStringAsFixed(4),    r.rWristScore.toStringAsFixed(3)],
      ['l_hip',      r.lHipY.toStringAsFixed(4),      r.lHipX.toStringAsFixed(4),      r.lHipScore.toStringAsFixed(3)],
      ['r_hip',      r.rHipY.toStringAsFixed(4),      r.rHipX.toStringAsFixed(4),      r.rHipScore.toStringAsFixed(3)],
      ['l_knee',     r.lKneeY.toStringAsFixed(4),     r.lKneeX.toStringAsFixed(4),     r.lKneeScore.toStringAsFixed(3)],
      ['r_knee',     r.rKneeY.toStringAsFixed(4),     r.rKneeX.toStringAsFixed(4),     r.rKneeScore.toStringAsFixed(3)],
      ['l_ankle',    r.lAnkleY.toStringAsFixed(4),    r.lAnkleX.toStringAsFixed(4),    r.lAnkleScore.toStringAsFixed(3)],
      ['r_ankle',    r.rAnkleY.toStringAsFixed(4),    r.rAnkleX.toStringAsFixed(4),    r.rAnkleScore.toStringAsFixed(3)],
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Table(
        columnWidths: const {
          0: FlexColumnWidth(2),
          1: FlexColumnWidth(2),
          2: FlexColumnWidth(2),
          3: FlexColumnWidth(1.5),
        },
        children: [
          _tableHeader(['KEYPOINT', 'y_norm', 'x_norm', 'score']),
          ...rows.map((row) => _tableRow(row,
              highlight: double.parse(row[3]) < 0.25)),
        ],
      ),
    );
  }

  Widget _distTable(_Reading r) {
    final scale = r.noseToAnkleNorm > 0.05
        ? (widget.actualHeightCm * 0.895) / r.noseToAnkleNorm
        : 0.0;

    String cm(double norm) =>
        scale > 0 ? '${(norm * scale).toStringAsFixed(1)} cm' : '—';

    final rows = [
      ['Shoulder span (norm)', r.shoulderSpanNorm.toStringAsFixed(5),      cm(r.shoulderSpanNorm)],
      ['Hip span (norm)',      r.hipSpanNorm.toStringAsFixed(5),           cm(r.hipSpanNorm)],
      ['Nose→Ankle (vert)',    r.noseToAnkleNorm.toStringAsFixed(5),       cm(r.noseToAnkleNorm)],
      ['Sh→Ankle (vert)',      r.shoulderToAnkleNorm.toStringAsFixed(5),   cm(r.shoulderToAnkleNorm)],
      ['Upper body',           r.upperBodyNorm.toStringAsFixed(5),         cm(r.upperBodyNorm)],
      ['L Sleeve (sh→wrist)',  r.lArmNorm.toStringAsFixed(5),              cm(r.lArmNorm)],
      ['R Sleeve (sh→wrist)',  r.rArmNorm.toStringAsFixed(5),              cm(r.rArmNorm)],
      ['L Leg (hip→knee→ank)', r.lLegNorm.toStringAsFixed(5),              cm(r.lLegNorm)],
      ['R Leg (hip→knee→ank)', r.rLegNorm.toStringAsFixed(5),              cm(r.rLegNorm)],
      ['L Hip→Ankle (vert)',   r.lHipToAnkleNorm.toStringAsFixed(5),       cm(r.lHipToAnkleNorm)],
      ['R Hip→Ankle (vert)',   r.rHipToAnkleNorm.toStringAsFixed(5),       cm(r.rHipToAnkleNorm)],
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
      child: Table(
        columnWidths: const {
          0: FlexColumnWidth(3),
          1: FlexColumnWidth(2.5),
          2: FlexColumnWidth(2),
        },
        children: [
          _tableHeader(['DISTANCE', 'normalised', 'at scale']),
          ...rows.map((row) => _tableRow(row)),
        ],
      ),
    );
  }

  // ── TAB 2: Analysis ───────────────────────────────────────────────────────

  Widget _buildAnalysisTab(Map<String, double> a) {
    if (a.isEmpty) {
      return const Center(
          child: Text('Need 2+ readings',
              style: TextStyle(color: Colors.white38)));
    }

    Widget row(String label, double val, String unit,
        {Color color = Colors.white}) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
                child: Text(label,
                    style: const TextStyle(
                        color: Colors.white60, fontSize: 12))),
            Text(
              '${val.toStringAsFixed(4)} $unit',
              style: TextStyle(
                  color: color,
                  fontSize: 12,
                  fontWeight: FontWeight.bold),
            ),
          ],
        ),
      );
    }

    Widget compareRow(String label, double calculated, double actual) {
      final err    = calculated - actual;
      final errPct = actual > 0 ? (err / actual * 100) : 0.0;
      final color  = errPct.abs() < 8
          ? Colors.greenAccent
          : errPct.abs() < 15
          ? Colors.orangeAccent
          : Colors.redAccent;
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 16),
        child: Row(
          children: [
            Expanded(
                child: Text(label,
                    style: const TextStyle(
                        color: Colors.white60, fontSize: 12))),
            Text('${calculated.toStringAsFixed(1)} cm',
                style: const TextStyle(color: Colors.white70, fontSize: 11)),
            const SizedBox(width: 6),
            Text('/ ${actual.toStringAsFixed(1)} cm',
                style: const TextStyle(
                    color: Colors.yellowAccent, fontSize: 11)),
            const SizedBox(width: 6),
            Text(
              '${errPct > 0 ? '+' : ''}${errPct.toStringAsFixed(1)}%',
              style: TextStyle(
                  color: color, fontSize: 11, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      );
    }

    final scaleN2A = a['scaleFromHeight_N2A']!;
    final scaleErr = ((scaleN2A - a['scaleForCorrectShoulder']!) /
        a['scaleForCorrectShoulder']! * 100)
        .abs();

    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 8),
      children: [
        _sectionHeader('AVERAGES ACROSS ${a['readings']!.toInt()} READINGS'),
        row('Nose → Ankle (norm)',       a['avgNoseToAnkleNorm']!,     ''),
        row('Shoulder → Ankle (norm)',   a['avgShoulderToAnkleNorm']!, ''),
        row('Shoulder span (norm)',      a['avgShoulderSpanNorm']!,    ''),
        row('Hip span (norm)',           a['avgHipSpanNorm']!,         ''),
        row('Upper body (norm)',         a['avgUpperBodyNorm']!,        ''),
        row('L Sleeve (norm)',           a['avgArmLNorm']!,            ''),
        row('R Sleeve (norm)',           a['avgArmRNorm']!,            ''),
        row('L Leg hip→knee→ank (norm)', a['avgLegLNorm']!,            ''),
        row('R Leg hip→knee→ank (norm)', a['avgLegRNorm']!,            ''),
        row('L Hip→Ankle vert (norm)',   a['avgHipToAnkleLNorm']!,     ''),
        row('R Hip→Ankle vert (norm)',   a['avgHipToAnkleRNorm']!,     ''),
        row('Shoulder StdDev',           a['shoulderSpanStdDev']!,
            '(lower=consistent)',
            color: a['shoulderSpanStdDev']! < 0.005
                ? Colors.greenAccent
                : Colors.orangeAccent),
        _sectionHeader('SCALE ANALYSIS'),
        row('Scale (nose→ankle)',         scaleN2A, 'cm/unit',
            color: Colors.cyanAccent),
        row('Scale (sh→ankle)',           a['scaleFromHeight_S2A']!, 'cm/unit'),
        row('Scale for correct shoulder', a['scaleForCorrectShoulder']!,
            'cm/unit', color: Colors.yellowAccent),
        row('Scale error %', scaleErr, '%',
            color: scaleErr < 10 ? Colors.greenAccent : Colors.redAccent),
        _sectionHeader('CALCULATED  vs  YOUR ACTUAL (at N2A scale)'),
        compareRow('Shoulder',     a['shoulderCm_atN2Ascale']!,         widget.actualShoulderCm),
        compareRow('Chest (circ)', a['chestChordCm_atN2Ascale']! * 3.1, widget.actualChestCm),
        compareRow('Waist (circ)', a['waistChordCm_atN2Ascale']! * 2.5, widget.actualWaistCm),
        compareRow('Hip (circ)',   a['hipCircCm_atN2Ascale']!,           widget.actualHipCm),
        compareRow('Left Sleeve',  a['leftSleeveCm_atN2Ascale']!,        widget.actualLeftSleeveCm),
        compareRow('Right Sleeve', a['rightSleeveCm_atN2Ascale']!,       widget.actualRightSleeveCm),
        compareRow('Left Leg',     a['leftLegCm_atN2Ascale']!,           widget.actualLeftLegCm),
        compareRow('Right Leg',    a['rightLegCm_atN2Ascale']!,          widget.actualRightLegCm),
      ],
    );
  }

  // ── TAB 3: Personal formula ───────────────────────────────────────────────

  Widget _buildFormulaTab(Map<String, double> a) {
    if (a.isEmpty) {
      return const Center(
          child: Text('Need 2+ readings',
              style: TextStyle(color: Colors.white38)));
    }

    final shMult   = a['personalShoulderMultiplier']!;
    final chMult   = a['personalChestMultiplier']!;
    final waMult   = a['personalWaistMultiplier']!;
    final hiMult   = a['personalHipMultiplier']!;
    final lSlMult  = a['personalLeftSleeveMultiplier']!;
    final rSlMult  = a['personalRightSleeveMultiplier']!;
    final lLegMult = a['personalLeftLegMultiplier']!;
    final rLegMult = a['personalRightLegMultiplier']!;
    final scaleN2A      = a['scaleFromHeight_N2A']!;
    final scaleRatioSh  = a['scaleForCorrectShoulder']! / scaleN2A;

    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        _sectionHeader('YOUR PERSONAL CORRECTION MULTIPLIERS'),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Text(
            'These factors correct for YOUR camera setup, distance, lens '
                'distortion, and body proportions. Paste them into '
                'MeasurementCalculator.',
            style: TextStyle(color: Colors.white38, fontSize: 11),
          ),
        ),
        _formulaCard(
          title: 'Scale correction ratio (shoulder-based)',
          value: scaleRatioSh,
          description: 'Multiply your N2A scale by this before computing widths.',
          code: 'final double scaleRatio = ${scaleRatioSh.toStringAsFixed(4)};',
          color: Colors.cyanAccent,
        ),
        _formulaCard(
          title: 'Shoulder width multiplier',
          value: shMult,
          description: 'shoulder_chord × ${shMult.toStringAsFixed(3)} = ${widget.actualShoulderCm} cm',
          code: 'final double shoulderMult = ${shMult.toStringAsFixed(4)};',
          color: Colors.greenAccent,
        ),
        _formulaCard(
          title: 'Chest circumference multiplier',
          value: chMult,
          description: 'chest_chord × ${chMult.toStringAsFixed(3)} = ${widget.actualChestCm} cm',
          code: 'final double chestMult = ${chMult.toStringAsFixed(4)};',
          color: Colors.amberAccent,
        ),
        _formulaCard(
          title: 'Waist circumference multiplier',
          value: waMult,
          description: 'waist_chord × ${waMult.toStringAsFixed(3)} = ${widget.actualWaistCm} cm',
          code: 'final double waistMult = ${waMult.toStringAsFixed(4)};',
          color: Colors.pinkAccent,
        ),
        _formulaCard(
          title: 'Hip circumference multiplier',
          value: hiMult,
          description: 'hip_chord × 3.0 × ${hiMult.toStringAsFixed(3)} = ${widget.actualHipCm} cm',
          code: 'final double hipMult = ${hiMult.toStringAsFixed(4)};',
          color: Colors.purpleAccent,
        ),
        _formulaCard(
          title: 'Left sleeve multiplier',
          value: lSlMult,
          description: 'left_arm_norm × scale × ${lSlMult.toStringAsFixed(3)} = ${widget.actualLeftSleeveCm} cm',
          code: 'final double leftSleeveMult = ${lSlMult.toStringAsFixed(4)};',
          color: Colors.lightBlueAccent,
        ),
        _formulaCard(
          title: 'Right sleeve multiplier',
          value: rSlMult,
          description: 'right_arm_norm × scale × ${rSlMult.toStringAsFixed(3)} = ${widget.actualRightSleeveCm} cm',
          code: 'final double rightSleeveMult = ${rSlMult.toStringAsFixed(4)};',
          color: Colors.tealAccent,
        ),
        _formulaCard(
          title: 'Left leg multiplier',
          value: lLegMult,
          description: 'left_hipToAnkle_norm × scale × ${lLegMult.toStringAsFixed(3)} = ${widget.actualLeftLegCm} cm',
          code: 'final double leftLegMult = ${lLegMult.toStringAsFixed(4)};',
          color: Colors.orangeAccent,
        ),
        _formulaCard(
          title: 'Right leg multiplier',
          value: rLegMult,
          description: 'right_hipToAnkle_norm × scale × ${rLegMult.toStringAsFixed(3)} = ${widget.actualRightLegCm} cm',
          code: 'final double rightLegMult = ${rLegMult.toStringAsFixed(4)};',
          color: Colors.deepOrangeAccent,
        ),

        _sectionHeader('COPY INTO MeasurementCalculator'),
        Container(
          margin: const EdgeInsets.all(8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF001020),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.white12),
          ),
          child: SelectableText(
            '// ── Personal calibration multipliers ──\n'
                'final double scaleRatio      = ${scaleRatioSh.toStringAsFixed(4)};\n'
                'final double chestMult       = ${chMult.toStringAsFixed(4)};\n'
                'final double waistMult       = ${waMult.toStringAsFixed(4)};\n'
                'final double hipMult         = ${hiMult.toStringAsFixed(4)};\n'
                'final double leftSleeveMult  = ${lSlMult.toStringAsFixed(4)};\n'
                'final double rightSleeveMult = ${rSlMult.toStringAsFixed(4)};\n'
                'final double leftLegMult     = ${lLegMult.toStringAsFixed(4)};\n'
                'final double rightLegMult    = ${rLegMult.toStringAsFixed(4)};\n\n'
                '// ── In calculate() ──\n'
                'final double trueScale     = scale * scaleRatio;\n'
                'final double shoulderCm    = shoulderNorm * trueScale;\n'
                'final double chestCirc     = (shoulderNorm * 0.90 * trueScale) * chestMult;\n'
                'final double waistCirc     = (hipNorm * 0.88   * trueScale) * waistMult;\n'
                'final double hipCirc       = (hipNorm * 3.0    * trueScale) * hipMult;\n'
                'final double leftSleeveCm  = leftArmNorm  * trueScale * leftSleeveMult;\n'
                'final double rightSleeveCm = rightArmNorm * trueScale * rightSleeveMult;\n'
                'final double leftLegCm     = leftH2ANorm  * trueScale * leftLegMult;\n'
                'final double rightLegCm    = rightH2ANorm * trueScale * rightLegMult;\n',
            style: const TextStyle(
              color: Colors.greenAccent,
              fontFamily: 'monospace',
              fontSize: 11,
            ),
          ),
        ),

        _sectionHeader('CONSISTENCY CHECK — ALL MEASUREMENTS'),
        ..._readings.map((r) {
          final s  = r.noseToAnkleNorm > 0.05
              ? (widget.actualHeightCm * 0.895) / r.noseToAnkleNorm
              : 0.0;
          final ts = s * scaleRatioSh;

          final rows = <_ConsistencyRow>[
            _ConsistencyRow('Shoulder', r.shoulderSpanNorm * ts,            widget.actualShoulderCm),
            _ConsistencyRow('Hip circ', r.hipSpanNorm * 3.0 * ts * hiMult, widget.actualHipCm),
            _ConsistencyRow('L Sleeve', r.lArmNorm * ts * lSlMult,         widget.actualLeftSleeveCm),
            _ConsistencyRow('R Sleeve', r.rArmNorm * ts * rSlMult,         widget.actualRightSleeveCm),
            _ConsistencyRow('L Leg',    r.lHipToAnkleNorm * ts * lLegMult, widget.actualLeftLegCm),
            _ConsistencyRow('R Leg',    r.rHipToAnkleNorm * ts * rLegMult, widget.actualRightLegCm),
          ];

          return Card(
            color: const Color(0xFF0D1020),
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Reading #${r.index}',
                      style: const TextStyle(
                          color: Colors.cyanAccent,
                          fontWeight: FontWeight.bold,
                          fontSize: 12)),
                  const SizedBox(height: 6),
                  ...rows.map((cr) {
                    final err    = cr.calculated - cr.actual;
                    final errPct = cr.actual > 0 ? err / cr.actual * 100 : 0.0;
                    final color  = errPct.abs() < 8
                        ? Colors.greenAccent
                        : errPct.abs() < 15
                        ? Colors.orangeAccent
                        : Colors.redAccent;
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 68,
                            child: Text(cr.label,
                                style: const TextStyle(
                                    color: Colors.white54, fontSize: 11)),
                          ),
                          Expanded(
                            child: LinearProgressIndicator(
                              value: (cr.calculated / (cr.actual * 1.5))
                                  .clamp(0.0, 1.0),
                              color: color,
                              backgroundColor: Colors.white10,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${cr.calculated.toStringAsFixed(1)} cm '
                                '(${err >= 0 ? '+' : ''}${err.toStringAsFixed(1)})',
                            style: TextStyle(
                                color: color,
                                fontSize: 10,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
          );
        }),

        const SizedBox(height: 20),
      ],
    );
  }

  // ── UI helpers ─────────────────────────────────────────────────────────────

  Widget _sectionHeader(String title) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      margin: const EdgeInsets.only(top: 8, bottom: 2),
      color: const Color(0xFF0A1A2A),
      child: Text(title,
          style: const TextStyle(
              color: Colors.cyan,
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.8)),
    );
  }

  Widget _formulaCard({
    required String title,
    required double value,
    required String description,
    required String code,
    required Color color,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF0D0D20),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title,
            style: TextStyle(
                color: color, fontSize: 13, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Row(children: [
          const Text('VALUE: ',
              style: TextStyle(color: Colors.white38, fontSize: 11)),
          Text(value.toStringAsFixed(4),
              style: TextStyle(
                  color: color, fontSize: 18, fontWeight: FontWeight.bold)),
        ]),
        const SizedBox(height: 4),
        Text(description,
            style: const TextStyle(color: Colors.white54, fontSize: 11)),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(4),
          ),
          child: SelectableText(code,
              style: const TextStyle(
                  color: Colors.greenAccent,
                  fontFamily: 'monospace',
                  fontSize: 10)),
        ),
      ]),
    );
  }

  TableRow _tableHeader(List<String> cols) {
    return TableRow(
      decoration: const BoxDecoration(color: Color(0xFF1A1A2E)),
      children: cols
          .map((c) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 3),
        child: Text(c,
            style: const TextStyle(
                color: Colors.cyan,
                fontSize: 10,
                fontWeight: FontWeight.bold)),
      ))
          .toList(),
    );
  }

  TableRow _tableRow(List<String> cols, {bool highlight = false}) {
    return TableRow(
      children: cols
          .map((c) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        child: Text(c,
            style: TextStyle(
              color: highlight ? Colors.redAccent : Colors.white70,
              fontSize: 10,
            )),
      ))
          .toList(),
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }
}

// ── Small helper data class ───────────────────────────────────────────────────

class _ConsistencyRow {
  final String label;
  final double calculated;
  final double actual;
  _ConsistencyRow(this.label, this.calculated, this.actual);
}
