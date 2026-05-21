import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/app_chrome.dart';
import '../../healthcare_request/presentation/healthcare_flow_controller.dart';

class BookingConfirmationScreen extends ConsumerWidget {
  const BookingConfirmationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(healthcareFlowProvider);
    final booking = state.booking;
    final analysis = state.analysis;

    if (booking == null || analysis == null) {
      return const AppScaffold(
        title: 'Booking',
        showBack: true,
        child: StateMessage(
          title: 'No booking yet',
          message: 'Confirm a recommended hospital to create a booking.',
        ),
      );
    }

    return AppScaffold(
      title: 'Booking Confirmed',
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          GlassPanel(
            child: Column(
              children: [
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: 1),
                  duration: const Duration(milliseconds: 850),
                  builder: (context, value, child) =>
                      Transform.scale(scale: value, child: child),
                  child: Container(
                    width: 92,
                    height: 92,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [AppColors.success, AppColors.mint],
                      ),
                    ),
                    child: const Icon(
                      Icons.check_rounded,
                      color: Colors.white,
                      size: 54,
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  booking.bookingStatus,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  booking.hospitalName ?? analysis.selectedHospital,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          MetricGrid(
            children: [
              MetricTile(
                label: 'Booking ID',
                value: booking.bookingId,
                icon: Icons.confirmation_number_rounded,
              ),
              MetricTile(
                label: 'Token',
                value: booking.token ?? 'Priority',
                icon: Icons.local_activity_rounded,
                color: AppColors.violet,
              ),
              MetricTile(
                label: 'Timing',
                value: booking.appointmentTime,
                icon: Icons.event_available_rounded,
              ),
              MetricTile(
                label: 'Reminder',
                value: 'Enabled',
                icon: Icons.notifications_active_rounded,
                color: AppColors.amber,
              ),
            ],
          ),
          const SizedBox(height: 18),
          PrimaryButton(
            label: 'Continue Follow-Up',
            icon: Icons.timeline_rounded,
            onPressed: () => context.go('/followup'),
          ),
        ],
      ),
    );
  }
}
