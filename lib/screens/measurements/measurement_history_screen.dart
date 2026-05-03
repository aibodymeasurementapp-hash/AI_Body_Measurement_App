import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../constants/app_constants.dart';
import '../../services/measurement_history_service.dart';
import '../../widgets/custom_app_bar.dart';

class MeasurementHistoryScreen extends ConsumerWidget {
  const MeasurementHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(measurementHistoryProvider);

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Measurement History',
        onBackPressed: () => context.goNamed('category'),
      ),
      body: historyAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
        error: (error, stackTrace) => Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.paddingLarge),
            child: Text(
              'Failed to load history.\n$error',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.red, fontSize: 14),
            ),
          ),
        ),
        data: (items) {
          if (items.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(AppSpacing.paddingLarge),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.history, size: 70, color: AppColors.textSecondary),
                    SizedBox(height: 16),
                    Text(
                      'No saved measurements yet',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Save a result first and it will appear here.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.paddingLarge),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Summary count
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Text(
                    '${items.length} saved measurement${items.length == 1 ? '' : 's'}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),

                // Horizontal scrollable table
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: _MeasurementTable(items: items),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _MeasurementTable extends StatelessWidget {
  final List<MeasurementHistoryItem> items;

  const _MeasurementTable({required this.items});

  static const _headers = [
    'Date',
    'Height',
    'Shoulder',
    'Chest',
    'Waist',
    'Left Sleeve',
    'Right Sleeve',
    'Left Leg',
    'Right Leg',
  ];

  // Column widths
  static const _dateWidth = 100.0;
  static const _dataWidth = 90.0;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header row
        Container(
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(12),
              topRight: Radius.circular(12),
            ),
          ),
          child: Row(
            children: _headers.map((header) {
              final isDate = header == 'Date';
              return _HeaderCell(
                text: header,
                width: isDate ? _dateWidth : _dataWidth,
              );
            }).toList(),
          ),
        ),

        // Data rows
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.primary.withOpacity(0.3)),
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(12),
              bottomRight: Radius.circular(12),
            ),
          ),
          child: Column(
            children: items.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              final isLast = index == items.length - 1;
              final isEven = index % 2 == 0;

              return Container(
                decoration: BoxDecoration(
                  color: isEven
                      ? AppColors.primaryLight.withOpacity(0.07)
                      : Colors.transparent,
                  borderRadius: isLast
                      ? const BorderRadius.only(
                    bottomLeft: Radius.circular(12),
                    bottomRight: Radius.circular(12),
                  )
                      : null,
                  border: !isLast
                      ? Border(
                    bottom: BorderSide(
                      color: AppColors.primary.withOpacity(0.15),
                    ),
                  )
                      : null,
                ),
                child: Row(
                  children: [
                    _DataCell(
                      text: _formatDate(item.createdAt),
                      width: _dateWidth,
                      isFirst: true,
                    ),
                    _DataCell(text: _fmt(item.height), width: _dataWidth),
                    _DataCell(text: _fmt(item.shoulderWidth), width: _dataWidth),
                    _DataCell(text: _fmt(item.chest), width: _dataWidth),
                    _DataCell(text: _fmt(item.waist), width: _dataWidth),
                    _DataCell(text: _fmt(item.leftArmLength), width: _dataWidth),
                    _DataCell(text: _fmt(item.rightArmLength), width: _dataWidth),
                    _DataCell(text: _fmt(item.leftLegLength), width: _dataWidth),
                    _DataCell(text: _fmt(item.rightLegLength), width: _dataWidth),
                  ],
                ),
              );
            }).toList(),
          ),
        ),

        // Legend
        const Padding(
          padding: EdgeInsets.only(top: 10),
          child: Text(
            '* All measurements in cm',
            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
        ),
      ],
    );
  }

  String _fmt(double value) => value.toStringAsFixed(1);

  String _formatDate(DateTime date) {
    final months = [
      'Jan','Feb','Mar','Apr','May','Jun',
      'Jul','Aug','Sep','Oct','Nov','Dec',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}

class _HeaderCell extends StatelessWidget {
  final String text;
  final double width;

  const _HeaderCell({required this.text, required this.width});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}

class _DataCell extends StatelessWidget {
  final String text;
  final double width;
  final bool isFirst;

  const _DataCell({
    required this.text,
    required this.width,
    this.isFirst = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 13),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: AppColors.textPrimary,
          fontSize: isFirst ? 12 : 13,
          fontWeight: isFirst ? FontWeight.w500 : FontWeight.normal,
        ),
      ),
    );
  }
}