import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/services/api_service.dart';
import '../../core/theme/app_colors.dart';
import '../../models/booking_model.dart';
import '../../core/services/booking_storage_service.dart';

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
  final String? orderCode;
  final BookingData? bookingData;

  const TrackingScreen({
    super.key,
    this.orderCode,
    this.bookingData,
  });

  @override
  State<TrackingScreen> createState() => _TrackingScreenState();
}

class _TrackingScreenState extends State<TrackingScreen> {
  final currencyFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

  String _currentOrderCode = 'KOS-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';
  BookingData? _booking;
  bool _showCctvLive = false;
  String _selectedExtend = '30d';
  int _additionalDays = 0;

  @override
  void initState() {
    super.initState();
    if (widget.orderCode != null && widget.orderCode!.isNotEmpty) {
      _currentOrderCode = widget.orderCode!;
    }
    _booking = widget.bookingData;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_booking == null) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is Map<String, dynamic>) {
        if (args['orderCode'] is String && (args['orderCode'] as String).isNotEmpty) {
          _currentOrderCode = args['orderCode'];
        }
        if (args['booking'] is BookingData) {
          _booking = args['booking'];
        }
      } else if (args is BookingData) {
        _booking = args;
      } else if (args is String && args.isNotEmpty) {
        _currentOrderCode = args;
      }
    }
    _loadOrderData();
  }

  void _loadOrderData() async {
    final order = await BookingStorageService.getOrderByCode(_currentOrderCode);
    if (order != null && mounted) {
      if (order['additionalDays'] is int && (order['additionalDays'] as int) > 0) {
        setState(() {
          _additionalDays = order['additionalDays'] as int;
        });
      }
    }
  }

  DateTime _calculateExpiryDate(DateTime start, int count, String type) {
    DateTime base;
    if (type == 'Mingguan') {
      base = start.add(Duration(days: count * 7));
    } else if (type == 'Harian') {
      base = start.add(Duration(days: count));
    } else {
      // Bulanan
      base = DateTime(start.year, start.month + count, start.day);
    }
    return base.add(Duration(days: _additionalDays));
  }

  void _copyOrderCode() {
    Clipboard.setData(ClipboardData(text: _currentOrderCode));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Nomor resi $_currentOrderCode berhasil disalin!'),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _openWhatsApp() async {
    final text = Uri.encodeComponent(
      'Halo CS KosinAja Padang, saya ingin menanyakan perkembangan barang dengan nomor resi #$_currentOrderCode.',
    );
    final url = Uri.parse('https://wa.me/6282169393475?text=$text');
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

  void _showResiModal() {
    final user = ApiService.currentUser;
    final userName = (user != null && user.nama.isNotEmpty) ? user.nama : 'Pelanggan KosinAja';
    final userPhone = (user != null && user.noWa.isNotEmpty) ? user.noWa : '082169393475';
    final itemsSummary = _booking != null && _booking!.items.isNotEmpty
        ? _booking!.items
            .where((i) => i.quantity > 0)
            .map((i) => '${i.quantity}x ${i.name}')
            .join(' • ')
        : 'Barang Standar Kos';

    final totalStr = _booking != null
        ? '${currencyFormat.format(_booking!.grandTotal)} (Terkonfirmasi)'
        : 'Rp 199.000 (Terkonfirmasi)';

    final startDate = _booking?.pickupDate ?? DateTime.now();
    final endDate = _calculateExpiryDate(
      startDate,
      _booking?.durationCount ?? 1,
      _booking?.durationType ?? 'Bulanan',
    );
    final periodStr =
        '${DateFormat('d MMM yyyy', 'id_ID').format(startDate)} – ${DateFormat('d MMM yyyy', 'id_ID').format(endDate)}';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SafeArea(
            top: false,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.88,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(top: 12, bottom: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFDDD2C6),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    child: Row(
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
                  ),
                  Flexible(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFAF7F2),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFEADBCC)),
                        ),
                        child: Column(
                          children: [
                            _buildResiRow('Nomor Resi', _currentOrderCode, isBold: true),
                            const Divider(height: 16, color: Color(0xFFEADBCC)),
                            _buildResiRow('Penyimpan', userName),
                            const SizedBox(height: 6),
                            _buildResiRow('Fasilitas Gudang', 'Hub Hotel Ibis Padang - Slot Aman'),
                            const SizedBox(height: 6),
                            _buildResiRow('Manifest Barang', itemsSummary),
                            const SizedBox(height: 6),
                            _buildResiRow('Total Biaya', totalStr),
                            const SizedBox(height: 6),
                            _buildResiRow(
                              'Metode Pembayaran',
                              _booking?.paymentMethod ?? 'QRIS Instant',
                            ),
                            const SizedBox(height: 6),
                            _buildResiRow('Masa Simpan', periodStr),
                            const SizedBox(height: 6),
                            _buildResiRow(
                              'Logistik',
                              '${_booking?.metodePickup == 'SELF_DROPOFF' ? 'Antar Mandiri' : 'Jemput Kurir'} / ${_booking?.metodeDelivery == 'SELF_PICKUP' ? 'Ambil di Hub' : 'Diantar Balik'}',
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 14, 20, 16),
                    child: SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          Navigator.pop(ctx);
                          await _handleSaveReceipt(
                            userName: userName,
                            userPhone: userPhone,
                            itemsSummary: itemsSummary,
                            periodStr: periodStr,
                            totalStr: totalStr,
                            logisticsStr:
                                '${_booking?.metodePickup == 'SELF_DROPOFF' ? 'Antar Mandiri' : 'Jemput Kurir'} / ${_booking?.metodeDelivery == 'SELF_PICKUP' ? 'Ambil di Hub' : 'Diantar Balik'}',
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                        ),
                        icon: const Icon(Icons.file_download_outlined, color: Colors.white, size: 20),
                        label: const Text(
                          'Simpan Bukti Resi',
                          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildResiRow(String key, String val, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(key, style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary)),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            val,
            textAlign: TextAlign.right,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isBold ? FontWeight.w800 : FontWeight.w600,
              color: isBold ? AppColors.primary : AppColors.text,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _handleSaveReceipt({
    required String userName,
    required String userPhone,
    required String itemsSummary,
    required String periodStr,
    required String totalStr,
    required String logisticsStr,
  }) async {
    final receiptText = BookingStorageService.formatReceiptShareText(
      orderCode: _currentOrderCode,
      userName: userName,
      userPhone: userPhone,
      warehouse: 'Hub Hotel Ibis Padang',
      itemsSummary: itemsSummary,
      periodStr: periodStr,
      totalCost: totalStr,
      paymentMethod: _booking?.paymentMethod ?? 'QRIS Instant',
      logistics: logisticsStr,
      status: 'Aktif Disimpan',
    );

    final success = await BookingStorageService.saveReceipt(
      orderCode: _currentOrderCode,
      receiptText: receiptText,
      receiptMeta: {
        'userName': userName,
        'userPhone': userPhone,
        'itemsSummary': itemsSummary,
        'periodStr': periodStr,
        'totalCost': totalStr,
        'paymentMethod': _booking?.paymentMethod ?? 'QRIS Instant',
        'logistics': logisticsStr,
        'status': 'Aktif Disimpan',
        'savedAt': DateTime.now().toIso8601String(),
      },
    );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Resi #$_currentOrderCode berhasil disimpan secara permanen di database!'),
          backgroundColor: AppColors.primary,
          behavior: SnackBarBehavior.floating,
        ),
      );

      _showReceiptSavedSuccessDialog(
        orderCode: _currentOrderCode,
        userName: userName,
        periodStr: periodStr,
        totalStr: totalStr,
        receiptText: receiptText,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gagal menyimpan resi.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showReceiptSavedSuccessDialog({
    required String orderCode,
    required String userName,
    required String periodStr,
    required String totalStr,
    required String receiptText,
  }) {
    showDialog(
      context: context,
      builder: (dlgCtx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          contentPadding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: const BoxDecoration(
                  color: Color(0xFFE8F5E9),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.save_alt_rounded,
                  color: Color(0xFF2E7D32),
                  size: 34,
                ),
              ),
              const SizedBox(height: 14),
              const Text(
                'Bukti Resi Berhasil Disimpan!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16.5, fontWeight: FontWeight.w800, color: Color(0xFF2E2018)),
              ),
              const SizedBox(height: 6),
              Text(
                'Resi #$orderCode telah disimpan secara permanen di database akun Anda dan memori perangkat.',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 12, color: Color(0xFF705545)),
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFAF7F2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFEADBCC)),
                ),
                child: Column(
                  children: [
                    _buildResiRow('Nomor Resi', orderCode, isBold: true),
                    const SizedBox(height: 4),
                    _buildResiRow('Penyimpan', userName),
                    const SizedBox(height: 4),
                    _buildResiRow('Masa Simpan', periodStr),
                    const SizedBox(height: 4),
                    _buildResiRow('Total Biaya', totalStr),
                    const Divider(height: 12, color: Color(0xFFEADBCC)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Status Penyimpanan', style: TextStyle(fontSize: 11, color: Color(0xFF705545))),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8F5E9),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'Tersimpan di Database',
                            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Color(0xFF2E7D32)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 44,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: receiptText));
                    Navigator.pop(dlgCtx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Teks format cetak resi berhasil disalin!'),
                        backgroundColor: AppColors.primary,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  ),
                  icon: const Icon(Icons.copy, size: 16, color: Colors.white),
                  label: const Text(
                    'Salin Format Cetak Resi',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                height: 44,
                child: OutlinedButton.icon(
                  onPressed: () async {
                    Navigator.pop(dlgCtx);
                    final url = Uri.parse('https://wa.me/?text=${Uri.encodeComponent(receiptText)}');
                    if (await canLaunchUrl(url)) {
                      await launchUrl(url, mode: LaunchMode.externalApplication);
                    }
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF2E7D32),
                    side: const BorderSide(color: Color(0xFFC8E6C9)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  ),
                  icon: const Icon(Icons.chat_bubble_outline, size: 16, color: Color(0xFF2E7D32)),
                  label: const Text(
                    'Bagikan Bukti ke WhatsApp',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
              const SizedBox(height: 4),
              TextButton(
                onPressed: () => Navigator.pop(dlgCtx),
                child: const Text('Tutup', style: TextStyle(color: Color(0xFF705545), fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showShareModal() {
    final user = ApiService.currentUser;
    final userName = (user != null && user.nama.isNotEmpty) ? user.nama : 'Pelanggan KosinAja';
    final userPhone = (user != null && user.noWa.isNotEmpty) ? user.noWa : '082169393475';

    final activeItems = _booking != null && _booking!.items.isNotEmpty
        ? _booking!.items.where((i) => i.quantity > 0).toList()
        : <BookingItem>[];
    final itemsSummary = activeItems.isNotEmpty
        ? activeItems.map((i) => '${i.quantity}x ${i.name}').join(', ')
        : 'Barang Titipan Mahasiswa';

    final startDate = _booking?.pickupDate ?? DateTime.now();
    final endDate = _calculateExpiryDate(
      startDate,
      _booking?.durationCount ?? 1,
      _booking?.durationType ?? 'Bulanan',
    );
    final periodStr =
        '${DateFormat('d MMM yyyy', 'id_ID').format(startDate)} – ${DateFormat('d MMM yyyy', 'id_ID').format(endDate)}';

    final totalStr = currencyFormat.format(_booking?.grandTotal ?? 199000);
    final logisticsStr =
        '${_booking?.metodePickup == 'SELF_DROPOFF' ? 'Antar Mandiri ke Hub' : 'Jemput Kurir'} / ${_booking?.metodeDelivery == 'SELF_PICKUP' ? 'Ambil Sendiri' : 'Diantar Balik'}';

    final shareText = BookingStorageService.formatReceiptShareText(
      orderCode: _currentOrderCode,
      userName: userName,
      userPhone: userPhone,
      warehouse: 'Hub Hotel Ibis Padang',
      itemsSummary: itemsSummary,
      periodStr: periodStr,
      totalCost: totalStr,
      paymentMethod: _booking?.paymentMethod ?? 'QRIS Instant',
      logistics: logisticsStr,
      status: 'Aktif Disimpan',
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFDDD2C6),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.share_outlined, color: AppColors.primary),
                          SizedBox(width: 8),
                          Text(
                            'Bagikan Resi Penitipan',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF2E2018),
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
                  const SizedBox(height: 6),
                  Text(
                    'Bagikan informasi resi pesanan #$_currentOrderCode ke WhatsApp atau salin teks resi resmi:',
                    style: const TextStyle(fontSize: 12, color: Color(0xFF705545)),
                  ),
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFAF7F2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFEADBCC)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Resi #$_currentOrderCode',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF2E2018),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE8F5E9),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                'Aktif Disimpan',
                                style: TextStyle(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF2E7D32),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '$itemsSummary • $periodStr',
                          style: const TextStyle(fontSize: 11.5, color: Color(0xFF705545)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        Navigator.pop(ctx);
                        final url = Uri.parse('https://wa.me/?text=${Uri.encodeComponent(shareText)}');
                        if (await canLaunchUrl(url)) {
                          await launchUrl(url, mode: LaunchMode.externalApplication);
                        } else {
                          Clipboard.setData(ClipboardData(text: shareText));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('WhatsApp tidak tersedia. Teks resi lengkap telah disalin ke clipboard!'),
                              backgroundColor: AppColors.primary,
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF25D366),
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                      ),
                      icon: const Icon(Icons.chat_bubble_outline, color: Colors.white, size: 20),
                      label: const Text(
                        'Bagikan Langsung ke WhatsApp',
                        style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5, color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    height: 46,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: shareText));
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Seluruh teks format resi #$_currentOrderCode berhasil disalin!'),
                            backgroundColor: AppColors.primary,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF2E2018),
                        side: const BorderSide(color: Color(0xFFEADBCC)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                      ),
                      icon: const Icon(Icons.copy, size: 18, color: AppColors.primary),
                      label: const Text(
                        'Salin Seluruh Rincian Resi',
                        style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    height: 40,
                    child: TextButton.icon(
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: 'https://www.kosinaja.id/track/$_currentOrderCode'));
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Tautan pelacakan online berhasil disalin!'),
                            backgroundColor: AppColors.primary,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                      icon: const Icon(Icons.link, size: 16, color: Color(0xFF705545)),
                      label: const Text(
                        'Salin Tautan Lacak (kosinaja.id)',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF705545)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showExtendModal() {
    final cat = _booking?.category ?? 'A';
    final isB = cat == 'B';

    // Opsi perpanjangan sesuai matriks harga resmi KosinAja (sama persis dengan aturan booking)
    final options = [
      {
        'id': '7d',
        'label': '+7 Hari (1 Minggu)',
        'price': currencyFormat.format(isB ? 95000 : 55000),
        'days': 7,
        'desc': 'Libur jeda perkuliahan singkat',
      },
      {
        'id': '14d',
        'label': '+14 Hari (2 Minggu)',
        'price': currencyFormat.format(isB ? 190000 : 110000),
        'days': 14,
        'desc': 'Perpanjangan 2 minggu',
      },
      {
        'id': '30d',
        'label': '+1 Bulan (30 Hari)',
        'price': currencyFormat.format(isB ? 299000 : 199000),
        'days': 30,
        'desc': 'Paling populer & hemat bulanan',
      },
      {
        'id': '60d',
        'label': '+2 Bulan (60 Hari)',
        'price': currencyFormat.format(isB ? 499000 : 379000),
        'days': 60,
        'desc': 'Liburan semester panjang',
      },
      {
        'id': '90d',
        'label': '+3 Bulan (1 Semester)',
        'price': currencyFormat.format(isB ? 699000 : 499000),
        'days': 90,
        'desc': 'Cuti kuliah / KKN luar kota',
      },
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            final selectedOpt = options.firstWhere(
              (o) => o['id'] == _selectedExtend,
              orElse: () => options[2],
            );

            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: SafeArea(
                top: false,
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.88,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          margin: const EdgeInsets.only(top: 12, bottom: 8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFDDD2C6),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Perpanjang Masa Penitipan',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.text,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Tarif Kategori $cat (${isB ? "Barang Besar/Elektronik" : "Barang Kecil/Sedang"})',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w700,
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
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Pilih tambahan durasi simpan untuk pesanan #$_currentOrderCode:',
                            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Flexible(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Column(
                            children: options.map((opt) {
                              final isSel = _selectedExtend == opt['id'];
                              return Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                child: InkWell(
                                  onTap: () {
                                    setModalState(() {
                                      _selectedExtend = opt['id'] as String;
                                    });
                                    setState(() {
                                      _selectedExtend = opt['id'] as String;
                                    });
                                  },
                                  borderRadius: BorderRadius.circular(12),
                                  child: Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: isSel
                                          ? const Color(0xFFFAF2EB)
                                          : Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: isSel ? AppColors.primary : const Color(0xFFEADBCC),
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
                                                opt['label'] as String,
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  fontWeight: isSel ? FontWeight.w700 : FontWeight.w600,
                                                  color: AppColors.text,
                                                ),
                                              ),
                                              Text(
                                                opt['desc'] as String,
                                                style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Text(
                                          opt['price'] as String,
                                          style: const TextStyle(
                                            fontSize: 12.5,
                                            fontWeight: FontWeight.w800,
                                            color: AppColors.primary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 10, 20, 16),
                        child: SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.pop(ctx);
                              _showExtendPaymentModal(selectedOpt: selectedOpt);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              elevation: 0,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Lanjut ke Pembayaran (${selectedOpt['price']})',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Icon(
                                  Icons.arrow_forward_ios_rounded,
                                  size: 14,
                                  color: Colors.white,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showExtendPaymentModal({required Map<String, dynamic> selectedOpt}) {
    final addDays = selectedOpt['days'] as int;
    final priceStr = selectedOpt['price'] as String;
    final labelStr = selectedOpt['label'] as String;

    final startDate = _booking?.pickupDate ?? DateTime.now();
    final durationCount = _booking?.durationCount ?? 1;
    final durationType = _booking?.durationType ?? 'Bulanan';
    final currentExpiry = _calculateExpiryDate(startDate, durationCount, durationType);
    final newExpiry = currentExpiry.add(Duration(days: addDays));

    String selectedPaymentMethod = 'QRIS';
    String selectedBank = 'BCA';
    bool isProcessing = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (paymentCtx) {
        return StatefulBuilder(
          builder: (paymentCtx, setPaymentState) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: SafeArea(
                top: false,
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.90,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          margin: const EdgeInsets.only(top: 12, bottom: 8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFDDD2C6),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Pembayaran Perpanjangan',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF2E2018),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Nomor Resi: #$_currentOrderCode',
                                  style: const TextStyle(
                                    fontSize: 11.5,
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                            IconButton(
                              icon: const Icon(Icons.close),
                              onPressed: () => Navigator.pop(paymentCtx),
                            ),
                          ],
                        ),
                      ),
                      Flexible(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFAF7F2),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(color: const Color(0xFFEADBCC)),
                                ),
                                child: Column(
                                  children: [
                                    _buildResiRow('Durasi Tambahan', labelStr, isBold: true),
                                    const SizedBox(height: 6),
                                    _buildResiRow(
                                      'Masa Simpan Semula',
                                      DateFormat('d MMM yyyy', 'id_ID').format(currentExpiry),
                                    ),
                                    const SizedBox(height: 6),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Text(
                                          'Batas Simpan Baru',
                                          style: TextStyle(fontSize: 11.5, color: Color(0xFF705545)),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFE8F5E9),
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: Text(
                                            DateFormat('d MMMM yyyy', 'id_ID').format(newExpiry),
                                            style: const TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w800,
                                              color: Color(0xFF2E7D32),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const Divider(height: 18, color: Color(0xFFEADBCC)),
                                    _buildResiRow('Biaya Perpanjangan', priceStr),
                                    const SizedBox(height: 6),
                                    _buildResiRow('Biaya Administrasi & Layanan', 'Gratis (Rp 0)'),
                                    const Divider(height: 18, color: Color(0xFFEADBCC)),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Text(
                                          'Total Pembayaran',
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w800,
                                            color: Color(0xFF2E2018),
                                          ),
                                        ),
                                        Text(
                                          priceStr,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w900,
                                            color: AppColors.primary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'Pilih Metode Pembayaran',
                                style: TextStyle(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF2E2018),
                                ),
                              ),
                              const SizedBox(height: 8),
                              _buildPaymentMethodTile(
                                id: 'QRIS',
                                title: 'QRIS Instan (Semua Bank / E-Wallet)',
                                subtitle: 'BCA, Mandiri, BRI, BNI, GoPay, OVO, Dana, ShopeePay',
                                icon: Icons.qr_code_scanner,
                                isSelected: selectedPaymentMethod == 'QRIS',
                                onTap: () => setPaymentState(() => selectedPaymentMethod = 'QRIS'),
                              ),
                              if (selectedPaymentMethod == 'QRIS') ...[
                                Container(
                                  margin: const EdgeInsets.only(top: 4, bottom: 10),
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: const Color(0xFFEADBCC)),
                                  ),
                                  child: Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          const Icon(Icons.qr_code_2, size: 50, color: Color(0xFF2E2018)),
                                          const SizedBox(width: 12),
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              const Text(
                                                'QRIS Standar Nasional (NMID)',
                                                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
                                              ),
                                              Text(
                                                'Merchant: KosinAja Hub Padang',
                                                style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                                              ),
                                              const Text(
                                                'Biaya Admin: Rp 0',
                                                style: TextStyle(
                                                  fontSize: 10.5,
                                                  color: Color(0xFF2E7D32),
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      const Text(
                                        'Klik "Bayar Sekarang" di bawah untuk memverifikasi pembayaran instan perpanjangan.',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(fontSize: 10.5, color: Color(0xFF705545)),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                              _buildPaymentMethodTile(
                                id: 'VA',
                                title: 'Virtual Account (Transfer Bank)',
                                subtitle: 'Transfer otomatis via ATM atau Mobile Banking',
                                icon: Icons.account_balance,
                                isSelected: selectedPaymentMethod == 'VA',
                                onTap: () => setPaymentState(() => selectedPaymentMethod = 'VA'),
                              ),
                              if (selectedPaymentMethod == 'VA') ...[
                                Container(
                                  margin: const EdgeInsets.only(top: 4, bottom: 10),
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFAF7F2),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: const Color(0xFFEADBCC)),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: ['BCA', 'Mandiri', 'BRI', 'BNI'].map((bank) {
                                          final isB = selectedBank == bank;
                                          return InkWell(
                                            onTap: () => setPaymentState(() => selectedBank = bank),
                                            child: Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                              decoration: BoxDecoration(
                                                color: isB ? AppColors.primary : Colors.white,
                                                borderRadius: BorderRadius.circular(8),
                                                border: Border.all(
                                                  color: isB ? AppColors.primary : const Color(0xFFEADBCC),
                                                ),
                                              ),
                                              child: Text(
                                                bank,
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w800,
                                                  color: isB ? Colors.white : const Color(0xFF2E2018),
                                                ),
                                              ),
                                            ),
                                          );
                                        }).toList(),
                                      ),
                                      const SizedBox(height: 12),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Nomor VA $selectedBank KosinAja',
                                                style: const TextStyle(fontSize: 11, color: Color(0xFF705545)),
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                '88019${_currentOrderCode.replaceAll(RegExp(r'[^0-9]'), '').padRight(8, '0')}',
                                                style: const TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w800,
                                                  color: Color(0xFF2E2018),
                                                  letterSpacing: 1.1,
                                                ),
                                              ),
                                            ],
                                          ),
                                          ElevatedButton(
                                            onPressed: () {
                                              Clipboard.setData(ClipboardData(
                                                text:
                                                    '88019${_currentOrderCode.replaceAll(RegExp(r'[^0-9]'), '').padRight(8, '0')}',
                                              ));
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                const SnackBar(
                                                  content: Text('Nomor VA berhasil disalin!'),
                                                  duration: Duration(seconds: 2),
                                                ),
                                              );
                                            },
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: const Color(0xFFFAF2EB),
                                              foregroundColor: AppColors.primary,
                                              elevation: 0,
                                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(8),
                                                side: const BorderSide(color: Color(0xFFEADBCC)),
                                              ),
                                            ),
                                            child: const Text('Salin',
                                                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                              _buildPaymentMethodTile(
                                id: 'WA',
                                title: 'Transfer Manual & Konfirmasi WhatsApp',
                                subtitle: 'Kirim bukti pembayaran langsung ke Admin Keuangan',
                                icon: Icons.chat_bubble_outline,
                                isSelected: selectedPaymentMethod == 'WA',
                                onTap: () => setPaymentState(() => selectedPaymentMethod = 'WA'),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 10, 20, 16),
                        child: SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton(
                            onPressed: isProcessing
                                ? null
                                : () async {
                                    if (selectedPaymentMethod == 'WA') {
                                      Navigator.pop(paymentCtx);
                                      final text = Uri.encodeComponent(
                                        'Halo Admin KosinAja, saya ingin membayar perpanjangan masa simpan pesanan #$_currentOrderCode sebesar $priceStr untuk $labelStr.',
                                      );
                                      final url = Uri.parse('https://wa.me/6282169393475?text=$text');
                                      if (await canLaunchUrl(url)) {
                                        await launchUrl(url, mode: LaunchMode.externalApplication);
                                      }
                                      return;
                                    }

                                    setPaymentState(() {
                                      isProcessing = true;
                                    });

                                    await Future.delayed(const Duration(milliseconds: 1000));

                                    if (!mounted) return;

                                    setState(() {
                                      _additionalDays += addDays;
                                    });

                                    await BookingStorageService.updateOrderExtension(
                                      orderCode: _currentOrderCode,
                                      additionalDays: addDays,
                                      newExpiryDateStr: DateFormat('d MMMM yyyy', 'id_ID').format(newExpiry),
                                      priceStr: priceStr,
                                      paymentMethod: selectedPaymentMethod == 'QRIS'
                                          ? 'QRIS Instan'
                                          : 'Virtual Account $selectedBank',
                                    );

                                    Navigator.pop(paymentCtx);

                                    _showPaymentSuccessDialog(
                                      orderCode: _currentOrderCode,
                                      labelStr: labelStr,
                                      priceStr: priceStr,
                                      newExpiryDate: newExpiry,
                                      paymentMethod: selectedPaymentMethod == 'QRIS'
                                          ? 'QRIS Instan'
                                          : 'Virtual Account $selectedBank',
                                    );
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              elevation: 0,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                            ),
                            child: isProcessing
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.2,
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                    ),
                                  )
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        selectedPaymentMethod == 'WA'
                                            ? 'Hubungi Admin CS ($priceStr)'
                                            : 'Bayar Sekarang ($priceStr)',
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w800,
                                          color: Colors.white,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      const Icon(
                                        Icons.arrow_forward_ios_rounded,
                                        size: 14,
                                        color: Colors.white,
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildPaymentMethodTile({
    required String id,
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFFAF2EB) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? AppColors.primary : const Color(0xFFEADBCC),
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
                color: isSelected ? AppColors.primary : AppColors.textMuted,
                size: 20,
              ),
              const SizedBox(width: 12),
              Icon(icon, color: isSelected ? AppColors.primary : const Color(0xFF705545), size: 22),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                        color: const Color(0xFF2E2018),
                      ),
                    ),
                    Text(
                      subtitle,
                      style: const TextStyle(fontSize: 11, color: Color(0xFF705545)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showPaymentSuccessDialog({
    required String orderCode,
    required String labelStr,
    required String priceStr,
    required DateTime newExpiryDate,
    required String paymentMethod,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dlgCtx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          contentPadding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: const BoxDecoration(
                  color: Color(0xFFE8F5E9),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle_rounded,
                  color: Color(0xFF2E7D32),
                  size: 44,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Pembayaran Perpanjangan Berhasil!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF2E2018),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Perpanjangan masa simpan $labelStr telah lunas dan diverifikasi.',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 12, color: Color(0xFF705545)),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFAF7F2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFEADBCC)),
                ),
                child: Column(
                  children: [
                    _buildResiRow('Nomor Resi', orderCode, isBold: true),
                    const SizedBox(height: 6),
                    _buildResiRow('Metode Bayar', paymentMethod),
                    const SizedBox(height: 6),
                    _buildResiRow('Total Dibayar', priceStr, isBold: true),
                    const Divider(height: 14, color: Color(0xFFEADBCC)),
                    _buildResiRow(
                      'Batas Simpan Baru',
                      DateFormat('d MMMM yyyy', 'id_ID').format(newExpiryDate),
                      isBold: true,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 46,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(dlgCtx);
                    _showResiModal();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.receipt_long, size: 18, color: Colors.white),
                      SizedBox(width: 8),
                      Text(
                        'Lihat Resi Diperbarui',
                        style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w800, color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                height: 40,
                child: TextButton(
                  onPressed: () => Navigator.pop(dlgCtx),
                  child: const Text(
                    'Tutup & Kembali ke Pelacakan',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF705545),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = ApiService.currentUser;
    final userName = (user != null && user.nama.isNotEmpty) ? user.nama : 'Pelanggan KosinAja';
    final userPhone = (user != null && user.noWa.isNotEmpty) ? user.noWa : '082169393475';

    final activeItems = _booking != null && _booking!.items.isNotEmpty
        ? _booking!.items.where((i) => i.quantity > 0).toList()
        : <BookingItem>[];

    final startDate = _booking?.pickupDate ?? DateTime.now();
    final durationCount = _booking?.durationCount ?? 1;
    final durationType = _booking?.durationType ?? 'Bulanan';
    final endDate = _calculateExpiryDate(startDate, durationCount, durationType);
    final daysRemaining = endDate.difference(DateTime.now()).inDays.clamp(1, 365);

    final isCourierPickup = _booking?.metodePickup != 'SELF_DROPOFF';
    final isCourierDelivery = _booking?.metodeDelivery != 'SELF_PICKUP';

    final formattedStartDate = DateFormat('d MMM yyyy', 'id_ID').format(startDate);
    final formattedEndDate = DateFormat('d MMM yyyy', 'id_ID').format(endDate);
    final sessionTime = _booking?.pickupSession ?? 'Pagi (08:30 - 11:30 WIB)';

    return Scaffold(
      backgroundColor: const Color(0xFFFAF7F2),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFAF7F2),
        elevation: 0,
        title: const Text(
          'Detail Penitipan',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: Color(0xFF2E2018),
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20, color: Color(0xFF2E2018)),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined, color: Color(0xFF2E2018)),
            tooltip: 'Bagikan Resi',
            onPressed: _showShareModal,
          ),
          IconButton(
            icon: const Icon(Icons.receipt_long_outlined, color: Color(0xFF2E2018)),
            tooltip: 'Resi Digital',
            onPressed: _showResiModal,
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Hub Context Sub-bar
              Row(
                children: [
                  const Icon(Icons.warehouse_outlined, color: AppColors.primary, size: 18),
                  const SizedBox(width: 6),
                  const Text(
                    'Hub Hotel Ibis Padang • Pusat Operasional',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF705545),
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F5E9),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFC8E6C9)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.circle, color: Color(0xFF2E7D32), size: 7),
                        const SizedBox(width: 4),
                        Text(
                          isCourierPickup ? 'Menunggu Penjemputan' : 'Menunggu Serah Terima',
                          style: const TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF2E7D32),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // 2. Overview Registration Card (Data Riil)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFEADBCC)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.02),
                      blurRadius: 6,
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
                              'Nomor Resi / Kode Booking',
                              style: TextStyle(fontSize: 11, color: Color(0xFF705545)),
                            ),
                            const SizedBox(height: 2),
                            Row(
                              children: [
                                Text(
                                  _currentOrderCode,
                                  style: const TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF2E2018),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                InkWell(
                                  onTap: _copyOrderCode,
                                  borderRadius: BorderRadius.circular(8),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFAF2EB),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: const Color(0xFFEADBCC)),
                                    ),
                                    child: const Row(
                                      children: [
                                        Icon(Icons.copy, size: 11, color: AppColors.primary),
                                        SizedBox(width: 4),
                                        Text(
                                          'Salin',
                                          style: TextStyle(
                                            fontSize: 10.5,
                                            fontWeight: FontWeight.w800,
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
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFAF2EB),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFEADBCC)),
                          ),
                          child: Text(
                            'Kategori ${_booking?.category ?? 'A'}',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 22, color: Color(0xFFEADBCC)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.event_repeat, color: AppColors.primary, size: 18),
                            const SizedBox(width: 8),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Masa Penitipan Barang',
                                  style: TextStyle(fontSize: 11, color: Color(0xFF705545)),
                                ),
                                Text(
                                  '$formattedStartDate – $formattedEndDate',
                                  style: const TextStyle(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF2E2018),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF3ECE4),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '$durationCount $durationType (~$daysRemaining Hari)',
                            style: const TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF985322),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // 3. Rincian Pemesan & Lokasi (Data Riil Kosan)
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFEADBCC)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Informasi Pengguna & Penjemputan',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF2E2018)),
                    ),
                    const SizedBox(height: 10),
                    _buildInfoRow(
                      Icons.person_outline,
                      'Penyimpan',
                      '$userName • $userPhone',
                    ),
                    const SizedBox(height: 8),
                    _buildInfoRow(
                      Icons.location_on_outlined,
                      'Kawasan Kos',
                      _booking?.lokasiNama.isNotEmpty == true
                          ? _booking!.lokasiNama
                          : 'Padang Barat / Pusat Kota',
                    ),
                    if (_booking?.kosAddress.isNotEmpty == true) ...[
                      const SizedBox(height: 8),
                      _buildInfoRow(
                        Icons.home_outlined,
                        'Alamat Detail',
                        _booking!.kosAddress +
                            (_booking!.kosNote.isNotEmpty ? ' (Patokan: ${_booking!.kosNote})' : ''),
                      ),
                    ],
                    const SizedBox(height: 8),
                    _buildInfoRow(
                      Icons.schedule_outlined,
                      'Jadwal Penjemputan',
                      '$sessionTime, $formattedStartDate',
                    ),
                    const SizedBox(height: 8),
                    _buildInfoRow(
                      Icons.local_shipping_outlined,
                      'Metode Logistik',
                      '${isCourierPickup ? "Jemput ke Kos" : "Antar Mandiri ke Hub"} (Awal) ➔ ${isCourierDelivery ? "Diantar ke Kos" : "Ambil di Hub"} (Balik)',
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // 4. Manifest Barang yang Diinputkan
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Manifest Barang Titipan',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF2E2018),
                    ),
                  ),
                  Text(
                    '${activeItems.length} Jenis Barang',
                    style: const TextStyle(fontSize: 11, color: Color(0xFF705545), fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              if (activeItems.isNotEmpty)
                Column(
                  children: activeItems.asMap().entries.map((entry) {
                    final idx = entry.key;
                    final item = entry.value;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFEADBCC)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: const Color(0xFFFAF2EB),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              item.type == ItemType.besar ? '🛋️' : '📦',
                              style: const TextStyle(fontSize: 18),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${item.quantity}x ${item.name}',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF2E2018),
                                  ),
                                ),
                                Text(
                                  'Tag: #$_currentOrderCode-${idx + 1} • ${item.type == ItemType.besar ? "Besar/Elektronik" : "Kecil/Sedang"}',
                                  style: const TextStyle(fontSize: 10.5, color: Color(0xFF705545)),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE8F5E9),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'Terdaftar',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF2E7D32),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                )
              else
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFEADBCC)),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.inventory_2_outlined, color: AppColors.primary),
                      SizedBox(width: 10),
                      Text('1x Box Standar Titipan Mahasiswa', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),

              const SizedBox(height: 18),

              // 5. Vertical Timeline Pelacakan Proses
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Pelacakan Proses Penitipan',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF2E2018),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFAF2EB),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFEADBCC)),
                    ),
                    child: const Text(
                      'Realtime Padang',
                      style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: AppColors.primary),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFEADBCC)),
                ),
                child: Column(
                  children: [
                    _buildTimelineStep(
                      title: 'Pesanan Dikonfirmasi',
                      time: formattedStartDate,
                      desc: 'Formulir data penitipan terverifikasi otomatis oleh sistem.',
                      isDone: true,
                    ),
                    _buildTimelineStep(
                      title: 'Pembayaran Terverifikasi',
                      time: 'Lunas',
                      desc: 'Tercatat melalui ${_booking?.paymentMethod ?? "QRIS"} (${currencyFormat.format(_booking?.grandTotal ?? 199000)}).',
                      isDone: true,
                    ),
                    _buildTimelineStep(
                      title: isCourierPickup ? 'Jadwal Penjemputan Kurir' : 'Jadwal Antar ke Hub',
                      time: sessionTime.split(' ')[0],
                      desc: isCourierPickup
                          ? 'Kurir dijadwalkan menjemput ke ${_booking?.lokasiNama ?? "kosan"}.'
                          : 'Barang diantar langsung ke Hub Gudang Hotel Ibis Padang.',
                      isDone: true,
                    ),
                    _buildActiveTimelineStep(
                      hubName: 'Hub Hotel Ibis Padang',
                      scheduleText: '$formattedStartDate – $formattedEndDate',
                    ),
                    _buildTimelineStep(
                      title: isCourierDelivery ? 'Pengantaran Kembali ke Kos' : 'Pengambilan Mandiri di Hub',
                      time: formattedEndDate,
                      desc: isCourierDelivery
                          ? 'Barang diantar kembali ke kosan saat semester baru dimulai.'
                          : 'Barang diambil langsung oleh pemilik di Hub Gudang.',
                      isDone: false,
                      isLast: true,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // 6. Action Button (Hubungi CS WhatsApp dengan resi riil)
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: _openWhatsApp,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF25D366),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  icon: const Icon(Icons.chat_bubble_rounded, size: 18),
                  label: const Text(
                    'Hubungi Admin CS (WhatsApp)',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5),
                  ),
                ),
              ),

              const SizedBox(height: 10),

              SizedBox(
                width: double.infinity,
                height: 46,
                child: OutlinedButton.icon(
                  onPressed: _showExtendModal,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF2E2018),
                    side: const BorderSide(color: Color(0xFFEADBCC)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: const Icon(Icons.more_time, color: AppColors.primary, size: 18),
                  label: const Text(
                    'Perpanjang Masa Penitipan',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                  ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String val) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: AppColors.primary),
        const SizedBox(width: 8),
        Text('$label: ', style: const TextStyle(fontSize: 11.5, color: Color(0xFF705545))),
        Expanded(
          child: Text(
            val,
            style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: Color(0xFF2E2018)),
          ),
        ),
      ],
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
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: isDone ? const Color(0xFFE8F5E9) : const Color(0xFFF3ECE4),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isDone ? Icons.check : Icons.schedule,
                  size: 13,
                  color: isDone ? const Color(0xFF2E7D32) : const Color(0xFF705545),
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: isDone ? const Color(0xFF2E7D32) : const Color(0xFFEADBCC),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: isDone ? FontWeight.w700 : FontWeight.w500,
                          color: isDone ? const Color(0xFF2E2018) : const Color(0xFF705545),
                        ),
                      ),
                      Text(
                        time,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF705545),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    desc,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF705545),
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

  Widget _buildActiveTimelineStep({
    required String hubName,
    required String scheduleText,
  }) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 20,
                height: 20,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.warehouse,
                  size: 12,
                  color: Colors.white,
                ),
              ),
              Expanded(
                child: Container(
                  width: 2,
                  color: const Color(0xFFEADBCC),
                ),
              ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 18),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFAF2EB),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFEADBCC)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Penyimpanan di Gudang',
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'Siap Masuk',
                            style: TextStyle(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$hubName • $scheduleText',
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF2E2018)),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'Monitoring 24/7 dengan garansi perlindungan barang hingga Rp10.000.000.',
                      style: TextStyle(fontSize: 10.5, color: Color(0xFF705545)),
                    ),
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
