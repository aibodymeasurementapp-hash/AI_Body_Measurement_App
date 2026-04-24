import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../constants/app_constants.dart';
import '../../models/dress.dart';
import '../../data/men_dresses.dart';
import '../../services/size_recommendation_service.dart';
import '../../providers/app_state_provider.dart';

class RecommendedDressesScreen extends ConsumerStatefulWidget {
  const RecommendedDressesScreen({super.key});

  @override
  ConsumerState<RecommendedDressesScreen> createState() =>
      _RecommendedDressesScreenState();
}

class _RecommendedDressesScreenState
    extends ConsumerState<RecommendedDressesScreen> {
  DressType? _selectedType; // null = All

  @override
  Widget build(BuildContext context) {
    final measurement = ref.watch(appStateProvider).latestResult;

    if (measurement == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          elevation: 0,
          title: const Text(
            'Recommendations',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          iconTheme: const IconThemeData(color: AppColors.textPrimary),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.primaryLight.withOpacity(0.3),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.straighten,
                  color: AppColors.primary,
                  size: 40,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'No measurements found.',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Please take measurements first.',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final recommendedSize =
    SizeRecommendationService.recommendSize(measurement);

    final allForSize = SizeRecommendationService.recommendedDresses(
      measurement,
      menDresses,
    );

    final filtered = _selectedType == null
        ? allForSize
        : allForSize.where((d) => d.type == _selectedType).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios,
              color: AppColors.textPrimary, size: 20),
          onPressed: () =>
          context.canPop() ? context.pop() : context.goNamed('result'),
        ),
        title: const Text(
          'Recommended for You',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Size Banner ──────────────────────────────────────────
          Container(
            margin: const EdgeInsets.fromLTRB(
              AppSpacing.paddingLarge,
              AppSpacing.paddingSmall,
              AppSpacing.paddingLarge,
              AppSpacing.paddingSmall,
            ),
            padding: const EdgeInsets.all(AppSpacing.paddingMedium),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primary.withOpacity(0.15),
                  AppColors.primaryLight.withOpacity(0.08),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius:
              BorderRadius.circular(AppSpacing.radiusLarge),
              border: Border.all(
                color: AppColors.primary.withOpacity(0.25),
                width: 1.5,
              ),
            ),
            child: Row(
              children: [
                // Size badge
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius:
                    BorderRadius.circular(AppSpacing.radiusMedium),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.35),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Text(
                    'Size ${recommendedSize.name.toUpperCase()}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),

                const SizedBox(width: 14),

                // Measurement details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Your Recommended Size',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Chest: ${measurement.chest.toStringAsFixed(1)} cm',
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),

                // Checkmark icon
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.success.withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_circle_outline,
                    color: AppColors.success,
                    size: 20,
                  ),
                ),
              ],
            ),
          ),

          // ── Filter Chips ─────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.paddingLarge),
            child: Row(
              children: [
                _filterChip('All', null),
                _filterChip('Pant Shirt', DressType.pantShirt),
                _filterChip('Shalwar Qameez', DressType.shalwarQameez),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // ── Count Label ──────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.paddingLarge),
            child: Text(
              '${filtered.length} item${filtered.length == 1 ? '' : 's'} found',
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),

          const SizedBox(height: 8),

          // ── Dress Grid ───────────────────────────────────────────
          Expanded(
            child: filtered.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight.withOpacity(0.3),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.search_off_rounded,
                      color: AppColors.primary,
                      size: 32,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'No dresses found.',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            )
                : GridView.builder(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.paddingMedium,
                0,
                AppSpacing.paddingMedium,
                AppSpacing.paddingLarge,
              ),
              gridDelegate:
              const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.60,
              ),
              itemCount: filtered.length,
              itemBuilder: (context, index) =>
                  _DressCard(dress: filtered[index]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _filterChip(String label, DressType? type) {
    final selected = _selectedType == type;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: () => setState(() => _selectedType = type),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding:
          const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: selected ? AppColors.primary : Colors.white,
            borderRadius:
            BorderRadius.circular(AppSpacing.radiusXLarge),
            border: Border.all(
              color: selected
                  ? AppColors.primary
                  : AppColors.border,
              width: 1.5,
            ),
            boxShadow: selected
                ? [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ]
                : [],
          ),
          child: Text(
            label,
            style: TextStyle(
              color: selected ? Colors.white : AppColors.textSecondary,
              fontWeight:
              selected ? FontWeight.bold : FontWeight.normal,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }
}

// ── Dress Card ──────────────────────────────────────────────────────────────

class _DressCard extends StatelessWidget {
  final Dress dress;
  const _DressCard({required this.dress});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Image ─────────────────────────────────────────────
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(AppSpacing.radiusLarge)),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    dress.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: AppColors.secondary.withOpacity(0.3),
                      child: const Icon(
                        Icons.image_not_supported,
                        color: AppColors.textSecondary,
                        size: 36,
                      ),
                    ),
                    loadingBuilder: (_, child, progress) {
                      if (progress == null) return child;
                      return Container(
                        color: AppColors.secondary.withOpacity(0.2),
                        child: const Center(
                          child: CircularProgressIndicator(
                            color: AppColors.primary,
                            strokeWidth: 2,
                          ),
                        ),
                      );
                    },
                  ),

                  // Size badge overlay (top-left)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(
                            AppSpacing.radiusSmall),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.4),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        'Size ${dress.sizeLabel}',
                        style: const TextStyle(
                          fontSize: 10,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Info ──────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.all(AppSpacing.paddingSmall),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Type pill
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight.withOpacity(0.25),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    dress.typeLabel,
                    style: const TextStyle(
                      fontSize: 10,
                      color: AppColors.primaryDark,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),

                const SizedBox(height: 4),

                // Title
                Text(
                  dress.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    height: 1.3,
                  ),
                ),

                const SizedBox(height: 6),

                // Price
                Text(
                  dress.priceLabel,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}