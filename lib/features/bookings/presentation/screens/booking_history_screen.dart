import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:rodakuu/core/config/app_strings.dart';
import 'package:rodakuu/core/error/error_mapper.dart';
import 'package:rodakuu/core/theme/app_colors.dart';
import 'package:rodakuu/core/theme/app_spacing.dart';
import 'package:rodakuu/core/utils/responsive.dart';
import 'package:rodakuu/core/widgets/app_empty_view.dart';
import 'package:rodakuu/core/widgets/app_error_view.dart';
import 'package:rodakuu/core/widgets/responsive_center.dart';
import 'package:rodakuu/features/bookings/domain/entities/booking.dart';
import 'package:rodakuu/features/bookings/presentation/providers/booking_providers.dart';
import 'package:rodakuu/features/bookings/presentation/widgets/booking_card.dart';

enum _HistoryTab { active, completed }

/// Layar daftar riwayat transaksi pemesanan dengan filter tab Aktif & Selesai.
class BookingHistoryScreen extends ConsumerStatefulWidget {
  const BookingHistoryScreen({super.key});

  @override
  ConsumerState<BookingHistoryScreen> createState() =>
      _BookingHistoryScreenState();
}

class _BookingHistoryScreenState extends ConsumerState<BookingHistoryScreen> {
  _HistoryTab _currentTab = _HistoryTab.active;

  @override
  Widget build(BuildContext context) {
    final bookingsAsync = ref.watch(myBookingsProvider);

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        title: const Text('Pesanan'),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: ResponsiveCenter(
          maxWidth: 640,
          padding: EdgeInsets.symmetric(
            horizontal: context.screenHorizontalPadding,
          ),
          child: RefreshIndicator(
            color: AppColors.navy900,
            onRefresh: () async {
              ref.invalidate(myBookingsProvider);
              try {
                await ref.read(myBookingsProvider.future);
              } on Object {
                // Error ditangani oleh provider state.
              }
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: AppSpacing.sm),
                SegmentedButton<_HistoryTab>(
                  segments: const [
                    ButtonSegment(
                      value: _HistoryTab.active,
                      label: Text('Aktif'),
                    ),
                    ButtonSegment(
                      value: _HistoryTab.completed,
                      label: Text('Selesai'),
                    ),
                  ],
                  selected: {_currentTab},
                  onSelectionChanged: (selected) {
                    setState(() {
                      _currentTab = selected.first;
                    });
                  },
                ),
                const SizedBox(height: AppSpacing.lg),
                Expanded(
                  child: switch (bookingsAsync) {
                    AsyncData(:final value) => _buildList(value),
                    AsyncError(:final error) => AppErrorView(
                      message: failureMessage(error),
                      onRetry: () => ref.invalidate(myBookingsProvider),
                    ),
                    _ => _buildSkeleton(),
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildList(List<Booking> allBookings) {
    final filtered = allBookings.where((b) {
      if (_currentTab == _HistoryTab.active) {
        return b.status.isActive;
      } else {
        return !b.status.isActive;
      }
    }).toList();

    if (filtered.isEmpty) {
      return LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: const AppEmptyView(
                title: AppStrings.emptyBookingsTitle,
                message: AppStrings.emptyBookingsSubtitle,
                icon: Icons.receipt_long_outlined,
              ),
            ),
          );
        },
      );
    }

    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        return BookingCard(booking: filtered[index]);
      },
    );
  }

  Widget _buildSkeleton() {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 4,
      itemBuilder: (context, index) {
        return Card(
          margin: const EdgeInsets.only(bottom: AppSpacing.md),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: [
                Container(
                  width: 72,
                  height: 56,
                  decoration: BoxDecoration(
                    color: AppColors.navy50,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 16,
                        width: 140,
                        decoration: BoxDecoration(
                          color: AppColors.navy50,
                          borderRadius: BorderRadius.circular(
                            AppSpacing.radiusSm,
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Container(
                        height: 12,
                        width: 100,
                        decoration: BoxDecoration(
                          color: AppColors.navy50,
                          borderRadius: BorderRadius.circular(
                            AppSpacing.radiusSm,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
