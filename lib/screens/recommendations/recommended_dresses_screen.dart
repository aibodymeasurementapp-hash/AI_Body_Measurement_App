import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../constants/app_constants.dart';
import '../../models/dress.dart';
import '../../data/men_dresses.dart';
import '../../services/size_recommendation_service.dart';
import '../../providers/app_state_provider.dart';

<<<<<<< HEAD
class RecommendedDressesScreen extends ConsumerStatefulWidget {
  final DressType? selectedType;

  const RecommendedDressesScreen({super.key, this.selectedType});

  @override
  ConsumerState<RecommendedDressesScreen> createState() =>
      _RecommendedDressesScreenState();
}

class _RecommendedDressesScreenState
    extends ConsumerState<RecommendedDressesScreen> {
  late DressType? _selectedType;

  static const Set<DressType> _allowedClothingTypes = {
    DressType.pantShirt,
    DressType.shalwarQameez,
  };

  @override
  void initState() {
    super.initState();
    _selectedType = _isAllowedClothingType(widget.selectedType)
        ? widget.selectedType
        : null;
  }

  static bool _isAllowedClothingType(DressType? type) {
    return type != null && _allowedClothingTypes.contains(type);
  }

  String get _screenTitle {
    switch (_selectedType) {
      case DressType.pantShirt:
        return 'Pant Shirt Pair Picks';
=======
class RecommendedDressesScreen extends ConsumerWidget {
  const RecommendedDressesScreen({super.key});

  String _screenTitle(DressType? type) {
    switch (type) {
      case DressType.pantShirt:
        return 'Pant Shirt Picks';
>>>>>>> 545a1120d8ac65c628454bf89699a4ff8fd55a89
      case DressType.shalwarQameez:
        return 'Shalwar Qameez Picks';
      default:
        return 'Recommended Clothes';
    }
  }

<<<<<<< HEAD
  String get _typeLabel {
    switch (_selectedType) {
=======
  String _typeLabel(DressType? type) {
    switch (type) {
>>>>>>> 545a1120d8ac65c628454bf89699a4ff8fd55a89
      case DressType.pantShirt:
        return 'Pant Shirt Pairs';
      case DressType.shalwarQameez:
        return 'Shalwar Qameez';
      default:
        return 'All Clothes';
    }
  }

  @override
<<<<<<< HEAD
  Widget build(BuildContext context) {
    final measurement = ref.watch(appStateProvider).latestResult;
=======
  Widget build(BuildContext context, WidgetRef ref) {
    final appState     = ref.watch(appStateProvider);
    final measurement  = appState.latestResult;
    final selectedType = appState.selectedDressType; // set by DressTypeScreen
>>>>>>> 545a1120d8ac65c628454bf89699a4ff8fd55a89

    if (measurement == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
<<<<<<< HEAD
        appBar: _buildAppBar(),
=======
        appBar: _buildAppBar(context, selectedType),
>>>>>>> 545a1120d8ac65c628454bf89699a4ff8fd55a89
        body: const _NoMeasurementState(),
      );
    }

    final recommendedSize =
    SizeRecommendationService.recommendSize(measurement);

    final allForSize = SizeRecommendationService.recommendedDresses(
      measurement,
      menClothesOnly,
    );

<<<<<<< HEAD
    final filtered = _selectedType == null
        ? allForSize
        : allForSize.where((dress) => dress.type == _selectedType).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
=======
    // Always filter by the dress type the user selected in DressTypeScreen
    final filtered = selectedType == null
        ? allForSize
        : allForSize.where((d) => d.type == selectedType).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(context, selectedType),
>>>>>>> 545a1120d8ac65c628454bf89699a4ff8fd55a89
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SizeBanner(
            sizeLabel: recommendedSize.name.toUpperCase(),
<<<<<<< HEAD
            chestCm: measurement.chest,
            typeLabel: _typeLabel,
          ),

          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.paddingLarge,
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _FilterChip(
                    label: 'All Clothes',
                    selected: _selectedType == null,
                    onTap: () => setState(() => _selectedType = null),
                  ),
                  const SizedBox(width: 8),
                  _FilterChip(
                    label: 'Pant Shirt Pairs',
                    selected: _selectedType == DressType.pantShirt,
                    onTap: () => setState(
                          () => _selectedType = DressType.pantShirt,
                    ),
                  ),
                  const SizedBox(width: 8),
                  _FilterChip(
                    label: 'Shalwar Qameez',
                    selected: _selectedType == DressType.shalwarQameez,
                    onTap: () => setState(
                          () => _selectedType = DressType.shalwarQameez,
                    ),
                  ),
                ],
              ),
            ),
=======
            chestCm:   measurement.chest,
            typeLabel: _typeLabel(selectedType),
>>>>>>> 545a1120d8ac65c628454bf89699a4ff8fd55a89
          ),

          const SizedBox(height: 8),

          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.paddingLarge,
            ),
            child: Text(
              '${filtered.length} clothing item${filtered.length == 1 ? '' : 's'} found',
              style: const TextStyle(
<<<<<<< HEAD
                color: AppColors.textSecondary,
                fontSize: 13,
=======
                color:      AppColors.textSecondary,
                fontSize:   13,
>>>>>>> 545a1120d8ac65c628454bf89699a4ff8fd55a89
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
<<<<<<< HEAD
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
=======
                crossAxisCount:  2,
                crossAxisSpacing: 12,
                mainAxisSpacing:  12,
>>>>>>> 545a1120d8ac65c628454bf89699a4ff8fd55a89
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

<<<<<<< HEAD
  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.background,
      elevation: 0,
=======
  AppBar _buildAppBar(BuildContext context, DressType? selectedType) {
    return AppBar(
      backgroundColor:        AppColors.background,
      elevation:              0,
>>>>>>> 545a1120d8ac65c628454bf89699a4ff8fd55a89
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
<<<<<<< HEAD
        _screenTitle,
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.bold,
          fontSize: 20,
=======
        _screenTitle(selectedType),
        style: const TextStyle(
          color:      AppColors.textPrimary,
          fontWeight: FontWeight.bold,
          fontSize:   20,
>>>>>>> 545a1120d8ac65c628454bf89699a4ff8fd55a89
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
<<<<<<< HEAD
            width: 80,
=======
            width:  80,
>>>>>>> 545a1120d8ac65c628454bf89699a4ff8fd55a89
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.primaryLight.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.straighten,
              color: AppColors.primary,
<<<<<<< HEAD
              size: 40,
=======
              size:  40,
>>>>>>> 545a1120d8ac65c628454bf89699a4ff8fd55a89
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'No measurements found.',
            style: TextStyle(
<<<<<<< HEAD
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
=======
              fontSize:   18,
              fontWeight: FontWeight.bold,
              color:      AppColors.textPrimary,
>>>>>>> 545a1120d8ac65c628454bf89699a4ff8fd55a89
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Please take measurements first.',
            style: TextStyle(
              fontSize: 14,
<<<<<<< HEAD
              color: AppColors.textSecondary,
=======
              color:    AppColors.textSecondary,
>>>>>>> 545a1120d8ac65c628454bf89699a4ff8fd55a89
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
<<<<<<< HEAD
          end: Alignment.bottomRight,
=======
          end:   Alignment.bottomRight,
>>>>>>> 545a1120d8ac65c628454bf89699a4ff8fd55a89
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
<<<<<<< HEAD
              vertical: 10,
            ),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.35),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
=======
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
>>>>>>> 545a1120d8ac65c628454bf89699a4ff8fd55a89
                ),
              ],
            ),
            child: Text(
              'Size $sizeLabel',
              style: const TextStyle(
<<<<<<< HEAD
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
=======
                color:       Colors.white,
                fontWeight:  FontWeight.bold,
                fontSize:    16,
>>>>>>> 545a1120d8ac65c628454bf89699a4ff8fd55a89
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
<<<<<<< HEAD
                    color: AppColors.textSecondary,
=======
                    color:    AppColors.textSecondary,
>>>>>>> 545a1120d8ac65c628454bf89699a4ff8fd55a89
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Chest: ${chestCm.toStringAsFixed(1)} cm',
                  style: const TextStyle(
<<<<<<< HEAD
                    fontSize: 14,
                    color: AppColors.textPrimary,
=======
                    fontSize:   14,
                    color:      AppColors.textPrimary,
>>>>>>> 545a1120d8ac65c628454bf89699a4ff8fd55a89
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          Container(
<<<<<<< HEAD
            width: 36,
=======
            width:  36,
>>>>>>> 545a1120d8ac65c628454bf89699a4ff8fd55a89
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.success.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_circle_outline,
              color: AppColors.success,
<<<<<<< HEAD
              size: 20,
=======
              size:  20,
>>>>>>> 545a1120d8ac65c628454bf89699a4ff8fd55a89
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
<<<<<<< HEAD
// Filter chip
// ─────────────────────────────────────────────────────────────────────────────

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(AppSpacing.radiusXLarge),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.border,
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
            fontWeight: selected ? FontWeight.bold : FontWeight.normal,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
=======
>>>>>>> 545a1120d8ac65c628454bf89699a4ff8fd55a89
// Empty state
// ─────────────────────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
<<<<<<< HEAD
    return const Center(
      child: Text(
        'No clothes found.',
        style: TextStyle(
          color: AppColors.textSecondary,
          fontSize: 15,
        ),
=======
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
>>>>>>> 545a1120d8ac65c628454bf89699a4ff8fd55a89
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
<<<<<<< HEAD
// Dress card  ← UPDATED: GestureDetector + Hero added
=======
// Dress card
>>>>>>> 545a1120d8ac65c628454bf89699a4ff8fd55a89
// ─────────────────────────────────────────────────────────────────────────────

class _DressCard extends StatelessWidget {
  final Dress dress;

  const _DressCard({required this.dress});

  @override
  Widget build(BuildContext context) {
<<<<<<< HEAD
    // ✅ GestureDetector wraps the whole card for tap navigation
=======
>>>>>>> 545a1120d8ac65c628454bf89699a4ff8fd55a89
    return GestureDetector(
      onTap: () => context.goNamed('dress-detail', extra: dress),
      child: Container(
        decoration: BoxDecoration(
<<<<<<< HEAD
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
=======
          color:        Colors.white,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
          boxShadow: [
            BoxShadow(
              color:      AppColors.primary.withOpacity(0.08),
              blurRadius: 12,
              offset:     const Offset(0, 4),
>>>>>>> 545a1120d8ac65c628454bf89699a4ff8fd55a89
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
<<<<<<< HEAD
                    // ✅ Hero tag links this image to dress_detail_screen
                    //    for the smooth shared-element transition
=======
>>>>>>> 545a1120d8ac65c628454bf89699a4ff8fd55a89
                    Hero(
                      tag: 'dress_image_${dress.id}',
                      child: _DressImage(imagePath: dress.imageUrl),
                    ),

                    Positioned(
<<<<<<< HEAD
                      top: 8,
=======
                      top:  8,
>>>>>>> 545a1120d8ac65c628454bf89699a4ff8fd55a89
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
<<<<<<< HEAD
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
=======
                          vertical:   4,
                        ),
                        decoration: BoxDecoration(
                          color:        AppColors.primary,
>>>>>>> 545a1120d8ac65c628454bf89699a4ff8fd55a89
                          borderRadius: BorderRadius.circular(
                            AppSpacing.radiusSmall,
                          ),
                          boxShadow: [
                            BoxShadow(
<<<<<<< HEAD
                              color: AppColors.primary.withOpacity(0.4),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
=======
                              color:      AppColors.primary.withOpacity(0.4),
                              blurRadius: 6,
                              offset:     const Offset(0, 2),
>>>>>>> 545a1120d8ac65c628454bf89699a4ff8fd55a89
                            ),
                          ],
                        ),
                        child: Text(
                          'Size ${dress.sizeLabel}',
                          style: const TextStyle(
<<<<<<< HEAD
                            fontSize: 10,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
=======
                            fontSize:    10,
                            color:       Colors.white,
                            fontWeight:  FontWeight.bold,
>>>>>>> 545a1120d8ac65c628454bf89699a4ff8fd55a89
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
<<<<<<< HEAD
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight.withOpacity(0.25),
=======
                      vertical:   2,
                    ),
                    decoration: BoxDecoration(
                      color:        AppColors.primaryLight.withOpacity(0.25),
>>>>>>> 545a1120d8ac65c628454bf89699a4ff8fd55a89
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      dress.type == DressType.pantShirt
                          ? 'Pant Shirt Pair'
                          : dress.typeLabel,
                      style: const TextStyle(
<<<<<<< HEAD
                        fontSize: 10,
                        color: AppColors.primaryDark,
=======
                        fontSize:   10,
                        color:      AppColors.primaryDark,
>>>>>>> 545a1120d8ac65c628454bf89699a4ff8fd55a89
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
<<<<<<< HEAD
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                      height: 1.3,
=======
                      fontSize:   12,
                      fontWeight: FontWeight.w700,
                      color:      AppColors.textPrimary,
                      height:     1.3,
>>>>>>> 545a1120d8ac65c628454bf89699a4ff8fd55a89
                    ),
                  ),

                  const SizedBox(height: 6),

                  Text(
                    dress.priceLabel,
                    style: const TextStyle(
<<<<<<< HEAD
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
=======
                      fontSize:   13,
                      fontWeight: FontWeight.bold,
                      color:      AppColors.primary,
>>>>>>> 545a1120d8ac65c628454bf89699a4ff8fd55a89
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
<<<<<<< HEAD
        fit: BoxFit.cover,
=======
        fit:          BoxFit.cover,
>>>>>>> 545a1120d8ac65c628454bf89699a4ff8fd55a89
        errorBuilder: (_, __, ___) => _imageFallback(),
      );
    }

    return Image.network(
      imagePath,
<<<<<<< HEAD
      fit: BoxFit.cover,
=======
      fit:          BoxFit.cover,
>>>>>>> 545a1120d8ac65c628454bf89699a4ff8fd55a89
      errorBuilder: (_, __, ___) => _imageFallback(),
      loadingBuilder: (_, child, progress) {
        if (progress == null) return child;
        return Container(
          color: AppColors.secondary.withOpacity(0.2),
          child: const Center(
            child: CircularProgressIndicator(
<<<<<<< HEAD
              color: AppColors.primary,
=======
              color:       AppColors.primary,
>>>>>>> 545a1120d8ac65c628454bf89699a4ff8fd55a89
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
<<<<<<< HEAD
        size: 40,
=======
        size:  40,
>>>>>>> 545a1120d8ac65c628454bf89699a4ff8fd55a89
      ),
    );
  }
}