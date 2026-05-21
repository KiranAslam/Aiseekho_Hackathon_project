import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../config/app_config.dart';
import '../../../shared/widgets/app_chrome.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..forward();
    _scale = CurvedAnimation(parent: _controller, curve: Curves.easeOutBack);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Spacer(),
            ScaleTransition(scale: _scale, child: const BrandMark()),
            const SizedBox(height: 28),
            Text(
              AppConfig.tagline,
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 14),
            Text(
              'Emergency detection, hospital intelligence, booking coordination, and AI reasoning in one care workflow.',
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(height: 1.5),
            ),
            const Spacer(),
            PrimaryButton(
              label: 'Start',
              icon: Icons.arrow_forward_rounded,
              onPressed: () => context.go('/request'),
            ),
          ],
        ),
      ),
    );
  }
}
