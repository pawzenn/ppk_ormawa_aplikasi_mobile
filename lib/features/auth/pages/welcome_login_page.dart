// lib/features/auth/pages/welcome_login_page.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../dashboard/pages/dashboard_page.dart';
import '../widgets/rounded_text_field.dart';

/// Halaman splash + login (PageView vertikal)
class WelcomeLoginPage extends StatefulWidget {
  const WelcomeLoginPage({super.key});

  @override
  State<WelcomeLoginPage> createState() => _WelcomeLoginPageState();
}

class _WelcomeLoginPageState extends State<WelcomeLoginPage> {
  final PageController _controller = PageController();
  final _nameCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscure = true;

  void _goLogin() {
    _controller.animateToPage(
      1,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _nameCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final green = const Color(0xFF1E7A3F);

    return Scaffold(
      body: PageView(
        controller: _controller,
        scrollDirection: Axis.vertical,
        physics: const BouncingScrollPhysics(),
        children: [
          _WelcomePage(onGoLogin: _goLogin),
          _LoginPage(
            green: green,
            nameCtrl: _nameCtrl,
            passCtrl: _passCtrl,
            obscure: _obscure,
            onToggleObscure: () => setState(() => _obscure = !_obscure),
          ),
        ],
      ),
    );
  }
}

/// ===================== PAGE 0 — WELCOME =====================
class _WelcomePage extends StatelessWidget {
  final VoidCallback onGoLogin;
  const _WelcomePage({required this.onGoLogin});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final green = const Color(0xFF1E7A3F);

    return Stack(
      children: [
        Positioned.fill(
          child: Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/image/splash.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
        Positioned.fill(
          child: Column(
            children: [
              const SizedBox(height: 90),
              Column(
                children: [
                  Text(
                    'SolarSonic',
                    style: GoogleFonts.orbitron(
                      textStyle: const TextStyle(color: Color(0xFFFFC107)),
                      fontSize: 40,
                      letterSpacing: 2,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'IoT',
                    style: GoogleFonts.orbitron(
                      color: Colors.white70,
                      fontSize: 22,
                      letterSpacing: 6,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'GuarD',
                    style: GoogleFonts.orbitron(
                      color: const Color(0xFFFFC107),
                      fontSize: 36,
                      letterSpacing: 3,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // === LOGO DI BAWAH JUDUL ===
                  Image.asset(
                    'assets/image/logo_solarsonic.png',
                    height: 260,
                  ),
                ],
              ),
              const Spacer(),
              Container(
                width: size.width,
                height: size.height * 0.38,
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F3F3),
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(size.width),
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x22000000),
                      blurRadius: 10,
                      offset: Offset(0, -2),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: onGoLogin,
                      child: Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x33000000),
                              blurRadius: 10,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.keyboard_arrow_up,
                          size: 28,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      'Selamat Datang!',
                      style: GoogleFonts.poppins(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: green,
                        shadows: const [
                          Shadow(
                            color: Color(0x22000000),
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Silakan masuk untuk melanjutkan.',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// ===================== PAGE 1 — LOGIN =====================
class _LoginPage extends StatelessWidget {
  final Color green;
  final TextEditingController nameCtrl;
  final TextEditingController passCtrl;
  final bool obscure;
  final VoidCallback onToggleObscure;

  const _LoginPage({
    required this.green,
    required this.nameCtrl,
    required this.passCtrl,
    required this.obscure,
    required this.onToggleObscure,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        color: const Color(0xFFEFF3F0),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 8),
              Center(
                child: CircleAvatar(
                  radius: 56,
                  backgroundColor: const Color(0xFFE8F3EC),
                  child: Icon(Icons.person, size: 56, color: green),
                ),
              ),
              const SizedBox(height: 14),
              Center(
                child: Text(
                  'Masuk',
                  style: GoogleFonts.poppins(
                    color: green,
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(height: 22),
              Text(
                'Nama',
                style: GoogleFonts.poppins(color: green, fontSize: 14),
              ),
              const SizedBox(height: 6),
              RoundedTextField(
                controller: nameCtrl,
                hint: 'Masukkan nama',
                leading: Icons.account_circle,
                background: green,
              ),
              const SizedBox(height: 14),
              Text(
                'Kata Sandi',
                style: GoogleFonts.poppins(color: green, fontSize: 14),
              ),
              const SizedBox(height: 6),
              RoundedTextField(
                controller: passCtrl,
                hint: 'Masukkan kata sandi',
                leading: Icons.lock,
                background: green,
                obscure: obscure,
                trailing: IconButton(
                  onPressed: onToggleObscure,
                  icon: Icon(
                    obscure ? Icons.visibility : Icons.visibility_off,
                    color: Colors.white,
                  ),
                ),
              ),
              const Spacer(),
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: () async {
                    final email = nameCtrl.text.trim();
                    final pass = passCtrl.text;

                    if (email.isEmpty || pass.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Email & password wajib diisi'),
                        ),
                      );
                      return;
                    }

                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (_) =>
                          const Center(child: CircularProgressIndicator()),
                    );

                    try {
                      await FirebaseAuth.instance.signInWithEmailAndPassword(
                        email: email,
                        password: pass,
                      );

                      final uid = FirebaseAuth.instance.currentUser?.uid;
                      // ignore: avoid_print
                      print('DEBUG: UID yang login sekarang = $uid');

                      if (context.mounted) {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (_) => const Dashboard(),
                          ),
                        );
                      }
                    } on FirebaseAuthException catch (e) {
                      if (context.mounted) {
                        Navigator.of(context).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content:
                                Text(e.message ?? 'Gagal login, coba lagi.'),
                          ),
                        );
                      }
                    } catch (_) {
                      if (context.mounted) {
                        Navigator.of(context).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Terjadi kesalahan tak terduga saat login',
                            ),
                          ),
                        );
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    elevation: 4,
                  ),
                  child: Text(
                    'Mulai',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}
