import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../constants/app_constants.dart';
import '../../widgets/custom_app_bar.dart';
import '../../providers/app_state_provider.dart';
import '../../models/dress.dart';

class CategorySelectionScreen extends ConsumerWidget {
  const CategorySelectionScreen({super.key});

  Future<void> _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();

    if (!context.mounted) return;

    context.goNamed('login');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Select Category',
        showBackButton: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.paddingLarge),
        child: Column(
          children: [
            const SizedBox(height: 20),

            const Text(
              'Choose your category',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),

            const SizedBox(height: 12),

            const Text(
              'Select the category that best fits you',
              style: TextStyle(
                fontSize: 16,
                color: AppColors.textSecondary,
              ),
            ),



            const SizedBox(height: 30),

            Expanded(
              child: GridView.count(
                crossAxisCount: 1,
                childAspectRatio: 4.5,
                crossAxisSpacing: 16,
                mainAxisSpacing: 24,
                children: [
                  _CategoryCard(
                    title: 'MEN',
                    imageUrl: AppImages.menCategory,
                    onTap: () {
                      ref
                          .read(appStateProvider.notifier)
                          .setSelectedCategory(DressCategory.men);
                      context.goNamed('dress-type');
                    },
                  ),
                  _CategoryCard(
                    title: 'WOMEN',
                    imageUrl: AppImages.womenCategory,
                    onTap: () {
                      ref
                          .read(appStateProvider.notifier)
                          .setSelectedCategory(DressCategory.women);
                      context.goNamed('dress-type');
                    },
                  ),
                  _CategoryCard(
                    title: 'KIDS',
                    imageUrl: AppImages.kidsCategory,
                    onTap: () {
                      ref
                          .read(appStateProvider.notifier)
                          .setSelectedCategory(DressCategory.kids);
                      context.goNamed('dress-type');
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            SafeArea(
              top: false,
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton.icon(
                  onPressed: () => _logout(context),
                  icon: const Icon(
                    Icons.logout,
                    color: AppColors.primary,
                  ),
                  label: const Text(
                    'Logout',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(
                      color: AppColors.primary,
                      width: 2,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        AppSpacing.radiusLarge,
                      ),
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
}

class _CategoryCard extends StatelessWidget {
  final String title;
  final String imageUrl;
  final VoidCallback onTap;

  const _CategoryCard({
    required this.title,
    required this.imageUrl,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    final titleFontSize = screenWidth * 0.09;
    final badgeFontSize = screenWidth * 0.04;
    final cardPaddingHorizontal = screenWidth * 0.05;
    final cardPaddingVertical = screenWidth * 0.03;
    final imageWidth = screenWidth * 0.38;
    final badgePaddingHorizontal = screenWidth * 0.05;
    final badgePaddingVertical = screenWidth * 0.025;

    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 8,
        shadowColor: Colors.black26,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: LinearGradient(
              colors: [
                AppColors.primary.withOpacity(0.12),
                AppColors.primaryLight.withOpacity(0.06),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                right: 0,
                top: 0,
                bottom: 0,
                width: imageWidth,
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(24),
                    bottomRight: Radius.circular(24),
                  ),
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: AppColors.border,
                        alignment: Alignment.center,
                        child: Icon(
                          Icons.person,
                          size: screenWidth * 0.10,
                          color: AppColors.textSecondary,
                        ),
                      );
                    },
                  ),
                ),
              ),

              Positioned.fill(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: cardPaddingHorizontal,
                    vertical: cardPaddingVertical,
                  ),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: titleFontSize,
                            fontWeight: FontWeight.w900,
                            color: AppColors.textPrimary,
                            letterSpacing: 1.0,
                            height: 1.1,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: cardPaddingVertical * 0.6),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: badgePaddingHorizontal,
                            vertical: badgePaddingVertical,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(30),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withOpacity(0.35),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Text(
                            'Select',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: badgeFontSize,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}