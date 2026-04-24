import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../constants/app_constants.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/primary_button.dart';
import '../../providers/app_state_provider.dart';

class ResultDisplayScreen extends ConsumerWidget {
  const ResultDisplayScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final result = ref.watch(appStateProvider).latestResult;

    if (result == null) {
      return Scaffold(
        appBar: const CustomAppBar(title: 'Results'),
        body: const Center(child: Text('No measurement results available')),
      );
    }

    return Scaffold(
      appBar: const CustomAppBar(title: 'Measurement Results'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.paddingLarge),
        child: Column(
          children: [

            const Text(
              'Your Measurements',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              'Measured on ${_formatDate(result.createdAt)}',
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),

            const SizedBox(height: 32),

            // ── Height ───────────────────────────────────────────
            _MeasurementSection(
              title: 'Height',
              icon: Icons.height,
              measurements: [
                _MeasurementItem('Total Height', result.height),
              ],
            ),

            const SizedBox(height: 16),

            // ── Upper body (clothing-relevant) ───────────────────
            _MeasurementSection(
              title: 'Upper Body',
              icon: Icons.accessibility_new,
              measurements: [
                _MeasurementItem('Shoulder Width', result.shoulderWidth),
                _MeasurementItem('Chest',          result.chest),
                _MeasurementItem('Waist',          result.waist),
                _MeasurementItem('Hip',            result.hip),
              ],
            ),

            const SizedBox(height: 16),

            // ── Sleeve length ────────────────────────────────────
            _MeasurementSection(
              title: 'Sleeve Length',
              icon: Icons.open_in_full,
              measurements: [
                _MeasurementItem('Left Sleeve',  result.leftArmLength),
                _MeasurementItem('Right Sleeve', result.rightArmLength),
              ],
            ),

            const SizedBox(height: 16),

            // ── Trouser/inseam length ────────────────────────────
            _MeasurementSection(
              title: 'Trouser Length',
              icon: Icons.straighten,
              measurements: [
                _MeasurementItem('Left Leg',  result.leftLegLength),
                _MeasurementItem('Right Leg', result.rightLegLength),
              ],
            ),

            const SizedBox(height: 32),

            // ── Action buttons ───────────────────────────────────
            PrimaryButton(
              text: 'Save Result',
              onPressed: () {
                ref.read(appStateProvider.notifier).saveResult(result);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Result saved successfully!'),
                    backgroundColor: AppColors.success,
                  ),
                );
              },
            ),

            const SizedBox(height: 16),

            SizedBox(
              width: double.infinity,
              height: 56,
              child: OutlinedButton(
                onPressed: () => context.goNamed('recommended-dresses'),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.primary, width: 2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
                  ),
                ),
                child: const Text(
                  'Get Dress Recommendations',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            TextButton(
              onPressed: () => context.goNamed('category'),
              child: const Text(
                'Back to Home',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) =>
      '${date.day}/${date.month}/${date.year}';
}

// ── Section widget ───────────────────────────────────────────────────────────

class _MeasurementSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<_MeasurementItem> measurements;

  const _MeasurementSection({
    required this.title,
    required this.icon,
    required this.measurements,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.paddingLarge),
        child: Column(
          children: [

            // Section header
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
                  ),
                  child: Icon(icon, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Measurement rows
            ...measurements.map(
                  (m) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [

                    Text(
                      m.name,
                      style: const TextStyle(
                        fontSize: 16,
                        color: AppColors.textPrimary,
                      ),
                    ),

                    // Shows cm only — values already come in cm from calculator
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${m.value.toStringAsFixed(1)} cm',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MeasurementItem {
  final String name;
  final double value;
  _MeasurementItem(this.name, this.value);
}