import 'dart:math' as math;

import 'package:expenses_tracker/core/theme/app_colors.dart';
import 'package:expenses_tracker/core/utils/app_formatters.dart';
import 'package:expenses_tracker/shared/models/app_models.dart';
import 'package:flutter/material.dart';

class ChartSection {
  const ChartSection({
    required this.color,
    required this.value,
    required this.label,
    required this.percentage,
    this.category,
  });

  final Color color;
  final double value;
  final String label;
  final int percentage;

  final CategoryType? category;
}

class SpendingDonutChart extends StatelessWidget {
  const SpendingDonutChart({
    super.key,
    required this.total,
    required this.sections,
    required this.symbol,
    this.onSectionTap,
  });

  final double total;
  final List<ChartSection> sections;
  final String symbol;
  final ValueChanged<ChartSection>? onSectionTap;

  static const double _size = 210;
  static const double _strokeWidth = 28;

  ChartSection? _sectionAt(Offset localPos) {
    final center = const Offset(_size / 2, _size / 2);
    final dx = localPos.dx - center.dx;
    final dy = localPos.dy - center.dy;
    final distance = math.sqrt(dx * dx + dy * dy);
    final outerRadius = _size / 2;
    final innerRadius = outerRadius - _strokeWidth;
    if (distance < innerRadius || distance > outerRadius) {
      return null; // hit the hole or outside the ring
    }
    var theta = math.atan2(dy, dx) - (-math.pi / 2);
    if (theta < 0) theta += 2 * math.pi;

    final total = sections.fold<double>(0, (s, x) => s + x.value);
    if (total <= 0) return null;
    var cursor = 0.0;
    for (final section in sections) {
      final sweep = (section.value / total) * 2 * math.pi;
      if (theta < cursor + sweep) {
        return section;
      }
      cursor += sweep;
    }
    return sections.isNotEmpty ? sections.last : null;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: _size,
      height: _size,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapUp: onSectionTap == null
            ? null
            : (details) {
                final hit = _sectionAt(details.localPosition);
                if (hit != null) onSectionTap!(hit);
              },
        child: Stack(
          alignment: Alignment.center,
          children: [
            CustomPaint(
              size: const Size.square(_size),
              painter: _DonutPainter(sections: sections),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  AppFormatters.money(
                    total,
                    symbol: '',
                    trimDecimals: true,
                  ).trim(),
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                Text(
                  symbol.isEmpty ? '' : '$symbol total',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class MonthlyTrendChart extends StatelessWidget {
  const MonthlyTrendChart({
    super.key,
    required this.points,
    required this.locale,
  });

  final List<MonthPoint> points;
  final Locale locale;

  @override
  Widget build(BuildContext context) {
    final maxValue = _roundedMax(
      points.fold<double>(0, (max, point) => math.max(max, point.total)),
    );
    final labels = List.generate(
      5,
      (index) => (maxValue - ((maxValue / 4) * index)).round(),
    );

    return SizedBox(
      height: 220,
      child: LayoutBuilder(
        builder: (context, constraints) {
          const axisWidth = 38.0;
          const labelHeight = 24.0;
          const gap = 8.0;
          final chartHeight = constraints.maxHeight - labelHeight;

          return Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                width: axisWidth,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: labelHeight),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: labels
                        .map(
                          (value) => Text(
                            '$value',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        )
                        .toList(growable: false),
                  ),
                ),
              ),
              const SizedBox(width: gap),
              Expanded(
                child: Stack(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: labelHeight),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const [
                          _DottedLine(color: AppColors.border),
                          _DottedLine(color: AppColors.border),
                          _DottedLine(color: AppColors.border),
                          _DottedLine(color: AppColors.border),
                          _DottedLine(color: AppColors.border),
                        ],
                      ),
                    ),
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: labelHeight,
                      height: chartHeight,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: points
                            .map(
                              (point) => Expanded(
                                child: _BarItem(
                                  heightFactor: point.total / maxValue,
                                ),
                              ),
                            )
                            .toList(growable: false),
                      ),
                    ),
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: Row(
                        children: points
                            .map(
                              (point) => Expanded(
                                child: Center(
                                  child: Text(
                                    AppFormatters.monthChip(
                                      point.month,
                                      locale,
                                    ).split(' ').first,
                                    overflow: TextOverflow.ellipsis,
                                    style:
                                        Theme.of(context).textTheme.bodyMedium,
                                  ),
                                ),
                              ),
                            )
                            .toList(growable: false),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  double _roundedMax(double value) {
    if (value <= 0) {
      return 300;
    }
    return (value / 300).ceil() * 300;
  }
}

class _DonutPainter extends CustomPainter {
  _DonutPainter({required this.sections});

  final List<ChartSection> sections;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final strokeWidth = 28.0;
    final total = sections.fold<double>(
      0,
      (sum, section) => sum + section.value,
    );
    var startAngle = -math.pi / 2;

    for (final section in sections) {
      final sweep = (section.value / total) * math.pi * 2;
      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.butt
        ..color = section.color;
      canvas.drawArc(
        rect.deflate(strokeWidth / 2),
        startAngle,
        sweep - 0.04,
        false,
        paint,
      );
      startAngle += sweep;
    }
  }

  @override
  bool shouldRepaint(covariant _DonutPainter oldDelegate) {
    return oldDelegate.sections != sections;
  }
}

class _BarItem extends StatelessWidget {
  const _BarItem({required this.heightFactor});

  final double heightFactor;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: FractionallySizedBox(
        heightFactor: heightFactor.clamp(0.0, 1.0),
        widthFactor: 0.6,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }
}

class _DottedLine extends StatelessWidget {
  const _DottedLine({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final dotCount = (constraints.maxWidth / 8).floor();
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(
            math.max(1, dotCount),
            (_) => Container(width: 4, height: 1, color: color),
          ),
        );
      },
    );
  }
}
