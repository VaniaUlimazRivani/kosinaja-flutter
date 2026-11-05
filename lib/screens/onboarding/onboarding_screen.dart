import 'dart:async';
import 'package:flutter/material.dart';
import '../auth/login_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> with TickerProviderStateMixin {
  late final AnimationController _entranceController;
  late final AnimationController _pulseController;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _floatAnimation;
  late final Animation<double> _glowAnimation;

  Timer? _transitionTimer;
  Timer? _navTimer;
  bool _isTransitioningToLogin = false;

  @override
  void initState() {
    super.initState();

    // 1. Controller untuk animasi kemunculan logo & bayangan bulat
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );

    _scaleAnimation = CurvedAnimation(
      parent: _entranceController,
      curve: Curves.easeOutBack,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _entranceController,
      curve: Curves.easeIn,
    );

    // 2. Controller untuk animasi denyut aura dan melayang (breathing/floating)
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    );

    _floatAnimation = Tween<double>(begin: 0.0, end: -8.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _glowAnimation = Tween<double>(begin: 0.85, end: 1.25).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _entranceController.forward().then((_) {
      if (mounted) {
        _pulseController.repeat(reverse: true);
      }
    });

    // 3. Mulai transisi warna background ke polos saat menjelang pindah ke login (3.5 detik)
    _transitionTimer = Timer(const Duration(milliseconds: 3500), () {
      if (mounted) {
        setState(() {
          _isTransitioningToLogin = true;
        });
      }
    });

    // 4. Berpindah mulus ke halaman Login setelah 4.6 detik
    _navTimer = Timer(const Duration(milliseconds: 4600), () {
      if (mounted) {
        _goToLogin();
      }
    });
  }

  @override
  void dispose() {
    _transitionTimer?.cancel();
    _navTimer?.cancel();
    _entranceController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _goToLogin() {
    _transitionTimer?.cancel();
    _navTimer?.cancel();
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, anim, secAnim) => const LoginScreen(),
        transitionsBuilder: (context, anim, secAnim, child) {
          return FadeTransition(opacity: anim, child: child);
        },
        transitionDuration: const Duration(milliseconds: 600),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const titleColor = Color(0xFF1E293B);
    const mutedColor = Color(0xFF64748B);
    const footerColor = Color(0xFF94A3B8);

    final screenWidth = MediaQuery.of(context).size.width;
    // Ukuran logo diperbesar sekitar 20% lagi (menjadi 52% dari lebar layar)
    final logoSize = screenWidth * 0.52;
    final cardSize = logoSize * 1.22;

    return Scaffold(
      backgroundColor: const Color(0xFFFAF6F0),
      body: GestureDetector(
        onTap: _goToLogin,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 1000),
          curve: Curves.easeInOut,
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            color: _isTransitioningToLogin ? const Color(0xFFFAF6F0) : null,
            gradient: _isTransitioningToLogin
                ? null
                : const RadialGradient(
                    center: Alignment(0, -0.15),
                    radius: 0.95,
                    colors: [
                      Color(0xFFFFFDF8),
                      Color(0xFFF7EFE4),
                      Color(0xFFEADBCC),
                    ],
                  ),
          ),
          child: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 20),

                // CENTER CONTENT: ANIMATED LOGO & BAYANGAN BULAT
                Expanded(
                  child: Center(
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          AnimatedBuilder(
                            animation: _pulseController,
                            builder: (context, child) {
                              return Transform.translate(
                                offset: Offset(0, _floatAnimation.value),
                                child: ScaleTransition(
                                  scale: _scaleAnimation,
                                  child: child,
                                ),
                              );
                            },
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                // 1. AURA BAYANGAN BULAT LUAR (MENGEMBANG & BERDENYUT)
                                AnimatedBuilder(
                                  animation: _pulseController,
                                  builder: (context, child) {
                                    final auraScale = _isTransitioningToLogin ? 0.75 : _glowAnimation.value;
                                    return Transform.scale(
                                      scale: auraScale,
                                      child: Container(
                                        width: cardSize * 1.25,
                                        height: cardSize * 1.25,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          gradient: RadialGradient(
                                            colors: [
                                              const Color(0xFFB86B35).withOpacity(0.28),
                                              const Color(0xFFD4A373).withOpacity(0.12),
                                              Colors.transparent,
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),

                                // 2. KARTU BAYANGAN BULAT MEWAH (CIRCULAR SHADOW CARD)
                                Container(
                                  width: cardSize,
                                  height: cardSize,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white,
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFFB86B35).withOpacity(
                                          _isTransitioningToLogin ? 0.06 : 0.28,
                                        ),
                                        blurRadius: _isTransitioningToLogin ? 14 : 38,
                                        spreadRadius: _isTransitioningToLogin ? 0 : 4,
                                        offset: const Offset(0, 14),
                                      ),
                                      BoxShadow(
                                        color: const Color(0xFF2A1B14).withOpacity(0.08),
                                        blurRadius: 14,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Center(
                                    child: Image.asset(
                                      'assets/images/logo.png',
                                      width: logoSize,
                                      height: logoSize,
                                      fit: BoxFit.contain,
                                      errorBuilder: (context, error, stackTrace) {
                                        return Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.home_outlined,
                                              size: logoSize * 0.5,
                                              color: titleColor.withOpacity(0.9),
                                            ),
                                            const SizedBox(height: 4),
                                            const Text(
                                              'KOSINAJA',
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w900,
                                                letterSpacing: 2,
                                                color: titleColor,
                                              ),
                                            ),
                                          ],
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 32),

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
                ),

                // BOTTOM CONTENT: 3 DOTS INDICATOR & VERSION
                AnimatedOpacity(
                  opacity: _isTransitioningToLogin ? 0.0 : 1.0,
                  duration: const Duration(milliseconds: 600),
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 24),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: Color(0xFFF3D4BE),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              width: 10,
                              height: 10,
                              decoration: const BoxDecoration(
                                color: Color(0xFFB86B35),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: Color(0xFF2A1B14),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
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
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
