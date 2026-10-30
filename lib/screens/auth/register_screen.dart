import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../core/theme/app_colors.dart';
import '../../core/services/api_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _agreeTerms = false;
  bool _isLoading = false;
  bool _isGoogleLoading = false;
  int _passwordStrength = 0; // 0 to 4

  @override
  void initState() {
    super.initState();
    _passwordController.addListener(_updatePasswordStrength);
  }

  @override
  void dispose() {
    _passwordController.removeListener(_updatePasswordStrength);
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _updatePasswordStrength() {
    final password = _passwordController.text;
    int strength = 0;
    if (password.length >= 6) strength++;
    if (password.length >= 8) strength++;
    if (RegExp(r'[0-9]').hasMatch(password)) strength++;
    if (RegExp(r'[A-Z]').hasMatch(password) ||
        RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password)) {
      strength++;
    }
    setState(() {
      _passwordStrength = strength;
    });
  }

  String get _strengthLabel {
    switch (_passwordStrength) {
      case 1:
        return 'Sangat Lemah';
      case 2:
        return 'Cukup';
      case 3:
        return 'Kuat';
      case 4:
        return 'Sangat Kuat';
      default:
        return '-';
    }
  }

  Color get _strengthColor {
    switch (_passwordStrength) {
      case 1:
        return const Color(0xFFEF4444);
      case 2:
        return const Color(0xFFF59E0B);
      case 3:
        return const Color(0xFF10B981);
      case 4:
        return const Color(0xFF059669);
      default:
        return const Color(0xFFE2E8F0);
    }
  }

  Future<void> _handleRegister() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirm = _confirmPasswordController.text;

    if (name.isEmpty || email.isEmpty || password.isEmpty || confirm.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Harap lengkapi seluruh formulir pendaftaran.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (!email.contains('@') || !email.contains('.')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Format email tidak valid (contoh: alex@gmail.com).'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (password.length < 8) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Kata sandi minimal 8 karakter.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (password != confirm) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Konfirmasi kata sandi tidak cocok.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (!_agreeTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Harap centang persetujuan Syarat & Ketentuan.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final result = await ApiService.register(
      nama: name,
      email: email,
      noWa: '081234567890',
      password: password,
      alamat: 'Padang, Sumatera Barat',
    );

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

    if (result['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? 'Akun berhasil dibuat! Silakan masuk.'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.pushReplacementNamed(context, '/login');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['error'] ?? 'Terjadi kesalahan saat pendaftaran.'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _handleGoogleSignUp() async {
    setState(() {
      _isGoogleLoading = true;
    });

    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        if (mounted) setState(() => _isGoogleLoading = false);
        return;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);
      final User? firebaseUser = userCredential.user;

      if (firebaseUser != null) {
        ApiService.currentUser = ApiUser(
          id: firebaseUser.uid,
          nama: firebaseUser.displayName ?? googleUser.displayName ?? 'Mahasiswa KosinAja',
          email: firebaseUser.email ?? googleUser.email,
          noWa: firebaseUser.phoneNumber ?? '081234567890',
          alamat: 'Kota Padang, Sumatera Barat',
        );

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Pendaftaran Google Berhasil! Selamat datang, ${firebaseUser.displayName ?? ''}'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
          ),
        );

        Navigator.pushReplacementNamed(context, '/home');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Google Sign-Up: $e'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isGoogleLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFFB86B35); // Terracotta
    const titleColor = Color(0xFF1E293B); // Deep Navy / Slate
    const subtitleColor = Color(0xFF64748B); // Slate Muted
    const borderColor = Color(0xFFE2E8F0);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. TOP HEADER (Logo + Button Masuk)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/logo.png',
                    height: 44,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return Row(
                        children: [
                          Icon(Icons.home_outlined, size: 28, color: titleColor),
                          const SizedBox(width: 6),
                          const Text(
                            'KOSINAJA',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.5,
                              color: titleColor,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, '/login');
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      side: const BorderSide(color: borderColor),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    icon: const Text(
                      'Masuk',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: titleColor,
                      ),
                    ),
                    label: const Icon(
                      Icons.person_outline_rounded,
                      size: 16,
                      color: titleColor,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // 2. SECURITY BADGE CAPSULE
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF7EF),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFF9DFC7)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(
                      Icons.shield_outlined,
                      size: 14,
                      color: primaryColor,
                    ),
                    SizedBox(width: 6),
                    Text(
                      'Keamanan Terjamin 100%',
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: primaryColor,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // 3. TITLE & SUBTITLE
              const Text(
                'Buat Akun Baru',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  color: titleColor,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Mulai pengalaman penitipan barang terbaik Anda dalam hitungan detik.',
                style: TextStyle(
                  fontSize: 13,
                  color: subtitleColor,
                  height: 1.4,
                ),
              ),

              const SizedBox(height: 24),

              // 4. INPUT: NAMA LENGKAP
              Text(
                'Nama Lengkap',
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                  color: titleColor.withOpacity(0.9),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: borderColor),
                ),
                child: TextField(
                  controller: _nameController,
                  style: const TextStyle(fontSize: 14, color: titleColor),
                  decoration: const InputDecoration(
                    hintText: 'cth. Alex Pratama',
                    hintStyle: TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
                    prefixIcon: Icon(Icons.person_outline_rounded, color: Color(0xFF94A3B8), size: 20),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // 5. INPUT: ALAMAT EMAIL
              Text(
                'Alamat Email',
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                  color: titleColor.withOpacity(0.9),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: borderColor),
                ),
                child: TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  style: const TextStyle(fontSize: 14, color: titleColor),
                  decoration: const InputDecoration(
                    hintText: 'alex@gmail.com',
                    hintStyle: TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
                    prefixIcon: Icon(Icons.mail_outline_rounded, color: Color(0xFF94A3B8), size: 20),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // 6. INPUT: KATA SANDI
              Text(
                'Kata Sandi',
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                  color: titleColor.withOpacity(0.9),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: borderColor),
                ),
                child: TextField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  style: const TextStyle(fontSize: 14, color: titleColor),
                  decoration: InputDecoration(
                    hintText: 'Minimal 8 karakter unik',
                    hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
                    prefixIcon: const Icon(Icons.lock_outline_rounded, color: Color(0xFF94A3B8), size: 20),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                        color: const Color(0xFF94A3B8),
                        size: 20,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                ),
              ),

              const SizedBox(height: 8),

              // 7. PASSWORD STRENGTH BAR
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Kekuatan kata sandi:',
                    style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
                  ),
                  Text(
                    _strengthLabel,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: _strengthColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: List.generate(4, (index) {
                  final isFilled = index < _passwordStrength;
                  return Expanded(
                    child: Container(
                      height: 4,
                      margin: EdgeInsets.only(right: index < 3 ? 6 : 0),
                      decoration: BoxDecoration(
                        color: isFilled ? _strengthColor : const Color(0xFFE2E8F0),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  );
                }),
              ),

              const SizedBox(height: 16),

              // 8. INPUT: KONFIRMASI KATA SANDI
              Text(
                'Konfirmasi Kata Sandi',
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                  color: titleColor.withOpacity(0.9),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: borderColor),
                ),
                child: TextField(
                  controller: _confirmPasswordController,
                  obscureText: _obscureConfirmPassword,
                  style: const TextStyle(fontSize: 14, color: titleColor),
                  decoration: InputDecoration(
                    hintText: 'Ulangi kata sandi',
                    hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
                    prefixIcon: const Icon(Icons.lock_outline_rounded, color: Color(0xFF94A3B8), size: 20),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirmPassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                        color: const Color(0xFF94A3B8),
                        size: 20,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureConfirmPassword = !_obscureConfirmPassword;
                        });
                      },
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // 9. CHECKBOX TERMS & PRIVACY
              GestureDetector(
                onTap: () {
                  setState(() {
                    _agreeTerms = !_agreeTerms;
                  });
                },
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 18,
                      height: 18,
                      margin: const EdgeInsets.only(top: 2),
                      decoration: BoxDecoration(
                        color: _agreeTerms ? primaryColor : Colors.white,
                        borderRadius: BorderRadius.circular(5),
                        border: Border.all(
                          color: _agreeTerms ? primaryColor : borderColor,
                          width: 1.5,
                        ),
                      ),
                      child: _agreeTerms
                          ? const Icon(Icons.check, size: 14, color: Colors.white)
                          : null,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: RichText(
                        text: TextSpan(
                          style: const TextStyle(
                            fontSize: 12,
                            color: subtitleColor,
                            height: 1.4,
                          ),
                          children: [
                            const TextSpan(text: 'Saya menyetujui '),
                            TextSpan(
                              text: 'Syarat & Ketentuan',
                              style: const TextStyle(
                                color: primaryColor,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const TextSpan(text: ' serta '),
                            TextSpan(
                              text: 'Kebijakan Privasi',
                              style: const TextStyle(
                                color: primaryColor,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const TextSpan(text: ' Kosinaja.'),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 22),

              // 10. BUTTON: BUAT AKUN SAYA
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleRegister,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    elevation: 2,
                    shadowColor: primaryColor.withOpacity(0.35),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Buat Akun Saya',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 20),

              // 11. DIVIDER: atau daftar dengan
              Row(
                children: [
                  const Expanded(child: Divider(color: borderColor)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    child: Text(
                      'atau daftar dengan',
                      style: TextStyle(
                        fontSize: 12,
                        color: subtitleColor.withOpacity(0.85),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const Expanded(child: Divider(color: borderColor)),
                ],
              ),

              const SizedBox(height: 16),

              // 12. GOOGLE SIGN-UP BUTTON
              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton(
                  onPressed: _isGoogleLoading ? null : _handleGoogleSignUp,
                  style: OutlinedButton.styleFrom(
                    backgroundColor: Colors.white,
                    side: const BorderSide(color: borderColor),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: _isGoogleLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CustomPaint(
                                painter: _GoogleLogoPainter(),
                              ),
                            ),
                            const SizedBox(width: 10),
                            const Text(
                              'Google',
                              style: TextStyle(
                                fontSize: 14.5,
                                fontWeight: FontWeight.w700,
                                color: titleColor,
                              ),
                            ),
                          ],
                        ),
                ),
              ),

              const SizedBox(height: 20),

              // 13. PROMPT: SUDAH MEMILIKI AKUN? MASUK DI SINI
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Sudah memiliki akun? ',
                    style: TextStyle(
                      fontSize: 13,
                      color: subtitleColor,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushReplacementNamed(context, '/login');
                    },
                    child: const Text(
                      'Masuk di sini',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: primaryColor,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 28),

              // 14. FOOTER TRUST BADGE
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFCF8F2),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFF1E6D4)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFEEDCC7)),
                      ),
                      child: const Icon(
                        Icons.shield_outlined,
                        size: 18,
                        color: primaryColor,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'Enkripsi End-to-End',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: titleColor,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Data Anda disimpan secara aman dengan proteksi terkini.',
                            style: TextStyle(
                              fontSize: 11,
                              color: subtitleColor,
                              height: 1.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

/// Custom Painter for Official 4-color Google "G" Icon
class _GoogleLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;
    final center = Offset(w / 2, h / 2);
    final radius = w / 2;

    final paintBlue = Paint()..color = const Color(0xFF4285F4)..style = PaintingStyle.fill;
    final paintRed = Paint()..color = const Color(0xFFEA4335)..style = PaintingStyle.fill;
    final paintYellow = Paint()..color = const Color(0xFFFBBC05)..style = PaintingStyle.fill;
    final paintGreen = Paint()..color = const Color(0xFF34A853)..style = PaintingStyle.fill;

    final strokeWidth = radius * 0.42;
    final strokePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    strokePaint.color = const Color(0xFF4285F4);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - strokeWidth / 2),
      -0.4,
      1.1,
      false,
      strokePaint,
    );

    strokePaint.color = const Color(0xFF34A853);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - strokeWidth / 2),
      0.7,
      1.6,
      false,
      strokePaint,
    );

    strokePaint.color = const Color(0xFFFBBC05);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - strokeWidth / 2),
      2.3,
      1.4,
      false,
      strokePaint,
    );

    strokePaint.color = const Color(0xFFEA4335);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - strokeWidth / 2),
      3.7,
      1.6,
      false,
      strokePaint,
    );

    final barRect = Rect.fromLTWH(
      center.dx - 1,
      center.dy - strokeWidth / 2,
      radius + 1,
      strokeWidth,
    );
    canvas.drawRect(barRect, paintBlue);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
