import 'dart:async';
import 'package:flutter/material.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // Berpindah otomatis ke halaman Login setelah 5 detik
    _timer = Timer(const Duration(seconds: 5), () {
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/login');
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _skipToLogin() {
    _timer?.cancel();
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    const titleColor = Color(0xFF1E293B);
    const mutedColor = Color(0xFF64748B);
    const footerColor = Color(0xFF94A3B8);

    return Scaffold(
      backgroundColor: const Color(0xFFFAF6F0),
      body: GestureDetector(
        onTap: _skipToLogin,
        behavior: HitTestBehavior.opaque,
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: RadialGradient(
              center: Alignment.center,
              radius: 0.9,
              colors: [
                Color(0xFFFFFDF8),
                Color(0xFFFAF6F0),
              ],
            ),
          ),
          child: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 20),

                // CENTER CONTENT: LOGO & TAGLINE
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // LOGO KOSINAJA
                        Image.asset(
                          'assets/images/logo.png',
                          height: 120,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            return Column(
                              children: [
                                Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    Icon(
                                      Icons.home_outlined,
                                      size: 72,
                                      color: titleColor.withOpacity(0.9),
                                    ),
                                    Positioned(
                                      bottom: 16,
                                      child: Container(
                                        padding: const EdgeInsets.all(5),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFD4A373).withOpacity(0.4),
                                          borderRadius: BorderRadius.circular(4),
                                          border: Border.all(
                                            color: const Color(0xFF9C6644),
                                            width: 1.5,
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Container(
                                              width: 3.5,
                                              height: 3.5,
                                              decoration: const BoxDecoration(
                                                color: Color(0xFF7F4F24),
                                                shape: BoxShape.circle,
                                              ),
                                            ),
                                            const SizedBox(width: 2.5),
                                            Container(
                                              width: 3.5,
                                              height: 3.5,
                                              decoration: const BoxDecoration(
                                                color: Color(0xFF7F4F24),
                                                shape: BoxShape.circle,
                                              ),
                                            ),
                                            const SizedBox(width: 2.5),
                                            Container(
                                              width: 3.5,
                                              height: 3.5,
                                              decoration: const BoxDecoration(
                                                color: Color(0xFF7F4F24),
                                                shape: BoxShape.circle,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  'KOSINAJA',
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 2.5,
                                    color: titleColor,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                const Text(
                                  'Jasa Titip Barang Kos',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: titleColor,
                                  ),
                                ),
                              ],
                            );
                          },
                        ),

                        const SizedBox(height: 36),

                        // TAGLINE
                        const Text(
                          'SOLUSI TITIP & SIMPAN BARANG',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 2.5,
                            color: mutedColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // BOTTOM CONTENT: 3 DOTS INDICATOR & VERSION
                Padding(
                  padding: const EdgeInsets.only(bottom: 24),
                  child: Column(
                    children: [
                      // 3 DOTS INDICATOR
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Color(0xFFF3D4BE), // Light peach dot
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            width: 10,
                            height: 10,
                            decoration: const BoxDecoration(
                              color: Color(0xFFB86B35), // Terracotta dot
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Color(0xFF2A1B14), // Espresso dot
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 14),

                      // VERSION & GUARANTEE TEXT
                      const Text(
                        'v1.0.0 • Aman & Terpercaya',
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w500,
                          color: footerColor,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
