import 'package:flutter/material.dart';
import '../../core/services/api_service.dart';
import '../../core/theme/app_colors.dart';

class OnboardingItem {
  final String badge;
  final String title;
  final String description;
  final String imageUrl;
  final List<Map<String, dynamic>> highlights;

  const OnboardingItem({
    required this.badge,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.highlights,
  });
}

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingItem> _slides = const [
    OnboardingItem(
      badge: '100% Khusus Mahasiswa Padang',
      title: 'Titip Praktis Tanpa Beban',
      description:
          'Simpan barang kos aman selama liburan semester tanpa perlu repot angkut semua barang pulang kampung.',
      imageUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuCYHHauUQKf-hMPyLgqNrQJdesZbZ13zNvqDtksCd9uCuwZdBqtdtlex-EJ4FI84Y4iaHmGSqT1lm_wZCBX5GboTnbBtE719LCpU7uKXGAU6RabgGZ7PMUOlrjI15eh1RdP1R4QOFnLufI5mftGx7Yej2kZYQGPo8eAIgzE24QgDLkGvp_Uckg2-WdvuB0Ec50KjdShz3yTZChzBZVM3VofH6gLqXzQptU-e6G21fVY8mqoXHFtFDe5',
      highlights: [
        {
          'icon': Icons.shield_outlined,
          'title': 'Asuransi Proteksi Rp 10 Juta',
          'desc': 'Perlindungan resmi kehilangan & kerusakan',
        },
        {
          'icon': Icons.warehouse_outlined,
          'title': 'Hub Dekat Kampus',
          'desc': 'Lokasi strategis di Pauh (UNAND) & Air Tawar (UNP)',
        },
        {
          'icon': Icons.phone_android_outlined,
          'title': 'Pemesanan 100% Online',
          'desc': 'Atur jadwal penjemputan langsung dari HP',
        },
      ],
    ),
    OnboardingItem(
      badge: 'Armada Pick-up KosinAja',
      title: 'Jemput Langsung ke Kosanmu',
      description:
          'Kurir KosinAja Padang siap angkut barang dari kosan di Pasar Baru, Pauh, Air Tawar, hingga Lubuk Begalung.',
      imageUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuCr30x42ylvxBCokRS27ZRL1GrfjczUEXNp07s7CvijfxuVQb3ppGMT3TINOH_hgowhT7WaxBRtiCYdSzDV7ixrCuB2JGiFl1Ao8dDhS2ic8sDVMSq9UfXfyQmF_j_KTomxtFAD26CarVMsIMZ0lkGJb-EKHo8afdSnVSckcE2NCOzck0k361WL53gJRNfh7At2WBGBUKlEZoOIfWBSqNeVYMZAnj5pD69p3rQr3gzIgULD24AaNUPt',
      highlights: [
        {
          'icon': Icons.event_available_outlined,
          'title': '1. Pilih Jadwal Bebas',
          'desc': 'Tentukan jam penjemputan sesuai senggangmu',
        },
        {
          'icon': Icons.local_shipping_outlined,
          'title': '2. Kurir Tiba dengan Pick-up',
          'desc': 'Barang diangkut rapi dengan armada terlindungi',
        },
        {
          'icon': Icons.qr_code_scanner_outlined,
          'title': '3. Timbang & Segel Barcode',
          'desc': 'Setiap item ditempeli kode QR unik terlacak',
        },
      ],
    ),
    OnboardingItem(
      badge: 'Transparan & Bebas Khawatir',
      title: 'Pantau Realtime & Bukti Foto',
      description:
          'Cek kondisi barang kapan saja melalui aplikasi lengkap dengan bukti foto serah terima dan CCTV gudang.',
      imageUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuA2hxPj6HvS4tmoBfOQYz_g2bgYbxKJanNz-uiQklWd6myfTDWOJU8GJmEidEV9Zlhz6G6B0wonPAYiG0sC8xaw-QmaO8quTbHIYiWb9IE033FIlHweq5LnvJjrZNSSmpY7pIkY03PaacZDQCZ_j7AYJBhjt6xnLrg9UYmPrsNrTnfMqvB6-QKfOaAtWcT2pDHAwfHw8iCbTlWdh6tz9Ajw8viUSbsn6kDA8wa3AtzLxOZrGEdNr2S8',
      highlights: [
        {
          'icon': Icons.camera_alt_outlined,
          'title': 'Bukti Foto Serah Terima',
          'desc': 'Foto 3 sisi kardus saat tiba di gudang',
        },
        {
          'icon': Icons.videocam_outlined,
          'title': 'Pengawasan CCTV 24/7',
          'desc': 'Gudang Pauh terjaga dan sensor suhu aktif',
        },
        {
          'icon': Icons.verified_outlined,
          'title': 'Inspeksi Berkala',
          'desc': 'Pemeriksaan rutin pallet bebas lembab dan rayap',
        },
      ],
    ),
  ];

  void _nextPage() async {
    if (_currentPage < _slides.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    } else {
      await ApiService.setOnboardingSeen();
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/register');
    }
  }

  void _skipToLogin() async {
    await ApiService.setOnboardingSeen();
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Top Navigation Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppColors.primarySoft,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.inventory_2_outlined,
                          color: AppColors.primary,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'KosinAja',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: AppColors.primary,
                              letterSpacing: -0.5,
                            ),
                      ),
                    ],
                  ),
                  TextButton(
                    onPressed: _skipToLogin,
                    child: Text(
                      'Lewati',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),
                ],
              ),
            ),

            // PageView Carousel
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemCount: _slides.length,
                itemBuilder: (context, index) {
                  final slide = _slides[index];
                  return SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 10),

                        // Image Banner Card
                        ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Stack(
                            children: [
                              Image.network(
                                slide.imageUrl,
                                height: 180,
                                width: double.infinity,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    Container(
                                  height: 180,
                                  color: AppColors.surfaceContainerHigh,
                                  child: const Center(
                                    child: Icon(
                                      Icons.image_outlined,
                                      size: 48,
                                      color: AppColors.outlineVariant,
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 12,
                                left: 12,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    slide.badge,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Title & Subtitle
                        Text(
                          slide.title,
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                color: AppColors.text,
                                fontWeight: FontWeight.w800,
                              ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          slide.description,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppColors.textSecondary,
                                height: 1.45,
                              ),
                        ),

                        const SizedBox(height: 16),

                        // Highlight USPs
                        Column(
                          children: slide.highlights.map((h) {
                            return Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.cardSurface,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: AppColors.border,
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 36,
                                    height: 36,
                                    decoration: BoxDecoration(
                                      color: AppColors.surfaceContainerLow,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(
                                      h['icon'] as IconData,
                                      color: AppColors.primary,
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          h['title'] as String,
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleSmall
                                              ?.copyWith(
                                                fontWeight: FontWeight.w700,
                                                fontSize: 13,
                                                color: AppColors.text,
                                              ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          h['desc'] as String,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall
                                              ?.copyWith(
                                                color: AppColors.textSecondary,
                                                fontSize: 12,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Bottom Navigation Area
            Container(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
              decoration: const BoxDecoration(
                color: AppColors.background,
                border: Border(
                  top: BorderSide(color: AppColors.border, width: 0.8),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Indicator Dots
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(_slides.length, (index) {
                      final isActive = index == _currentPage;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: isActive ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: isActive
                              ? AppColors.primary
                              : AppColors.outlineVariant.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 16),

                  // Main Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _nextPage,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _currentPage == _slides.length - 1
                                ? 'Mulai Sekarang'
                                : 'Lanjut',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.arrow_forward, size: 18, color: Colors.white),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Secondary Link to Login
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Sudah punya akun? ',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                      ),
                      GestureDetector(
                        onTap: () async {
                          await ApiService.setOnboardingSeen();
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/login');
                        },
                        child: Text(
                          'Masuk di sini',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
