// lib/features/dashboard/widgets/sound_control_card.dart
import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class SoundControlCard extends StatefulWidget {
  final String lahanId;

  const SoundControlCard({
    super.key,
    required this.lahanId,
  });

  @override
  State<SoundControlCard> createState() => _SoundControlCardState();
}

class _SoundControlCardState extends State<SoundControlCard> {
  late final DatabaseReference _ctrlRef;
  late final DatabaseReference _stateRef;

  bool soundAuto = true;
  double manualVolume = 50.0;

  Timer? _debounce;

  String appliedMode = '-';
  int appliedVolume = 0;
  bool speakerConnected = false;
  DateTime? lastSeen;

  StreamSubscription<DatabaseEvent>? _stateSub;

  @override
  void initState() {
    super.initState();

    _ctrlRef =
        FirebaseDatabase.instance.ref().child('control/${widget.lahanId}');
    _stateRef =
        FirebaseDatabase.instance.ref().child('state/${widget.lahanId}');

    // Baca nilai awal kontrol
    _ctrlRef.get().then((snap) {
      final m = (snap.value as Map?) ?? {};
      setState(() {
        final mode = (m['sound_mode'] ?? 'AUTO').toString().toUpperCase();
        soundAuto = (mode == 'AUTO');
        manualVolume = ((m['volume'] ?? 50) as num).toDouble();
      });
    }).catchError((e) {
      debugPrint('init control read error: $e');
    });

    // Dengarkan state (feedback dari Raspberry)
    _stateSub = _stateRef.onValue.listen(
      (e) {
        final m = (e.snapshot.value as Map?) ?? {};
        setState(() {
          appliedMode = (m['applied_mode'] ?? '-').toString();
          appliedVolume = ((m['applied_volume'] ?? 0) as num).toInt();
          speakerConnected = (m['speaker_connected'] ?? false) as bool;

          final ts = m['last_seen'];
          if (ts is int) {
            lastSeen = DateTime.fromMillisecondsSinceEpoch(
                    ts > 2000000000 ? ts : ts * 1000)
                .toLocal();
          } else {
            lastSeen = null;
          }
        });
      },
      onError: (e) => debugPrint('state listen error: $e'),
    );
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _stateSub?.cancel();
    super.dispose();
  }

  Future<void> _commitControl() async {
    try {
      await _ctrlRef.update({
        'sound_mode': soundAuto ? 'AUTO' : 'MANUAL',
        'volume': manualVolume.round(),
        'updated_at': ServerValue.timestamp,
      });
    } catch (e) {
      debugPrint('RTDB update error: $e');
    }
  }

  void _debouncedCommit() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 800), _commitControl);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black12),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Suara Burung',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),

            // Toggle Auto / Manual
            Row(
              children: [
                Expanded(
                  child: RadioListTile<bool>(
                    value: true,
                    groupValue: soundAuto,
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                    visualDensity: VisualDensity.compact,
                    onChanged: (v) {
                      setState(() => soundAuto = true);
                      _commitControl(); // langsung kirim saat pindah Auto
                    },
                    title: const Text('Auto'),
                  ),
                ),
                Expanded(
                  child: RadioListTile<bool>(
                    value: false,
                    groupValue: soundAuto,
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                    visualDensity: VisualDensity.compact,
                    onChanged: (v) {
                      setState(() => soundAuto = false);
                      _commitControl(); // pindah Manual -> kirim status
                    },
                    title: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('Manual'),
                        SizedBox(width: 8),
                        Icon(Icons.hearing, size: 18, color: Colors.grey),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // Slider volume (aktif hanya saat Manual)
            Row(
              children: [
                const Icon(Icons.volume_mute, size: 20),
                const SizedBox(width: 4),
                Expanded(
                  child: Slider(
                    value: manualVolume,
                    min: 0,
                    max: 100,
                    divisions: 100,
                    label: manualVolume.round().toString(),
                    onChanged: soundAuto
                        ? null
                        : (v) {
                            setState(() => manualVolume = v);
                            _debouncedCommit();
                          },
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(Icons.volume_up, size: 20),
                const SizedBox(width: 4),
                SizedBox(
                  width: 32,
                  child: Text(
                    manualVolume.round().toString(),
                    textAlign: TextAlign.right,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),

            // Text(
            //   soundAuto
            //       ? 'Mode Auto aktif (volume dikendalikan sistem).'
            //       : 'Mode Manual: volume = ${manualVolume.round()}',
            //   style: const TextStyle(color: Colors.black54),
            // ),

            const SizedBox(height: 8),

            // Info feedback dari perangkat (opsional)
            // if (lastSeen != null)
            //   Text(
            //     'Terakhir aktif: $lastSeen'
            //     ' • mode terapan: $appliedMode'
            //     ' • volume: $appliedVolume'
            //     '${speakerConnected ? ' • speaker tersambung' : ''}',
            //     style: const TextStyle(
            //       fontSize: 11,
            //       color: Colors.black45,
            //     ),
            //     maxLines: 3,
            //     overflow: TextOverflow.ellipsis,
            //     softWrap: true,
            //   ),
          ],
        ),
      ),
    );
  }
}
