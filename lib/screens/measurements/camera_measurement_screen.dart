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

  File?  _selectedImage;
  Size?  _imageSize;
  final  ImagePicker _picker = ImagePicker();

  // Gyro factor recorded at shutter time.
  // For gallery images (tilt unknown) we default to 1.0.
  double _capturedGyroFactor = 1.0;
  String _capturedTiltInfo   = '';

  final GyroService _gyro = GyroService();

  @override
  void initState() {
    super.initState();
    // Warm up the sensor so a reading is ready by capture time.
    // If sensor is unavailable this is a silent no-op.
    _gyro.startListening();
  }

  @override
  void dispose() {
    _gyro.stopListening();
    super.dispose();
  }

  // ── Image dimension helper ─────────────────────────────────────────────
  Future<void> _getImageDimensions(File file) async {
    final bytes        = await file.readAsBytes();
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

  // ── Open camera ────────────────────────────────────────────────────────
  // Snapshot the gyro correction factor just before the shutter opens.
  // The correction is recorded regardless of tilt severity — gyro NEVER
  // prevents the user from taking a photo.

  /*
  Future<void> _openCamera() async {
    try {
      // Read gyro before the camera dialog takes focus (most accurate moment)
      final double factor = _gyro.correctionFactor;
      final String info   = _gyro.isGyroAvailable
          ? "tilt ${_gyro.tiltAngleDeg.abs().toStringAsFixed(1)}°"
          : "gyro unavailable";

      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
      );
      if (image == null) return;

      final file = File(image.path);
      setState(() {
        _selectedImage      = file;
        _capturedGyroFactor = factor;
        _capturedTiltInfo   = info;
      });

      await _getImageDimensions(file);
      await ref.read(poseProvider.notifier).detectPose(file.path);
    } catch (e) {
      _showError("Camera failed: $e");
    }
  }
  */
  // ── Gallery selection ──────────────────────────────────────────────────
  // Tilt at original capture time is unknown → use 1.0 (no correction).
  Future<void> _selectImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      if (image == null) return;

      final file = File(image.path);
      setState(() {
        _selectedImage      = file;
        _capturedGyroFactor = 1.0;
        _capturedTiltInfo   = 'gallery — no tilt data';
      });

      await _getImageDimensions(file);
      await ref.read(poseProvider.notifier).detectPose(file.path);
    } catch (e) {
      _showError("Gallery selection failed: $e");
    }
  }

  // ── Retake ─────────────────────────────────────────────────────────────
  void _retake() {
    setState(() {
      _selectedImage      = null;
      _imageSize          = null;
      _capturedGyroFactor = 1.0;
      _capturedTiltInfo   = '';
    });
    ref.read(poseProvider.notifier).clearPose();
  }

  // ── Confirm — gated on pose validity only ──────────────────────────────
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

    final userProfile    = ref.read(appStateProvider).userProfile;
    final double height  = userProfile?.heightCm ?? 170.0;

    await ref
        .read(measurementStateProvider.notifier)
        .processCameraMeasurements(
      _selectedImage!.path,
      height,
      userProfile:          userProfile,
      gyroCorrectionFactor: _capturedGyroFactor, // applied as soft correction
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
    final pose             = ref.watch(poseProvider);

    final validation = pose != null
        ? PoseValidationService.validate(pose)
        : const PoseValidationResult.invalid("No pose detected");

    final bool validPose = validation.isValid;

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

            // ── Image preview ──────────────────────────────────────────
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

            // ── Pose status ────────────────────────────────────────────
            if (_selectedImage != null)
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

            // ── Gyro tilt info (informational only) ────────────────────
            if (_selectedImage != null && _capturedTiltInfo.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: _TiltInfoChip(
                  info:   _capturedTiltInfo,
                  factor: _capturedGyroFactor,
                ),
              ),

            const SizedBox(height: 20),

            // ── Buttons ────────────────────────────────────────────────
            if (_selectedImage == null) ...[

             // PrimaryButton(
             //   text: "Open Camera",
             //   onPressed: _openCamera,
             // ),

              const SizedBox(height: 12),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton(
                  onPressed: _selectImage,
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(
                        color: AppColors.primary, width: 2),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                      BorderRadius.circular(AppSpacing.radiusLarge),
                    ),
                  ),
                  child: const Text(
                    "Select from Gallery",
                    style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 16,
                        fontWeight: FontWeight.w600),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton.icon(
                  onPressed: () => context.goNamed('live-camera'),
                  icon: const Icon(Icons.videocam, color: AppColors.primary),
                  label: const Text(
                    'Use Live Camera',
                    style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 16,
                        fontWeight: FontWeight.w600),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(
                        color: AppColors.primary, width: 2),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                      BorderRadius.circular(AppSpacing.radiusLarge),
                    ),
                  ),
                ),
              ),

            ] else ...[

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _retake,
                      child: const Text("Retake"),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: PrimaryButton(
                      text: "Confirm",
                      // Gated on pose only — gyro does NOT block this
                      onPressed: validPose ? _confirm : null,
                      isLoading: measurementState.isLoading,
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
          borderRadius:
          BorderRadius.circular(AppSpacing.radiusLarge),
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

// ── Small tilt info chip shown below the image ─────────────────────────────

class _TiltInfoChip extends StatelessWidget {
  final String info;
  final double factor;

  const _TiltInfoChip({required this.info, required this.factor});

  @override
  Widget build(BuildContext context) {
    // factor = 1.0 → no correction needed → neutral colour
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
