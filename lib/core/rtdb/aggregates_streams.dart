// lib/core/rtdb/aggregates_streams.dart
import 'package:firebase_database/firebase_database.dart';

import '../utils/date_time_utils.dart';

final DatabaseReference _rtdb = FirebaseDatabase.instance.ref();

/// Model kecil untuk data harian
class DayDoc {
  final String dateKey; // yyyy-MM-dd
  final num pagi;
  final num malam;
  final num total;

  DayDoc(
    this.dateKey, {
    this.pagi = 0,
    this.malam = 0,
    this.total = 0,
  });
}

/// Model untuk bucket bulanan (5 bucket tanggal)
class MonthBuckets {
  final List<num> totals; // panjang 5
  final List<String> labels;

  MonthBuckets(this.totals, this.labels);
}

/// Stream 7 hari terakhir dari aggregates/daily/{lahanId}/{YYYY-MM-DD}
Stream<List<DayDoc>> watchLast7Days({String lahanId = 'lahan1'}) {
  final now = DateTime.now();
  final startKey = keyOfDate(now.subtract(const Duration(days: 6)));
  final endKey = keyOfDate(now);

  final q = _rtdb
      .child('aggregates/daily/$lahanId')
      .orderByKey()
      .startAt(startKey)
      .endAt(endKey);

  return q.onValue.map((snap) {
    final raw = snap.snapshot.value;
    if (raw == null) return const <DayDoc>[];

    final Map<dynamic, dynamic> map = raw is Map
        ? Map<dynamic, dynamic>.from(raw)
        : raw is List
            ? {for (var i = 0; i < raw.length; i++) '$i': raw[i]}
            : {};

    final keys = map.keys.map((e) => e.toString()).toList()..sort();

    final result = <DayDoc>[];
    for (final k in keys) {
      final v = map[k];
      if (v == null) continue;
      final m = Map<dynamic, dynamic>.from(v as Map);
      final pagi = (m['hama_pagi'] ?? 0) as num;
      final malam = (m['hama_malam'] ?? 0) as num;
      final total = (m['total'] ?? (pagi + malam)) as num;
      result.add(
        DayDoc(k, pagi: pagi, malam: malam, total: total),
      );
    }

    return result;
  });
}

/// Stream 5 bucket bulanan dari aggregates/daily/{lahanId}
/// (masih dipertahankan kalau nanti butuh total per minggu)
Stream<MonthBuckets> watchMonth5Buckets(
  DateTime month, {
  String lahanId = 'lahan1',
}) {
  final startKey = monthStartKey(month);
  final lastDay = DateTime(month.year, month.month + 1, 0).day;
  final endKey = monthEndKey(month);

  final labels = <String>[
    '1–7',
    '8–14',
    '15–21',
    '22–28',
    '29–$lastDay',
  ];

  final q = _rtdb
      .child('aggregates/daily/$lahanId')
      .orderByKey()
      .startAt(startKey)
      .endAt(endKey);

  return q.onValue.map((snap) {
    final raw = snap.snapshot.value;
    final map = raw is Map
        ? Map<String, dynamic>.from(raw as Map)
        : raw is List
            ? {for (var i = 0; i < raw.length; i++) '$i': raw[i]}
            : <String, dynamic>{};

    final totals = List<num>.filled(5, 0);

    for (final entry in map.entries) {
      final key = entry.key.toString(); // YYYY-MM-DD
      if (key.length < 10) continue;
      final day = int.tryParse(key.substring(8, 10)) ?? 0;
      if (day <= 0 || day > lastDay) continue;

      final idx = ((day - 1) ~/ 7).clamp(0, 4);
      final m = Map<String, dynamic>.from(entry.value as Map);
      totals[idx] += (m['total'] ?? 0) as num;
    }

    return MonthBuckets(totals, labels);
  });
}

/// Stream data harian 1 bulan, dikelompokkan jadi 5 minggu:
/// [ [hari1..hari7], [8..14], [15..21], [22..28], [29..31] ]
Stream<List<List<DayDoc>>> watchMonthWeeks(
  DateTime month, {
  String lahanId = 'lahan1',
}) {
  final startKey = monthStartKey(month);
  final endKey = monthEndKey(month);
  final lastDay = DateTime(month.year, month.month + 1, 0).day;

  final q = _rtdb
      .child('aggregates/daily/$lahanId')
      .orderByKey()
      .startAt(startKey)
      .endAt(endKey);

  return q.onValue.map((snap) {
    final raw = snap.snapshot.value;
    if (raw == null) {
      return List<List<DayDoc>>.generate(5, (_) => <DayDoc>[]);
    }

    final Map<dynamic, dynamic> map = raw is Map
        ? Map<dynamic, dynamic>.from(raw)
        : raw is List
            ? {for (var i = 0; i < raw.length; i++) '$i': raw[i]}
            : {};

    final keys = map.keys.map((e) => e.toString()).toList()..sort();

    // Siapkan 5 bucket minggu
    final List<List<DayDoc>> weeks =
        List<List<DayDoc>>.generate(5, (_) => <DayDoc>[]);

    for (final k in keys) {
      final v = map[k];
      if (v == null) continue;
      final m = Map<dynamic, dynamic>.from(v as Map);

      final pagi = (m['hama_pagi'] ?? 0) as num;
      final malam = (m['hama_malam'] ?? 0) as num;
      final total = (m['total'] ?? (pagi + malam)) as num;

      // k seharusnya YYYY-MM-DD
      if (k.length < 10) continue;
      final day = int.tryParse(k.substring(8, 10)) ?? 0;
      if (day <= 0 || day > lastDay) continue;

      final idx = ((day - 1) ~/ 7).clamp(0, 4);

      weeks[idx].add(
        DayDoc(k.toString(), pagi: pagi, malam: malam, total: total),
      );
    }

    return weeks;
  });
}
