// lib/features/dashboard/pages/notifications_view.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/rtdb/events_streams.dart';
import '../../../core/lahan/current_lahan.dart';

class NotificationsView extends StatelessWidget {
  const NotificationsView({super.key});

  @override
  Widget build(BuildContext context) {
    final fmtDay = DateFormat('EEEE, dd MMM yyyy', 'id_ID');
    final fmtTime = DateFormat('HH:mm', 'id_ID');

    return ValueListenableBuilder<String>(
      valueListenable: CurrentLahan.instance.lahanId,
      builder: (context, lahanId, _) {
        return StreamBuilder<List<EventItem>>(
          stream: watchRecentEvents(
            lahanId: lahanId,
            window: const Duration(hours: 48),
            onlyClass: 'tikus',
            minConf: 0.0,
            maxItems: 200,
          ),
          builder: (context, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final data = snap.data ?? const <EventItem>[];
            if (data.isEmpty) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Text('Belum ada deteksi dalam 2 hari terakhir.'),
                ),
              );
            }

            String? lastDateKey;

            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: data.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, i) {
                final e = data[i];
                final dateKey = DateFormat('yyyy-MM-dd').format(e.timeLocal);

                final isNewGroup = dateKey != lastDateKey;
                if (isNewGroup) lastDateKey = dateKey;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (isNewGroup) ...[
                      Text(
                        fmtDay.format(e.timeLocal),
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 6),
                    ],
                    Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        leading: const Icon(Icons.pest_control),
                        title: const Text(
                          'Hama terdeteksi',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        subtitle: Text(
                          'Pukul ${fmtTime.format(e.timeLocal)}'
                          '${e.conf > 0 ? ' • akurasi ${e.conf.toStringAsFixed(2)}' : ''}',
                        ),
                        // trailing DIHAPUS supaya tidak ada tanda ">"
                        // trailing: const Icon(Icons.chevron_right),
                      ),
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }
}
