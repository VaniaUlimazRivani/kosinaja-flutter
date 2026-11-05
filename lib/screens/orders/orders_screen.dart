import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/services/api_service.dart';
import '../../core/theme/app_colors.dart';
import 'order_detail_screen.dart';
import '../tracking/tracking_screen.dart';
import '../../widgets/xendit_payment_modal.dart';
import '../../core/services/booking_storage_service.dart';

class OrderHistoryItem {
  final String? bookingId;
  final String orderCode;
  final String date;
  final String status;
  final String statusType; // 'active', 'completed'
  final String paymentStatus; // 'UNPAID', 'PENDING', 'PAID', etc.
  final String title;
  final String subtitle;
  final String schedule;
  final String price;
  final String imageUrl;

  const OrderHistoryItem({
    this.bookingId,
    required this.orderCode,
    required this.date,
    required this.status,
    required this.statusType,
    this.paymentStatus = 'UNPAID',
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

  static const String _defaultItemImage =
      'https://images.unsplash.com/photo-1584622650111-993a426fbf0a?auto=format&fit=crop&w=300&q=80';
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
          'https://images.unsplash.com/photo-1584622650111-993a426fbf0a?auto=format&fit=crop&w=300&q=80',
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
          'https://images.unsplash.com/photo-1534349762230-e0cadf78f5da?auto=format&fit=crop&w=300&q=80',
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
          'https://images.unsplash.com/photo-1544816155-12df9643f363?auto=format&fit=crop&w=300&q=80',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _orders = [];
    _fetchOrders();
  }

  Future<void> _fetchOrders() async {
    setState(() => _isLoading = true);
    try {
      final localOrders = await BookingStorageService.getOrders();
      List<OrderHistoryItem> combined = [];
      if (localOrders.isNotEmpty) {
        combined = localOrders.map((o) {
          final isDone = o['statusType'] == 'completed';
          return OrderHistoryItem(
            bookingId: o['bookingId'],
            orderCode: o['orderCode'] ?? o['kodeBooking'] ?? 'KOS-0000',
            date: o['date'] ?? DateFormat('d MMM yyyy', 'id_ID').format(DateTime.now()),
            status: o['status'] ?? 'Menunggu Penjemputan',
            statusType: isDone ? 'completed' : 'active',
            paymentStatus: (o['paymentStatus'] ?? 'PAID').toString().toUpperCase(),
            title: o['title'] ?? 'Barang Titipan Mahasiswa',
            subtitle: o['subtitle'] ?? 'Hub Hotel Ibis Padang',
            schedule: o['schedule'] ?? '1 Bulan',
            price: o['price'] ?? 'Rp 199.000',
            imageUrl: _defaultItemImage,
          );
        }).toList();
        if (mounted) {
          setState(() {
            _orders = combined;
          });
        }
      }
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
                bookingId: b['id']?.toString(),
                orderCode: b['kodeBooking'] ?? 'STC-0000',
                date: createdAt,
                status: statusLabel,
                statusType: isDone ? 'completed' : 'active',
                paymentStatus: (b['paymentStatus'] ?? 'UNPAID').toString().toUpperCase(),
                title: itemsTitle,
                subtitle: 'Kategori ${b['kategori'] ?? 'A'} • ${b['lokasiPickup'] ?? 'Kota Padang'}',
                schedule: '${b['durasiBulan'] ?? 1} Bulan',
                price: priceFmt,
                imageUrl: _defaultItemImage,
              );
            }).toList();

            setState(() {
              final localCodes = combined.map((c) => c.orderCode).toSet();
              final serverOnly = mapped.where((m) => !localCodes.contains(m.orderCode)).toList();
              _orders = [...combined, ...serverOnly];
            });
          }
        }
      }
    } catch (_) {}
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  /// Membuka pop-up pembayaran Xendit in-app dan memfasilitasi refresh otomatis
  Future<void> _payBookingWithXendit(OrderHistoryItem order) async {
    if (order.bookingId == null || order.bookingId!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ID pesanan tidak valid untuk pembayaran.')),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
            ),
            SizedBox(width: 12),
            Text('Menyiapkan pop-up pembayaran Xendit...'),
          ],
        ),
        duration: Duration(seconds: 2),
      ),
    );

    final res = await ApiService.createXenditInvoice(order.bookingId!);
    if (!mounted) return;

    if (res['success'] == true) {
      final invoiceUrl = res['invoiceUrl'] as String?;
      if (invoiceUrl != null && invoiceUrl.isNotEmpty) {
        final rawPrice = int.tryParse(order.price.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;

        await XenditPaymentModal.show(
          context: context,
          bookingId: order.bookingId!,
          kodeBooking: order.orderCode,
          invoiceUrl: invoiceUrl,
          totalHarga: rawPrice,
        );

        if (mounted) {
          _fetchOrders(); // Refresh status pesanan otomatis setelah modal ditutup
        }
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(res['error'] ?? 'Gagal membuat invoice pembayaran Xendit'),
          backgroundColor: AppColors.error,
        ),
      );
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
                    errorBuilder: (_, __, ___) => Container(
                      height: 160,
                      color: const Color(0xFFF3ECE4),
                      alignment: Alignment.center,
                      child: const Icon(Icons.inventory_2, size: 48, color: AppColors.primary),
                    ),
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
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                    child: const Text('Tutup', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
      backgroundColor: const Color(0xFFFAF7F2),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFAF7F2),
        elevation: 0,
        automaticallyImplyLeading: false,
        titleSpacing: 20,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Riwayat Penitipan',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: Color(0xFF2E2018),
                letterSpacing: -0.3,
              ),
            ),
            SizedBox(height: 2),
            Text(
              'Pantau status barang & arsip penitipanmu',
              style: TextStyle(
                fontSize: 11,
                color: Color(0xFF7A6F68),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFEAE1D5)),
              ),
              alignment: Alignment.center,
              child: const Icon(Icons.support_agent_outlined, size: 20, color: AppColors.primary),
            ),
            tooltip: 'Pusat Bantuan',
            onPressed: () {
              Navigator.pushNamed(context, '/help');
            },
          ),
          const SizedBox(width: 14),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _fetchOrders,
          color: AppColors.primary,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_isLoading)
                  const Padding(
                    padding: EdgeInsets.only(bottom: 12),
                    child: LinearProgressIndicator(
                      minHeight: 2,
                      backgroundColor: Color(0xFFFAF7F2),
                      color: AppColors.primary,
                    ),
                  ),

                // SEGMENTED TAB FILTER (Home Color Synchronized)
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFE8DF),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      // Tab 1: Sedang Berjalan
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _activeTab = 'active';
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 9),
                            decoration: BoxDecoration(
                              color: _activeTab == 'active' ? AppColors.primary : Colors.transparent,
                              borderRadius: BorderRadius.circular(11),
                              boxShadow: _activeTab == 'active'
                                  ? [
                                      BoxShadow(
                                        color: AppColors.primary.withOpacity(0.25),
                                        blurRadius: 6,
                                        offset: const Offset(0, 2),
                                      ),
                                    ]
                                  : null,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  '📦 Berjalan',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: _activeTab == 'active' ? Colors.white : const Color(0xFF6D625B),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: _activeTab == 'active'
                                        ? Colors.white.withOpacity(0.25)
                                        : const Color(0xFFE3D9CD),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    '${activeOrders.length}',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w800,
                                      color: _activeTab == 'active' ? Colors.white : const Color(0xFF6D625B),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),

                      // Tab 2: Selesai / Riwayat
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _activeTab = 'completed';
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 9),
                            decoration: BoxDecoration(
                              color: _activeTab == 'completed' ? AppColors.primary : Colors.transparent,
                              borderRadius: BorderRadius.circular(11),
                              boxShadow: _activeTab == 'completed'
                                  ? [
                                      BoxShadow(
                                        color: AppColors.primary.withOpacity(0.25),
                                        blurRadius: 6,
                                        offset: const Offset(0, 2),
                                      ),
                                    ]
                                  : null,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  '✓ Selesai',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: _activeTab == 'completed' ? Colors.white : const Color(0xFF6D625B),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: _activeTab == 'completed'
                                        ? Colors.white.withOpacity(0.25)
                                        : const Color(0xFFE3D9CD),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    '${completedOrders.length}',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w800,
                                      color: _activeTab == 'completed' ? Colors.white : const Color(0xFF6D625B),
                                    ),
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

                const SizedBox(height: 14),

                // ORDERS LIST
                if (displayedOrders.isEmpty) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(28),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: const Color(0xFFEFE8DF)),
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF1E8),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          alignment: Alignment.center,
                          child: const Text('📦', style: TextStyle(fontSize: 26)),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _activeTab == 'active' ? 'Belum Ada Titipan Berjalan' : 'Belum Ada Riwayat Selesai',
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Color(0xFF2E2018)),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _activeTab == 'active'
                              ? 'Yuk amankan barang kosmu sekarang dengan aman dan terjangkau.'
                              : 'Semua pesanan penitipan yang telah selesai akan diarsipkan di sini.',
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 11.5, color: Color(0xFF7A6F68), height: 1.3),
                        ),
                        if (_activeTab == 'active') ...[
                          const SizedBox(height: 14),
                          ElevatedButton(
                            onPressed: () => Navigator.pushNamed(context, '/booking-step1'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: const Text(
                              '+ Buat Titipan Baru',
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ] else ...[
                  Column(
                    children: displayedOrders.map((order) {
                      final isActive = order.statusType == 'active';
                      final isUnpaid = order.paymentStatus == 'UNPAID';

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: const Color(0xFFEFE8DF)),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFA34E36).withOpacity(0.04),
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Card Top Row
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    const Text('🔖', style: TextStyle(fontSize: 13)),
                                    const SizedBox(width: 5),
                                    Text(
                                      order.orderCode,
                                      style: const TextStyle(
                                        fontSize: 12.5,
                                        fontWeight: FontWeight.w800,
                                        color: Color(0xFF2E2018),
                                        letterSpacing: 0.2,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    const Text('•', style: TextStyle(color: Color(0xFFD6C8B8), fontSize: 11)),
                                    const SizedBox(width: 4),
                                    Text(
                                      order.date,
                                      style: const TextStyle(fontSize: 11, color: Color(0xFF8C827A), fontWeight: FontWeight.w500),
                                    ),
                                  ],
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                                  decoration: BoxDecoration(
                                    color: isActive ? const Color(0xFFE8F5E9) : const Color(0xFFF3ECE4),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: isActive ? const Color(0xFFC8E6C9) : const Color(0xFFE5D9CC),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        width: 6,
                                        height: 6,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: isActive ? const Color(0xFF2E7D32) : const Color(0xFF8C827A),
                                        ),
                                      ),
                                      const SizedBox(width: 5),
                                      Text(
                                        order.status,
                                        style: TextStyle(
                                          fontSize: 10.5,
                                          fontWeight: FontWeight.w800,
                                          color: isActive ? const Color(0xFF2E7D32) : const Color(0xFF7A6F68),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 12),

                            // Middle Info Row
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.network(
                                    order.imageUrl,
                                    width: 62,
                                    height: 62,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => Container(
                                      width: 62,
                                      height: 62,
                                      color: const Color(0xFFFAF8F5),
                                      alignment: Alignment.center,
                                      child: const Text('📦', style: TextStyle(fontSize: 22)),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        order.title,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w800,
                                          color: Color(0xFF2E2018),
                                          height: 1.25,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 3),
                                      Row(
                                        children: [
                                          const Text('📍', style: TextStyle(fontSize: 11)),
                                          const SizedBox(width: 4),
                                          Expanded(
                                            child: Text(
                                              order.subtitle,
                                              style: const TextStyle(fontSize: 11, color: Color(0xFF7A6F68)),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                                        decoration: BoxDecoration(
                                          color: isActive ? const Color(0xFFFFF7F2) : const Color(0xFFF7F4EF),
                                          borderRadius: BorderRadius.circular(6),
                                          border: Border.all(
                                            color: isActive ? const Color(0xFFFFE2D4) : const Color(0xFFE8E0D5),
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(isActive ? '⏳ ' : '✓ ', style: const TextStyle(fontSize: 9.5)),
                                            Text(
                                              order.schedule,
                                              style: TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.w700,
                                                color: isActive ? AppColors.primary : const Color(0xFF6D625B),
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

                            const SizedBox(height: 12),
                            const Divider(height: 1, color: Color(0xFFF5EFE8)),
                            const SizedBox(height: 10),

                            // Bottom Actions Row
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      isActive ? 'Total Tagihan' : 'Total Biaya',
                                      style: const TextStyle(fontSize: 10, color: Color(0xFF8C827A), fontWeight: FontWeight.w600),
                                    ),
                                    const SizedBox(height: 1),
                                    Text(
                                      order.price,
                                      style: TextStyle(
                                        fontSize: 14.5,
                                        fontWeight: FontWeight.w800,
                                        color: isActive ? AppColors.primary : const Color(0xFF5C524C),
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    if (isActive && isUnpaid) ...[
                                      InkWell(
                                        onTap: () => _payBookingWithXendit(order),
                                        borderRadius: BorderRadius.circular(10),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFFFF1E8),
                                            borderRadius: BorderRadius.circular(10),
                                            border: Border.all(color: const Color(0xFFFFD9C7)),
                                          ),
                                          child: const Row(
                                            children: [
                                              Icon(Icons.payment, size: 13, color: AppColors.primary),
                                              SizedBox(width: 4),
                                              Text(
                                                'Bayar Xendit',
                                                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.primary),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                    ],

                                    if (isActive)
                                      InkWell(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) => TrackingScreen(
                                                orderCode: order.orderCode,
//
//
//
//
//
//
                                              ),
                                            ),
                                          );
                                        },
                                        borderRadius: BorderRadius.circular(10),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFFFF5EE),
                                            borderRadius: BorderRadius.circular(10),
                                            border: Border.all(color: const Color(0xFFFFD9C7)),
                                          ),
                                          child: const Row(
                                            children: [
                                              Text(
                                                'Detail & Lacak',
                                                style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800, color: AppColors.primary),
                                              ),
                                              SizedBox(width: 4),
                                              Icon(Icons.arrow_forward_ios_rounded, size: 11, color: AppColors.primary),
                                            ],
                                          ),
                                        ),
                                      )
                                    else
                                      InkWell(
                                        onTap: () => _showCompletedEvidenceModal(order),
                                        borderRadius: BorderRadius.circular(10),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFFAF8F5),
                                            borderRadius: BorderRadius.circular(10),
                                            border: Border.all(color: const Color(0xFFEAE1D5)),
                                          ),
                                          child: const Row(
                                            children: [
                                              Icon(Icons.photo_camera_outlined, size: 14, color: Color(0xFF5C524C)),
                                              SizedBox(width: 5),
                                              Text(
                                                'Bukti Foto Selesai',
                                                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF5C524C)),
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
                      );
                    }).toList(),
                  ),
                ],

                const SizedBox(height: 10),

                // Promotional CTA Section (Home Synced)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF7F2),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: const Color(0xFFFFE0D0)),
                  ),
                  child: Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFF1E8),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Text('📦', style: TextStyle(fontSize: 20)),
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Butuh simpan barang tambahan?',
                                  style: TextStyle(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF2E2018),
                                  ),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  'Amankan barang kosmu selama liburan tanpa pusing bayar sewa penuh.',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Color(0xFF7A6F68),
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
                        height: 42,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pushNamed(context, '/booking-step1');
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          icon: const Icon(Icons.add, size: 16, color: Colors.white),
                          label: const Text(
                            'Titip Barang Baru',
                            style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
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
        backgroundColor: Colors.white,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: const Color(0xFF8C827A),
        selectedFontSize: 11,
        unselectedFontSize: 11,
        elevation: 0,
        items: const [
          BottomNavigationBarItem(
            icon: ImageIcon(AssetImage('assets/images/icon_home.png')),
            activeIcon: ImageIcon(AssetImage('assets/images/icon_home_active.png')),
            label: 'Home',
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
