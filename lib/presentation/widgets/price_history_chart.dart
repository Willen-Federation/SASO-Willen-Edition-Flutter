import 'dart:ui' as ui show TextDirection;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../data/models/price_history_entry.dart';

/// Displays a list of price history entries with a sparkline chart when there
/// are two or more data points.
class PriceHistoryChart extends StatelessWidget {
  const PriceHistoryChart({super.key, required this.entries});

  final List<PriceHistoryEntry> entries;

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Text('価格データがありません'),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (entries.length >= 2) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              '価格推移',
              style: Theme.of(context).textTheme.titleSmall,
            ),
          ),
          SizedBox(
            height: 120,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _PriceSparkline(entries: entries),
            ),
          ),
          const Divider(),
        ],
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Text(
            '取得履歴',
            style: Theme.of(context).textTheme.titleSmall,
          ),
        ),
        ...entries.reversed.map(
          (e) => ListTile(
            dense: true,
            leading: const Icon(Icons.sell_outlined, size: 18),
            title: Text(
              '¥${_fmt.format(e.price)}',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: Text(
              DateFormat('yyyy/MM/dd HH:mm').format(e.fetchedAt.toLocal()),
            ),
            trailing: _SourceChip(source: e.source),
          ),
        ),
      ],
    );
  }

  static final _fmt = NumberFormat('#,###');
}

// ── Sparkline ──────────────────────────────────────────────────────────────

class _PriceSparkline extends StatelessWidget {
  const _PriceSparkline({required this.entries});
  final List<PriceHistoryEntry> entries;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;
    return CustomPaint(
      painter: _SparklinePainter(entries: entries, color: color),
      child: const SizedBox.expand(),
    );
  }
}

class _SparklinePainter extends CustomPainter {
  _SparklinePainter({required this.entries, required this.color});

  final List<PriceHistoryEntry> entries;
  final Color color;

  static final _labelFmt = NumberFormat('#,###');
  static final _dateFmt = DateFormat('M/d');

  @override
  void paint(Canvas canvas, Size size) {
    if (entries.length < 2) return;

    final prices = entries.map((e) => e.price.toDouble()).toList();
    final minP = prices.reduce((a, b) => a < b ? a : b);
    final maxP = prices.reduce((a, b) => a > b ? a : b);
    final rangeP = (maxP - minP).clamp(1.0, double.infinity);

    const padLeft = 56.0;
    const padRight = 8.0;
    const padTop = 8.0;
    const padBottom = 24.0;
    final chartW = size.width - padLeft - padRight;
    final chartH = size.height - padTop - padBottom;
    final n = entries.length;

    Offset toOffset(int i, double price) {
      final x = padLeft + (i / (n - 1)) * chartW;
      final y = padTop + (1 - (price - minP) / rangeP) * chartH;
      return Offset(x, y);
    }

    // Fill under line.
    final fillPath = Path();
    fillPath.moveTo(toOffset(0, prices[0]).dx, padTop + chartH);
    for (int i = 0; i < n; i++) {
      fillPath.lineTo(toOffset(i, prices[i]).dx, toOffset(i, prices[i]).dy);
    }
    fillPath.lineTo(toOffset(n - 1, prices[n - 1]).dx, padTop + chartH);
    fillPath.close();
    canvas.drawPath(
      fillPath,
      Paint()..color = color.withValues(alpha: 0.12),
    );

    // Line.
    final linePaint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final linePath = Path();
    linePath.moveTo(toOffset(0, prices[0]).dx, toOffset(0, prices[0]).dy);
    for (int i = 1; i < n; i++) {
      linePath.lineTo(toOffset(i, prices[i]).dx, toOffset(i, prices[i]).dy);
    }
    canvas.drawPath(linePath, linePaint);

    // Dots.
    final dotPaint = Paint()..color = color;
    for (int i = 0; i < n; i++) {
      canvas.drawCircle(toOffset(i, prices[i]), 3, dotPaint);
    }

    // Y-axis labels (min / max).
    final textStyle = TextStyle(
      fontSize: 10,
      color: color.withValues(alpha: 0.8),
    );
    void drawLabel(String text, Offset anchor) {
      final tp = TextPainter(
        text: TextSpan(text: text, style: textStyle),
        textDirection: ui.TextDirection.ltr,
      )..layout();
      tp.paint(
        canvas,
        Offset(padLeft - tp.width - 4, anchor.dy - tp.height / 2),
      );
    }

    drawLabel('¥${_labelFmt.format(maxP.toInt())}', toOffset(0, maxP));
    drawLabel('¥${_labelFmt.format(minP.toInt())}', toOffset(0, minP));

    // X-axis date labels for first and last.
    final dateStyle = TextStyle(fontSize: 9, color: Colors.grey.shade600);
    void drawDateLabel(String text, double x, {bool right = false}) {
      final tp = TextPainter(
        text: TextSpan(text: text, style: dateStyle),
        textDirection: ui.TextDirection.ltr,
      )..layout();
      canvas.drawText(
        tp,
        Offset(right ? x - tp.width : x, padTop + chartH + 4),
      );
    }

    drawDateLabel(
      _dateFmt.format(entries.first.fetchedAt.toLocal()),
      padLeft,
    );
    drawDateLabel(
      _dateFmt.format(entries.last.fetchedAt.toLocal()),
      padLeft + chartW,
      right: true,
    );
  }

  @override
  bool shouldRepaint(_SparklinePainter old) =>
      old.entries != entries || old.color != color;
}

extension on Canvas {
  void drawText(TextPainter tp, Offset offset) => tp.paint(this, offset);
}

// ── Source chip ────────────────────────────────────────────────────────────

class _SourceChip extends StatelessWidget {
  const _SourceChip({required this.source});
  final String source;

  @override
  Widget build(BuildContext context) {
    final label = switch (source) {
      'openbd' => 'OpenBD',
      'google_books' => 'Google',
      _ => source,
    };
    return Chip(
      label: Text(label, style: const TextStyle(fontSize: 10)),
      padding: EdgeInsets.zero,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      visualDensity: VisualDensity.compact,
    );
  }
}
