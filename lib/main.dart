// lib/main.dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'firebase_options.dart';
import 'core/lahan/current_lahan.dart';
import 'features/auth/pages/welcome_login_page.dart';
import 'features/dashboard/pages/dashboard_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Init Firebase
  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }

  // Init locale Indonesia (biar date format id_ID jalan)
  await initializeDateFormatting('id_ID', null);

  // Init CurrentLahan (load preferensi dari SharedPreferences)
  await CurrentLahan.instance.init();

  // DEBUG: cek UID user yang lagi login (kalau ada sesi login tersimpan)
  final uid = FirebaseAuth.instance.currentUser?.uid;
  debugPrint('=== CURRENT UID (main): $uid ===');

  runApp(const SolarSonicApp());
}

class SolarSonicApp extends StatelessWidget {
  const SolarSonicApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SolarSonic IoT Guard',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFF1E7A3F),
        brightness: Brightness.light,
      ),
      home: const AppRoot(),
    );
  }
}

/// Mengecek apakah user sedang login atau belum
class AppRoot extends StatelessWidget {
  const AppRoot({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snap) {
        // Masih loading → tampilkan splash kecil
        if (snap.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        final user = snap.data;

        // Kalau belum login → ke halaman welcome/login
        if (user == null) {
          return const WelcomeLoginPage();
        }

        // Sudah login → langsung Dashboard
        return const Dashboard();
      },
    );
  }
}
