import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../constants/app_constants.dart';
import '../../widgets/custom_app_bar.dart';
import '../../providers/app_state_provider.dart';
import '../../models/dress.dart';

class DressTypeScreen extends ConsumerWidget {
  const DressTypeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appState     = ref.watch(appStateProvider);
    final categoryName = appState.selectedCategory?.name.toUpperCase() ?? '';

    return Scaffold(
      appBar: CustomAppBar(
        title: categoryName,
        onBackPressed: () => context.goNamed('category'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.paddingLarge),
        child: Column(
          children: [
            const SizedBox(height: 20),

            Text(
              'Select Dress Type for $categoryName',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),

            const SizedBox(height: 12),

            const Text(
              'Choose the type of dress you want to measure',
              style: TextStyle(
                fontSize: 16,
                color: AppColors.textSecondary,
              ),
            ),

            const SizedBox(height: 40),

            Expanded(
              child: Column(
                children: [

                  _DressTypeCard(
                    title: 'Pant Shirt',
                    subtitle: 'Western style clothing',
                    icon: Icons.checkroom,
                    onTap: () {
                      ref
                          .read(appStateProvider.notifier)
                          .setSelectedDressType(DressType.pantShirt);
                      context.goNamed('manual-measurement');
                    },
                  ),

                  const SizedBox(height: 20),

                  _DressTypeCard(
                    title: 'Shalwar Qameez',
                    subtitle: 'Traditional style clothing',
                    icon: Icons.accessibility,
                    onTap: () {
                      ref
                          .read(appStateProvider.notifier)
                          .setSelectedDressType(DressType.shalwarQameez);
                      context.goNamed('manual-measurement');
                    },
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

class _DressTypeCard extends StatelessWidget {
  final String      title;
  final String      subtitle;
  final IconData    icon;
  final VoidCallback onTap;

  const _DressTypeCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 6,
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.paddingLarge),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
            gradient: LinearGradient(
              colors: [
                AppColors.primary.withOpacity(0.05),
                AppColors.primaryLight.withOpacity(0.02),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Row(
            children: [

              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius:
                  BorderRadius.circular(AppSpacing.radiusMedium),
                ),
                child: Icon(icon, color: Colors.white, size: 28),
              ),

              const SizedBox(width: 20),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),

              const Icon(
                Icons.arrow_forward_ios,
                color: AppColors.primary,
                size: 20,
              ),

            ],
          ),
        ),
      ),
    );
  }
}