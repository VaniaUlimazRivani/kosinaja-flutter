import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/services/api_service.dart';
import '../../core/theme/app_colors.dart';
import 'order_detail_screen.dart';

class OrderHistoryItem {
  final String orderCode;
  final String date;
  final String status;
  final String statusType; // 'active', 'completed'
  final String title;
  final String subtitle;
  final String schedule;
  final String price;
  final String imageUrl;

  const OrderHistoryItem({
    required this.orderCode,
    required this.date,
    required this.status,
    required this.statusType,
    required this.title,
    required this.subtitle,
    required this.schedule,
    required this.price,
    required this.imageUrl,
  });
}

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  String _activeTab = 'active'; // 'active' or 'completed'
  bool _isLoading = false;
  List<OrderHistoryItem> _orders = [];

  static const List<OrderHistoryItem> _defaultOrders = [
    OrderHistoryItem(
      orderCode: 'STC-1310-367',
      date: '10 Nov 2026',
      status: 'Di Gudang Pauh',
      statusType: 'active',
      title: '1x Kulkas Mini, 2x Dus Buku',
      subtitle: 'Kategori B • Zona Kampus UNAND',
      schedule: '10 Nov - 10 Des 2026 (Sisa 18 Hari)',
      price: 'Rp 75.000',
      imageUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuCkSax5t-IOo3GycBaJm5HVWgYxgPiX1F_qqzMG-5b0KcaqFt882nCHoz2_drdc88SyG38lZ4KRQdLBeZbCssQNTKyuYayAL0bNiCGbLBLPChtLYbTDacIGP8z1VD4ZD--J1p3YiGdhx66GuvSrmP24auUoJkpqWEiodDAaSk0jLBeENFJXEHu_S6B-Kl_LTNdSO-wu_t1dL3LT1eTLx0KgEpI2KSGTYEwTcNkmHIGHZ7yw7HeBSKC5',
    ),
    OrderHistoryItem(
      orderCode: 'STC-0824-112',
      date: '15 Agu 2026',
      status: 'Selesai Dikembalikan',
      statusType: 'completed',
      title: '3x Dus Pakaian Mahasiswa',
      subtitle: 'Kategori A • Area UNP Air Tawar',
      schedule: '15 Agu - 15 Sep 2026 (1 Bulan)',
      price: 'Rp 45.000',
      imageUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuC5zHvZ2imFQGiCxr9Y8YbtY7cs7Od6kx0EyhZPx3IAel4jeb7GzWLSPCDJ0TIu2wUibB5Fk_YyaRxU_gTFofDtR5ahjh-HapVVljyZUL49XLbXu3x0z5SuGTAdiNVPSoto1zMwbyGtG3_8DzO64_FAJiYAwUHu2CG2a61sbZXybDxTVft-ReoZ_NeXG5IEvz4RslTz0veV0cSsAxrm50DDwTLbyu2Bdb0puKhuNTPdfI-gPNFu4r-J',
    ),
    OrderHistoryItem(
      orderCode: 'STC-0511-098',
      date: '12 Mei 2026',
      status: 'Selesai Dikembalikan',
      statusType: 'completed',
      title: '1x Koper 24 Inch, 1x Kipas Angin',
      subtitle: 'Kategori A • Pasar Ambacang',
      schedule: '12 Mei - 12 Jun 2026 (1 Bulan)',
      price: 'Rp 35.000',
      imageUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuAQFzpIJYRUZ5HEequecDrADWd2Io1hfKHWFIMt_YNI4qJ9M1F4xpONIjBpQsB-BF1Whlk2x-n7PGMtGWLg-6xT1_F0tw6G47Wv1VyIgSEDyGpvPB0mYZRrCTx3Icbfa8B5KULpTABw2YPe-vxtnh6fmPPaIvS-k03GN4wEQJJrZjMNlylBmuXJunhz4UsBz7Bk6zWL_KKADPClZY2LU4e1UKCd288TljSAPlQAIPIedXsIUh0rRD6m',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _orders = List.from(_defaultOrders);
    _fetchOrders();
  }

  Future<void> _fetchOrders() async {
    setState(() => _isLoading = true);
    try {
      final res = await ApiService.getBookings(userId: ApiService.currentUser?.id);
      if (mounted) {
        if (res['success'] == true && res['bookings'] is List) {
          final List list = res['bookings'];
          if (list.isNotEmpty) {
            final mapped = list.map((b) {
              final status = b['status'] ?? 'LEAD';
              final isDone = status == 'COMPLETED' || status == 'CLOSED';

              String statusLabel = 'Menunggu Konfirmasi';
              if (status == 'APPROVED') statusLabel = 'Disetujui Admin';
              if (status == 'PICKUP_SCHEDULED') statusLabel = 'Jadwal Penjemputan';
              if (status == 'IN_STORAGE') statusLabel = 'Di Gudang Pauh';
              if (status == 'DELIVERY_SCHEDULED') statusLabel = 'Jadwal Pengantaran';
              if (status == 'COMPLETED') statusLabel = 'Selesai Dikembalikan';

              String itemsTitle = 'Barang Titipan';
              if (b['items'] is List && (b['items'] as List).isNotEmpty) {
                itemsTitle = (b['items'] as List)
                    .map((it) => '${it['jumlah'] ?? 1}x ${it['namaBarang'] ?? it['nama'] ?? 'Barang'}')
                    .join(', ');
              }

              final createdAt = b['createdAt'] != null
                  ? DateFormat('d MMM yyyy', 'id_ID')
                      .format(DateTime.tryParse(b['createdAt']) ?? DateTime.now())
                  : 'Baru saja';

              final priceFmt = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0)
                  .format(b['totalHarga'] ?? 0);

              return OrderHistoryItem(
                orderCode: b['kodeBooking'] ?? 'STC-0000',
                date: createdAt,
                status: statusLabel,
                statusType: isDone ? 'completed' : 'active',
                title: itemsTitle,
                subtitle: 'Kategori ${b['kategori'] ?? 'A'} • ${b['lokasiPickup'] ?? 'Kota Padang'}',
                schedule: '${b['durasiBulan'] ?? 1} Bulan',
                price: priceFmt,
                imageUrl: _defaultOrders.first.imageUrl,
              );
            }).toList();

            setState(() {
              _orders = mapped;
            });
          }
        }
      }
    } catch (_) {}
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  void _showCompletedEvidenceModal(OrderHistoryItem item) {
    showDialog(
      context: context,
      builder: (ctx) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Bukti Serah Terima Selesai',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
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
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(
                    item.imageUrl,
                    height: 160,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  item.title,
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                ),
                const SizedBox(height: 4),
                Text(
                  'Nomor Resi: ${item.orderCode}',
                  style: const TextStyle(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Status: Barang telah diantar kembali ke kosan tujuan dengan segel utuh dan ditandatangani mahasiswa.',
                  style: TextStyle(fontSize: 11, color: AppColors.textSecondary, height: 1.35),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(ctx),
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

  @override
  Widget build(BuildContext context) {
    final activeOrders = _orders.where((o) => o.statusType == 'active').toList();
    final completedOrders = _orders.where((o) => o.statusType == 'completed').toList();
    final displayedOrders = _activeTab == 'active' ? activeOrders : completedOrders;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: AppColors.primarySoft,
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Icon(
                Icons.inventory_2_outlined,
                color: AppColors.primary,
                size: 16,
              ),
            ),
            const SizedBox(width: 8),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'KosinAja',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                  ),
                ),
                Text(
                  'Riwayat Tracking',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.support_agent_outlined),
            onPressed: () {
              Navigator.pushNamed(context, '/help');
            },
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _fetchOrders,
          color: AppColors.primary,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Context
              Text(
                'Riwayat Pesanan',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: AppColors.text,
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                'Daftar titipan aktif dan riwayat sebelumnya',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
              ),

              const SizedBox(height: 18),

              // Segmented Tab Filter
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _activeTab = 'active';
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: _activeTab == 'active'
                                ? AppColors.primary
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: _activeTab == 'active'
                                ? [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.08),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ]
                                : null,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.inventory_2_outlined,
                                size: 16,
                                color: _activeTab == 'active'
                                    ? Colors.white
                                    : AppColors.textSecondary,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Sedang Berjalan (${activeOrders.length})',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: _activeTab == 'active'
                                      ? Colors.white
                                      : AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _activeTab = 'completed';
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: _activeTab == 'completed'
                                ? AppColors.primary
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: _activeTab == 'completed'
                                ? [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.08),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ]
                                : null,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.task_alt,
                                size: 16,
                                color: _activeTab == 'completed'
                                    ? Colors.white
                                    : AppColors.textSecondary,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Selesai / Riwayat (${completedOrders.length})',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: _activeTab == 'completed'
                                      ? Colors.white
                                      : AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              // Orders List Cards
              Column(
                children: displayedOrders.map((order) {
                  final isActive = order.statusType == 'active';

                  return Container(
                    margin: const EdgeInsets.only(bottom: 14),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.cardSurface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.03),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Card Top Row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  isActive ? Icons.inventory_2 : Icons.archive_outlined,
                                  color: isActive ? AppColors.primary : AppColors.secondary,
                                  size: 18,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  order.orderCode,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.text,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                const Text('•', style: TextStyle(color: AppColors.outlineVariant)),
                                const SizedBox(width: 6),
                                Text(
                                  order.date,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: isActive
                                    ? AppColors.secondaryContainer
                                    : AppColors.surfaceContainerHigh,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  if (isActive) ...[
                                    Container(
                                      width: 6,
                                      height: 6,
                                      decoration: const BoxDecoration(
                                        color: AppColors.primary,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                  ],
                                  Text(
                                    order.status,
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      color: isActive
                                          ? AppColors.onSecondaryContainer
                                          : AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),

                        // Card Body
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainerLow,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  order.imageUrl,
                                  width: 64,
                                  height: 64,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      order.title,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.text,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      order.subtitle,
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.schedule,
                                          size: 13,
                                          color: isActive ? AppColors.primary : AppColors.textMuted,
                                        ),
                                        const SizedBox(width: 4),
                                        Expanded(
                                          child: Text(
                                            order.schedule,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontSize: 11,
                                              fontWeight:
                                                  isActive ? FontWeight.w700 : FontWeight.w500,
                                              color: isActive ? AppColors.primary : AppColors.textSecondary,
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

                        const SizedBox(height: 12),

                        // Card Bottom Row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  isActive ? 'Total Biaya Titip' : 'Total Terbayar',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                Text(
                                  order.price,
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w800,
                                    color: isActive ? AppColors.primary : AppColors.text,
                                  ),
                                ),
                              ],
                            ),
                            if (isActive)
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => OrderDetailScreen(
                                        orderCode: order.orderCode,
                                        currentStatus: order.statusType == 'active' ? 'IN_STORAGE' : 'COMPLETED',
                                        rawData: {
                                          'title': order.title,
                                          'subtitle': order.subtitle,
                                          'schedule': order.schedule,
                                        },
                                      ),
                                    ),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: const Row(
                                  children: [
                                    Text('Lihat Detail & Lacak', style: TextStyle(fontSize: 12)),
                                    SizedBox(width: 4),
                                    Icon(Icons.arrow_forward, size: 14),
                                  ],
                                ),
                              )
                            else
                              OutlinedButton.icon(
                                onPressed: () => _showCompletedEvidenceModal(order),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppColors.text,
                                  side: const BorderSide(color: AppColors.border),
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                icon: const Icon(Icons.photo_camera_outlined, size: 15),
                                label: const Text('Bukti Foto Selesai', style: TextStyle(fontSize: 12)),
                              ),
                          ],
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 10),

              // Promotional CTA Section
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.secondaryContainer.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.primarySoft),
                ),
                child: Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.primarySoft,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.luggage, color: AppColors.primary, size: 22),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Butuh simpan barang tambahan?',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.text,
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'Amankan barang kosmu selama libur semester tanpa pusing bayar sewa penuh.',
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
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      height: 44,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pushNamed(context, '/booking-step1');
                        },
                        icon: const Icon(Icons.add_box_outlined, size: 18),
                        label: const Text('+ Titip Barang Baru', style: TextStyle(fontSize: 13)),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 2, // Riwayat tab
        onTap: (index) {
          if (index == 0) {
            Navigator.pushReplacementNamed(context, '/home');
          } else if (index == 1) {
            Navigator.pushNamed(context, '/booking-step1');
          } else if (index == 3) {
            Navigator.pushReplacementNamed(context, '/profile');
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
}
