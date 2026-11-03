/**
 * Layar Detail Booking, Status Log, dan Laporan Kondisi Barang Kosinaja
 * Ditulis untuk modul Alvin (Lokasi & History)
 */

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/services/shipping_calculator.dart';
import '../../core/theme/app_colors.dart';
import '../../models/location_model.dart';

class OrderDetailScreen extends StatefulWidget {
  final String orderCode;
  final String currentStatus;
  final Map<String, dynamic>? rawData;

  const OrderDetailScreen({
    super.key,
    required this.orderCode,
    this.currentStatus = 'IN_STORAGE',
    this.rawData,
  });

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final LocationCoordinate _pickupCoord = const LocationCoordinate(
    latitude: -0.8971,
    longitude: 100.3507,
    name: 'Kos Melati Indah (UNP Air Tawar)',
    address: 'Jl. Belibis No. 14, Air Tawar Barat, Kec. Padang Utara, Kota Padang',
  );

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

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
      'Halo Admin KosinAja Padang, saya ingin menanyakan perkembangan barang dengan nomor resi #${widget.orderCode}.',
    );
    final url = Uri.parse('https://wa.me/6281234567890?text=$text');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.rawData?['title'] ?? '1x Kulkas Mini, 2x Dus Buku';
    final subtitle = widget.rawData?['subtitle'] ?? 'Kategori B • Zona Kampus UNP Air Tawar';
    final schedule = widget.rawData?['schedule'] ?? '28 Okt 2026 - 28 Des 2026 (2 Bulan)';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Detail Pesanan #${widget.orderCode}', style: const TextStyle(fontSize: 16)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.copy, size: 18),
            tooltip: 'Salin Resi',
            onPressed: _copyOrderCode,
          ),
          IconButton(
            icon: const Icon(Icons.support_agent, color: AppColors.primary),
            tooltip: 'Bantuan WA',
            onPressed: _openWhatsApp,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primary,
          indicatorWeight: 3,
          tabs: const [
            Tab(icon: Icon(Icons.timeline, size: 18), text: 'Status Log'),
            Tab(icon: Icon(Icons.fact_check_outlined, size: 18), text: 'Laporan Fisik'),
            Tab(icon: Icon(Icons.receipt_long_outlined, size: 18), text: 'Rincian & Rute'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildStatusLogTab(),
          _buildConditionReportTab(),
          _buildDetailsAndRouteTab(title, subtitle, schedule),
        ],
      ),
    );
  }

  // --- TAB 1: STATUS LOG STEPPER TIMELINE ---
  Widget _buildStatusLogTab() {
    final steps = [
      {
        'title': 'Pesanan Dikonfirmasi Sistem',
        'desc': 'Booking penitipan berhasil diverifikasi admin Kosinaja Padang.',
        'time': '28 Okt 2026, 08:30 WIB',
        'done': true,
      },
      {
        'title': 'Kurir Meluncur ke Kos Penjemputan',
        'desc': 'Kurir Rahmat (Armada Motor Box BA 4521 QP) menuju Jl. Belibis Air Tawar.',
        'time': '28 Okt 2026, 09:45 WIB',
        'done': true,
      },
      {
        'title': 'Barang Dijemput & Diberi Segel Keamanan',
        'desc': 'Serah terima barang selesai, lakban segel barcode terpasang rapat.',
        'time': '28 Okt 2026, 10:20 WIB',
        'done': true,
      },
      {
        'title': 'Inspeksi & Penimbangan Gudang',
        'desc': 'Pemeriksaan kebersihan fisik dan penempatan di rak elevasi anti-lembab.',
        'time': '28 Okt 2026, 11:30 WIB',
        'done': true,
      },
      {
        'title': 'Disimpan Aman di Gudang Air Tawar',
        'desc': 'Barang tersimpan di Slot Rak A-03 (Terpantau CCTV 24/7 & suhu 23.5°C).',
        'time': '28 Okt 2026, 12:00 WIB',
        'done': true,
        'current': true,
      },
      {
        'title': 'Pengembalian Barang ke Pelanggan',
        'desc': 'Barang siap diantar kembali saat semester baru dimulai.',
        'time': 'Estimasi: 28 Des 2026',
        'done': false,
      },
    ];

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.primarySoft,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.primaryContainer),
          ),
          child: const Row(
            children: [
              Icon(Icons.shield_outlined, color: AppColors.primary, size: 20),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Barang Anda terproteksi asuransi & tersimpan di ruang sejuk.',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.primaryDark),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        ...steps.asMap().entries.map((entry) {
          final index = entry.key;
          final step = entry.value;
          final isLast = index == steps.length - 1;
          final isDone = step['done'] as bool;
          final isCurrent = step['current'] == true;

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: isCurrent
                          ? AppColors.primary
                          : (isDone ? AppColors.success : AppColors.surfaceContainerHigh),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Icon(
                        isCurrent
                            ? Icons.radio_button_checked
                            : (isDone ? Icons.check : Icons.circle_outlined),
                        size: 14,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  if (!isLast)
                    Container(
                      width: 2,
                      height: 52,
                      color: isDone ? AppColors.success : AppColors.border,
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
                          Expanded(
                            child: Text(
                              step['title'] as String,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: isCurrent ? FontWeight.w800 : FontWeight.w700,
                                color: isCurrent ? AppColors.primary : AppColors.text,
                              ),
                            ),
                          ),
                          Text(
                            step['time'] as String,
                            style: const TextStyle(fontSize: 10, color: AppColors.textMuted),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        step['desc'] as String,
                        style: const TextStyle(fontSize: 11, color: AppColors.textSecondary, height: 1.3),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        }).toList(),
      ],
    );
  }

  // --- TAB 2: LAPORAN KONDISI MINGGUAN & FOTO INSPEKSI ---
  Widget _buildConditionReportTab() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text(
          'Laporan Kondisi & Inspeksi Mingguan',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.text),
        ),
        const SizedBox(height: 4),
        const Text(
          'Pemeriksaan rutin berkala oleh Quality Guard Kosinaja Padang (hanya lihat)',
          style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 14),

        _buildReportCard(
          week: 'Minggu ke-1 (18 Okt 2026)',
          inspector: 'Fandi Kurniawan (Quality Guard)',
          temp: '23.5°C',
          humidity: '55% RH (Stabil)',
          notes: [
            'Segel lakban merah utuh tanpa robekan.',
            'Kardus buku terangkat di rak pallet bebas kelembaban.',
            'Kulkas mini dalam kondisi kering & steril.',
          ],
          images: [
            'https://images.unsplash.com/photo-1586528116311-ad8dd3c8310d?w=500&auto=format&fit=crop&q=60',
            'https://images.unsplash.com/photo-1553413077-190dd305871c?w=500&auto=format&fit=crop&q=60',
          ],
        ),

        const SizedBox(height: 14),

        _buildReportCard(
          week: 'Minggu ke-2 (25 Okt 2026)',
          inspector: 'Siti Rahma (Staff Gudang Air Tawar)',
          temp: '24.0°C',
          humidity: '54% RH (Kering & Bersih)',
          notes: [
            'Pembersihan filter udara gudang berkala terlaksana.',
            'Pengecekan barcode scanner terbaca normal.',
          ],
          images: [
            'https://images.unsplash.com/photo-1586528116311-ad8dd3c8310d?w=500&auto=format&fit=crop&q=60',
          ],
        ),
      ],
    );
  }

  Widget _buildReportCard({
    required String week,
    required String inspector,
    required String temp,
    required String humidity,
    required List<String> notes,
    required List<String> images,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.primarySoft,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  week,
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.primary),
                ),
              ),
              Row(
                children: [
                  const Icon(Icons.thermostat, size: 14, color: Colors.red),
                  Text(' $temp  ', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700)),
                  const Icon(Icons.water_drop, size: 14, color: Colors.blue),
                  Text(' $humidity', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...notes.map((n) => Padding(
                padding: const EdgeInsets.only(bottom: 3),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.check_circle, size: 13, color: AppColors.success),
                    const SizedBox(width: 6),
                    Expanded(child: Text(n, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary))),
                  ],
                ),
              )),
          const SizedBox(height: 10),
          const Text('FOTO DOKUMENTASI:', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: AppColors.textMuted)),
          const SizedBox(height: 6),
          SizedBox(
            height: 90,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: images.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                return ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    images[index],
                    width: 120,
                    height: 90,
                    fit: BoxFit.cover,
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          Text('Inspektor: $inspector', style: const TextStyle(fontSize: 10, color: AppColors.textMuted, fontStyle: FontStyle.italic)),
        ],
      ),
    );
  }

  // --- TAB 3: RINCIAN & RUTE MAPS ---
  Widget _buildDetailsAndRouteTab(String title, String subtitle, String schedule) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        // Rincian Penitipan
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.cardSurface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Rincian Penitipan Barang', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800)),
              const SizedBox(height: 8),
              Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.primary)),
              const SizedBox(height: 2),
              Text(subtitle, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
              const SizedBox(height: 2),
              Text('Jadwal: $schedule', style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
            ],
          ),
        ),

        const SizedBox(height: 14),

        // Lokasi Penjemputan & Tautan Google Maps
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.cardSurface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.location_on, color: AppColors.primary, size: 20),
                  const SizedBox(width: 8),
                  const Text('Lokasi Penjemputan', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800)),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.successSoft,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text('Radius 0.8 km', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.success)),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(_pickupCoord.name ?? '', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
              const SizedBox(height: 2),
              Text(_pickupCoord.address ?? '', style: const TextStyle(fontSize: 11, color: AppColors.textSecondary, height: 1.3)),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    ShippingCalculator.launchGoogleMapsRoute(
                      ShippingCalculator.depoPadang,
                      _pickupCoord,
                    );
                  },
                  icon: const Icon(Icons.navigation, size: 16),
                  label: const Text('Buka Rute di Google Maps'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 14),

        // Rincian Biaya
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.cardSurface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Rincian Biaya Transparan', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800)),
              SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Biaya Penitipan (2 Bulan)', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                  Text('Rp 150.000', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
                ],
              ),
              SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Tarif Dasar Penjemputan', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                  Text('Rp 10.000', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
                ],
              ),
              SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Surcharge Kategori B (Armada Pikap)', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                  Text('Rp 15.000', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
                ],
              ),
              Divider(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Total Pembayaran', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800)),
                  Text('Rp 175.000', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: AppColors.primary)),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
