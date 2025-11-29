// lib/core/lahan/current_lahan.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Menyimpan dan mem-broadcast ID lahan yang sedang aktif.
/// - disimpan ke SharedPreferences (supaya persist)
/// - disesuaikan dengan ACL di RTDB: /acl/{uid}
class CurrentLahan {
  static const _prefKey = 'current_lahan_id';
  static final CurrentLahan instance = CurrentLahan._();
  CurrentLahan._();

  /// Default fallback (kalau user belum pernah pilih)
  /// Saat init akan dioverride oleh ACL jika ada.
  final ValueNotifier<String> lahanId = ValueNotifier<String>('lahan1');

  /// Dipanggil dari main() sekali saat startup.
  Future<void> init() async {
    final sp = await SharedPreferences.getInstance();

    // 1. Ambil dari SharedPreferences kalau sudah pernah disimpan
    final saved = sp.getString(_prefKey);
    if (saved != null && saved.isNotEmpty) {
      lahanId.value = saved;
      debugPrint('CurrentLahan.init: load dari SharedPreferences → $saved');
    } else {
      debugPrint(
          'CurrentLahan.init: belum ada di SharedPreferences, pakai default=${lahanId.value}');
    }

    // 2. Jika user sudah login & punya ACL, pilihkan lahan pertama yang ada di ACL
    final uid = FirebaseAuth.instance.currentUser?.uid;
    debugPrint('CurrentLahan.init: uid sekarang = $uid');

    if (uid != null) {
      final aclRef = FirebaseDatabase.instance.ref('acl/$uid');
      final aclSnap = await aclRef.get();

      debugPrint('CurrentLahan.init: snapshot acl/$uid = ${aclSnap.value}');

      if (aclSnap.exists) {
        final m = (aclSnap.value as Map?) ?? {};
        if (m.isNotEmpty) {
          final firstKey = m.keys.first.toString();
          debugPrint('CurrentLahan.init: daftar lahan dari ACL = ${m.keys}');

          // Kalau lahan yang tersimpan tidak ada di ACL, pakai lahan pertama
          if (!m.containsKey(lahanId.value)) {
            debugPrint(
                'CurrentLahan.init: lahan tersimpan (${lahanId.value}) tidak ada di ACL, ganti ke $firstKey');
            lahanId.value = firstKey;
            await sp.setString(_prefKey, firstKey);
          }
        } else {
          debugPrint('CurrentLahan.init: ACL kosong untuk uid=$uid');
        }
      } else {
        debugPrint('CurrentLahan.init: node acl/$uid tidak ada');
      }
    }
  }

  /// Ganti lahan aktif dan simpan ke SharedPreferences
  Future<void> setLahan(String id) async {
    lahanId.value = id;
    final sp = await SharedPreferences.getInstance();
    await sp.setString(_prefKey, id);
    debugPrint('CurrentLahan.setLahan: lahan aktif diganti ke $id');
  }
}

/// Item lahan untuk ditampilkan di list picker
class LahanItem {
  final String id;
  final String label;
  final bool online;

  LahanItem({
    required this.id,
    required this.label,
    required this.online,
  });
}

/// Stream daftar lahan yang dimiliki user berdasarkan ACL: /acl/{uid}
/// + ambil optional display_name dari lahan_meta/$id (sesuai rules)
Stream<List<LahanItem>> watchUserLahan() async* {
  final uid = FirebaseAuth.instance.currentUser?.uid;
  if (uid == null) {
    debugPrint('watchUserLahan: UID null → user belum login');
    yield const <LahanItem>[];
    return;
  }

  final db = FirebaseDatabase.instance.ref();
  debugPrint('watchUserLahan: listen ACL untuk uid=$uid');

  await for (final aclEv in db.child('acl/$uid').onValue) {
    try {
      final raw = aclEv.snapshot.value;
      debugPrint('watchUserLahan: raw ACL snapshot = $raw');

      final aclMap = (raw as Map?) ?? {};
      final ids = aclMap.keys.map((e) => e.toString()).toList()..sort();
      debugPrint('watchUserLahan: ids terdeteksi dari ACL = $ids');

      final items = <LahanItem>[];

      for (final id in ids) {
        // Default: label = id
        String label = id;

        // Coba ambil lahan_meta/$id/display_name (INI sesuai rules-mu)
        try {
          final metaSnap = await db
              .child('lahan_meta')
              .child(id)
              .child('display_name')
              .get();
          if (metaSnap.exists && metaSnap.value != null) {
            label = metaSnap.value.toString();
          }
        } catch (e) {
          debugPrint('watchUserLahan: gagal baca lahan_meta/$id → $e');
        }

        // Untuk sekarang, status online belum dihitung (false dulu)
        items.add(LahanItem(
          id: id,
          label: label,
          online: false,
        ));
      }

      debugPrint('watchUserLahan: hasil items length=${items.length} '
          '→ ${items.map((e) => '${e.id}/${e.label}').toList()}');

      yield items;
    } catch (e, st) {
      debugPrint('watchUserLahan ERROR (outer): $e\n$st');
      // Jangan bikin stream mati, kirim list kosong saja
      yield const <LahanItem>[];
    }
  }
}
