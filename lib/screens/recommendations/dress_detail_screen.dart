import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../constants/app_constants.dart';
import '../../models/dress.dart';

class DressDetailScreen extends ConsumerStatefulWidget {
  final Dress dress;

  const DressDetailScreen({super.key, required this.dress});

  @override
  ConsumerState<DressDetailScreen> createState() => _DressDetailScreenState();
}

class _DressDetailScreenState extends ConsumerState<DressDetailScreen>
    with TickerProviderStateMixin {
  bool _isWishlisted = false;

  late AnimationController _heartController;
  late AnimationController _fadeController;
  late AnimationController _slideController;

  late Animation<double> _heartScale;
  late Animation<double> _fadeIn;
  late Animation<Offset> _slideUp;

  @override
  void initState() {
    super.initState();

    _heartController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _heartScale = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.4), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.4, end: 1.0), weight: 50),
    ]).animate(
      CurvedAnimation(parent: _heartController, curve: Curves.easeOut),
    );

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeIn = CurvedAnimation(parent: _fadeController, curve: Curves.easeIn);

    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _slideUp = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeOut),
    );

    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _heartController.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  void _toggleWishlist() {
    setState(() => _isWishlisted = !_isWishlisted);
    _heartController.forward(from: 0);
  }

  // ✅ Always goes back to recommended-dresses screen
  void _onBackPressed() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.goNamed('recommended-dresses');
    }
  }

  @override
  Widget build(BuildContext context) {
    final dress = widget.dress;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // ── Scrollable content ──────────────────────────────────────
          CustomScrollView(
            slivers: [
              _buildSliverAppBar(dress, screenHeight),
              SliverToBoxAdapter(
                child: FadeTransition(
                  opacity: _fadeIn,
                  child: SlideTransition(
                    position: _slideUp,
                    child: _buildDetailBody(dress),
                  ),
                ),
              ),
            ],
          ),

          // ── Bottom CTA bar (pinned) ─────────────────────────────────
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: FadeTransition(
              opacity: _fadeIn,
              child: _BottomBar(dress: dress),
            ),
          ),
        ],
      ),
    );
  }

  // ── Sliver app bar with hero image ────────────────────────────────────────

  SliverAppBar _buildSliverAppBar(Dress dress, double screenHeight) {
    return SliverAppBar(
      expandedHeight: screenHeight * 0.48,
      pinned: true,
      backgroundColor: AppColors.background,
      elevation: 0,
      scrolledUnderElevation: 0,
      automaticallyImplyLeading: false,
      leading: Padding(
        padding: const EdgeInsets.all(8.0),
        child: _CircleButton(
          icon: Icons.arrow_back_ios_new_rounded,
          // ✅ Uses _onBackPressed which always returns to recommended-dresses
          onTap: _onBackPressed,
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: ScaleTransition(
            scale: _heartScale,
            child: _CircleButton(
              icon: _isWishlisted
                  ? Icons.favorite_rounded
                  : Icons.favorite_border_rounded,
              iconColor:
              _isWishlisted ? Colors.redAccent : AppColors.textPrimary,
              onTap: _toggleWishlist,
            ),
          ),
        ),
        const SizedBox(width: 4),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Hero image — tag must match _DressCard's Hero tag
            Hero(
              tag: 'dress_image_${dress.id}',
              child: _DressImage(imagePath: dress.imageUrl),
            ),

            // Gradient fade at bottom into background colour
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              height: 80,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      AppColors.background,
                      AppColors.background.withOpacity(0),
                    ],
                  ),
                ),
              ),
            ),

            // Size badge — top-left, safely below status bar
            Positioned(
              top: 16,
              left: 16,
              child: SafeArea(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius:
                    BorderRadius.circular(AppSpacing.radiusMedium),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.4),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Text(
                    'Size ${dress.sizeLabel}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      letterSpacing: 0.4,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Detail body ───────────────────────────────────────────────────────────

  Widget _buildDetailBody(Dress dress) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.paddingLarge,
        AppSpacing.paddingMedium,
        AppSpacing.paddingLarge,
        120, // extra space so content clears the bottom bar
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Type badge + price
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _TypeBadge(dress: dress),
              Text(
                dress.priceLabel,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Title
          Text(
            dress.title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
              height: 1.3,
            ),
          ),

          const SizedBox(height: 20),

          Divider(color: AppColors.border.withOpacity(0.5), height: 1),

          const SizedBox(height: 20),

          // AI size card
          _MeasurementInfoCard(dress: dress),

          const SizedBox(height: 20),

          // Description heading
          const Text(
            'Description',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            dress.description,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
              height: 1.6,
            ),
          ),

          const SizedBox(height: 24),

          // Feature icons
          const _FeatureRow(),

          const SizedBox(height: 20),

          Divider(color: AppColors.border.withOpacity(0.5), height: 1),

          const SizedBox(height: 20),

          // Delivery info
          const _DeliveryInfoRow(),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Private sub-widgets
// ─────────────────────────────────────────────────────────────────────────────

class _CircleButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color? iconColor;

  const _CircleButton({
    required this.icon,
    required this.onTap,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.10),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(
          icon,
          size: 18,
          color: iconColor ?? AppColors.textPrimary,
        ),
      ),
    );
  }
}

class _TypeBadge extends StatelessWidget {
  final Dress dress;

  const _TypeBadge({required this.dress});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.primaryLight.withOpacity(0.25),
        borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Text(
        dress.type == DressType.pantShirt ? 'Pant Shirt Pair' : dress.typeLabel,
        style: const TextStyle(
          fontSize: 11,
          color: AppColors.primaryDark,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}

class _MeasurementInfoCard extends StatelessWidget {
  final Dress dress;

  const _MeasurementInfoCard({required this.dress});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.paddingMedium),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withOpacity(0.10),
            AppColors.primaryLight.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.20),
          width: 1.2,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.straighten_rounded,
              color: AppColors.primary,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'AI-Recommended Size',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Best fit for your body — Size ${dress.sizeLabel}',
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.success.withOpacity(0.12),
              borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.check_circle_rounded,
                  color: AppColors.success,
                  size: 14,
                ),
                SizedBox(width: 4),
                Text(
                  'Match',
                  style: TextStyle(
                    color: AppColors.success,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
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

class _FeatureRow extends StatelessWidget {
  const _FeatureRow();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _FeatureTile(
          icon: Icons.local_shipping_outlined,
          label: 'Free Delivery',
          color: AppColors.primary,
        ),
        _FeatureTile(
          icon: Icons.replay_rounded,
          label: 'Easy Returns',
          color: AppColors.success,
        ),
        _FeatureTile(
          icon: Icons.verified_outlined,
          label: '100% Original',
          color: Colors.amber.shade700,
        ),
      ],
    );
  }
}

class _FeatureTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _FeatureTile({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: color.withOpacity(0.10),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 22),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _DeliveryInfoRow extends StatelessWidget {
  const _DeliveryInfoRow();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(
          Icons.location_on_outlined,
          size: 18,
          color: AppColors.textSecondary,
        ),
        const SizedBox(width: 6),
        Expanded(
          child: RichText(
            text: const TextSpan(
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
              children: [
                TextSpan(text: 'Delivery within '),
                TextSpan(
                  text: '3–5 working days',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                TextSpan(text: ' across Pakistan'),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _BottomBar extends StatelessWidget {
  final Dress dress;

  const _BottomBar({required this.dress});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.paddingLarge,
        AppSpacing.paddingMedium,
        AppSpacing.paddingLarge,
        AppSpacing.paddingMedium + MediaQuery.of(context).padding.bottom,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppSpacing.radiusXLarge),
        ),
      ),
      child: Row(
        children: [
          // Price column
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Total Price',
                style: TextStyle(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                dress.priceLabel,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),

          const SizedBox(width: 16),

          // Add to Cart button
          Expanded(
            child: SizedBox(
              height: 50,
              child: ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        '${dress.title} added to cart!',
                        style: const TextStyle(fontSize: 13),
                      ),
                      backgroundColor: AppColors.primary,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          AppSpacing.radiusMedium,
                        ),
                      ),
                      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
                icon: const Icon(Icons.shopping_cart_outlined, size: 18),
                label: const Text(
                  'Add to Cart',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.3,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
                  ),
                ),
              ),
            ),
          ),
        ],
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
    final bool isAsset = imagePath.startsWith('assets/');

    if (isAsset) {
      return Image.asset(
        imagePath,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _fallback(),
      );
    }

    return Image.network(
      imagePath,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => _fallback(),
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
    );
  }

  Widget _fallback() {
    return Container(
      color: AppColors.secondary.withOpacity(0.3),
      child: const Icon(
        Icons.checkroom_rounded,
        color: AppColors.textSecondary,
        size: 60,
      ),
    );
  }
}