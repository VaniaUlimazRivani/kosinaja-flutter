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

  final List<Map<String, String>> _sessions = [
    {
      'id': 'Pagi (08:30 - 11:30 WIB)',
      'label': 'Pagi',
      'time': '08:30 - 11:30 WIB',
      'icon': '🌅',
    },
    {
      'id': 'Siang (13:00 - 15:30 WIB)',
      'label': 'Siang',
      'time': '13:00 - 15:30 WIB',
      'icon': '☀️',
    },
    {
      'id': 'Sore (16:00 - 18:00 WIB)',
      'label': 'Sore',
      'time': '16:00 - 18:00 WIB',
      'icon': '🌇',
    },
  ];

  late List<DateTime> _availableDates;

  @override
  void initState() {
    super.initState();
    _booking = widget.bookingData ?? BookingData();

    // Default logistik & pengemasan
    if (_booking.deliveryMethod.isEmpty) {
      _booking.deliveryMethod = 'JEMPUT_KURIR';
    }
    if (_booking.metodePickup.isEmpty) {
      _booking.metodePickup = 'PICKUP';
    }
    if (_booking.metodeDelivery.isEmpty) {
      _booking.metodeDelivery = 'DELIVERY';
    }
    if (_booking.packingMethod.isEmpty) {
      _booking.packingMethod = 'PACKING_SENDIRI';
    }

    // Jika user memilih Antar Sendiri, packing wajib di Hub
    if (_booking.metodePickup == 'SELF_DROPOFF') {
      _booking.packingMethod = 'PACKING_SENDIRI';
      _booking.packingFee = 0;
    }

    // Jika alamat masih kosong, gunakan alamat tersimpan di profil
    if (_booking.kosAddress.trim().isEmpty) {
      final user = ApiService.currentUser;
      final userAddr = user?.alamat;
      if (userAddr != null && userAddr.trim().isNotEmpty) {
        _booking.kosAddress = userAddr.trim();
      }
    }

    final now = DateTime.now();
    _availableDates = List.generate(7, (i) => now.add(Duration(days: i + 1)));

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
    // Sinkronisasi data logistik sebelum ke step 3
    if (_booking.metodePickup == 'SELF_DROPOFF') {
      _booking.deliveryMethod = 'ANTAR_SENDIRI';
      _booking.packingMethod = 'PACKING_SENDIRI';
      _booking.packingFee = 0;
    } else {
      _booking.deliveryMethod = 'JEMPUT_KURIR';
    }

    // Validasi alamat jika metode penjemputan adalah jemput kurir
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
    final isPickupCourier = _booking.metodePickup == 'PICKUP';

    return Scaffold(
      backgroundColor: const Color(0xFFFAF7F2),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFAF7F2),
        elevation: 0,
        titleSpacing: 0,
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20, color: AppColors.text),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Booking Penitipan',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: Color(0xFF2E2018),
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Stepper Progress Header (Identik Langkah 1)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              color: const Color(0xFFFAF7F2),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Langkah 2 dari 3: Lokasi & Jadwal',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3ECE4),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFE5D9CC)),
                        ),
                        child: const Text(
                          'Langkah 2/3',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF985322),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 5,
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Container(
                          height: 5,
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Container(
                          height: 5,
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8DACB),
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // SCROLLABLE CONTENT
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Widget Interaktif Lokasi & Logistik (OSM + 2-Way Logistics)
                    LocationPickerWidget(
                      booking: _booking,
                      onLocationChanged: (result) {
                        setState(() {
                          _booking.pickupDistanceKm = result.kalkulasi.jarakKm;
                          _booking.userLatitude = result.coordinate.latitude;
                          _booking.userLongitude = result.coordinate.longitude;

                          // Jika berpindah ke antar sendiri, auto reset packing ke mandiri
                          if (result.metodePickup == 'SELF_DROPOFF') {
                            _booking.packingMethod = 'PACKING_SENDIRI';
                            _booking.packingFee = 0;
                          }
                        });
                      },
                    ),

                    const SizedBox(height: 22),

                    // OPSI LAYANAN PENGEMASAN / PACKING
                    const Text(
                      '3. Layanan Pengemasan / Packing',
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.text,
                      ),
                    ),
                    const SizedBox(height: 3),
                    const Text(
                      'Persiapan perlindungan barang sebelum disimpan di gudang',
                      style: TextStyle(fontSize: 11.5, color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 10),

                    if (isPickupCourier) ...[
                      // Jika dijemput kurir: tampilkan 2 opsi packing
                      _buildPackingCard(
                        icon: '📦',
                        title: 'Packing Mandiri',
                        desc: 'Barang sudah kamu kemas rapi sendiri',
                        priceLabel: 'GRATIS',
                        isSelected: _booking.packingMethod == 'PACKING_SENDIRI',
                        onTap: () {
                          setState(() {
                            _booking.packingMethod = 'PACKING_SENDIRI';
                            _booking.packingFee = 0;
                          });
                        },
                      ),
                      const SizedBox(height: 8),
                      _buildPackingCard(
                        icon: '✨',
                        title: 'Jasa Packing KosinAja',
                        desc: 'Kurir sediakan kardus tebal & bubble wrap',
                        priceLabel: '+ Rp 15.000',
                        isSelected: _booking.packingMethod == 'JASA_PACKING',
                        onTap: () {
                          setState(() {
                            _booking.packingMethod = 'JASA_PACKING';
                            _booking.packingFee = 15000;
                          });
                        },
                      ),
                    ] else ...[
                      // Jika antar sendiri ke Hub: tampilkan info packing di Hub
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFAF2EB),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFFEADBCC)),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.info_outline_rounded,
                                color: AppColors.primary,
                                size: 18,
                              ),
                            ),
                            const SizedBox(width: 10),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Packing Langsung di Hub Gudang',
                                    style: TextStyle(
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.text,
                                    ),
                                  ),
                                  SizedBox(height: 2),
                                  Text(
                                    'Karena kamu memilih Antar Sendiri, konsultasi atau pembelian packing dapat dilayani langsung saat serah terima di Gudang Hub Hotel Ibis.',
                                    style: TextStyle(
                                      fontSize: 11,
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

                    const SizedBox(height: 22),

                    // TANGGAL PENJEMPUTAN DENGAN KALENDER
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          '4. Jadwal Tanggal Penjemputan',
                          style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700,
                            color: AppColors.text,
                          ),
                        ),
                        TextButton.icon(
                          onPressed: _pickCustomDate,
                          icon: const Icon(Icons.calendar_month_outlined, size: 15, color: AppColors.primary),
                          label: const Text(
                            'Kalender',
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary,
                            ),
                          ),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Horizontal Date Selector
                    SizedBox(
                      height: 70,
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
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              width: 68,
                              margin: const EdgeInsets.only(right: 8),
                              decoration: BoxDecoration(
                                color: isSelected ? AppColors.primary : Colors.white,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: isSelected ? AppColors.primary : const Color(0xFFEADBCC),
                                  width: isSelected ? 1.5 : 1,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(isSelected ? 0.08 : 0.02),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    dayName,
                                    style: TextStyle(
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w600,
                                      color: isSelected ? Colors.white70 : AppColors.textSecondary,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    dayNum,
                                    style: TextStyle(
                                      fontSize: 13,
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

                    const SizedBox(height: 18),

                    // SESI JAM PENJEMPUTAN
                    const Text(
                      '5. Sesi Waktu Kedatangan',
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.text,
                      ),
                    ),
                    const SizedBox(height: 8),

                    Column(
                      children: _sessions.map((session) {
                        final isSelected = _booking.pickupSession == session['id'];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                _booking.pickupSession = session['id']!;
                              });
                            },
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
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
                                  Text(
                                    session['icon']!,
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                  const SizedBox(width: 10),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        session['label']!,
                                        style: TextStyle(
                                          fontSize: 12.5,
                                          fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                                          color: AppColors.text,
                                        ),
                                      ),
                                      Text(
                                        session['time']!,
                                        style: const TextStyle(
                                          fontSize: 11,
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const Spacer(),
                                  Icon(
                                    isSelected
                                        ? Icons.check_circle_rounded
                                        : Icons.radio_button_unchecked_rounded,
                                    color: isSelected ? AppColors.primary : AppColors.textMuted,
                                    size: 18,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),

            // STICKY BOTTOM BAR (TOTAL & CTA)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                border: const Border(
                  top: BorderSide(color: Color(0xFFEADBCC)),
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
                          'Total Sewa + Ongkir',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          currencyFormat.format(totalPayment),
                          style: const TextStyle(
                            fontSize: 16.5,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 14),
                  ElevatedButton(
                    onPressed: _proceedToStep3,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFB86B35),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Lanjut Ringkasan',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 13,
                          ),
                        ),
                        SizedBox(width: 6),
                        Icon(Icons.arrow_forward_ios_rounded, size: 14),
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

  Widget _buildPackingCard({
    required String icon,
    required String title,
    required String desc,
    required String priceLabel,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : const Color(0xFFF3ECE4),
                borderRadius: BorderRadius.circular(10),
              ),
              alignment: Alignment.center,
              child: Text(icon, style: const TextStyle(fontSize: 17)),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: AppColors.text,
                    ),
                  ),
                  const SizedBox(height: 1),
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
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary.withOpacity(0.12) : const Color(0xFFF5EFE9),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                priceLabel,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: isSelected ? AppColors.primary : AppColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
