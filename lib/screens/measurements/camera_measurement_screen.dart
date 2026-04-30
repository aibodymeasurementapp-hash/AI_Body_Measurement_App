import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../constants/app_constants.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/skeleton_painter.dart';

import '../../providers/app_state_provider.dart';
import '../../providers/measurement_provider.dart';
import '../../providers/pose_provider.dart';

import '../../services/pose_validation_service.dart';
import '../../services/gyro_service.dart';

class CameraMeasurementScreen extends ConsumerStatefulWidget {
  const CameraMeasurementScreen({super.key});

  @override
  ConsumerState<CameraMeasurementScreen> createState() =>
      _CameraMeasurementScreenState();
}

class _CameraMeasurementScreenState
    extends ConsumerState<CameraMeasurementScreen> {

  File? _selectedImage;
  Size? _imageSize;
  final ImagePicker _picker = ImagePicker();

  double _capturedGyroFactor = 1.0;
  String _capturedTiltInfo = '';

  final GyroService _gyro = GyroService();

  bool _isDetectingPose = false;

  @override
  void initState() {
    super.initState();
    _gyro.startListening();
  }

  @override
  void dispose() {
    _gyro.stopListening();
    super.dispose();
  }

  // ── Image dimension helper ─────────────────────────────────────────────
  Future<void> _getImageDimensions(File file) async {
    final bytes = await file.readAsBytes();
    final decodedImage = await decodeImageFromList(bytes);
    if (mounted) {
      setState(() {
        _imageSize = Size(
          decodedImage.width.toDouble(),
          decodedImage.height.toDouble(),
        );
      });
    }
  }

  // ── Gallery selection ──────────────────────────────────────────────────
  Future<void> _selectImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      if (image == null) return;

      final file = File(image.path);

      setState(() {
        _selectedImage = file;
        _capturedGyroFactor = 1.0;
        _capturedTiltInfo = 'gallery — no tilt data';
        _isDetectingPose = true;
      });

      await _getImageDimensions(file);

      // Detect pose and wait for it to fully complete
      await ref.read(poseProvider.notifier).detectPose(file.path);

      // ✅ Use addPostFrameCallback so Riverpod pose state
      // is fully propagated before we re-evaluate validPose
      if (mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            setState(() {
              _isDetectingPose = false;
            });
          }
        });
      }
    } catch (e) {
      _showError("Gallery selection failed: $e");
      if (mounted) setState(() => _isDetectingPose = false);
    }
  }

  // ── Retake ─────────────────────────────────────────────────────────────
  void _retake() {
    setState(() {
      _selectedImage = null;
      _imageSize = null;
      _capturedGyroFactor = 1.0;
      _capturedTiltInfo = '';
      _isDetectingPose = false;
    });
    ref.read(poseProvider.notifier).clearPose();
  }

  // ── Confirm ────────────────────────────────────────────────────────────
  Future<void> _confirm() async {
    if (_selectedImage == null) return;

    final pose = ref.read(poseProvider);
    if (pose == null) {
      _showError("No pose detected. Please retake the photo.");
      return;
    }

    final validation = PoseValidationService.validate(pose);
    if (!validation.isValid) {
      _showError(validation.failureReason ?? "Invalid pose detected.");
      return;
    }

    final userProfile = ref.read(appStateProvider).userProfile;
    final double height = userProfile?.heightCm ?? 170.0;

    await ref.read(measurementStateProvider.notifier)
        .processCameraMeasurements(
      _selectedImage!.path,
      height,
      userProfile: userProfile,
      gyroCorrectionFactor: _capturedGyroFactor,
    );
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  // ── Build ──────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final measurementState = ref.watch(measurementStateProvider);
    final pose = ref.watch(poseProvider);

    final validation = pose != null
        ? PoseValidationService.validate(pose)
        : const PoseValidationResult.invalid("No pose detected");

    final bool validPose = validation.isValid;

    // ✅ Only enable confirm when: not detecting, pose is valid, not already processing
    final bool canConfirm =
        !_isDetectingPose && validPose && !measurementState.isLoading;

    ref.listen(measurementStateProvider, (previous, next) {
      if (next.result != null && !next.isLoading) {
        ref.read(appStateProvider.notifier).setLatestResult(next.result!);
        context.goNamed('result');
      }
    });

    return Scaffold(
      appBar: CustomAppBar(
        title: "AI Measurement",
        onBackPressed: () => context.goNamed('manual-measurement'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.paddingLarge),
        child: Column(
          children: [

            const Text(
              "AI Body Measurement",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              "Stand 2–3 metres from camera\n"
                  "Full body head to toe must be visible\n"
                  "Arms slightly away from body\n"
                  "Face the camera directly",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
            ),

            const SizedBox(height: 24),

            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius:
                  BorderRadius.circular(AppSpacing.radiusLarge),
                  border: Border.all(color: AppColors.border, width: 2),
                ),
                child: _selectedImage == null
                    ? _buildPlaceholder()
                    : _buildImagePreview(validPose),
              ),
            ),

            const SizedBox(height: 12),

            // ── Status row ───────────────────────────────────────────────
            if (_selectedImage != null)
              Column(
                children: [
                  if (_isDetectingPose)
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        SizedBox(width: 8),
                        Text("Detecting pose..."),
                      ],
                    )
                  else
                    Text(
                      validPose
                          ? "✅ Pose detected correctly"
                          : validation.failureReason ?? "Adjust your position",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: validPose ? Colors.green : Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                ],
              ),

            if (_selectedImage != null && _capturedTiltInfo.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: _TiltInfoChip(
                  info: _capturedTiltInfo,
                  factor: _capturedGyroFactor,
                ),
              ),

            const SizedBox(height: 20),

            // ── Buttons ──────────────────────────────────────────────────
            if (_selectedImage == null) ...[
              const SizedBox(height: 12),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton(
                  onPressed: _selectImage,
                  child: const Text("Select from Gallery"),
                ),
              ),

              const SizedBox(height: 12),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton.icon(
                  onPressed: () => context.goNamed('live-camera'),
                  icon: const Icon(Icons.videocam),
                  label: const Text('Use Live Camera'),
                ),
              ),

            ] else ...[
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      // ✅ Disable retake while detecting or processing
                      onPressed: (_isDetectingPose || measurementState.isLoading)
                          ? null
                          : _retake,
                      child: const Text("Retake"),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: PrimaryButton(
                      text: "Confirm",
                      // ✅ Fixed: uses canConfirm which waits for pose state
                      onPressed: canConfirm ? _confirm : null,
                      isLoading: measurementState.isLoading || _isDetectingPose,
                    ),
                  ),
                ],
              ),
            ],

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.camera_alt_outlined, size: 64),
          SizedBox(height: 16),
          Text("No image selected"),
        ],
      ),
    );
  }

  Widget _buildImagePreview(bool validPose) {
    final pose = ref.watch(poseProvider);
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
          child: Image.file(
            _selectedImage!,
            width: double.infinity,
            height: double.infinity,
            fit: BoxFit.contain,
          ),
        ),
        if (pose != null && _imageSize != null)
          Positioned.fill(
            child: CustomPaint(
              painter: SkeletonPainter(
                pose,
                imageSize: _imageSize!,
                isValidPose: validPose,
              ),
            ),
          ),
      ],
    );
  }
}

class _TiltInfoChip extends StatelessWidget {
  final String info;
  final double factor;

  const _TiltInfoChip({required this.info, required this.factor});

  @override
  Widget build(BuildContext context) {
    final Color bg = factor >= 0.985
        ? Colors.blueGrey.shade100
        : factor >= 0.940
        ? Colors.orange.shade100
        : Colors.red.shade100;

    final Color fg = factor >= 0.985
        ? Colors.blueGrey.shade700
        : factor >= 0.940
        ? Colors.orange.shade800
        : Colors.red.shade800;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        "📐 $info  •  correction ${factor.toStringAsFixed(3)}",
        style: TextStyle(fontSize: 11, color: fg),
      ),
    );
  }
}