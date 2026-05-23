import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/app_chrome.dart';
import '../../healthcare_request/presentation/healthcare_flow_controller.dart';

class FollowUpScreen extends ConsumerWidget {
  const FollowUpScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(healthcareFlowProvider);
    final analysis = state.analysis;
    final booking = state.booking;

    return AppScaffold(
      title: 'Follow-Up',
      actions: [
        IconButton(
          tooltip: 'Analytics',
          onPressed: () => context.push('/analytics'),
          icon: const Icon(Icons.dashboard_customize_rounded),
        ),
      ],
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          GlassPanel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Care continuity workflow',
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 20),
                ),
                const SizedBox(height: 10),
                Text(
                  analysis?.followUp ??
                      'Follow-up reminders and status updates will appear after booking.',
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          _TimelineItem(
            title: 'Booking recorded',
            subtitle: booking?.bookingId ?? 'Waiting for booking confirmation',
            icon: Icons.fact_check_rounded,
            done: booking != null,
          ),
          _TimelineItem(
            title: 'Reminder scheduled',
            subtitle: 'One hour before appointment',
            icon: Icons.notifications_active_rounded,
            done: booking != null,
          ),
          _TimelineItem(
            title: 'Arrival status',
            subtitle: analysis == null
                ? 'Pending ETA'
                : 'Expected in ${analysis.eta}',
            icon: Icons.route_rounded,
            done: analysis != null,
          ),
          _TimelineItem(
            title: 'AI outcome review',
            subtitle: 'Post-visit status and operational learning',
            icon: Icons.auto_graph_rounded,
            done: false,
          ),
          const SizedBox(height: 18),
          PrimaryButton(
            label: 'New Healthcare Request',
            icon: Icons.add_rounded,
            onPressed: () => context.go('/request'),
          ),
        ],
      ),
    );
  }
}

class _TimelineItem extends StatelessWidget {
  const _TimelineItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.done,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final bool done;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GlassPanel(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Icon(icon, color: done ? AppColors.success : AppColors.teal),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 4),
                  Text(subtitle),
                ],
              ),
            ),
            Icon(
              done
                  ? Icons.check_circle_rounded
                  : Icons.radio_button_unchecked_rounded,
              color: done ? AppColors.success : Colors.grey,
            ),
          ],
        ),
      ),
    );
  }
}
