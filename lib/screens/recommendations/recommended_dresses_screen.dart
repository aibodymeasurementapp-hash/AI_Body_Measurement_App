import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../constants/app_constants.dart';
import '../../models/dress.dart';
import '../../data/men_dresses.dart';
import '../../services/size_recommendation_service.dart';
import '../../providers/app_state_provider.dart';

class RecommendedDressesScreen extends ConsumerWidget {
  const RecommendedDressesScreen({super.key});

  String _screenTitle(DressType? type) {
    switch (type) {
      case DressType.pantShirt:
        return 'Pant Shirt Picks';
      case DressType.shalwarQameez:
        return 'Shalwar Qameez Picks';
      default:
        return 'Recommended Clothes';
    }
  }

  String _typeLabel(DressType? type) {
    switch (type) {
      case DressType.pantShirt:
        return 'Pant Shirt Pairs';
      case DressType.shalwarQameez:
        return 'Shalwar Qameez';
      default:
        return 'All Clothes';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appState     = ref.watch(appStateProvider);
    final measurement  = appState.latestResult;
    final selectedType = appState.selectedDressType; // set by DressTypeScreen

    if (measurement == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: _buildAppBar(context, selectedType),
        body: const _NoMeasurementState(),
      );
    }

    final recommendedSize =
    SizeRecommendationService.recommendSize(measurement);

    final allForSize = SizeRecommendationService.recommendedDresses(
      measurement,
      menClothesOnly,
    );

    // Always filter by the dress type the user selected in DressTypeScreen
    final filtered = selectedType == null
        ? allForSize
        : allForSize.where((d) => d.type == selectedType).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(context, selectedType),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SizeBanner(
            sizeLabel: recommendedSize.name.toUpperCase(),
            chestCm:   measurement.chest,
            typeLabel: _typeLabel(selectedType),
          ),

          const SizedBox(height: 8),

          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.paddingLarge,
            ),
            child: Text(
              '${filtered.length} clothing item${filtered.length == 1 ? '' : 's'} found',
              style: const TextStyle(
                color:      AppColors.textSecondary,
                fontSize:   13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),

          const SizedBox(height: 8),

          Expanded(
            child: filtered.isEmpty
                ? const _EmptyState()
                : GridView.builder(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.paddingMedium,
                0,
                AppSpacing.paddingMedium,
                AppSpacing.paddingLarge,
              ),
              gridDelegate:
              const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount:  2,
                crossAxisSpacing: 12,
                mainAxisSpacing:  12,
                childAspectRatio: 0.60,
              ),
              itemCount: filtered.length,
              itemBuilder: (context, index) {
                final dress = filtered[index];
                return _DressCard(dress: dress);
              },
            ),
          ),
        ],
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context, DressType? selectedType) {
    return AppBar(
      backgroundColor:        AppColors.background,
      elevation:              0,
      scrolledUnderElevation: 0,
      leading: IconButton(
        icon: const Icon(
          Icons.arrow_back_ios,
          color: AppColors.textPrimary,
          size: 20,
        ),
        onPressed: () =>
        context.canPop() ? context.pop() : context.goNamed('result'),
      ),
      title: Text(
        _screenTitle(selectedType),
        style: const TextStyle(
          color:      AppColors.textPrimary,
          fontWeight: FontWeight.bold,
          fontSize:   20,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// No measurement state
// ─────────────────────────────────────────────────────────────────────────────

class _NoMeasurementState extends StatelessWidget {
  const _NoMeasurementState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width:  80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.primaryLight.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.straighten,
              color: AppColors.primary,
              size:  40,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'No measurements found.',
            style: TextStyle(
              fontSize:   18,
              fontWeight: FontWeight.bold,
              color:      AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Please take measurements first.',
            style: TextStyle(
              fontSize: 14,
              color:    AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Size banner
// ─────────────────────────────────────────────────────────────────────────────

class _SizeBanner extends StatelessWidget {
  final String sizeLabel;
  final double chestCm;
  final String typeLabel;

  const _SizeBanner({
    required this.sizeLabel,
    required this.chestCm,
    required this.typeLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
          end:   Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.25),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical:   10,
            ),
            decoration: BoxDecoration(
              color:        AppColors.primary,
              borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
              boxShadow: [
                BoxShadow(
                  color:      AppColors.primary.withOpacity(0.35),
                  blurRadius: 8,
                  offset:     const Offset(0, 3),
                ),
              ],
            ),
            child: Text(
              'Size $sizeLabel',
              style: const TextStyle(
                color:       Colors.white,
                fontWeight:  FontWeight.bold,
                fontSize:    16,
                letterSpacing: 0.5,
              ),
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  typeLabel,
                  style: const TextStyle(
                    fontSize: 12,
                    color:    AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Chest: ${chestCm.toStringAsFixed(1)} cm',
                  style: const TextStyle(
                    fontSize:   14,
                    color:      AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          Container(
            width:  36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.success.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_circle_outline,
              color: AppColors.success,
              size:  20,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Empty state
// ─────────────────────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width:  80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.primaryLight.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.checkroom_outlined,
              color: AppColors.textSecondary,
              size:  40,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'No clothes found.',
            style: TextStyle(
              fontSize:   16,
              fontWeight: FontWeight.w600,
              color:      AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'No items match your selected dress type.',
            style: TextStyle(
              fontSize: 13,
              color:    AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Dress card
// ─────────────────────────────────────────────────────────────────────────────

class _DressCard extends StatelessWidget {
  final Dress dress;

  const _DressCard({required this.dress});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.goNamed('dress-detail', extra: dress),
      child: Container(
        decoration: BoxDecoration(
          color:        Colors.white,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
          boxShadow: [
            BoxShadow(
              color:      AppColors.primary.withOpacity(0.08),
              blurRadius: 12,
              offset:     const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(AppSpacing.radiusLarge),
                ),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Hero(
                      tag: 'dress_image_${dress.id}',
                      child: _DressImage(imagePath: dress.imageUrl),
                    ),

                    Positioned(
                      top:  8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical:   4,
                        ),
                        decoration: BoxDecoration(
                          color:        AppColors.primary,
                          borderRadius: BorderRadius.circular(
                            AppSpacing.radiusSmall,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color:      AppColors.primary.withOpacity(0.4),
                              blurRadius: 6,
                              offset:     const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Text(
                          'Size ${dress.sizeLabel}',
                          style: const TextStyle(
                            fontSize:    10,
                            color:       Colors.white,
                            fontWeight:  FontWeight.bold,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(AppSpacing.paddingSmall),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical:   2,
                    ),
                    decoration: BoxDecoration(
                      color:        AppColors.primaryLight.withOpacity(0.25),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      dress.type == DressType.pantShirt
                          ? 'Pant Shirt Pair'
                          : dress.typeLabel,
                      style: const TextStyle(
                        fontSize:   10,
                        color:      AppColors.primaryDark,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    dress.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize:   12,
                      fontWeight: FontWeight.w700,
                      color:      AppColors.textPrimary,
                      height:     1.3,
                    ),
                  ),

                  const SizedBox(height: 6),

                  Text(
                    dress.priceLabel,
                    style: const TextStyle(
                      fontSize:   13,
                      fontWeight: FontWeight.bold,
                      color:      AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Dress image widget
// ─────────────────────────────────────────────────────────────────────────────

class _DressImage extends StatelessWidget {
  final String imagePath;

  const _DressImage({required this.imagePath});

  @override
  Widget build(BuildContext context) {
    final bool isAssetImage = imagePath.startsWith('assets/');

    if (isAssetImage) {
      return Image.asset(
        imagePath,
        fit:          BoxFit.cover,
        errorBuilder: (_, __, ___) => _imageFallback(),
      );
    }

    return Image.network(
      imagePath,
      fit:          BoxFit.cover,
      errorBuilder: (_, __, ___) => _imageFallback(),
      loadingBuilder: (_, child, progress) {
        if (progress == null) return child;
        return Container(
          color: AppColors.secondary.withOpacity(0.2),
          child: const Center(
            child: CircularProgressIndicator(
              color:       AppColors.primary,
              strokeWidth: 2,
            ),
          ),
        );
      },
    );
  }

  Widget _imageFallback() {
    return Container(
      color: AppColors.secondary.withOpacity(0.3),
      child: const Icon(
        Icons.checkroom_rounded,
        color: AppColors.textSecondary,
        size:  40,
      ),
    );
  }
}