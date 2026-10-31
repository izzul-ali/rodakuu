import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:rodakuu/core/config/app_constants.dart';
import 'package:rodakuu/core/config/app_strings.dart';
import 'package:rodakuu/core/error/error_mapper.dart';
import 'package:rodakuu/core/router/app_routes.dart';
import 'package:rodakuu/core/theme/app_colors.dart';
import 'package:rodakuu/core/theme/app_spacing.dart';
import 'package:rodakuu/core/utils/formatters.dart';
import 'package:rodakuu/core/utils/responsive.dart';
import 'package:rodakuu/core/utils/validators.dart';
import 'package:rodakuu/core/widgets/app_button.dart';
import 'package:rodakuu/core/widgets/app_error_view.dart';
import 'package:rodakuu/core/widgets/app_loading.dart';
import 'package:rodakuu/core/widgets/app_text_field.dart';
import 'package:rodakuu/core/widgets/responsive_center.dart';
import 'package:rodakuu/features/bookings/domain/entities/booked_range.dart';
import 'package:rodakuu/features/bookings/domain/entities/booking_request.dart';
import 'package:rodakuu/features/bookings/domain/services/booking_calculator.dart';
import 'package:rodakuu/features/bookings/presentation/providers/booking_form_controller.dart';
import 'package:rodakuu/features/bookings/presentation/providers/booking_providers.dart';
import 'package:rodakuu/features/bookings/presentation/widgets/date_range_field.dart';
import 'package:rodakuu/features/bookings/presentation/widgets/price_summary.dart';
import 'package:rodakuu/features/vehicles/domain/entities/vehicle.dart';
import 'package:rodakuu/features/vehicles/presentation/providers/vehicle_providers.dart';
import 'package:rodakuu/features/vehicles/presentation/widgets/vehicle_image.dart';

/// Layar formulir pengajuan pemesanan rental kendaraan.
class BookingFormScreen extends ConsumerStatefulWidget {
  const BookingFormScreen({super.key, required this.vehicleId});

  final String vehicleId;

  @override
  ConsumerState<BookingFormScreen> createState() => _BookingFormScreenState();
}

class _BookingFormScreenState extends ConsumerState<BookingFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _locationController = TextEditingController();
  final _notesController = TextEditingController();

  DateTimeRange? _selectedRange;
  String? _dateError;

  @override
  void dispose() {
    _locationController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _onDateRangeChanged(
    DateTimeRange? range,
    List<BookedRange> bookedRanges,
  ) {
    setState(() {
      _selectedRange = range;
      _dateError = DateRangeField.validateDateRange(range, bookedRanges);
    });
  }

  Future<void> _submit(Vehicle vehicle, List<BookedRange> bookedRanges) async {
    final dateErr = DateRangeField.validateDateRange(
      _selectedRange,
      bookedRanges,
    );
    setState(() {
      _dateError = dateErr;
    });

    if (dateErr != null) {
      return;
    }

    if (!_formKey.currentState!.validate()) {
      return;
    }

    final request = BookingRequest(
      vehicleId: vehicle.id,
      startDate: _selectedRange!.start,
      endDate: _selectedRange!.end,
      pickupLocation: _locationController.text.trim(),
      notes: _notesController.text.trim().isNotEmpty
          ? _notesController.text.trim()
          : null,
    );

    final bookingId = await ref
        .read(bookingFormControllerProvider.notifier)
        .createBooking(request);

    if (bookingId != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppStrings.bookingSuccessMessage)),
      );
      context.go(AppRoutes.bookingDetail(bookingId));
    }
  }

  @override
  Widget build(BuildContext context) {
    final vehicleAsync = ref.watch(vehicleDetailProvider(widget.vehicleId));
    final bookedRangesAsync = ref.watch(bookedRangesProvider(widget.vehicleId));
    final bookedRanges = bookedRangesAsync.value ?? const <BookedRange>[];

    ref.listen<AsyncValue<void>>(bookingFormControllerProvider, (
      previous,
      next,
    ) {
      if (next is AsyncError) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(failureMessage(next.error))));
      }
    });

    final isSubmitting = ref.watch(bookingFormControllerProvider).isLoading;

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(title: const Text('Form Pemesanan')),
      body: switch (vehicleAsync) {
        AsyncData(:final value) => _buildForm(
          context,
          value,
          bookedRanges,
          isSubmitting,
        ),
        AsyncError(:final error) => AppErrorView(
          message: failureMessage(error),
          onRetry: () =>
              ref.invalidate(vehicleDetailProvider(widget.vehicleId)),
        ),
        _ => const Center(child: AppLoading()),
      },
      bottomNavigationBar: vehicleAsync.hasValue
          ? _buildBottomBar(
              vehicleAsync.requireValue,
              bookedRanges,
              isSubmitting,
            )
          : null,
    );
  }

  Widget _buildForm(
    BuildContext context,
    Vehicle vehicle,
    List<BookedRange> bookedRanges,
    bool isSubmitting,
  ) {
    final theme = Theme.of(context);

    final totalDays = _selectedRange != null
        ? BookingCalculator.totalDays(
            _selectedRange!.start,
            _selectedRange!.end,
          )
        : 0;
    final totalPrice = BookingCalculator.totalPrice(
      vehicle.pricePerDay,
      totalDays,
    );

    return SingleChildScrollView(
      child: ResponsiveCenter(
        maxWidth: 640,
        padding: EdgeInsets.symmetric(
          horizontal: context.screenHorizontalPadding,
          vertical: AppSpacing.lg,
        ),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Ringkasan Kendaraan
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                  border: Border.all(color: AppColors.border, width: 1),
                ),
                child: Row(
                  children: [
                    SizedBox(
                      width: 72,
                      height: 56,
                      child: VehicleImage(
                        type: vehicle.type,
                        imageUrl: vehicle.imageUrl,
                        borderRadius: BorderRadius.circular(
                          AppSpacing.radiusSm,
                        ),
                        semanticLabel: vehicle.fullName,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            vehicle.fullName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppColors.navy900,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${formatRupiah(vehicle.pricePerDay)} / hari',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),

              // Pemilih Tanggal
              DateRangeField(
                selectedRange: _selectedRange,
                bookedRanges: bookedRanges,
                errorMessage: _dateError,
                onRangeChanged: (range) =>
                    _onDateRangeChanged(range, bookedRanges),
              ),
              const SizedBox(height: AppSpacing.lg),

              // Lokasi Pengambilan
              AppTextField(
                label: 'Lokasi Pengambilan',
                hint: 'Contoh: Stasiun Gambir atau Bandara Soekarno Hatta',
                controller: _locationController,
                validator: Validators.pickupLocation,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: AppSpacing.lg),

              // Catatan
              AppTextField(
                label: 'Catatan (Opsional)',
                hint: 'Catatan tambahan untuk pemilik rental',
                controller: _notesController,
                validator: Validators.notes,
                maxLength: AppConstants.notesMaxLength,
                maxLines: 3,
                textInputAction: TextInputAction.done,
              ),
              const SizedBox(height: AppSpacing.lg),

              // Ringkasan Harga
              if (_selectedRange != null && _dateError == null)
                PriceSummary(
                  pricePerDay: vehicle.pricePerDay,
                  totalDays: totalDays,
                  totalPrice: totalPrice,
                ),
              const SizedBox(height: AppSpacing.xxl),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomBar(
    Vehicle vehicle,
    List<BookedRange> bookedRanges,
    bool isSubmitting,
  ) {
    final canSubmit =
        _selectedRange != null && _dateError == null && !isSubmitting;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.white,
        border: Border(top: BorderSide(color: AppColors.border, width: 1)),
      ),
      child: SafeArea(
        top: false,
        child: ResponsiveCenter(
          maxWidth: 640,
          heightFactor: 1.0,
          padding: EdgeInsets.symmetric(
            horizontal: context.screenHorizontalPadding,
            vertical: AppSpacing.md,
          ),
          child: AppButton.primary(
            text: AppStrings.actionCreateBooking,
            isLoading: isSubmitting,
            onPressed: canSubmit ? () => _submit(vehicle, bookedRanges) : null,
          ),
        ),
      ),
    );
  }
}
