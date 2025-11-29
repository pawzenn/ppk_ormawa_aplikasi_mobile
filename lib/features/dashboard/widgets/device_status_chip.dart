// lib/features/dashboard/widgets/device_status_chip.dart
import 'package:flutter/material.dart';

class DeviceStatusChip extends StatelessWidget {
  final bool isOnline;
  final DateTime? lastSeen;

  const DeviceStatusChip({
    super.key,
    required this.isOnline,
    this.lastSeen,
  });

  @override
  Widget build(BuildContext context) {
    final bg = isOnline ? Colors.green.shade600 : Colors.grey.shade500;
    final label = isOnline ? 'Alat ON' : 'Alat OFF';

    String sub = '';
    if (lastSeen != null) {
      // sub = 'Terakhir aktif: '
      //     '${lastSeen!.hour.toString().padLeft(2, '0')}'
      //     ':'
      //     '${lastSeen!.minute.toString().padLeft(2, '0')}';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33000000),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.memory, size: 16, color: Colors.white),
          const SizedBox(width: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
              if (sub.isNotEmpty)
                Text(
                  sub,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 10,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
