import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../../core/theme/app_theme.dart';

class AppScaffold extends StatelessWidget {
  const AppScaffold({
    required this.child,
    this.title,
    this.actions,
    this.showBack = false,
    super.key,
  });

  final Widget child;
  final String? title;
  final List<Widget>? actions;
  final bool showBack;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: title == null
          ? null
          : AppBar(
              automaticallyImplyLeading: showBack,
              title: Text(
                title!,
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
              actions: actions,
            ),
      body: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: Theme.of(context).brightness == Brightness.light
                  ? const [
                      Color(0xFFF7FBFA),
                      Color(0xFFEFF7F6),
                      Color(0xFFFFFBF4),
                    ]
                  : const [
                      Color(0xFF071417),
                      Color(0xFF102024),
                      Color(0xFF141126),
                    ],
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}

class BrandMark extends StatelessWidget {
  const BrandMark({this.compact = false, super.key});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: compact ? 42 : 56,
          height: compact ? 42 : 56,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            gradient: const LinearGradient(
              colors: [AppColors.teal, AppColors.mint],
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.teal.withValues(alpha: 0.28),
                blurRadius: 28,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Icon(
            Icons.health_and_safety_rounded,
            color: Colors.white,
            size: compact ? 24 : 31,
          ),
        ),
        if (!compact) ...[
          const SizedBox(width: 14),
          const Flexible(
            child: Text(
              'Rahe-Sehat\nHealthcare AI',
              style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 21,
                height: 1.05,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class GlassPanel extends StatelessWidget {
  const GlassPanel({required this.child, this.padding, this.onTap, super.key});

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final panel = ClipRRect(
      borderRadius: BorderRadius.circular(26),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          padding: padding ?? const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: (isDark ? Colors.white : Colors.white).withValues(
              alpha: isDark ? 0.08 : 0.72,
            ),
            borderRadius: BorderRadius.circular(26),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.1)
                  : Colors.white,
            ),
          ),
          child: child,
        ),
      ),
    );
    return onTap == null
        ? panel
        : InkWell(
            borderRadius: BorderRadius.circular(26),
            onTap: onTap,
            child: panel,
          );
  }
}

class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    required this.label,
    required this.onPressed,
    this.icon,
    this.loading = false,
    super.key,
  });

  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
      onPressed: loading ? null : onPressed,
      icon: loading
          ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Icon(icon ?? Icons.auto_awesome_rounded),
      label: Text(label),
      style: FilledButton.styleFrom(
        minimumSize: const Size.fromHeight(56),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        textStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
      ),
    );
  }
}

class MetricTile extends StatelessWidget {
  const MetricTile({
    required this.label,
    required this.value,
    required this.icon,
    this.color = AppColors.teal,
    super.key,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF14262A) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.08) : AppColors.line,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.06),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 21),
          ),
          const Spacer(),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Theme.of(
                context,
              ).textTheme.bodySmall?.color?.withValues(alpha: 0.68),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
          ),
        ],
      ),
    );
  }
}

class MetricGrid extends StatelessWidget {
  const MetricGrid({required this.children, super.key});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final columns = width >= 920
            ? 4
            : width >= 560
            ? 3
            : 2;
        const gap = 12.0;
        final tileWidth = (width - gap * (columns - 1)) / columns;

        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            for (final child in children)
              SizedBox(width: tileWidth, height: 132, child: child),
          ],
        );
      },
    );
  }
}

class StateMessage extends StatelessWidget {
  const StateMessage({
    required this.title,
    required this.message,
    this.icon = Icons.info_rounded,
    super.key,
  });

  final String title;
  final String message;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GlassPanel(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: AppColors.teal, size: 40),
            const SizedBox(height: 14),
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(message, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

class LoadingSkeleton extends StatelessWidget {
  const LoadingSkeleton({this.height = 120, super.key});

  final double height;

  @override
  Widget build(BuildContext context) {
    final base = Theme.of(context).brightness == Brightness.light
        ? Colors.grey.shade200
        : Colors.white12;
    return Shimmer.fromColors(
      baseColor: base,
      highlightColor: Colors.white.withValues(alpha: 0.55),
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: base,
          borderRadius: BorderRadius.circular(24),
        ),
      ),
    );
  }
}
