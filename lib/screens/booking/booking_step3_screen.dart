import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/services/api_service.dart';
import '../../core/theme/app_colors.dart';
import '../../models/booking_model.dart';
import '../../widgets/xendit_payment_modal.dart';

class BookingStep3Screen extends StatefulWidget {
  final BookingData? bookingData;
  const BookingStep3Screen({super.key, this.bookingData});

  @override
  State<BookingStep3Screen> createState() => _BookingStep3ScreenState();
}

class _BookingStep3ScreenState extends State<BookingStep3Screen> {
  late BookingData _booking;
  final currencyFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
  String _selectedPayment = 'QRIS';
  bool _isProcessing = false;

  String _orderCode = 'STC-1310-367';

  @override
  void initState() {
    super.initState();
    _booking = widget.bookingData ?? BookingData();
  }

  void _showSuccessModal({bool isCod = false}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: const BoxDecoration(
                    color: AppColors.successSoft,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_circle,
                    color: AppColors.success,
                    size: 40,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  isCod ? 'Pesanan Terkonfirmasi!' : 'Pembayaran Terverifikasi!',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.text,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  isCod
                      ? 'Pesanan penitipan telah dibuat. Silakan siapkan uang tunai sesuai tagihan untuk kurir saat penjemputan barang.'
                      : 'Pembayaran via Xendit telah berhasil diterima. Kurir armada Padang siap menjemput barang sesuai jadwal.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Nomor Resi:',
                            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                          ),
                          Text(
                            _orderCode,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Metode Pembayaran:',
                            style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                          ),
                          Text(
                            isCod ? 'Tunai (COD saat Penjemputan)' : 'Xendit Gateway (LUNAS)',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: isCod ? AppColors.primary : const Color(0xFF2E7D52),
                            ),
                          ),
                        ],
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
                      Navigator.pop(ctx);
                      Navigator.pushNamed(context, '/tracking');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                    ),
                    child: const Text('Lacak Status Penitipan'),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: TextButton(
                    onPressed: () {
                      Navigator.pop(ctx);
                      Navigator.pushNamedAndRemoveUntil(context, '/home', (r) => false);
                    },
                    child: const Text(
                      'Kembali ke Beranda',
                      style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Menampilkan Modal Pesanan Berhasil Dibuat saat Belum Selesai Bayar
  void _showPendingPaymentModal({
    required String bookingId,
    required String invoiceUrl,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF3CD),
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFFFFEEBA)),
                  ),
                  child: const Icon(
                    Icons.access_time_filled,
                    color: Color(0xFF856404),
                    size: 36,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Pesanan Penitipan Dibuat!',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.text,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Status saat ini: Menunggu Pembayaran. Anda dapat melanjutkan pembayaran Xendit kapan saja melalui menu Riwayat.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Nomor Resi:',
                            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                          ),
                          Text(
                            _orderCode,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Total Tagihan:',
                            style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                          ),
                          Text(
                            currencyFormat.format(_booking.grandTotal),
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: AppColors.text,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      Navigator.pop(ctx);
                      final isPaid = await XenditPaymentModal.show(
                        context: context,
                        bookingId: bookingId,
                        kodeBooking: _orderCode,
                        invoiceUrl: invoiceUrl,
                        totalHarga: _booking.grandTotal,
                      );
                      if (isPaid == true) {
                        _showSuccessModal(isCod: false);
                      } else {
                        _showPendingPaymentModal(bookingId: bookingId, invoiceUrl: invoiceUrl);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0052CC),
                      foregroundColor: Colors.white,
                    ),
                    icon: const Icon(Icons.payment, size: 18),
                    label: const Text('Buka Pop-up Pembayaran'),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pop(ctx);
                      Navigator.pushNamedAndRemoveUntil(context, '/orders', (r) => false);
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(color: AppColors.primary),
                    ),
                    child: const Text('Lihat di Menu Riwayat'),
                  ),
                ),
                const SizedBox(height: 4),
                TextButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    Navigator.pushNamedAndRemoveUntil(context, '/home', (r) => false);
                  },
                  child: const Text(
                    'Kembali ke Beranda',
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _handlePay() async {
    setState(() {
      _isProcessing = true;
    });

    final activeItems = _booking.items
        .where((i) => i.quantity > 0)
        .map((i) => {
              'nama': i.name,
              'jumlah': i.quantity,
            })
        .toList();

    final user = ApiService.currentUser;
    final payload = {
      if (user != null && user.id.isNotEmpty) 'userId': user.id,
      'nama': user?.nama ?? 'Mahasiswa KosinAja',
      'noWa': (user != null && user.noWa.isNotEmpty) ? user.noWa : '081234567890',
      'alamat': _booking.kosAddress,
      'lokasiPickup': _booking.kosAddress,
      'tanggalPickup': _booking.pickupDate.toIso8601String(),
      'items': activeItems.isNotEmpty
          ? activeItems
          : [
              {'nama': 'Dus Perlengkapan Kos', 'jumlah': 1}
            ],
      'durasiBulan': _booking.durationCount,
      'tipeDurasi': _booking.durationType == 'Bulanan'
          ? 'BULAN'
          : (_booking.durationType == 'Mingguan' ? 'MINGGU' : 'HARI'),
      'durasiNilai': _booking.durationCount,
      'metodePickup': 'PICKUP',
      'metodeDelivery': 'DELIVERY',
      'metodePembayaran': _selectedPayment,
      'latitude': -0.9294,
      'longitude': 100.3632,
    };

    final result = await ApiService.createBooking(payload);

    if (!mounted) return;

    if (result['success'] != true) {
      setState(() => _isProcessing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['error'] ?? 'Gagal membuat booking penitipan.'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final bookingData = result['booking'];
    final bookingId = bookingData != null ? bookingData['id'] : null;

    if (bookingData != null && bookingData['kodeBooking'] != null) {
      setState(() {
        _orderCode = bookingData['kodeBooking'];
      });
    }

    // Jika metode pembayaran COD (Tunai saat Kurir Tiba)
    if (_selectedPayment == 'COD' || bookingId == null) {
      setState(() => _isProcessing = false);
      _showSuccessModal(isCod: true);
      return;
    }

    // Jika Online (QRIS atau Virtual Account Xendit)
    final invoiceRes = await ApiService.createXenditInvoice(bookingId);

    if (!mounted) return;
    setState(() => _isProcessing = false);

    final invoiceUrl = invoiceRes['invoiceUrl'] as String?;

    if (invoiceRes['success'] == true && invoiceUrl != null && invoiceUrl.isNotEmpty) {
      // Tampilkan Pop-up Pembayaran In-App Xendit (WebView modal tanpa keluar aplikasi)
      final isPaid = await XenditPaymentModal.show(
        context: context,
        bookingId: bookingId,
        kodeBooking: _orderCode,
        invoiceUrl: invoiceUrl,
        totalHarga: _booking.grandTotal,
      );

      if (!mounted) return;

      if (isPaid == true) {
        _showSuccessModal(isCod: false);
      } else {
        _showPendingPaymentModal(bookingId: bookingId, invoiceUrl: invoiceUrl);
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            invoiceRes['error'] ?? 'Booking dibuat, silakan selesaikan pembayaran di menu Riwayat.',
          ),
          backgroundColor: AppColors.warning,
          behavior: SnackBarBehavior.floating,
        ),
      );
      _showSuccessModal(isCod: false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final activeItems = _booking.items.where((i) => i.quantity > 0).toList();
    final pickupDateStr = DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(_booking.pickupDate);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Ringkasan & Bayar'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Stepper Progress Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              color: AppColors.surface,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Langkah 3 dari 3: Konfirmasi & Bayar',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.primarySoft,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          '100%',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: Container(height: 6, color: AppColors.primary),
                  ),
                ],
              ),
            ),

            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Countdown Banner
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.primarySoft.withOpacity(0.4),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.timer_outlined, color: AppColors.primary, size: 20),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Selesaikan pemesanan sebelum kuota pallet Hub Pauh penuh hari ini.',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primaryDark,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Rincian Manifest Barang Card
                    const Text(
                      'Rincian Manifest Barang',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.text,
                      ),
                    ),
                    const SizedBox(height: 10),

                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.cardSurface,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ...activeItems.map((item) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 6,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppColors.primarySoft,
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          '${item.quantity}x',
                                          style: const TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w800,
                                            color: AppColors.primary,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        item.name,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.text,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Text(
                                    currencyFormat.format(item.monthlyPrice * item.quantity),
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.text,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                          const Divider(height: 16, color: AppColors.border),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Durasi Penitipan',
                                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                              ),
                              Text(
                                '${_booking.durationCount} ${_booking.durationType}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Jadwal Penjemputan',
                                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                              ),
                              Text(
                                _booking.pickupSession.split(' ')[0],
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.text,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            pickupDateStr,
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.textMuted,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Alamat: ${_booking.kosAddress}',
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Metode Pembayaran
                    const Text(
                      'Pilih Metode Pembayaran',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.text,
                      ),
                    ),
                    const SizedBox(height: 10),

                    // 1. QRIS
                    _buildPaymentOption(
                      id: 'QRIS',
                      title: 'QRIS Instant (Xendit Gateway)',
                      subtitle: 'BSI, Bank Nagari, Mandiri, BCA, GoPay, OVO • Verifikasi Otomatis',
                      icon: Icons.qr_code_2,
                      isRecommended: true,
                    ),

                    const SizedBox(height: 10),

                    // 2. Virtual Account
                    _buildPaymentOption(
                      id: 'VA',
                      title: 'Virtual Account Bank (Xendit)',
                      subtitle: 'Bank Nagari, Mandiri, BRI, BCA, BNI',
                      icon: Icons.account_balance_outlined,
                      isRecommended: false,
                    ),

                    const SizedBox(height: 10),

                    // 3. COD
                    _buildPaymentOption(
                      id: 'COD',
                      title: 'Bayar Tunai saat Kurir Tiba',
                      subtitle: 'Bayar langsung ke kurir KosinAja armada Padang',
                      icon: Icons.payments_outlined,
                      isRecommended: false,
                    ),

                    const SizedBox(height: 24),

                    // Rincian Biaya
                    const Text(
                      'Rincian Biaya',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.text,
                      ),
                    ),
                    const SizedBox(height: 10),

                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.cardSurface,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Column(
                        children: [
                          _buildCostRow(
                            'Sewa Penitipan Barang',
                            currencyFormat.format(_booking.storageSubtotal),
                          ),
                          const SizedBox(height: 8),
                          _buildCostRow(
                            'Ongkos Antar-Jemput Kos',
                            currencyFormat.format(_booking.deliveryFee),
                          ),
                          const SizedBox(height: 8),
                          _buildCostRow(
                            'Asuransi Proteksi Rp 10 Juta',
                            'GRATIS',
                            isGreen: true,
                          ),
                          const SizedBox(height: 8),
                          _buildCostRow(
                            'Voucher Diskon Mahasiswa',
                            '-${currencyFormat.format(_booking.discount)}',
                            isDiscount: true,
                          ),
                          const Divider(height: 20, color: AppColors.border),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Total Pembayaran',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.text,
                                ),
                              ),
                              Text(
                                currencyFormat.format(_booking.grandTotal),
                                style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),

            // Sticky Bottom Bayar CTA
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: BoxDecoration(
                color: AppColors.cardSurface,
                border: const Border(
                  top: BorderSide(color: AppColors.border, width: 1),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 8,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Total Tagihan',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          currencyFormat.format(_booking.grandTotal),
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: _isProcessing ? null : _handlePay,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                    child: _isProcessing
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('Bayar Sekarang'),
                              SizedBox(width: 6),
                              Icon(Icons.lock, size: 16),
                            ],
                          ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentOption({
    required String id,
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isRecommended,
  }) {
    final isSelected = _selectedPayment == id;

    return InkWell(
      onTap: () {
        setState(() {
          _selectedPayment = id;
        });
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primarySoft.withOpacity(0.3) : AppColors.cardSurface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
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
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: AppColors.primary, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.text,
                        ),
                      ),
                      if (isRecommended) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                          decoration: BoxDecoration(
                            color: AppColors.successSoft,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'Instan',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              color: AppColors.success,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCostRow(String title, String val, {bool isGreen = false, bool isDiscount = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
        Text(
          val,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: isGreen
                ? AppColors.success
                : isDiscount
                    ? AppColors.primary
                    : AppColors.text,
          ),
        ),
      ],
    );
  }
}
