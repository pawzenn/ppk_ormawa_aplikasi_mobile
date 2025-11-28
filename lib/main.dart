// lib/main.dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter_application_1/core/firebase/firebase_options.md';
import 'package:intl/date_symbol_data_local.dart';
import 'core/lahan/current_lahan.dart';
import 'features/auth/pages/welcome_login_page.dart';
import 'features/dashboard/pages/dashboard_page.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Init Firebase

  // await Firebase.initializeApp(
  //   options: DefaultFirebaseOptions.currentPlatform,
  // );

  // Fix bug stuck in main
  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }

  // Init locale Indonesia (biar date format id_ID jalan)
  await initializeDateFormatting('id_ID', null);

  // Init CurrentLahan (load preferensi dari SharedPreferences)
  await CurrentLahan.instance.init();

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
