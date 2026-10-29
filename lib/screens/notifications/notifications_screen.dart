import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  String _selectedFilter = 'all'; // 'all', 'tracking', 'payment'

  final List<Map<String, dynamic>> _notifications = [
    {
      'id': 'notif-1',
      'type': 'payment',
      'title': 'Pembayaran Berhasil via Xendit',
      'message': 'Pembayaran tagihan penitipan Rp 105.000 via QRIS Instant (Xendit Gateway) telah berhasil diverifikasi otomatis.',
      'time': '10 menit lalu',
      'isRead': false,
      'refCode': 'XND-88291034',
      'icon': Icons.check_circle_outline,
      'iconColor': AppColors.success,
      'iconBg': AppColors.successSoft,
      'actionLabel': 'Lihat Invoice Xendit',
      'route': '/tracking',
    },
    {
      'id': 'notif-2',
      'type': 'tracking',
      'title': 'Barang Telah Tiba di Gudang Pauh',
      'message': 'Titipan #STC-1310-367 telah sampai dan disegel dengan barcode aman di Slot Rak A-04 oleh Inspektur Bambang.',
      'time': '1 jam lalu',
      'isRead': false,
      'refCode': '#STC-1310-367',
      'icon': Icons.warehouse_outlined,
      'iconColor': AppColors.primary,
      'iconBg': AppColors.primarySoft,
      'actionLabel': 'Pantau Live CCTV',
      'route': '/tracking',
    },
    {
      'id': 'notif-3',
      'type': 'tracking',
      'title': 'Kurir Sedang Menuju Kosanmu',
      'message': 'Driver Ahmad Dani sedang menuju ke Kos Melati Indah, Air Tawar Barat (Estimasi tiba: 15 menit). Siapkan barangmu ya!',
      'time': 'Hari ini, 09:30 WIB',
      'isRead': true,
      'refCode': 'SLOT-SIANG',
      'icon': Icons.local_shipping_outlined,
      'iconColor': AppColors.warning,
      'iconBg': AppColors.warningSoft,
      'actionLabel': 'Lacak Posisi Kurir',
      'route': '/tracking',
    },
    {
      'id': 'notif-4',
      'type': 'tracking',
      'title': 'Jadwal Penjemputan Terkonfirmasi',
      'message': 'Pemesanan penitipan #STC-1310-367 untuk 1 Box + 1 Koper telah dikonfirmasi untuk sesi penjemputan Siang.',
      'time': 'Kemarin, 14:15 WIB',
      'isRead': true,
      'refCode': '#STC-1310-367',
      'icon': Icons.calendar_month_outlined,
      'iconColor': AppColors.secondary,
      'iconBg': AppColors.surfaceContainerHigh,
      'actionLabel': 'Detail Pesanan',
      'route': '/orders',
    },
  ];

  void _markAllAsRead() {
    setState(() {
      for (var item in _notifications) {
        item['isRead'] = true;
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Semua notifikasi telah ditandai dibaca'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showSimulatedPushNotification() {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: const BoxDecoration(
                    color: AppColors.primarySoft,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.notifications_active, color: AppColors.primary, size: 30),
                ),
                const SizedBox(height: 14),
                const Text(
                  'Simulasi Push Notification Masuk',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Notifikasi real-time dari server backend saat status barang diubah oleh petugas gudang / driver:',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.bolt, size: 16, color: AppColors.warning),
                          SizedBox(width: 4),
                          Text('KosinAja Realtime Alert', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                        ],
                      ),
                      SizedBox(height: 6),
                      Text(
                        'Status Baru: "Barang Berhasil Disimpan di Gudang Pauh". Sensor suhu: 24.2°C.',
                        style: TextStyle(fontSize: 13, color: AppColors.text),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Tutup'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          Navigator.pushNamed(context, '/tracking');
                        },
                        child: const Text('Buka CCTV'),
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

  void _showInvoiceDialog(String refCode) {
    showModalBottomSheet(
      context: context,
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Detail Pembayaran Xendit',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.text),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.successSoft,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'LUNAS',
                        style: TextStyle(color: AppColors.success, fontWeight: FontWeight.bold, fontSize: 11),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                const Text(
                  'Invoice resmi transaksi pembayaran penitipan KosinAja',
                  style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 18),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    children: [
                      _buildInvoiceRow('Payment Gateway', 'Xendit (Invoice API)'),
                      const Divider(height: 16),
                      _buildInvoiceRow('ID Transaksi', refCode, isBold: true),
                      const Divider(height: 16),
                      _buildInvoiceRow('Metode Pembayaran', 'QRIS Instant (Semua Bank / e-Wallet)'),
                      const Divider(height: 16),
                      _buildInvoiceRow('Waktu Transaksi', '29 Okt 2026, 14:35:12 WIB'),
                      const Divider(height: 16),
                      _buildInvoiceRow('Total Dibayar', 'Rp 105.000', isBold: true, isHighlight: true),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('E-Receipt Xendit berhasil diunduh ke memori HP!')),
                      );
                    },
                    icon: const Icon(Icons.receipt_long, size: 18),
                    label: const Text('Download E-Receipt Resmi'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInvoiceRow(String label, String value, {bool isBold = false, bool isHighlight = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: TextStyle(
              fontSize: isHighlight ? 14 : 12,
              fontWeight: (isBold || isHighlight) ? FontWeight.bold : FontWeight.w500,
              color: isHighlight ? AppColors.primary : AppColors.text,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _notifications.where((n) {
      if (_selectedFilter == 'all') return true;
      return n['type'] == _selectedFilter;
    }).toList();

    final unreadCount = _notifications.where((n) => n['isRead'] == false).length;

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: const Text('Notifikasi & Status'),
        actions: [
          if (unreadCount > 0)
            TextButton(
              onPressed: _markAllAsRead,
              child: const Text('Tandai Dibaca', style: TextStyle(fontSize: 12)),
            ),
        ],
      ),
      body: Column(
        children: [
          // Filter Chips
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            color: AppColors.cardSurface,
            child: Row(
              children: [
                _buildFilterChip('all', 'Semua (${_notifications.length})'),
                const SizedBox(width: 8),
                _buildFilterChip('tracking', 'Status Titipan'),
                const SizedBox(width: 8),
                _buildFilterChip('payment', 'Transaksi Xendit'),
              ],
            ),
          ),

          // Simulation Banner for Demo
          Container(
            margin: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.primarySoft.withOpacity(0.4),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.primary.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.notifications_active_outlined, color: AppColors.primary, size: 20),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    'Fitur Notifikasi Aktif • Realtime Push Server',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primary),
                  ),
                ),
                GestureDetector(
                  onTap: _showSimulatedPushNotification,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'Tes Notif',
                      style: TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Notification List
          Expanded(
            child: filtered.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.notifications_off_outlined, size: 48, color: AppColors.textMuted),
                        SizedBox(height: 12),
                        Text('Belum ada notifikasi pada kategori ini.', style: TextStyle(color: AppColors.textSecondary)),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    physics: const BouncingScrollPhysics(),
                    itemCount: filtered.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final item = filtered[index];
                      final bool isRead = item['isRead'];

                      return InkWell(
                        onTap: () {
                          setState(() {
                            item['isRead'] = true;
                          });
                          if (item['type'] == 'payment') {
                            _showInvoiceDialog(item['refCode']);
                          } else {
                            Navigator.pushNamed(context, item['route']);
                          }
                        },
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: isRead ? AppColors.cardSurface : AppColors.cardSurface,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isRead ? AppColors.border : AppColors.primary.withOpacity(0.4),
                              width: isRead ? 1 : 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.03),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Icon Indicator
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: item['iconBg'],
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(item['icon'], color: item['iconColor'], size: 22),
                              ),
                              const SizedBox(width: 12),

                              // Content
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Flexible(
                                          child: Text(
                                            item['title'],
                                            style: TextStyle(
                                              fontWeight: isRead ? FontWeight.bold : FontWeight.w800,
                                              fontSize: 13,
                                              color: AppColors.text,
                                            ),
                                          ),
                                        ),
                                        if (!isRead)
                                          Container(
                                            width: 8,
                                            height: 8,
                                            decoration: const BoxDecoration(
                                              color: AppColors.primary,
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      item['message'],
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: AppColors.textSecondary,
                                        height: 1.35,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          item['time'],
                                          style: const TextStyle(
                                            fontSize: 11,
                                            color: AppColors.textMuted,
                                          ),
                                        ),
                                        Text(
                                          '${item['actionLabel']} >',
                                          style: const TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.primary,
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
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String value, String label) {
    final isSelected = _selectedFilter == value;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilter = value;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? AppColors.primary : AppColors.border),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected ? Colors.white : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
