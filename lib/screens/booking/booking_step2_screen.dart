import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/services/api_service.dart';
import '../../core/theme/app_colors.dart';
import '../../models/booking_model.dart';
import '../../widgets/location_picker_widget.dart';

class BookingStep2Screen extends StatefulWidget {
  final BookingData? bookingData;
  const BookingStep2Screen({super.key, this.bookingData});

  @override
  State<BookingStep2Screen> createState() => _BookingStep2ScreenState();
}

class _BookingStep2ScreenState extends State<BookingStep2Screen> {
  late BookingData _booking;
  final currencyFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

  final List<String> _sessions = [
    'Pagi (08:30 - 11:30 WIB)',
    'Siang (13:00 - 15:30 WIB)',
    'Sore (16:00 - 18:00 WIB)',
  ];

  late List<DateTime> _availableDates;

  @override
  void initState() {
    super.initState();
    _booking = widget.bookingData ?? BookingData();

    // Pastikan default nilai logistik
    if (_booking.deliveryMethod.isEmpty) {
      _booking.deliveryMethod = 'JEMPUT_KURIR';
    }
    if (_booking.packingMethod.isEmpty) {
      _booking.packingMethod = 'PACKING_SENDIRI';
    }

    // Jika alamat masih kosong, gunakan alamat profil user tersimpan jika ada
    if (_booking.kosAddress.trim().isEmpty) {
      final user = ApiService.currentUser;
      final userAddr = user?.alamat;
      if (userAddr != null && userAddr.trim().isNotEmpty) {
        _booking.kosAddress = userAddr.trim();
      }
    }

    final now = DateTime.now();
    _availableDates = List.generate(7, (i) => now.add(Duration(days: i + 1)));

    // Pastikan tanggal default masuk ke salah satu list tanggal tersedia
    if (!_availableDates.any((d) => DateUtils.isSameDay(d, _booking.pickupDate))) {
      _availableDates.insert(0, _booking.pickupDate);
    }
  }

  Future<void> _pickCustomDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _booking.pickupDate.isBefore(now) ? now.add(const Duration(days: 1)) : _booking.pickupDate,
      firstDate: now.add(const Duration(days: 1)),
      lastDate: now.add(const Duration(days: 90)),
      helpText: 'PILIH TANGGAL PENJEMPUTAN',
      confirmText: 'PILIH',
      cancelText: 'BATAL',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              onSurface: AppColors.text,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _booking.pickupDate = picked;
        if (!_availableDates.any((d) => DateUtils.isSameDay(d, picked))) {
          _availableDates.insert(0, picked);
        }
      });
    }
  }

  void _proceedToStep3() {
    // Sinkronisasi data logistik dan pengemasan sebelum lanjut
    if (_booking.metodePickup == 'SELF_DROPOFF') {
      _booking.deliveryMethod = 'ANTAR_SENDIRI';
      _booking.deliveryFee = 0;
    } else {
      _booking.deliveryMethod = 'JEMPUT_KURIR';
    }

    // Validasi alamat jika metode pickup adalah jemput kurir
    if (_booking.metodePickup == 'PICKUP' && _booking.kosAddress.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Harap masukkan alamat detail kosan penjemputan.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    Navigator.pushNamed(
      context,
      '/booking-step3',
      arguments: _booking,
    );
  }

  @override
  Widget build(BuildContext context) {
    final totalPayment = _booking.grandTotal;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Lokasi & Logistik'),
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
                        'Langkah 2 dari 3: Lokasi & Jadwal',
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
                          '66%',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: const LinearProgressIndicator(
                      value: 0.66,
                      backgroundColor: AppColors.border,
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                      minHeight: 6,
                    ),
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
                    // Widget Interaktif Pemilihan Lokasi & Logistik OSM (OpenStreetMap)
                    LocationPickerWidget(
                      booking: _booking,
                      onLocationChanged: (result) {
                        setState(() {
                          _booking.pickupDistanceKm = result.kalkulasi.jarakKm;
                          _booking.userLatitude = result.coordinate.latitude;
                          _booking.userLongitude = result.coordinate.longitude;
                        });
                      },
                    ),

                    const SizedBox(height: 24),

                    // Opsi Layanan Pengemasan / Packing
                    const Text(
                      'Layanan Pengemasan / Packing',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.text,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Pilih apakah barang sudah siap atau membutuhkan bantuan packing.',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 10),

                    _buildPackingOption(
                      icon: '📦',
                      title: 'Packing Mandiri',
                      desc: 'Barang sudah dipacking rapi oleh kamu dalam dus/koper.',
                      price: 'GRATIS',
                      isSelected: _booking.packingMethod == 'PACKING_SENDIRI',
                      onTap: () {
                        setState(() {
                          _booking.packingMethod = 'PACKING_SENDIRI';
                          _booking.packingFee = 0;
                        });
                      },
                    ),
                    const SizedBox(height: 8),
                    _buildPackingOption(
                      icon: '✨',
                      title: 'Jasa Packing KosinAja',
                      desc: 'Disediakan kardus tebal, lakban, & bubble wrap oleh kurir.',
                      price: '+ Rp 15.000',
                      isSelected: _booking.packingMethod == 'JASA_PACKING',
                      onTap: () {
                        setState(() {
                          _booking.packingMethod = 'JASA_PACKING';
                          _booking.packingFee = 15000;
                        });
                      },
                    ),

                    const SizedBox(height: 24),

                    // Tanggal Penjemputan dengan tombol Kalender
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Pilih Tanggal Penjemputan',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppColors.text,
                          ),
                        ),
                        TextButton.icon(
                          onPressed: _pickCustomDate,
                          icon: const Icon(Icons.calendar_month, size: 16, color: AppColors.primary),
                          label: const Text(
                            'Pilih di Kalender',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // Horizontal Date Selector
                    SizedBox(
                      height: 74,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _availableDates.length,
                        itemBuilder: (context, index) {
                          final date = _availableDates[index];
                          final isSelected = DateUtils.isSameDay(date, _booking.pickupDate);
                          final dayName = DateFormat('EEE', 'id_ID').format(date);
                          final dayNum = DateFormat('d MMM', 'id_ID').format(date);

                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                _booking.pickupDate = date;
                              });
                            },
                            child: Container(
                              width: 70,
                              margin: const EdgeInsets.only(right: 10),
                              decoration: BoxDecoration(
                                color: isSelected ? AppColors.primary : AppColors.cardSurface,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isSelected ? AppColors.primary : AppColors.border,
                                  width: isSelected ? 1.5 : 1,
                                ),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    dayName,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: isSelected ? Colors.white70 : AppColors.textSecondary,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    dayNum,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w800,
                                      color: isSelected ? Colors.white : AppColors.text,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Sesi Jam Penjemputan
                    const Text(
                      'Pilih Sesi Jam Penjemputan',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.text,
                      ),
                    ),
                    const SizedBox(height: 10),

                    Column(
                      children: _sessions.map((session) {
                        final isSelected = _booking.pickupSession == session;
                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                _booking.pickupSession = session;
                              });
                            },
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.primarySoft.withOpacity(0.4)
                                    : AppColors.cardSurface,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isSelected ? AppColors.primary : AppColors.border,
                                  width: isSelected ? 1.5 : 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    isSelected
                                        ? Icons.radio_button_checked
                                        : Icons.radio_button_off,
                                    color: isSelected ? AppColors.primary : AppColors.textMuted,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    session,
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight:
                                          isSelected ? FontWeight.w700 : FontWeight.w500,
                                      color: AppColors.text,
                                    ),
                                  ),
                                  const Spacer(),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.successSoft,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Text(
                                      'Tersedia',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.success,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),

            // Sticky Bottom CTA
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
                          'Estimasi Total Sewa + Ongkir',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          currencyFormat.format(totalPayment),
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
                    onPressed: _proceedToStep3,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('Lanjut: Bayar'),
                        SizedBox(width: 6),
                        Icon(Icons.arrow_forward, size: 16),
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

  Widget _buildPackingOption({
    required String icon,
    required String title,
    required String desc,
    required String price,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primarySoft.withOpacity(0.25) : AppColors.cardSurface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : const Color(0xFFF0EBE1),
                borderRadius: BorderRadius.circular(10),
              ),
              alignment: Alignment.center,
              child: Text(
                icon,
                style: const TextStyle(fontSize: 18),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.text,
                    ),
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
            const SizedBox(width: 8),
            Text(
              price,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
