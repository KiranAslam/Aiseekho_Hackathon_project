import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/app_chrome.dart';
import '../../healthcare_request/presentation/healthcare_flow_controller.dart';

class AnalyticsScreen extends ConsumerStatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  ConsumerState<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends ConsumerState<AnalyticsScreen> {
  final _cityController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final state = ref.read(healthcareFlowProvider);
      final city = state.currentCity ?? 'Karachi';
      _cityController.text = city;
      ref.read(healthcareFlowProvider.notifier).loadAnalytics(city: city);
    });
  }

  @override
  void dispose() {
    _cityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(healthcareFlowProvider);
    final activeCity = state.currentCity?.trim().isNotEmpty == true
        ? state.currentCity!.trim()
        : (_cityController.text.trim().isEmpty ? 'Karachi' : _cityController.text.trim());
    return AppScaffold(
      title: 'Hospital Intelligence',
      showBack: true,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          GlassPanel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$activeCity operational view',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Congestion, peak-hour detection, emergency load, and patient inflow signals from FastAPI analytics.',
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: _cityController,
                  textInputAction: TextInputAction.search,
                  decoration: InputDecoration(
                    labelText: 'City for analytics',
                    prefixIcon: const Icon(Icons.location_city_rounded),
                    suffixIcon: IconButton(
                      tooltip: 'Load city intelligence',
                      onPressed: () {
                        final city = _cityController.text.trim().isEmpty
                            ? 'Karachi'
                            : _cityController.text.trim();
                        ref
                            .read(healthcareFlowProvider.notifier)
                            .loadAnalytics(city: city);
                      },
                      icon: const Icon(Icons.search_rounded),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          if (state.isLoadingAnalytics) ...const [
            LoadingSkeleton(height: 130),
            SizedBox(height: 12),
            LoadingSkeleton(height: 130),
          ] else if (state.analytics.isEmpty)
            const StateMessage(
              title: 'No analytics yet',
              message:
                  'The backend will populate operational intelligence as requests are processed.',
            )
          else ...[
            SizedBox(
              height: 170,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: state.analytics.take(8).length,
                separatorBuilder: (context, index) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final item = state.analytics[index];
                  final loadColor = item.emergencyLoad == 'HIGH'
                      ? AppColors.danger
                      : item.emergencyLoad == 'MEDIUM'
                      ? AppColors.amber
                      : AppColors.success;
                  return SizedBox(
                    width: 250,
                    child: GlassPanel(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.hospitalName,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.w900),
                          ),
                          const Spacer(),
                          Text('${item.peakDay} | ${item.peakHours}'),
                          const SizedBox(height: 8),
                          Chip(
                            avatar: Icon(
                              Icons.monitor_heart_rounded,
                              color: loadColor,
                              size: 18,
                            ),
                            label: Text('${item.emergencyLoad} load'),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 18),
            GlassPanel(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Congestion heatmap',
                    style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
                  ),
                  const SizedBox(height: 14),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: state.analytics.take(24).map((item) {
                      final color = item.emergencyLoad == 'HIGH'
                          ? AppColors.danger
                          : item.emergencyLoad == 'MEDIUM'
                          ? AppColors.amber
                          : AppColors.success;
                      return Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.72),
                          borderRadius: BorderRadius.circular(12),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            ...state.analytics
                .take(6)
                .map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: GlassPanel(
                      child: ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(
                          Icons.local_hospital_rounded,
                          color: AppColors.teal,
                        ),
                        title: Text(
                          item.hospitalName,
                          style: const TextStyle(fontWeight: FontWeight.w900),
                        ),
                        subtitle: Text(
                          'Peak: ${item.peakDay}, ${item.peakHours} | Ward: ${item.mostBusyWard}',
                        ),
                        trailing: Text(item.emergencyLoad),
                      ),
                    ),
                  ),
                ),
          ],
        ],
      ),
    );
  }
}
