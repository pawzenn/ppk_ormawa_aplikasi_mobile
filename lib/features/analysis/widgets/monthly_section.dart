// lib/features/analysis/widgets/monthly_section.dart
import 'package:flutter/material.dart';

import '../../../core/lahan/current_lahan.dart';
import '../../../core/rtdb/aggregates_streams.dart';
import '../../../shared/widgets/bar_chart_simple.dart';

class MonthlySection extends StatelessWidget {
  final DateTime month;
  final String title;
  final VoidCallback onPrev;
  final VoidCallback onNext;

  const MonthlySection({
    super.key,
    required this.month,
    required this.title,
    required this.onPrev,
    required this.onNext,
  });

  static const _weekLabels = [
    '1–7',
    '8–14',
    '15–21',
    '22–28',
    '29–31',
  ];

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: CurrentLahan.instance.lahanId,
      builder: (context, lahanId, _) {
        return StreamBuilder<List<List<DayDoc>>>(
          stream: watchMonthWeeks(month, lahanId: lahanId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            // 5 minggu, masing-masing list DayDoc
            final weeks = snapshot.data ?? List.generate(5, (_) => <DayDoc>[]);

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Header bulan + tombol prev/next
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      onPressed: onPrev,
                      icon: const Icon(Icons.chevron_left),
                    ),
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    IconButton(
                      onPressed: onNext,
                      icon: const Icon(Icons.chevron_right),
                    ),
                  ],
                ),
                const SizedBox(height: 6),

                // Loop per minggu
                for (var i = 0; i < weeks.length; i++) ...[
                  Text(
                    'Minggu ${i + 1} (${_weekLabels[i]})',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 6),
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: SizedBox(
                        height: 200,
                        child: _buildWeekChart(weeks[i]),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ],
            );
          },
        );
      },
    );
  }

  /// Bangun chart 1 minggu: bar per hari (tanggal di bulan).
  Widget _buildWeekChart(List<DayDoc> days) {
    if (days.isEmpty) {
      // Kalau tidak ada data sama sekali, tampilkan chart kosong dengan 1 bar 0
      return BarChartSimple(
        values: const [0],
        bottomLabels: const ['-'],
        color: const Color(0xFF1E7A3F),
      );
    }

    // Urutkan dulu berdasarkan tanggal key
    final sorted = [...days]..sort((a, b) => a.dateKey.compareTo(b.dateKey));

    final labels = <String>[];
    final values = <double>[];

    for (final d in sorted) {
      // dateKey: yyyy-MM-dd -> ambil hari saja
      try {
        final dt = DateTime.parse(d.dateKey);
        labels.add(dt.day.toString());
      } catch (_) {
        labels.add(d.dateKey); // fallback kalau format beda
      }
      values.add(d.total.toDouble());
    }

    return BarChartSimple(
      values: values,
      bottomLabels: labels,
      color: const Color(0xFF1E7A3F),
    );
  }
}
