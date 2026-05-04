import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../constants/app_constants.dart';
import '../../models/measurement.dart';
import '../../providers/app_state_provider.dart';
import '../../providers/measurement_provider.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/primary_button.dart';
<<<<<<< HEAD
=======
import '../payment/payment_screen.dart';
import '../../services/firebase_service.dart';
>>>>>>> 545a1120d8ac65c628454bf89699a4ff8fd55a89

enum MeasurementField {
  height,
  shoulderWidth,
  chest,
  waist,
  sleeveLength,
  shirtLength,
  inseam,
}

extension MeasurementFieldX on MeasurementField {
  String get label {
    switch (this) {
<<<<<<< HEAD
      case MeasurementField.height:        return 'Height';
      case MeasurementField.shoulderWidth: return 'Shoulder Width';
      case MeasurementField.chest:         return 'Chest';
      case MeasurementField.waist:         return 'Waist';
      case MeasurementField.sleeveLength:  return 'Sleeve Length';
      case MeasurementField.shirtLength:   return 'Shirt Length';
      case MeasurementField.inseam:        return 'Inseam';
=======
      case MeasurementField.height:
        return 'Height';
      case MeasurementField.shoulderWidth:
        return 'Shoulder Width';
      case MeasurementField.chest:
        return 'Chest';
      case MeasurementField.waist:
        return 'Waist';
      case MeasurementField.sleeveLength:
        return 'Sleeve Length';
      case MeasurementField.shirtLength:
        return 'Shirt Length';
      case MeasurementField.inseam:
        return 'Inseam';
>>>>>>> 545a1120d8ac65c628454bf89699a4ff8fd55a89
    }
  }
}

class ManualMeasurementScreen extends ConsumerStatefulWidget {
  const ManualMeasurementScreen({super.key});

  @override
  ConsumerState<ManualMeasurementScreen> createState() =>
      _ManualMeasurementScreenState();
}

class _ManualMeasurementScreenState
    extends ConsumerState<ManualMeasurementScreen> {

  final _instructionsController = TextEditingController();

  static const double _step = 0.5;

  late Map<MeasurementField, double> _values;

  final Map<MeasurementField, (double, double)> _limits = {
<<<<<<< HEAD
    MeasurementField.height:        (0, 500),
    MeasurementField.shoulderWidth: (0, 100),
    MeasurementField.chest:         (0, 200),
    MeasurementField.waist:         (0, 240),
    MeasurementField.sleeveLength:  (0, 100),
    MeasurementField.shirtLength:   (0, 100),
    MeasurementField.inseam:        (0, 100),
=======
    MeasurementField.height: (0, 500),
    MeasurementField.shoulderWidth: (0, 100),
    MeasurementField.chest: (0, 200),
    MeasurementField.waist: (0, 240),
    MeasurementField.sleeveLength: (0, 100),
    MeasurementField.shirtLength: (0, 100),
    MeasurementField.inseam: (0, 100),
>>>>>>> 545a1120d8ac65c628454bf89699a4ff8fd55a89
  };

  @override
  void initState() {
    super.initState();
<<<<<<< HEAD
    final profileHeight =
        ref.read(appStateProvider).userProfile?.heightCm ?? 170.0;
    _values = {
      MeasurementField.height:        profileHeight,
      MeasurementField.shoulderWidth: 43,
      MeasurementField.chest:         96,
      MeasurementField.waist:         80,
      MeasurementField.sleeveLength:  60,
      MeasurementField.shirtLength:   70,
      MeasurementField.inseam:        76,
=======

    final profileHeight =
        ref.read(appStateProvider).userProfile?.heightCm ?? 170.0;

    _values = {
      MeasurementField.height: profileHeight,
      MeasurementField.shoulderWidth: 43,
      MeasurementField.chest: 96,
      MeasurementField.waist: 80,
      MeasurementField.sleeveLength: 60,
      MeasurementField.shirtLength: 70,
      MeasurementField.inseam: 76,
>>>>>>> 545a1120d8ac65c628454bf89699a4ff8fd55a89
    };
  }

  @override
  void dispose() {
    _instructionsController.dispose();
    super.dispose();
  }

  void _handleStateChanges(previous, next) {
    if (next.result != null && !next.isLoading) {
      ref.read(appStateProvider.notifier).setLatestResult(next.result!);
      context.goNamed('result');
    }
<<<<<<< HEAD
=======

>>>>>>> 545a1120d8ac65c628454bf89699a4ff8fd55a89
    if (next.error != null && previous?.error != next.error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(next.error!),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _update(MeasurementField field, double value) {
    final (min, max) = _limits[field]!;
    setState(() {
      _values[field] = value.clamp(min, max);
    });
  }

  Future<void> _onContinue() async {
    final measurement = Measurement(
      id: 'measurement_${DateTime.now().millisecondsSinceEpoch}',
<<<<<<< HEAD
      height:       _values[MeasurementField.height]!,
      shoulder:     _values[MeasurementField.shoulderWidth]!,
      chest:        _values[MeasurementField.chest]!,
      waist:        _values[MeasurementField.waist]!,
      sleevesLength: _values[MeasurementField.sleeveLength]!,
      shirtLength:  _values[MeasurementField.shirtLength]!,
      inseam:       _values[MeasurementField.inseam]!,
=======
      height: _values[MeasurementField.height]!,
      shoulder: _values[MeasurementField.shoulderWidth]!,
      chest: _values[MeasurementField.chest]!,
      waist: _values[MeasurementField.waist]!,
      sleevesLength: _values[MeasurementField.sleeveLength]!,
      shirtLength: _values[MeasurementField.shirtLength]!,
      inseam: _values[MeasurementField.inseam]!,
>>>>>>> 545a1120d8ac65c628454bf89699a4ff8fd55a89
      additionalInstructions: _instructionsController.text.trim(),
      createdAt: DateTime.now(),
    );

    ref.read(appStateProvider.notifier).setCurrentMeasurement(measurement);
<<<<<<< HEAD
=======

>>>>>>> 545a1120d8ac65c628454bf89699a4ff8fd55a89
    await ref
        .read(measurementStateProvider.notifier)
        .processManualMeasurements(measurement);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(measurementStateProvider);
<<<<<<< HEAD
=======

>>>>>>> 545a1120d8ac65c628454bf89699a4ff8fd55a89
    ref.listen(measurementStateProvider, _handleStateChanges);

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Custom Measurements',
        onBackPressed: () => context.goNamed('dress-type'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.paddingLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            const Text(
              'Enter Your Measurements',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),

            const SizedBox(height: 16),
<<<<<<< HEAD
            const _InfoBadge(),
=======

            const _InfoBadge(),

>>>>>>> 545a1120d8ac65c628454bf89699a4ff8fd55a89
            const SizedBox(height: 24),

            ...MeasurementField.values.map((field) {
              final (min, max) = _limits[field]!;
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _MeasurementRow(
                  label: field.label,
                  value: _values[field]!,
                  min: min,
                  max: max,
                  step: _step,
                  onChanged: (v) => _update(field, v),
                ),
              );
            }),

            const SizedBox(height: 20),

            AppTextField(
              label: 'Additional Instructions',
              hintText: 'Any special requirements...',
              controller: _instructionsController,
              maxLines: 4,
            ),

            const SizedBox(height: 32),

            PrimaryButton(
              text: 'Continue',
              isLoading: state.isLoading,
              onPressed: _onContinue,
            ),

            const SizedBox(height: 12),

            const _CameraButton(),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

<<<<<<< HEAD
// ── Camera Button with Payment Gate ──────────────────────────────────────────
class _CameraButton extends ConsumerWidget {
  const _CameraButton();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: OutlinedButton.icon(
        icon: const Icon(Icons.camera_alt_outlined),
        label: const Text('Use Camera Measurement'),
        onPressed: () => _handlePress(context, ref),
      ),
    );
  }

  void _handlePress(BuildContext context, WidgetRef ref) {
    final isPremium = ref.read(appStateProvider).isPremium;

    if (isPremium) {
      context.goNamed('camera-measurement');
    } else {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: const Color(0xFF1A1A2E),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        builder: (_) => const _PaywallSheet(),
      );
    }
  }
}

// ── Paywall Bottom Sheet ──────────────────────────────────────────────────────
class _PaywallSheet extends StatelessWidget {
  const _PaywallSheet();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [

          // Handle bar
          Container(
            width: 40, height: 4,
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          const SizedBox(height: 20),

          Container(
            width: 64, height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF7ECAC3).withOpacity(0.12),
            ),
            child: const Icon(Icons.camera_alt_outlined,
                color: Color(0xFF7ECAC3), size: 32),
          ),

          const SizedBox(height: 14),

          const Text(
            'Camera Measurement is Pro',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 6),

          const Text(
            'AI-powered body scanning requires\na one-time Pro purchase.',
            style: TextStyle(color: Colors.white54, fontSize: 13, height: 1.5),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 28),

          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF7ECAC3),
                foregroundColor: const Color(0xFF1A1A2E),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
                elevation: 0,
              ),
              onPressed: () {
                Navigator.pop(context);
                context.goNamed('plans');
              },
              child: const Text(
                'Unlock for \$4.99',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
              ),
            ),
          ),

          const SizedBox(height: 12),

          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Maybe later',
              style: TextStyle(color: Colors.white38),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Info Badge ────────────────────────────────────────────────────────────────
=======
>>>>>>> 545a1120d8ac65c628454bf89699a4ff8fd55a89
class _InfoBadge extends StatelessWidget {
  const _InfoBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Text(
        'All measurements in cm',
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: AppColors.primary,
        ),
      ),
    );
  }
}

<<<<<<< HEAD
// ── Sheet Plan Tile ───────────────────────────────────────────────────────────
=======
// class _CameraButton extends ConsumerWidget {
//   const _CameraButton();
//
//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     return SizedBox(
//       width: double.infinity,
//       height: 56,
//       child: OutlinedButton(
//         onPressed: () => _handleCameraPress(context, ref),
//         child: const Text('Use Camera Measurement'),
//       ),
//     );
//   }
//
//   Future<void> _handleCameraPress(BuildContext context, WidgetRef ref) async {
//     final userId = ref.read(appStateProvider).userProfile?.id ?? 'guest';
//     final hasAccess = await FirebaseService().hasActiveSubscription(userId);
//
//     if (!context.mounted) return;
//
//     if (hasAccess) {
//       context.goNamed('camera-measurement');
//     } else {
//       showModalBottomSheet(
//         context: context,
//         isScrollControlled: true,
//         backgroundColor: const Color(0xFF1A1A2E),
//         shape: const RoundedRectangleBorder(
//           borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
//         ),
//         builder: (_) => _PaywallSheet(userId: userId),
//       );
//     }
//   }
// }
//
// class _PaywallSheet extends StatelessWidget {
//   final String userId;
//   const _PaywallSheet({required this.userId});
//
//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Container(
//             width: 40,
//             height: 4,
//             decoration: BoxDecoration(
//               color: Colors.white24,
//               borderRadius: BorderRadius.circular(2),
//             ),
//           ),
//           const SizedBox(height: 20),
//           const Icon(Icons.camera_alt_outlined,
//               color: Color(0xFF7ECAC3), size: 44),
//           const SizedBox(height: 12),
//           const Text(
//             'Camera Measurement is Pro',
//             style: TextStyle(
//               color: Colors.white,
//               fontSize: 20,
//               fontWeight: FontWeight.w500,
//             ),
//           ),
//           const SizedBox(height: 6),
//           const Text(
//             'AI-powered body scanning using MoveNet\nrequires a Pro subscription.',
//             style: TextStyle(color: Colors.white54, fontSize: 13),
//             textAlign: TextAlign.center,
//           ),
//           const SizedBox(height: 28),
//           _SheetPlanTile(
//             label: 'Pro Monthly',
//             price: 'PKR 999 / month',
//             onTap: () {
//               Navigator.pop(context);
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(
//                   builder: (_) => PaymentScreen(
//                     userId: userId,
//                     planName: 'pro_monthly',
//                     amountPKR: 999,
//                   ),
//                 ),
//               );
//             },
//           ),
//           const SizedBox(height: 12),
//           _SheetPlanTile(
//             label: 'Pro Yearly',
//             price: 'PKR 8,999 / year  •  2 months free',
//             isBest: true,
//             onTap: () {
//               Navigator.pop(context);
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(
//                   builder: (_) => PaymentScreen(
//                     userId: userId,
//                     planName: 'pro_yearly',
//                     amountPKR: 8999,
//                   ),
//                 ),
//               );
//             },
//           ),
//           const SizedBox(height: 16),
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('Maybe later',
//                 style: TextStyle(color: Colors.white38)),
//           ),
//         ],
//       ),
//     );
//   }
// }

class _CameraButton extends StatelessWidget {
  const _CameraButton();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: OutlinedButton(
        onPressed: () => context.goNamed('camera-measurement'),
        child: const Text('Use Camera Measurement'),
      ),
    );
  }
}



>>>>>>> 545a1120d8ac65c628454bf89699a4ff8fd55a89
class _SheetPlanTile extends StatelessWidget {
  final String label;
  final String price;
  final bool isBest;
  final VoidCallback onTap;

  const _SheetPlanTile({
    required this.label,
    required this.price,
    required this.onTap,
    this.isBest = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFF252540),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isBest ? const Color(0xFF7ECAC3) : Colors.white12,
            width: isBest ? 1.5 : 0.5,
          ),
        ),
<<<<<<< HEAD
        child: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w500)),
                const SizedBox(height: 2),
                Text(price,
                    style: const TextStyle(
                        color: Colors.white54, fontSize: 12)),
              ],
            ),
            const Spacer(),
            if (isBest)
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFF7ECAC3),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text('BEST',
                    style: TextStyle(
                        color: Color(0xFF1A1A2E),
                        fontSize: 9,
                        fontWeight: FontWeight.w600)),
              ),
          ],
        ),
=======
        child: Row(children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                price,
                style: const TextStyle(color: Colors.white54, fontSize: 12),
              ),
            ],
          ),
          const Spacer(),
          if (isBest)
            Container(
              padding:
              const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFF7ECAC3),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'BEST',
                style: TextStyle(
                  color: Color(0xFF1A1A2E),
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ]),
>>>>>>> 545a1120d8ac65c628454bf89699a4ff8fd55a89
      ),
    );
  }
}

<<<<<<< HEAD
// ── Measurement Row ───────────────────────────────────────────────────────────
=======
>>>>>>> 545a1120d8ac65c628454bf89699a4ff8fd55a89
class _MeasurementRow extends StatelessWidget {
  final String label;
  final double value;
  final double min;
  final double max;
  final double step;
  final ValueChanged<double> onChanged;

  const _MeasurementRow({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.step,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final atMin = value <= min;
    final atMax = value >= max;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          IconButton(
            onPressed: atMin ? null : () => onChanged(value - step),
            icon: const Icon(Icons.remove_circle_outline),
          ),
          Text('${value.toStringAsFixed(1)} cm'),
          IconButton(
            onPressed: atMax ? null : () => onChanged(value + step),
            icon: const Icon(Icons.add_circle_outline),
          ),
        ],
      ),
    );
  }
}