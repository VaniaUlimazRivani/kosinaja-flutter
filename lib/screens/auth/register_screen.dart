import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/services/api_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  String _selectedCampus = 'UNAND - Universitas Andalas';
  bool _agreeTerms = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;

  final List<String> _campuses = const [
    'UNAND - Universitas Andalas',
    'UNP - Universitas Negeri Padang',
    'UIN Imam Bonjol Padang',
    'UPI "YPTK" Padang',
    'Politeknik Negeri Padang (PNP)',
    'Universitas Bung Hatta (UBH)',
    'Universitas Baiturrahmah',
    'Kampus Lainnya di Kota Padang',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  int _calculatePasswordStrength(String password) {
    if (password.isEmpty) return 0;
    int strength = 0;
    if (password.length >= 6) strength++;
    if (password.length >= 8) strength++;
    if (RegExp(r'[0-9]').hasMatch(password)) strength++;
    if (RegExp(r'[A-Z]').hasMatch(password) || RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password)) {
      strength++;
    }
    return strength;
  }

  void _handleRegister() async {
    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirm = _confirmPasswordController.text;

    if (name.isEmpty || phone.isEmpty || email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Harap lengkapi semua kolom pendaftaran (Nama, WhatsApp, Email, & Password).'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (!email.contains('@') || !email.contains('.')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Format email tidak valid (contoh: vania@student.unp.ac.id).'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (password.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Kata sandi minimal 6 karakter.'),
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
          content: Text('Harap setujui Syarat & Ketentuan Layanan KosinAja.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // Formatting phone: jika diawali 8xx jadi 08xx
    final formattedPhone = phone.startsWith('0') ? phone : '0$phone';

    // Panggil API Backend Next.js -> Simpan ke Database MongoDB
    final result = await ApiService.register(
      nama: name,
      email: email,
      noWa: formattedPhone,
      password: password,
      alamat: _selectedCampus,
    );

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

    if (result['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? 'Pendaftaran berhasil tersimpan ke MongoDB!'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['error'] ?? 'Terjadi kesalahan saat mendaftar.'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _handleGoogleSignUp() {
    setState(() {
      _nameController.text = 'Vania Ulimaz Rivani';
      _emailController.text = 'vania@student.unp.ac.id';
      _phoneController.text = '82283217789';
      _selectedCampus = 'UNP - Universitas Negeri Padang';
      _passwordController.text = 'MahasiswaPadang2026!';
      _confirmPasswordController.text = 'MahasiswaPadang2026!';
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Akun Google Kampus terhubung! Data nama, email, dan kampus otomatis terisi.'),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final strength = _calculatePasswordStrength(_passwordController.text);
    const strengthLabels = ['Belum diisi', 'Lemah', 'Cukup', 'Bagus', 'Sangat Kuat'];
    const strengthColors = [
      AppColors.outlineVariant,
      AppColors.error,
      AppColors.warning,
      Color(0xFF1E88E5),
      AppColors.success,
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            } else {
              Navigator.pushReplacementNamed(context, '/');
            }
          },
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: AppColors.primarySoft,
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Icon(
                Icons.school_outlined,
                color: AppColors.primary,
                size: 16,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'Daftar Akun Mahasiswa',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.text,
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Text(
                'Mulai Titip Barang Tanpa Cemas',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: AppColors.text,
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const SizedBox(height: 6),
              Text(
                'Khusus mahasiswa kampus di Kota Padang (UNAND, UNP, UIN IB, dll.)',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
              ),

              const SizedBox(height: 24),

              // Nama Lengkap
              Text(
                'Nama Lengkap (Sesuai KTM)',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.text,
                    ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _nameController,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  hintText: 'Contoh: Rifqi Alamsyah',
                  prefixIcon: Icon(Icons.badge_outlined, color: AppColors.primary),
                ),
              ),

              const SizedBox(height: 18),

              // Nomor WhatsApp
              Text(
                'Nomor WhatsApp Aktif',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.text,
                    ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  hintText: '812-3456-7890',
                  prefixIcon: Padding(
                    padding: const EdgeInsets.only(left: 14, right: 10),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainerHigh,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            '+62',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                              color: AppColors.text,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          width: 1,
                          height: 20,
                          color: AppColors.outlineVariant,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 18),

              // Email Mahasiswa (Wajib untuk database MongoDB)
              Text(
                'Email Mahasiswa / Kampus SSO',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.text,
                    ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  hintText: 'nama@student.kampus.ac.id',
                  prefixIcon: Icon(Icons.email_outlined, color: AppColors.primary),
                ),
              ),

              const SizedBox(height: 18),

              // Asal Kampus Dropdown
              Text(
                'Asal Kampus / Universitas',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.text,
                    ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border, width: 1.5),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedCampus,
                    isExpanded: true,
                    icon: const Icon(Icons.arrow_drop_down, color: AppColors.primary),
                    items: _campuses.map((campus) {
                      return DropdownMenuItem<String>(
                        value: campus,
                        child: Text(
                          campus,
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.text,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setState(() {
                          _selectedCampus = val;
                        });
                      }
                    },
                  ),
                ),
              ),

              const SizedBox(height: 18),

              // Kata Sandi
              Text(
                'Kata Sandi Akun',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.text,
                    ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText: 'Minimal 6-8 karakter',
                  prefixIcon: const Icon(Icons.lock_outline, color: AppColors.primary),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: AppColors.textMuted,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                ),
              ),

              // Password Strength Indicator
              if (_passwordController.text.isNotEmpty) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: Row(
                        children: List.generate(4, (index) {
                          final isFilled = index < strength;
                          return Expanded(
                            child: Container(
                              height: 4,
                              margin: const EdgeInsets.only(right: 4),
                              decoration: BoxDecoration(
                                color: isFilled
                                    ? strengthColors[strength]
                                    : AppColors.outlineVariant.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          );
                        }),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      strengthLabels[strength],
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: strengthColors[strength],
                      ),
                    ),
                  ],
                ),
              ],

              const SizedBox(height: 18),

              // Konfirmasi Kata Sandi
              Text(
                'Ulangi Kata Sandi',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.text,
                    ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _confirmPasswordController,
                obscureText: _obscureConfirmPassword,
                decoration: InputDecoration(
                  hintText: 'Ketik ulang kata sandi',
                  prefixIcon: const Icon(Icons.lock_reset_outlined, color: AppColors.primary),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureConfirmPassword
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: AppColors.textMuted,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureConfirmPassword = !_obscureConfirmPassword;
                      });
                    },
                  ),
                ),
              ),

              const SizedBox(height: 18),

              // Checkbox S&K
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Checkbox(
                    value: _agreeTerms,
                    activeColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                    onChanged: (val) {
                      setState(() {
                        _agreeTerms = val ?? false;
                      });
                    },
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: RichText(
                        text: const TextSpan(
                          text: 'Saya menyetujui ',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                            height: 1.4,
                          ),
                          children: [
                            TextSpan(
                              text: 'Syarat & Ketentuan Penitipan',
                              style: TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            TextSpan(
                              text: ' serta kebijakan proteksi barang KosinAja Padang.',
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleRegister,
                  child: _isLoading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Daftar Akun Baru'),
                ),
              ),

              const SizedBox(height: 18),

              // Divider "atau daftar dengan"
              Row(
                children: [
                  const Expanded(child: Divider(color: AppColors.border)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    child: Text(
                      'atau daftar lebih cepat dengan',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textMuted,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),
                  const Expanded(child: Divider(color: AppColors.border)),
                ],
              ),

              const SizedBox(height: 16),

              // Tombol Daftar Akun Google / SSO Kampus
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton.icon(
                  onPressed: _handleGoogleSignUp,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.text,
                    side: const BorderSide(color: AppColors.border, width: 1.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: Container(
                    width: 20,
                    height: 20,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Text(
                        'G',
                        style: TextStyle(
                          color: Color(0xFF4285F4),
                          fontWeight: FontWeight.w900,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                  label: const Text(
                    'Daftar dengan Akun Google / SSO',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Trust Badges
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.verified_outlined, color: AppColors.success, size: 20),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Gratis jemput perdana area Pauh & Air Tawar untuk pendaftaran baru.',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                          height: 1.35,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Footer Link to Login
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Sudah punya akun? ',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushReplacementNamed(context, '/login');
                      },
                      child: Text(
                        'Masuk di sini',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
