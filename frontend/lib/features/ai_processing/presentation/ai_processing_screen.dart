import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/app_chrome.dart';
import '../../healthcare_request/presentation/healthcare_flow_controller.dart';

class AiProcessingScreen extends ConsumerStatefulWidget {
  const AiProcessingScreen({super.key});

  @override
  ConsumerState<AiProcessingScreen> createState() => _AiProcessingScreenState();
}

class _AiProcessingScreenState extends ConsumerState<AiProcessingScreen> {
  int _visibleStep = 0;
  Timer? _timer;
  bool _navigated = false;

  static const _agents = [
    (
      'Intent Understanding Agent',
      'Language, symptom, urgency, and request type extraction',
    ),
    (
      'Provider Discovery Agent',
      'Nearby hospitals and emergency-ready providers',
    ),
    (
      'Operational Intelligence Agent',
      'Congestion, wait time, peak load, and traffic intelligence',
    ),
    (
      'Decision & Optimization Agent',
      'Ranking hospitals by urgency, ETA, congestion, and readiness',
    ),
    (
      'Emergency Coordination Agent',
      'Priority path and escalation compatibility',
    ),
    (
      'Execution Agent',
      'Booking simulation, token generation, and queue assignment',
    ),
    ('Follow-Up Agent', 'Reminder workflow and continuity of care'),
  ];

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(milliseconds: 720), (_) {
      if (!mounted) return;
      setState(
        () => _visibleStep = (_visibleStep + 1).clamp(0, _agents.length - 1),
      );
      final state = ref.read(healthcareFlowProvider);
      if (state.analysis != null &&
          _visibleStep >= _agents.length - 1 &&
          !_navigated) {
        _navigated = true;
        Future<void>.delayed(const Duration(milliseconds: 850), () {
          if (mounted) context.go('/recommendation');
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(healthcareFlowProvider);
    return AppScaffold(
      title: 'AI Processing',
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
                    const BrandMark(compact: true),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            state.analysis == null
                                ? 'Coordinating care agents'
                                : 'AI decision completed',
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(fontWeight: FontWeight.w900),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            state.analysis == null
                                ? 'Live visualization of backend orchestration'
                                : 'Preparing the recommendation board',
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 22),
                LinearProgressIndicator(
                  value: (_visibleStep + 1) / _agents.length,
                  minHeight: 9,
                  borderRadius: BorderRadius.circular(99),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          ...List.generate(_agents.length, (index) {
            final active = index <= _visibleStep;
            final complete = index < _visibleStep || state.analysis != null;
            final agent = _agents[index];
            return _AgentTile(
              title: agent.$1,
              subtitle: agent.$2,
              active: active,
              complete: complete,
              isLast: index == _agents.length - 1,
            );
          }),
          const SizedBox(height: 18),
          if (state.error != null)
            StateMessage(
              title: 'Processing stopped',
              message: state.error!,
              icon: Icons.warning_rounded,
            )
          else if (state.analysis == null)
            const LoadingSkeleton(height: 132)
          else
            GlassPanel(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Reasoning trace',
                    style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
                  ),
                  const SizedBox(height: 8),
                  ...state.analysis!.reasoningLogs.map(
                    (log) => ExpansionTile(
                      tilePadding: EdgeInsets.zero,
                      leading: const Icon(
                        Icons.terminal_rounded,
                        color: AppColors.teal,
                      ),
                      title: Text(
                        log,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Trace ID: ${state.analysis!.traceId ?? 'available after backend execution'}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ),
                      ],
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

class _AgentTile extends StatelessWidget {
  const _AgentTile({
    required this.title,
    required this.subtitle,
    required this.active,
    required this.complete,
    required this.isLast,
  });

  final String title;
  final String subtitle;
  final bool active;
  final bool complete;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final color = complete
        ? AppColors.success
        : active
        ? AppColors.teal
        : Colors.grey;
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 12),
      child: GlassPanel(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 280),
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.14),
                shape: BoxShape.circle,
              ),
              child: Icon(
                complete ? Icons.check_rounded : Icons.bolt_rounded,
                color: color,
              ),
            ),
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
                  Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ),
            if (active && !complete)
              const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
          ],
        ),
      ),
    );
  }
}
