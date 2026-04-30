import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../constants/app_constants.dart';
import '../../models/dress.dart';
import '../../data/men_dresses.dart';
import '../../services/size_recommendation_service.dart';
import '../../providers/app_state_provider.dart';

class RecommendedDressesScreen extends ConsumerStatefulWidget {
  /// Pass the category the user picked on the previous screen.
  /// If null the screen shows both categories (backward-compatible).
  final DressType? selectedType;

  const RecommendedDressesScreen({super.key, this.selectedType});

  @override
  ConsumerState<RecommendedDressesScreen> createState() =>
      _RecommendedDressesScreenState();
}

class _RecommendedDressesScreenState
    extends ConsumerState<RecommendedDressesScreen> {
  // Active filter chip — initialised from the route argument
  late DressType? _selectedType;

  @override
  void initState() {
    super.initState();
    _selectedType = widget.selectedType; // null = "All"
  }

  // ── helpers ─────────────────────────────────────────────────────

  String get _screenTitle {
    switch (_selectedType) {
      case DressType.pantShirt:
        return 'Pant Shirt Picks';
      case DressType.shalwarQameez:
        return 'Shalwar Qameez Picks';
      default:
        return 'Recommended for You';
    }
  }

  // ── build ────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final measurement = ref.watch(appStateProvider).latestResult;

    // ── No measurements guard ──────────────────────────────────────
    if (measurement == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: _buildAppBar(),
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

    // ── Compute recommended size & dress list ──────────────────────
    final recommendedSize =
    SizeRecommendationService.recommendSize(measurement);

    // All dresses matching the user's size
    final allForSize = SizeRecommendationService.recommendedDresses(
      measurement,
      menDresses,
    );

    // Apply the active category filter
    final filtered = _selectedType == null
        ? allForSize
        : allForSize.where((d) => d.type == _selectedType).toList();

    // ── UI ─────────────────────────────────────────────────────────
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Size Banner ────────────────────────────────────────
          _SizeBanner(
            sizeLabel: recommendedSize.name.toUpperCase(),
            chestCm: measurement.chest,
            typeLabel: _selectedType == null
                ? 'All Categories'
                : (_selectedType == DressType.pantShirt
                ? 'Pant Shirt'
                : 'Shalwar Qameez'),
          ),

          // ── Filter Chips ───────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.paddingLarge),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _FilterChip(
                    label: 'All',
                    selected: _selectedType == null,
                    onTap: () => setState(() => _selectedType = null),
                  ),
                  const SizedBox(width: 8),
                  _FilterChip(
                    label: 'Pant Shirt',
                    selected: _selectedType == DressType.pantShirt,
                    onTap: () => setState(
                            () => _selectedType = DressType.pantShirt),
                  ),
                  const SizedBox(width: 8),
                  _FilterChip(
                    label: 'Shalwar Qameez',
                    selected: _selectedType == DressType.shalwarQameez,
                    onTap: () => setState(
                            () => _selectedType = DressType.shalwarQameez),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 8),

          // ── Count Label ────────────────────────────────────────
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

          // ── Dress Grid ─────────────────────────────────────────
          Expanded(
            child: filtered.isEmpty
                ? _EmptyState()
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

  // ── AppBar ───────────────────────────────────────────────────────
  AppBar _buildAppBar() => AppBar(
    backgroundColor: AppColors.background,
    elevation: 0,
    scrolledUnderElevation: 0,
    leading: IconButton(
      icon: const Icon(Icons.arrow_back_ios,
          color: AppColors.textPrimary, size: 20),
      onPressed: () =>
      context.canPop() ? context.pop() : context.goNamed('result'),
    ),
    title: Text(
      _screenTitle,
      style: const TextStyle(
        color: AppColors.textPrimary,
        fontWeight: FontWeight.bold,
        fontSize: 20,
      ),
    ),
  );
}

// ════════════════════════════════════════════════════════════════════
// SIZE BANNER
// ════════════════════════════════════════════════════════════════════

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
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.25),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          // Size badge
          Container(
            padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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
              'Size $sizeLabel',
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
                Text(
                  typeLabel,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Chest: ${chestCm.toStringAsFixed(1)} cm',
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          // Check icon
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
    );
  }
}

// ════════════════════════════════════════════════════════════════════
// FILTER CHIP
// ════════════════════════════════════════════════════════════════════

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

// ════════════════════════════════════════════════════════════════════
// EMPTY STATE
// ════════════════════════════════════════════════════════════════════

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
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
    );
  }
}

// ════════════════════════════════════════════════════════════════════
// DRESS CARD
// ════════════════════════════════════════════════════════════════════

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
          // ── Image ──────────────────────────────────────────────
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

                  // Size badge overlay
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

          // ── Info ───────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.all(AppSpacing.paddingSmall),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Type pill
                Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
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