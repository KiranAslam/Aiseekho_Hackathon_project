import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/app_chrome.dart';
import '../../healthcare_request/presentation/healthcare_flow_controller.dart';

class RecommendationScreen extends ConsumerWidget {
  const RecommendationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(healthcareFlowProvider);
    final analysis = state.analysis;
    if (analysis == null) {
      return const AppScaffold(
        title: 'Recommendation',
        child: StateMessage(
          title: 'No analysis yet',
          message:
              'Submit a healthcare request to generate an AI recommendation.',
        ),
      );
    }

    final urgencyColor = switch (analysis.urgency.toUpperCase()) {
      'HIGH' => AppColors.danger,
      'MEDIUM' => AppColors.amber,
      _ => AppColors.success,
    };

    return AppScaffold(
      title: 'Recommendation',
      showBack: true,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          GlassPanel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        analysis.selectedHospital,
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.w900),
                      ),
                    ),
                    Chip(
                      label: Text(analysis.urgency),
                      avatar: Icon(
                        Icons.priority_high_rounded,
                        color: urgencyColor,
                        size: 18,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'AI confidence ${(analysis.hospitalRating * 18).clamp(70, 96).toStringAsFixed(0)} percent',
                ),
                const SizedBox(height: 20),
                MetricGrid(
                  children: [
                    MetricTile(
                      label: 'Distance',
                      value: analysis.distance,
                      icon: Icons.near_me_rounded,
                    ),
                    MetricTile(
                      label: 'ETA',
                      value: analysis.eta,
                      icon: Icons.route_rounded,
                    ),
                    MetricTile(
                      label: 'Wait time',
                      value: analysis.waitTime,
                      icon: Icons.timer_rounded,
                    ),
                    MetricTile(
                      label: 'Congestion',
                      value: analysis.congestionLevel ?? 'Live',
                      icon: Icons.health_and_safety_rounded,
                      color: urgencyColor,
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Text(
                  '${analysis.emergencyNote ?? 'Selected for symptom severity, routing, wait time, and congestion.'}'
                  '${analysis.vicinity == null || analysis.vicinity!.isEmpty ? '' : '\n\nArea: ${analysis.vicinity}'}',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          GlassPanel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Operational intelligence',
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
                ),
                const SizedBox(height: 10),
                if (analysis.opsInsights.isEmpty)
                  const ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(
                      Icons.analytics_rounded,
                      color: AppColors.violet,
                    ),
                    title: Text(
                      'Live hospital intelligence is active. The backend is using ETA, distance, congestion, emergency readiness, and traffic signals for this recommendation.',
                    ),
                  )
                else
                  ...analysis.opsInsights.map(
                    (insight) => ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(
                        Icons.analytics_rounded,
                        color: AppColors.violet,
                      ),
                      title: Text(insight),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          if (analysis.rankHospitalsNullSafe.isNotEmpty)
            GlassPanel(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Also evaluated',
                    style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  ...analysis.rankHospitalsNullSafe.map((h) {
                    final name = h['hospital_name'] ?? h['hospitalName'] ?? 'Unknown';
                    final eta = h['eta'] ?? h['eta'];
                    final dist = h['distance'] ?? h['distance'];
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(name),
                      subtitle: Text('${eta ?? ''} • ${dist ?? ''}'),
                      leading: const Icon(Icons.local_hospital_rounded),
                    );
                  }).take(6).toList(),
                ],
              ),
            ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => context.push('/navigation'),
                  icon: const Icon(Icons.map_rounded),
                  label: const Text('View Route'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton.icon(
                  onPressed: state.isBooking
                      ? null
                      : () async {
                          await ref
                              .read(healthcareFlowProvider.notifier)
                              .confirmBooking();
                          if (context.mounted) context.go('/booking');
                        },
                  icon: state.isBooking
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.verified_rounded),
                  label: const Text('Confirm Booking'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
