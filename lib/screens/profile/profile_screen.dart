import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme/app_colors.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Contact WhatsApp launcher helper
  Future<void> _openWhatsAppSupport() async {
    final uri = Uri.parse('https://wa.me/6282283217789?text=Halo%20Admin%20KosinAja%2C%20saya%20butuh%20bantuan%20terkait%20akun%20mahasiswa%20saya.');
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          _showWhatsAppFallbackModal();
        }
      }
    } catch (_) {
      if (mounted) {
        _showWhatsAppFallbackModal();
      }
    }
  }

  void _showWhatsAppFallbackModal() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 18),
                const CircleAvatar(
                  radius: 28,
                  backgroundColor: Color(0xFFEAF5EE),
                  child: Icon(Icons.support_agent, color: Color(0xFF25D366), size: 32),
                ),
                const SizedBox(height: 14),
                const Text(
                  'Customer Support KosinAja',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.text,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Hubungi admin posko Padang untuk bantuan penjemputan, barang darurat, atau konfirmasi:',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '+62 822-8321-7789',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: AppColors.text,
                        ),
                      ),
                      Text(
                        'Posko Air Tawar',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF2E7D52),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Tutup'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showSavedAddressesModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                const Row(
                  children: [
                    Icon(Icons.pin_drop, color: AppColors.primary, size: 22),
                    SizedBox(width: 8),
                    Text(
                      'Alamat Kos Tersimpan',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.text,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                const Text(
                  'Alamat yang biasa digunakan untuk penjemputan barang',
                  style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 18),

                // Alamat 1 (Utama)
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.primarySoft.withOpacity(0.35),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Kos Melati Indah',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: AppColors.text,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'Utama',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Jl. Cendrawasih No. 12, Air Tawar Barat, Padang Utara (Dekat Fakultas Bahasa & Seni UNP)',
                        style: TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.3),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Catatan: Lantai 2 Kamar 204, tangga sebelah kiri',
                        style: TextStyle(fontSize: 12, color: AppColors.primary, fontStyle: FontStyle.italic),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // Alamat 2
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Kos Merpati Putih (Kampus UNAND)',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: AppColors.text,
                        ),
                      ),
                      SizedBox(height: 6),
                      Text(
                        'Jl. Pasar Baru No. 45, Limau Manis, Pauh, Kota Padang',
                        style: TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.3),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Kamar C3, dekat gerbang pos satpam',
                        style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Fitur tambah alamat baru via Maps segera aktif!'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    icon: const Icon(Icons.add_location_alt_outlined, size: 18),
                    label: const Text('+ Tambah Alamat Baru'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showTermsModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.75,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
              child: ListView(
                controller: scrollController,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.border,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  const Row(
                    children: [
                      Icon(Icons.shield_outlined, color: AppColors.primary, size: 24),
                      SizedBox(width: 8),
                      Text(
                        'Syarat & Ketentuan Titip',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.text,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Kompilasi SOP perlindungan barang mahasiswa KosinAja Padang',
                    style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 18),
                  _buildTermItem(
                    '1. Keaslian Identitas Mahasiswa',
                    'Setiap penitip wajib terverifikasi melalui KTM / SSO kampus aktif untuk menjamin keamanan bersama antarmahasiswa.',
                  ),
                  _buildTermItem(
                    '2. Larangan Barang Terlarang',
                    'Dilarang menitipkan bahan mudah terbakar (gas, bensin, korek), cairan berbahaya tanpa segel kedap, bahan makanan basah/cepat busuk, dan barang ilegal.',
                  ),
                  _buildTermItem(
                    '3. Segel Keamanan Barcode',
                    'Setiap box/koli akan disegel dengan cable-tie barcode berlisensi di depan mahasiswa saat serah terima di kos.',
                  ),
                  _buildTermItem(
                    '4. Garansi & Asuransi Perlindungan',
                    'KosinAja menjamin ganti rugi hingga Rp 1.500.000/box untuk kerusakan atau kehilangan fisik akibat penanganan gudang, sesuai SOP verifikasi CCTV.',
                  ),
                  _buildTermItem(
                    '5. Kebijakan Perpanjangan Waktu',
                    'Penitipan dapat diperpanjang sewaktu-waktu melalui aplikasi minimal 24 jam sebelum masa sewa berakhir dengan tarif harian/mingguan reguler.',
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Saya Mengerti SOP KosinAja'),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildTermItem(String title, String desc) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.text,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            desc,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  void _showEditProfileDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Edit Profil Mahasiswa', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Data mahasiswa Anda telah tervalidasi via SSO UNP.',
                style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
              ),
              SizedBox(height: 14),
              TextField(
                enabled: false,
                decoration: InputDecoration(
                  labelText: 'Nama Lengkap',
                  hintText: 'Vania Ulimaz Rivani',
                  prefixIcon: Icon(Icons.person_outline),
                ),
              ),
              SizedBox(height: 12),
              TextField(
                enabled: false,
                decoration: InputDecoration(
                  labelText: 'Nomor WhatsApp',
                  hintText: '0822-8321-xxxx',
                  prefixIcon: Icon(Icons.chat_outlined),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Tutup'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Perubahan data SSO memerlukan verifikasi admin.'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              child: const Text('Simpan'),
            ),
          ],
        );
      },
    );
  }

  void _showLogoutConfirmation() {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: AppColors.error.withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.lock_clock,
                    color: AppColors.error,
                    size: 28,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Yakin ingin keluar?',
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                    color: AppColors.text,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Sesi penitipan aktif tetap berjalan aman dan barangmu di gudang tetap dijaga 24/7.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 46,
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppColors.border),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text('Batal', style: TextStyle(color: AppColors.text)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: SizedBox(
                        height: 46,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            Navigator.pushNamedAndRemoveUntil(
                              context,
                              '/login',
                              (route) => false,
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.error,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text('Ya, Keluar'),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface.withOpacity(0.95),
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: AppColors.primarySoft,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.inventory_2,
                color: AppColors.primary,
                size: 20,
              ),
            ),
            const SizedBox(width: 10),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'KosinAja',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                  ),
                ),
                Text(
                  'Profil Mahasiswa',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Pusat Bantuan',
            icon: const Icon(Icons.support_agent, color: AppColors.textSecondary),
            onPressed: () {
              Navigator.pushNamed(context, '/help');
            },
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: GestureDetector(
              onTap: _showEditProfileDialog,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.primary.withOpacity(0.3), width: 1.5),
                ),
                child: const CircleAvatar(
                  radius: 16,
                  backgroundColor: AppColors.primarySoft,
                  child: Icon(Icons.person, size: 20, color: AppColors.primary),
                ),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          child: Column(
            children: [
              // 1. Profile Header Delight Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                decoration: BoxDecoration(
                  color: AppColors.cardSurface,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.topCenter,
                  children: [
                    Positioned(
                      top: -20,
                      right: -20,
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.primaryFixed.withOpacity(0.4),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: -15,
                      left: -20,
                      child: Container(
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.secondaryContainer.withOpacity(0.35),
                        ),
                      ),
                    ),

                    // Card Content
                    Column(
                      children: [
                        // Avatar with Edit Camera Button
                        Stack(
                          children: [
                            Container(
                              width: 96,
                              height: 96,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.surfaceContainer,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.08),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(48),
                                child: Image.network(
                                  'https://lh3.googleusercontent.com/aida-public/AB6AXuAhIoVq87JiKYyuMP0kZoIj1zQ9JYB_B0a4v9L469yQKcYFAF14Gt99EFH0h7LAURiA3J3qfJXL_HZ5XRJm7_P5FnPjflBwHygVYwuDnpS6f1R8y7lC5U30xVZrK39DPXoU4I-kHu8bjNBoABnPHKJ5JSHGBlmNmfIoGksxbB1jR2QvkdhEV5GcvD45lMg6d8ZE9lX8xNyozIeMV1ityAyJnWoJo7RAo3cdUfhVBdTs5FGs_EIDcd8z',
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      color: AppColors.primarySoft,
                                      child: const Icon(
                                        Icons.person,
                                        size: 54,
                                        color: AppColors.primary,
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: GestureDetector(
                                onTap: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Pilih foto profil baru dari galeri HP'),
                                      behavior: SnackBarBehavior.floating,
                                    ),
                                  );
                                },
                                child: Container(
                                  width: 32,
                                  height: 32,
                                  decoration: const BoxDecoration(
                                    color: AppColors.primary,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black26,
                                        blurRadius: 4,
                                        offset: Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.photo_camera,
                                    size: 18,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 14),

                        // User Name
                        const Text(
                          'Vania Ulimaz Rivani',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: AppColors.text,
                            letterSpacing: -0.3,
                          ),
                        ),

                        const SizedBox(height: 6),

                        // Verified Student Badge
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEAF5EE),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: const Color(0xFFC8E6D2)),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.verified_user,
                                color: Color(0xFF2E7D52),
                                size: 15,
                              ),
                              SizedBox(width: 6),
                              Text(
                                'Mahasiswa UNP Terverifikasi',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF2E7D52),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Student Storage Summary Pill
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainerLow,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Row(
                            children: [
                              const Expanded(
                                child: Column(
                                  children: [
                                    Text(
                                      '1 Box',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w800,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                    SizedBox(height: 2),
                                    Text(
                                      'Penitipan Aktif',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                height: 32,
                                width: 1,
                                color: AppColors.border,
                              ),
                              const Expanded(
                                child: Column(
                                  children: [
                                    Text(
                                      '3 Kali',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w800,
                                        color: AppColors.secondary,
                                      ),
                                    ),
                                    SizedBox(height: 2),
                                    Text(
                                      'Selesai Dititip',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // 2. User Academic & Contact Information Card
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppColors.cardSurface,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Data Akun & Kost',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: AppColors.text,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEAF5EE),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.circle, color: Color(0xFF2E7D52), size: 6),
                              SizedBox(width: 4),
                              Text(
                                'Tervalidasi',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF2E7D52),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 14),

                    // WhatsApp Row
                    _buildInfoTile(
                      icon: Icons.chat,
                      iconBg: const Color(0xFF25D366).withOpacity(0.15),
                      iconColor: const Color(0xFF25D366),
                      label: 'Nomor WhatsApp',
                      value: '0822-8321-xxxx',
                      trailing: const Icon(Icons.lock_outline, size: 16, color: AppColors.textSecondary),
                    ),

                    const SizedBox(height: 10),

                    // Email SSO Row
                    _buildInfoTile(
                      icon: Icons.school,
                      iconBg: AppColors.primaryFixed,
                      iconColor: AppColors.primary,
                      label: 'Email Kampus SSO',
                      value: 'vania@student.unp.ac.id',
                      trailing: const Icon(Icons.check_circle, size: 16, color: Color(0xFF2E7D52)),
                    ),

                    const SizedBox(height: 10),

                    // Campus Row
                    _buildInfoTile(
                      icon: Icons.account_balance,
                      iconBg: AppColors.secondaryContainer,
                      iconColor: AppColors.secondary,
                      label: 'Kampus Utama',
                      value: 'Universitas Negeri Padang (UNP)',
                    ),

                    const SizedBox(height: 10),

                    // Kost Address Row
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: AppColors.primarySoft,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.location_on, color: AppColors.primary, size: 20),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Text(
                                      'Alamat Kos Utama',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                                      decoration: BoxDecoration(
                                        color: AppColors.primaryFixed,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: const Text(
                                        'Utama',
                                        style: TextStyle(
                                          fontSize: 9,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.primary,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 3),
                                const Text(
                                  'Kos Melati Indah',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.text,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                const Text(
                                  'Jl. Cendrawasih No. 12, Air Tawar Barat, Padang Utara',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textSecondary,
                                    height: 1.3,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // 3. Tactile Menu List
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.cardSurface,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _buildMenuItem(
                      icon: Icons.person_outline,
                      title: 'Edit Profil & Data Mahasiswa',
                      onTap: _showEditProfileDialog,
                    ),
                    _buildMenuItem(
                      icon: Icons.pin_drop_outlined,
                      title: 'Alamat Kos Tersimpan',
                      badgeText: '2 Lokasi',
                      onTap: _showSavedAddressesModal,
                    ),
                    _buildMenuItem(
                      icon: Icons.health_and_safety_outlined,
                      title: 'Pusat Bantuan & SOP Keamanan',
                      onTap: () {
                        Navigator.pushNamed(context, '/help');
                      },
                    ),
                    _buildMenuItem(
                      icon: Icons.description_outlined,
                      title: 'Syarat & Ketentuan Penitipan',
                      onTap: _showTermsModal,
                    ),
                    // WhatsApp Special Highlight Item
                    InkWell(
                      onTap: _openWhatsAppSupport,
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEAF5EE).withOpacity(0.6),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFFC8E6D2)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 36,
                              height: 36,
                              decoration: const BoxDecoration(
                                color: Color(0xFF25D366),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.support_agent,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Hubungi CS WhatsApp KosinAja',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.text,
                                    ),
                                  ),
                                  SizedBox(height: 2),
                                  Row(
                                    children: [
                                      Icon(Icons.circle, color: Color(0xFF2E7D52), size: 6),
                                      SizedBox(width: 4),
                                      Text(
                                        'Online • Respon Cepat Mahasiswa',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Color(0xFF2E7D52),
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const Icon(
                              Icons.chevron_right,
                              color: Color(0xFF2E7D52),
                              size: 20,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              // 4. Logout Trigger Section
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: _showLogoutConfirmation,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.cardSurface,
                    foregroundColor: AppColors.error,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(color: AppColors.error.withOpacity(0.2)),
                    ),
                  ),
                  icon: const Icon(Icons.logout, size: 20, color: AppColors.error),
                  label: const Text(
                    'Keluar dari Akun',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppColors.error,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 14),

              // Footer Version Info
              const Text(
                'KosinAja Padang v2.4.1 • Solusi Titip Kost Terpercaya',
                style: TextStyle(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                ),
              ),

              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 3, // Profil tab
        onTap: (index) {
          if (index == 0) {
            Navigator.pushReplacementNamed(context, '/home');
          } else if (index == 1) {
            Navigator.pushNamed(context, '/booking-step1');
          } else if (index == 2) {
            Navigator.pushReplacementNamed(context, '/orders');
          }
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textSecondary,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.cottage_outlined),
            activeIcon: Icon(Icons.cottage),
            label: 'Beranda',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory_2_outlined),
            activeIcon: Icon(Icons.inventory_2),
            label: 'Booking',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.local_shipping_outlined),
            activeIcon: Icon(Icons.local_shipping),
            label: 'Riwayat',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle_outlined),
            activeIcon: Icon(Icons.account_circle),
            label: 'Profil',
          ),
        ],
      ),
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String label,
    required String value,
    Widget? trailing,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: iconBg,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.text,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          if (trailing != null) trailing,
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    String? badgeText,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: const BoxDecoration(
                color: AppColors.surfaceContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AppColors.textSecondary, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Row(
                children: [
                  Flexible(
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.text,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (badgeText != null) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerHigh,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        badgeText,
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: AppColors.textSecondary,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
