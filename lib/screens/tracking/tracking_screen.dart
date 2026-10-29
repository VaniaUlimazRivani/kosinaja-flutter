import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme/app_colors.dart';

class PhotoItem {
  final String title;
  final String code;
  final String description;
  final String imageUrl;

  const PhotoItem({
    required this.title,
    required this.code,
    required this.description,
    required this.imageUrl,
  });
}

class TrackingScreen extends StatefulWidget {
  final String orderCode;
  const TrackingScreen({super.key, this.orderCode = 'STC-1310-367'});

  @override
  State<TrackingScreen> createState() => _TrackingScreenState();
}

class _TrackingScreenState extends State<TrackingScreen> {
  bool _showCctvLive = false;
  String _selectedExtend = '30d';

  final List<PhotoItem> _photos = const [
    PhotoItem(
      title: 'Kardus Buku & Dokumen',
      code: 'Barcode #UNAND-4910',
      description: 'Tersegel lakban cokelat rapat tanpa robekan.',
      imageUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuA2hxPj6HvS4tmoBfOQYz_g2bgYbxKJanNz-uiQklWd6myfTDWOJU8GJmEidEV9Zlhz6G6B0wonPAYiG0sC8xaw-QmaO8quTbHIYiWb9IE033FIlHweq5LnvJjrZNSSmpY7pIkY03PaacZDQCZ_j7AYJBhjt6xnLrg9UYmPrsNrTnfMqvB6-QKfOaAtWcT2pDHAwfHw8iCbTlWdh6tz9Ajw8viUSbsn6kDA8wa3AtzLxOZrGEdNr2S8',
    ),
    PhotoItem(
      title: 'Kulkas Mini Portabel',
      code: 'Segel #UNAND-4911',
      description: 'Lapisan bubble wrap 3 layer & pengering internal.',
      imageUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuCr30x42ylvxBCokRS27ZRL1GrfjczUEXNp07s7CvijfxuVQb3ppGMT3TINOH_hgowhT7WaxBRtiCYdSzDV7ixrCuB2JGiFl1Ao8dDhS2ic8sDVMSq9UfXfyQmF_j_KTomxtFAD26CarVMsIMZ0lkGJb-EKHo8afdSnVSckcE2NCOzck0k361WL53gJRNfh7At2WBGBUKlEZoOIfWBSqNeVYMZAnj5pD69p3rQr3gzIgULD24AaNUPt',
    ),
    PhotoItem(
      title: 'Rak Pallet Gudang Pauh',
      code: 'Lokasi Slot A-04',
      description: 'Tersimpan rapi di zona elevasi bebas lembab.',
      imageUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuCYHHauUQKf-hMPyLgqNrQJdesZbZ13zNvqDtksCd9uCuwZdBqtdtlex-EJ4FI84Y4iaHmGSqT1lm_wZCBX5GboTnbBtE719LCpU7uKXGAU6RabgGZ7PMUOlrjI15eh1RdP1R4QOFnLufI5mftGx7Yej2kZYQGPo8eAIgzE24QgDLkGvp_Uckg2-WdvuB0Ec50KjdShz3yTZChzBZVM3VofH6gLqXzQptU-e6G21fVY8mqoXHFtFDe5',
    ),
  ];

  void _copyOrderCode() {
    Clipboard.setData(ClipboardData(text: widget.orderCode));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Nomor resi ${widget.orderCode} berhasil disalin!'),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _openWhatsApp() async {
    final text = Uri.encodeComponent(
      'Halo Petugas Gudang KosinAja Pauh, saya ingin menanyakan perkembangan barang dengan nomor resi ${widget.orderCode}.',
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

  void _showPhotoDetail(PhotoItem photo) {
    showDialog(
      context: context,
      builder: (ctx) {
        return Dialog(
          backgroundColor: Colors.black,
          insetPadding: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 8, 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      photo.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
              ),
              ClipRRect(
                child: Image.network(
                  photo.imageUrl,
                  height: 240,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.success,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        photo.code,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      photo.description,
                      style: const TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showExtendModal() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            final options = [
              {'id': '7d', 'label': '+7 Hari (1 Minggu)', 'price': 'Rp 15.000', 'desc': 'Libur singkat'},
              {'id': '14d', 'label': '+14 Hari (2 Minggu)', 'price': 'Rp 28.000', 'desc': 'Libur jeda semester'},
              {'id': '30d', 'label': '+30 Hari (1 Bulan)', 'price': 'Rp 55.000', 'desc': 'Paling populer & hemat'},
              {'id': '1sem', 'label': '+1 Semester (6 Bulan)', 'price': 'Rp 250.000', 'desc': 'Cuti kuliah / KKN'},
            ];

            return Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Perpanjang Masa Penitipan',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.text,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Pilih tambahan durasi simpan untuk pesanan ${widget.orderCode}:',
                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 14),
                  ...options.map((opt) {
                    final isSel = _selectedExtend == opt['id'];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: InkWell(
                        onTap: () {
                          setModalState(() {
                            _selectedExtend = opt['id']!;
                          });
                          setState(() {
                            _selectedExtend = opt['id']!;
                          });
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isSel
                                ? AppColors.primarySoft.withOpacity(0.3)
                                : AppColors.cardSurface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSel ? AppColors.primary : AppColors.border,
                              width: isSel ? 1.5 : 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                isSel
                                    ? Icons.radio_button_checked
                                    : Icons.radio_button_off,
                                color: isSel ? AppColors.primary : AppColors.textMuted,
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      opt['label']!,
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: isSel ? FontWeight.w700 : FontWeight.w600,
                                        color: AppColors.text,
                                      ),
                                    ),
                                    Text(
                                      opt['desc']!,
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                opt['price']!,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Permohonan perpanjangan berhasil diajukan ke Petugas Gudang!'),
                            backgroundColor: AppColors.success,
                          ),
                        );
                      },
                      child: const Text('Ajukan Perpanjangan'),
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

  void _showResiModal() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.receipt_long, color: AppColors.primary),
                      SizedBox(width: 8),
                      Text(
                        'Resi Digital Penitipan',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.text,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  children: [
                    _buildResiRow('Nomor Resi', widget.orderCode, isBold: true),
                    const Divider(height: 16, color: AppColors.border),
                    _buildResiRow('Penyimpan', 'Rifqi Alamsyah (UNAND)'),
                    const SizedBox(height: 6),
                    _buildResiRow('Fasilitas Gudang', 'Hub Pauh UNAND - Slot A-04'),
                    const SizedBox(height: 6),
                    _buildResiRow('Item Disimpan', '1 Kardus Buku + 1 Kulkas Mini'),
                    const SizedBox(height: 6),
                    _buildResiRow('Total Biaya', 'Rp 75.000 (Lunas)'),
                    const SizedBox(height: 6),
                    _buildResiRow('Payment Gateway', 'Xendit (Invoice #XND-88291)'),
                    const SizedBox(height: 6),
                    _buildResiRow('Masa Simpan', '10 Nov 2026 - 10 Des 2026'),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('File PDF resi penitipan berhasil diunduh.'),
                        backgroundColor: AppColors.success,
                      ),
                    );
                  },
                  icon: const Icon(Icons.file_download),
                  label: const Text('Unduh File PDF Resi'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildResiRow(String key, String val, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(key, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
        Text(
          val,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isBold ? FontWeight.w800 : FontWeight.w600,
            color: isBold ? AppColors.primary : AppColors.text,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Detail Penitipan'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined),
            onPressed: () {
              Clipboard.setData(ClipboardData(text: 'https://kosinaja.com/track/${widget.orderCode}'));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Tautan pelacakan berhasil disalin!')),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.receipt_long_outlined),
            onPressed: _showResiModal,
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hub Context Sub-bar
              Row(
                children: [
                  const Icon(Icons.warehouse_outlined, color: AppColors.primary, size: 18),
                  const SizedBox(width: 6),
                  const Text(
                    'Hub Pauh • Kampus UNAND',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.successSoft,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.circle, color: AppColors.success, size: 8),
                        SizedBox(width: 4),
                        Text(
                          'Aktif di Gudang',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppColors.success,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              // Overview Registration Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.cardSurface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.02),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Nomor Registrasi Penitipan',
                              style: TextStyle(fontSize: 11, color: AppColors.textMuted),
                            ),
                            const SizedBox(height: 2),
                            Row(
                              children: [
                                Text(
                                  widget.orderCode,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.text,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                InkWell(
                                  onTap: _copyOrderCode,
                                  borderRadius: BorderRadius.circular(12),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: AppColors.surfaceContainerLow,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Row(
                                      children: [
                                        Icon(Icons.copy, size: 12, color: AppColors.primary),
                                        SizedBox(width: 4),
                                        Text(
                                          'Salin',
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w700,
                                            color: AppColors.primary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                    const Divider(height: 24, color: AppColors.border),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.event_repeat, color: AppColors.primary, size: 20),
                            SizedBox(width: 8),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Batas Masa Simpan',
                                  style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                                ),
                                Text(
                                  '10 Des 2026',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.text,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.secondaryContainer,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            'Sisa 18 Hari',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppColors.onSecondaryContainer,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Vertical Timeline Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.local_shipping_outlined, color: AppColors.primary, size: 20),
                      SizedBox(width: 6),
                      Text(
                        'Pelacakan Proses',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.text,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text(
                      'Realtime Padang',
                      style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.cardSurface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  children: [
                    _buildTimelineStep(
                      title: 'Pesanan Dibuat',
                      time: '08:30 WIB',
                      desc: 'Formulir penitipan terverifikasi otomatis oleh sistem.',
                      isDone: true,
                    ),
                    _buildTimelineStep(
                      title: 'Pembayaran Terverifikasi',
                      time: '08:35 WIB',
                      desc: 'Lunas via QRIS (BSI Mahasiswa).',
                      isDone: true,
                    ),
                    _buildTimelineStep(
                      title: 'Jadwal Penjemputan Dikonfirmasi',
                      time: '09:00 WIB',
                      desc: 'Slot penjemputan Kosan Melati, Pasar Baru Pauh.',
                      isDone: true,
                    ),
                    _buildTimelineStep(
                      title: 'Barang Dijemput Kurir (Fauzan)',
                      time: '10:15 WIB',
                      desc: 'Diambil menggunakan Mobil Pick-up KosinAja armada Padang.',
                      isDone: true,
                    ),
                    _buildTimelineStep(
                      title: 'Barang Tiba di Gudang Pauh',
                      time: '11:20 WIB',
                      desc: 'Proses unloading & desinfeksi kardus tuntas.',
                      isDone: true,
                    ),
                    _buildActiveTimelineStep(),
                    _buildTimelineStep(
                      title: 'Pengantaran Kembali ke Kos',
                      time: 'Mendatang',
                      desc: 'Dijadwalkan saat semester baru dimulai (Jadwal Reservasi).',
                      isDone: false,
                      isLast: true,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Bukti Foto Fisik Gallery
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.verified, color: AppColors.primary, size: 20),
                      SizedBox(width: 6),
                      Text(
                        'Bukti Foto Fisik',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.text,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.successSoft,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text(
                      '3 Foto Terverifikasi',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.success,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              const Text(
                'Laporan Kondisi Barang Saat Tiba di Fasilitas Gudang Pauh:',
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 12),

              Column(
                children: _photos.map((item) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    child: InkWell(
                      onTap: () => _showPhotoDetail(item),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.cardSurface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                item.imageUrl,
                                width: 68,
                                height: 68,
                                fit: BoxFit.cover,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(Icons.qr_code_2, size: 14, color: AppColors.success),
                                      const SizedBox(width: 4),
                                      Text(
                                        item.code,
                                        style: const TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.success,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    item.title,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.text,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    item.description,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(Icons.chevron_right, color: AppColors.textMuted),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 12),

              // Catatan Inspeksi Petugas
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.secondaryContainer.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: AppColors.cardSurface,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.engineering, color: AppColors.secondary, size: 18),
                    ),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Inspeksi Petugas: Bambang',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.text,
                                ),
                              ),
                              Text(
                                '10 Nov, 11:35 WIB',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 4),
                          Text(
                            '“Kondisi barang utuh, segel barcode aman, tidak ada kerusakan fisik atau kelembaban saat serah terima.”',
                            style: TextStyle(
                              fontSize: 11,
                              fontStyle: FontStyle.italic,
                              color: AppColors.textSecondary,
                              height: 1.35,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              // Garansi Keamanan Card
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.border),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.verified_user_outlined, color: AppColors.primary, size: 28),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Garansi Keamanan KosinAja',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: AppColors.text,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Kompensasi perlindungan barang hingga Rp10.000.000 selama masa penitipan di Padang.',
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
              ),

              const SizedBox(height: 24),

              // Action Buttons
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: _openWhatsApp,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1B7A43),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: const Icon(Icons.chat, color: Colors.white),
                  label: const Text(
                    'Hubungi Petugas Gudang / Kurir',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                  ),
                ),
              ),

              const SizedBox(height: 10),

              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton.icon(
                  onPressed: _showExtendModal,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.text,
                    side: const BorderSide(color: AppColors.border, width: 1.5),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: const Icon(Icons.more_time, color: AppColors.primary),
                  label: const Text(
                    'Perpanjang Masa Penitipan',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimelineStep({
    required String title,
    required String time,
    required String desc,
    required bool isDone,
    bool isLast = false,
  }) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  color: isDone ? AppColors.successSoft : AppColors.surfaceContainerHigh,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isDone ? Icons.check : Icons.schedule,
                  size: 14,
                  color: isDone ? AppColors.success : AppColors.textMuted,
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: isDone ? AppColors.success : AppColors.border,
                  ),
                ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: isDone ? FontWeight.w700 : FontWeight.w500,
                          color: isDone ? AppColors.text : AppColors.textMuted,
                        ),
                      ),
                      Text(
                        time,
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    desc,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveTimelineStep() {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 22,
                height: 22,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.videocam,
                  size: 14,
                  color: Colors.white,
                ),
              ),
              Expanded(
                child: Container(
                  width: 2,
                  color: AppColors.border,
                ),
              ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Penitipan Aktif & Pengawasan CCTV',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'Berjalan',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    const Row(
                      children: [
                        Icon(Icons.schedule, size: 13, color: AppColors.primary),
                        SizedBox(width: 4),
                        Text(
                          '10 Nov – 10 Des (Pallet A-04)',
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Monitoring 24/7 dengan sensor suhu terjaga dan asuransi proteksi aktif.',
                      style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 8),

                    // CCTV Toggle
                    InkWell(
                      onTap: () {
                        setState(() {
                          _showCctvLive = !_showCctvLive;
                        });
                      },
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.cardSurface,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _showCctvLive ? Icons.videocam_off : Icons.live_tv,
                              size: 14,
                              color: AppColors.primary,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              _showCctvLive
                                  ? 'Tutup Live Monitor'
                                  : 'Buka Live Status Sensor & CCTV',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    if (_showCctvLive) ...[
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Stack(
                          children: [
                            Image.network(
                              'https://lh3.googleusercontent.com/aida-public/AB6AXuCYHHauUQKf-hMPyLgqNrQJdesZbZ13zNvqDtksCd9uCuwZdBqtdtlex-EJ4FI84Y4iaHmGSqT1lm_wZCBX5GboTnbBtE719LCpU7uKXGAU6RabgGZ7PMUOlrjI15eh1RdP1R4QOFnLufI5mftGx7Yej2kZYQGPo8eAIgzE24QgDLkGvp_Uckg2-WdvuB0Ec50KjdShz3yTZChzBZVM3VofH6gLqXzQptU-e6G21fVY8mqoXHFtFDe5',
                              height: 120,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                            Container(
                              padding: const EdgeInsets.all(6),
                              color: Colors.black.withOpacity(0.6),
                              child: const Row(
                                children: [
                                  Icon(Icons.circle, color: Colors.red, size: 8),
                                  SizedBox(width: 6),
                                  Text(
                                    'CCTV-PAUH-CAM03 • LIVE FEED',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  Spacer(),
                                  Text(
                                    '24.2°C • 58% RH (Aman)',
                                    style: TextStyle(
                                      color: Colors.greenAccent,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
