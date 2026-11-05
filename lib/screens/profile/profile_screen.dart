import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/services/api_service.dart';
import '../../core/theme/app_colors.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? _stats;
  String? _profileImagePath;

  @override
  void initState() {
    super.initState();
    _loadProfileStats();
    _loadSavedProfileImage();
  }

  Future<void> _loadProfileStats() async {
    if (ApiService.currentUser == null) return;
    final res = await ApiService.getProfile();
    if (mounted) {
      setState(() {
        if (res['success'] == true) {
          _stats = res['stats'];
        }
      });
    }
  }

  Future<void> _loadSavedProfileImage() async {
    final user = ApiService.currentUser;
    final prefs = await SharedPreferences.getInstance();
    final key = 'profile_image_${user?.id ?? "local"}';
    final savedPath = prefs.getString(key);
    if (savedPath != null && File(savedPath).existsSync()) {
      if (mounted) {
        setState(() {
          _profileImagePath = savedPath;
        });
      }
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: source,
        maxWidth: 600,
        maxHeight: 600,
        imageQuality: 85,
      );
      if (picked != null) {
        final user = ApiService.currentUser;
        final prefs = await SharedPreferences.getInstance();
        final key = 'profile_image_${user?.id ?? "local"}';
        await prefs.setString(key, picked.path);
        if (mounted) {
          setState(() {
            _profileImagePath = picked.path;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Foto profil berhasil diperbarui!'),
              backgroundColor: Color(0xFF2E7D52),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        String msg = 'Gagal memilih foto: $e';
        if (e.toString().contains('channel-error') || e.toString().contains('MissingPluginException')) {
          msg = 'Aplikasi perlu di-restart penuh (stop lalu jalankan ulang flutter run -d infinix) agar modul kamera & galeri terpasang ke HP.';
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(msg),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _showImagePickerOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
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
                const SizedBox(height: 16),
                const Text(
                  'Ubah Foto Profil',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: AppColors.text,
                  ),
                ),
                const SizedBox(height: 16),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primarySoft,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.camera_alt, color: AppColors.primary),
                  ),
                  title: const Text('Ambil dari Kamera', style: TextStyle(fontWeight: FontWeight.w600)),
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.camera);
                  },
                ),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: Color(0xFFEAF5EE),
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                    child: const Icon(Icons.photo_library, color: Color(0xFF2E7D52)),
                  ),
                  title: const Text('Pilih dari Galeri HP', style: TextStyle(fontWeight: FontWeight.w600)),
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.gallery);
                  },
                ),
                if (_profileImagePath != null)
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.error.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.delete_outline, color: AppColors.error),
                    ),
                    title: const Text('Hapus Foto (Gunakan Inisial)', style: TextStyle(color: AppColors.error, fontWeight: FontWeight.w600)),
                    onTap: () async {
                      Navigator.pop(context);
                      final user = ApiService.currentUser;
                      final prefs = await SharedPreferences.getInstance();
                      final key = 'profile_image_${user?.id ?? "local"}';
                      await prefs.remove(key);
                      if (mounted) {
                        setState(() {
                          _profileImagePath = null;
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Foto profil dihapus, kembali ke inisial nama.'),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _getInitials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts[0].isEmpty) return 'K';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

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
    final userAddr = ApiService.currentUser?.alamat?.trim() ?? '';

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
                  'Alamat yang digunakan untuk penjemputan barang',
                  style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 18),

                // Alamat Akun Utama
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
                            'Alamat Terdaftar',
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
                      Text(
                        userAddr.isNotEmpty ? userAddr : 'Kota Padang, Sumatera Barat',
                        style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.3),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Catatan: Alamat terverifikasi akun',
                        style: TextStyle(fontSize: 12, color: AppColors.primary, fontStyle: FontStyle.italic),
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
                          content: Text('Alamat dapat disesuaikan pada saat pengisian form booking.'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    icon: const Icon(Icons.add_location_alt_outlined, size: 18),
                    label: const Text('Atur Alamat Saat Booking'),
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
                    'Setiap penitip wajib terverifikasi melalui data akun aktif untuk menjamin keamanan bersama antarmahasiswa.',
                  ),
                  _buildTermItem(
                    '2. Larangan Barang Terlarang',
                    'Dilarang menitipkan bahan mudah terbakar (gas, bensin, korek), cairan berbahaya tanpa segel kedap, bahan makanan basah/cepat busuk, dan barang ilegal.',
                  ),
                  _buildTermItem(
                    '3. Segel Keamanan Barcode',
                    'Setiap box/koli akan disegel dengan stiker barcode berlisensi di depan mahasiswa saat serah terima di kos.',
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
    final user = ApiService.currentUser;
    final nameCtrl = TextEditingController(text: user?.nama ?? '');
    final phoneCtrl = TextEditingController(text: user?.noWa ?? '');
    final addrCtrl = TextEditingController(text: user?.alamat ?? '');

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Edit Profil Mahasiswa', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Perbarui data identitas Anda:',
                  style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Nama Lengkap',
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: phoneCtrl,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'Nomor WhatsApp',
                    prefixIcon: Icon(Icons.chat_outlined),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: addrCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Alamat Kos / Domisili',
                    prefixIcon: Icon(Icons.home_outlined),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () async {
                final newName = nameCtrl.text.trim();
                final newPhone = phoneCtrl.text.trim();
                final newAddr = addrCtrl.text.trim();

                if (newName.isEmpty) return;

                Navigator.pop(context);

                // Update user locally in ApiService
                if (user != null) {
                  final updated = user.copyWith(
                    nama: newName,
                    noWa: newPhone,
                    alamat: newAddr,
                  );
                  ApiService.currentUser = updated;
                  setState(() {});
                }

                // Kirim ke backend jika user ID tersedia
                if (user != null && user.id.isNotEmpty) {
                  await ApiService.updateProfile(
                    userId: user.id,
                    nama: newName,
                    noWa: newPhone,
                    alamat: newAddr,
                  );
                }

                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Data profil berhasil diperbarui!'),
                      backgroundColor: Color(0xFF2E7D52),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
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
                          onPressed: () async {
                            final nav = Navigator.of(context);
                            await ApiService.logout();
                            if (!mounted) return;
                            nav.pushNamedAndRemoveUntil('/login', (route) => false);
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
    final user = ApiService.currentUser;
    final userName = user?.nama.isNotEmpty == true ? user!.nama : 'Pelanggan KosinAja';
    final userPhone = user?.noWa.isNotEmpty == true ? user!.noWa : 'Belum Terdaftar';
    final userEmail = user?.email.isNotEmpty == true ? user!.email : 'Belum Terdaftar';
    final userAddress = user?.alamat?.isNotEmpty == true ? user!.alamat! : 'Kota Padang, Sumatera Barat';

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        automaticallyImplyLeading: false,
        titleSpacing: 20,
        title: const Text(
          'Profil Saya',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: Color(0xFF2E2018),
            letterSpacing: -0.3,
          ),
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
                  child: Icon(Icons.edit, size: 16, color: AppColors.primary),
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
              // 1. Profile Header Delight Card (Clip antiAlias to fix overflow)
              Container(
                width: double.infinity,
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
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                        child: Column(
                          children: [
                            // Avatar with Camera Picker Button
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
                                    child: _profileImagePath != null && File(_profileImagePath!).existsSync()
                                        ? Image.file(
                                            File(_profileImagePath!),
                                            fit: BoxFit.cover,
                                            width: 96,
                                            height: 96,
                                          )
                                        : Container(
                                            decoration: const BoxDecoration(
                                              gradient: LinearGradient(
                                                colors: [Color(0xFFB86B35), Color(0xFF8C4F23)],
                                                begin: Alignment.topLeft,
                                                end: Alignment.bottomRight,
                                              ),
                                            ),
                                            child: Center(
                                              child: Text(
                                                _getInitials(userName),
                                                style: const TextStyle(
                                                  fontSize: 32,
                                                  fontWeight: FontWeight.w800,
                                                  color: Colors.white,
                                                  letterSpacing: 1,
                                                ),
                                              ),
                                            ),
                                          ),
                                  ),
                                ),
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: GestureDetector(
                                    onTap: _showImagePickerOptions,
                                    child: Container(
                                      width: 34,
                                      height: 34,
                                      decoration: BoxDecoration(
                                        color: AppColors.primary,
                                        shape: BoxShape.circle,
                                        border: Border.all(color: Colors.white, width: 2),
                                        boxShadow: const [
                                          BoxShadow(
                                            color: Colors.black26,
                                            blurRadius: 4,
                                            offset: Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: const Icon(
                                        Icons.camera_alt,
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
                            Text(
                              userName,
                              style: const TextStyle(
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
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.verified_user,
                                    color: Color(0xFF2E7D52),
                                    size: 15,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    userAddress,
                                    style: const TextStyle(
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
                                  Expanded(
                                    child: Column(
                                      children: [
                                        Text(
                                          '${_stats?['activeBookings'] ?? 1} Box',
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w800,
                                            color: AppColors.primary,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        const Text(
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
                                  Expanded(
                                    child: Column(
                                      children: [
                                        Text(
                                          '${_stats?['completedBookings'] ?? 3} Kali',
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w800,
                                            color: AppColors.secondary,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        const Text(
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
                      value: userPhone,
                      trailing: const Icon(Icons.lock_outline, size: 16, color: AppColors.textSecondary),
                    ),

                    const SizedBox(height: 10),

                    // Email SSO Row
                    _buildInfoTile(
                      icon: Icons.school,
                      iconBg: AppColors.primaryFixed,
                      iconColor: AppColors.primary,
                      label: 'Email Terdaftar',
                      value: userEmail,
                      trailing: const Icon(Icons.check_circle, size: 16, color: Color(0xFF2E7D52)),
                    ),

                    const SizedBox(height: 10),

                    // Campus Row
                    _buildInfoTile(
                      icon: Icons.account_balance,
                      iconBg: AppColors.secondaryContainer,
                      iconColor: AppColors.secondary,
                      label: 'Kampus / Domisili',
                      value: userAddress,
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
                                Text(
                                  userAddress,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.text,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                const Text(
                                  'Kota Padang, Sumatera Barat',
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

              // 3. Quick Action Navigation Menu
              Container(
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
                    _buildActionTile(
                      icon: Icons.pin_drop_outlined,
                      iconColor: AppColors.primary,
                      title: 'Alamat Kos Tersimpan',
                      subtitle: 'Daftar alamat untuk penjemputan barang',
                      onTap: _showSavedAddressesModal,
                    ),
                    const Divider(height: 1, indent: 64, endIndent: 20, color: AppColors.border),
                    _buildActionTile(
                      icon: Icons.receipt_long_outlined,
                      iconColor: AppColors.secondary,
                      title: 'Riwayat & Tagihan Penitipan',
                      subtitle: 'Cek invoice, tagihan, dan bukti pembayaran',
                      onTap: () {
                        Navigator.pushNamed(context, '/orders');
                      },
                    ),
                    const Divider(height: 1, indent: 64, endIndent: 20, color: AppColors.border),
                    _buildActionTile(
                      icon: Icons.shield_outlined,
                      iconColor: const Color(0xFF2E7D52),
                      title: 'SOP & Ketentuan Titip',
                      subtitle: 'Standar keamanan gudang & garansi ganti rugi',
                      onTap: _showTermsModal,
                    ),
                    const Divider(height: 1, indent: 64, endIndent: 20, color: AppColors.border),
                    _buildActionTile(
                      icon: Icons.chat_outlined,
                      iconColor: const Color(0xFF25D366),
                      title: 'Bantuan Customer Service',
                      subtitle: 'WhatsApp posko operasional Padang 24/7',
                      onTap: _openWhatsAppSupport,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // 4. Logout Action Button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton.icon(
                  onPressed: _showLogoutConfirmation,
                  style: OutlinedButton.styleFrom(
                    backgroundColor: AppColors.cardSurface,
                    side: BorderSide(color: AppColors.error.withOpacity(0.4)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  icon: const Icon(Icons.logout, color: AppColors.error, size: 20),
                  label: const Text(
                    'Keluar dari Akun',
                    style: TextStyle(
                      color: AppColors.error,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Version Footer
              const Text(
                'KosinAja Mobile v1.0.0 • Made with ❤️ for Padang Students',
                style: TextStyle(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 3,
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
            icon: ImageIcon(AssetImage('assets/images/icon_home.png')),
            activeIcon: ImageIcon(AssetImage('assets/images/icon_home_active.png')),
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
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(8),
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
                const SizedBox(height: 1),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.text,
                  ),
                ),
              ],
            ),
          ),
          if (trailing != null) trailing,
        ],
      ),
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
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
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.textSecondary, size: 20),
          ],
        ),
      ),
    );
  }
}
