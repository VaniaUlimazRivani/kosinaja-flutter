import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme/app_colors.dart';

class FaqItem {
  final int id;
  final String question;
  final Widget content;

  const FaqItem({
    required this.id,
    required this.question,
    required this.content,
  });
}

class HelpScreen extends StatefulWidget {
  const HelpScreen({super.key});

  @override
  State<HelpScreen> createState() => _HelpScreenState();
}

class _HelpScreenState extends State<HelpScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
  final Set<int> _expandedIds = {1}; // default first FAQ expanded
  String _searchQuery = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _openWhatsAppCS() async {
    final text = Uri.encodeComponent(
      'Halo Admin KosinAja Padang, saya ingin bertanya seputar SOP dan penitipan barang kos.',
    );
    final url = Uri.parse('https://wa.me/6281234567890?text=$text');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tidak dapat membuka WhatsApp.')),
        );
      }
    }
  }

  List<FaqItem> _getFaqItems() {
    return [
      FaqItem(
        id: 1,
        question: '1. Barang apa saja yang boleh dan TIDAK boleh dititipkan?',
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Untuk menjaga keselamatan seluruh barang mahasiswa dan mematuhi standar kebersihan gudang, berikut klasifikasi barang:',
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.4),
            ),
            const SizedBox(height: 10),
            // Allowed Card
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.check_circle, size: 16, color: AppColors.success),
                      SizedBox(width: 6),
                      Text(
                        'Barang Boleh Dititipkan (Diizinkan):',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.text),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      '📦 Kardus buku & ATK',
                      '👕 Koper & pakaian',
                      '❄️ Kulkas mini (kering & off)',
                      '💧 Dispenser galon',
                      '🛏️ Kasur busa lipat',
                      '🛵 Sepeda motor (STNK Asli)',
                    ].map((item) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Text(item, style: const TextStyle(fontSize: 11, color: AppColors.text)),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            // Prohibited Card
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.errorContainer.withOpacity(0.4),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.cancel, size: 16, color: AppColors.error),
                      SizedBox(width: 6),
                      Text(
                        'Barang Dilarang Keras (Ditolak Langsung):',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.error),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      '🍲 Makanan basah / cepat basi',
                      '🐱 Hewan peliharaan & tanaman',
                      '🔥 Bahan kimia / gas mudah terbakar',
                      '⚔️ Senjata tajam / ilegal',
                      '💎 Emas, perhiasan & uang tunai',
                    ].map((item) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColors.error.withOpacity(0.3)),
                        ),
                        child: Text(item, style: const TextStyle(fontSize: 11, color: AppColors.error)),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      FaqItem(
        id: 2,
        question: '2. Bagaimana alur penjemputan barang di kos saya?',
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Proses sangat mudah tanpa repot angkat berat sendiri:',
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 8),
            _buildStepRow(1, 'Pilih paket & tentukan jadwal penjemputan via aplikasi KosinAja.'),
            const SizedBox(height: 6),
            _buildStepRow(2, 'Kurir KosinAja tiba di depan kosan membawa barcode label & plastik wrapping.'),
            const SizedBox(height: 6),
            _buildStepRow(3, 'Tanda tangan digital serah terima & barang dibawa armada pick-up terlindungi.'),
          ],
        ),
      ),
      FaqItem(
        id: 3,
        question: '3. Berapa tarif ongkos jemput untuk area kampus di Padang?',
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'KosinAja menerapkan subsidi tarif flat ramah dompet mahasiswa khusus lingkar kampus Kota Padang:',
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _buildTarifCard('Kampus UNAND Limau Manis', 'Mulai Rp15.000 / trip'),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildTarifCard('Kampus UNP Air Tawar', 'Mulai Rp20.000 / trip'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildTarifCard('Kampus UIN Imam Bonjol', 'Mulai Rp20.000 / trip'),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildTarifCard('Area PNP / Politeknik', 'Mulai Rp15.000 / trip'),
                ),
              ],
            ),
            const SizedBox(height: 6),
            const Text(
              '*Gratis ongkir jemput untuk durasi penitipan di atas 2 bulan penuh.',
              style: TextStyle(fontSize: 11, fontStyle: FontStyle.italic, color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
      const FaqItem(
        id: 4,
        question: '4. Bagaimana jika masa liburan semester saya diperpanjang?',
        content: Text(
          'Tenang saja! Anda dapat memperpanjang masa penitipan secara langsung dari menu "Perpanjang Masa Penitipan" di layar pelacakan minimal 3 hari sebelum tenggat habis. Hitungan prorata otomatis secara mingguan atau bulanan tanpa denda keterlambatan.',
          style: TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.45),
        ),
      ),
      const FaqItem(
        id: 5,
        question: '5. Apakah barang saya terjamin asuransi keamanan?',
        content: Text(
          'Tentu. Seluruh paket penitipan otomatis dilindungi Perlindungan Dasar Gratis sampai dengan klaim Rp2.500.000 per pesanan terhadap risiko kebakaran, kebocoran air, atau kehilangan. Untuk barang berharga, Anda dapat mengaktifkan proteksi premium hingga Rp10.000.000.',
          style: TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.45),
        ),
      ),
    ];
  }

  Widget _buildStepRow(int number, String desc) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 20,
          height: 20,
          decoration: const BoxDecoration(
            color: AppColors.secondaryContainer,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              '$number',
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.onSecondaryContainer),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(desc, style: const TextStyle(fontSize: 12, color: AppColors.text)),
        ),
      ],
    );
  }

  Widget _buildTarifCard(String campus, String price) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(campus, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.text)),
          const SizedBox(height: 2),
          Text(price, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.primary)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final allFaqs = _getFaqItems();
    final filteredFaqs = allFaqs.where((f) {
      if (_searchQuery.isEmpty) return true;
      return f.question.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Pusat Bantuan & SOP'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Badge & Title
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.secondaryContainer,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.verified_user, size: 14, color: AppColors.primary),
                    SizedBox(width: 4),
                    Text(
                      'GARANSI TRANSPARAN',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: AppColors.onSecondaryContainer,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Pusat Bantuan & SOP Keamanan',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: AppColors.text,
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Semua informasi keamanan, SOP barang, dan panduan praktis penitipan kos di Padang.',
                style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
              ),

              const SizedBox(height: 18),

              // Search Bar
              TextField(
                controller: _searchCtrl,
                onChanged: (val) {
                  setState(() {
                    _searchQuery = val.trim();
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Cari pertanyaan atau SOP keamanan...',
                  prefixIcon: const Icon(Icons.search, color: AppColors.textMuted),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, size: 18),
                          onPressed: () {
                            _searchCtrl.clear();
                            setState(() {
                              _searchQuery = '';
                            });
                          },
                        )
                      : null,
                ),
              ),

              const SizedBox(height: 18),

              // 3 Pilar Keamanan Banner
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.cardSurface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.security, color: AppColors.primary, size: 20),
                            SizedBox(width: 6),
                            Text(
                              '3 Pilar Keamanan KosinAja',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: AppColors.text,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainerHigh,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'SOP v2.4',
                            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildPilarItem(
                      icon: Icons.qr_code_scanner,
                      title: '1. Segel Barcode Anti-Bongkar',
                      desc: 'Setiap kardus/koper ditempeli stiker segel tamper-evident sebelum diangkut.',
                    ),
                    const SizedBox(height: 10),
                    _buildPilarItem(
                      icon: Icons.photo_camera_back,
                      title: '2. Inspeksi Foto 360° di Gudang',
                      desc: 'Foto fisik barang diunggah langsung ke akun saat tiba di Hub Pauh.',
                    ),
                    const SizedBox(height: 10),
                    _buildPilarItem(
                      icon: Icons.warehouse,
                      title: '3. Gudang Aman & Bebas Banjir',
                      desc: 'Lokasi dataran tinggi Pauh & Limau Manih dengan CCTV 24/7 dan sirkulasi anti-lembab.',
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // FAQ Section Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Pertanyaan Sering Diajukan (FAQ)',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.text,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${filteredFaqs.length} Tanya Jawab',
                      style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // FAQ Accordions List
              if (filteredFaqs.isEmpty)
                Container(
                  padding: const EdgeInsets.all(24),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Column(
                    children: [
                      Icon(Icons.search_off, size: 36, color: AppColors.textMuted),
                      SizedBox(height: 8),
                      Text(
                        'Topik Tidak Ditemukan',
                        style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Coba kata kunci lain atau hubungi admin customer care kami.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                )
              else
                Column(
                  children: filteredFaqs.map((faq) {
                    final isExpanded = _expandedIds.contains(faq.id);

                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      decoration: BoxDecoration(
                        color: AppColors.cardSurface,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isExpanded ? AppColors.primary : AppColors.border,
                        ),
                      ),
                      child: Column(
                        children: [
                          InkWell(
                            onTap: () {
                              setState(() {
                                if (isExpanded) {
                                  _expandedIds.remove(faq.id);
                                } else {
                                  _expandedIds.add(faq.id);
                                }
                              });
                            },
                            borderRadius: BorderRadius.circular(14),
                            child: Padding(
                              padding: const EdgeInsets.all(14),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Text(
                                      faq.question,
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: isExpanded ? FontWeight.w700 : FontWeight.w600,
                                        color: isExpanded ? AppColors.primary : AppColors.text,
                                        height: 1.35,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Icon(
                                    isExpanded ? Icons.expand_less : Icons.expand_more,
                                    color: isExpanded ? AppColors.primary : AppColors.textMuted,
                                    size: 22,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          if (isExpanded) ...[
                            const Divider(height: 1, color: AppColors.border),
                            Padding(
                              padding: const EdgeInsets.all(14),
                              child: faq.content,
                            ),
                          ],
                        ],
                      ),
                    );
                  }).toList(),
                ),

              const SizedBox(height: 20),

              // Customer Support Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.cardSurface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(0xFF25D366).withOpacity(0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.chat, color: Color(0xFF25D366), size: 24),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Masih punya pertanyaan?',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.text,
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'Chat langsung dengan Tim CS KosinAja. Standby setiap hari 07.30 - 22.00 WIB (Fast Response untuk mahasiswa).',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: AppColors.textSecondary,
                                  height: 1.35,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton.icon(
                        onPressed: _openWhatsAppCS,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                        ),
                        icon: const Icon(Icons.forum_outlined, size: 18),
                        label: const Text('Chat WhatsApp Sekarang'),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              const Center(
                child: Text(
                  'Layanan aktif di Limau Manih, Pauh, Air Tawar & se-Kota Padang',
                  style: TextStyle(fontSize: 11, color: AppColors.textMuted),
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPilarItem({
    required IconData icon,
    required String title,
    required String desc,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(icon, color: AppColors.primary, size: 18),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.text),
              ),
              const SizedBox(height: 2),
              Text(
                desc,
                style: const TextStyle(fontSize: 11, color: AppColors.textSecondary, height: 1.3),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
