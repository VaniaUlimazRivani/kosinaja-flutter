import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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

  final TextEditingController _addressCtrl = TextEditingController();
  final TextEditingController _noteCtrl = TextEditingController();

  final List<String> _campusChips = [
    'UNAND Limau Manih',
    'UNP Air Tawar',
    'UIN IB Lubuk Lintah',
    'UPI Lubuk Begalung',
    'Politeknik Negeri Padang',
  ];

  final List<String> _sessions = [
    'Pagi (08:30 - 11:30 WIB)',
    'Siang (13:00 - 15:30 WIB)',
    'Sore (16:00 - 18:00 WIB)',
  ];

  late List<DateTime> _availableDates;
  int get _totalItemsCount => _booking.items.fold(0, (sum, i) => sum + i.quantity);
  String get _determinedCategory {
    final count = _totalItemsCount;
    final hasHeavy = _booking.items.any((i) =>
        i.category == 'B' ||
        i.name.toLowerCase().contains('kulkas') ||
        i.name.toLowerCase().contains('kasur') ||
        i.name.toLowerCase().contains('mesin'));
    final hasVehicle = _booking.items.any((i) =>
        i.name.toLowerCase().contains('motor') ||
        i.name.toLowerCase().contains('sepeda') ||
        i.name.toLowerCase().contains('kendaraan'));

    if (hasVehicle || count > 7) return 'Custom';
    if (hasHeavy || count >= 4) return 'B';
    return 'A';
  }


  @override
  void initState() {
    super.initState();
    _booking = widget.bookingData ?? BookingData();
    _addressCtrl.text = _booking.kosAddress;
    _noteCtrl.text = _booking.kosNote;

    final now = DateTime.now();
    _availableDates = List.generate(7, (i) => now.add(Duration(days: i + 1)));
  }

  @override
  void dispose() {
    _addressCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  void _proceedToStep3() {
    final addr = _addressCtrl.text.trim();
    if (addr.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Harap masukkan alamat lengkap kosan penjemputan.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    _booking.kosAddress = addr;
    _booking.kosNote = _noteCtrl.text.trim();

    Navigator.pushNamed(
      context,
      '/booking-step3',
      arguments: _booking,
    );
  }

  @override
  Widget build(BuildContext context) {
    final totalPayment = _booking.storageSubtotal + _booking.deliveryFee;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Lokasi & Jadwal'),
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
                    child: Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: Container(height: 6, color: AppColors.primary),
                        ),
                        Expanded(
                          flex: 1,
                          child: Container(height: 6, color: AppColors.surfaceContainerHigh),
                        ),
                      ],
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
                    LocationPickerWidget(
                      category: _determinedCategory,
                      itemCount: _totalItemsCount,
                      onShippingCalculated: (shipping) {
                        setState(() {
                          _booking.deliveryFee = shipping.totalCost;
                        });
                      },
                      onLocationChanged: (preset) {
                        setState(() {
                          _booking.campus = preset.shortName;
                          _addressCtrl.text = preset.address;
                          _booking.kosAddress = preset.address;
                        });
                      },
                    ),

                    const SizedBox(height: 16),

                    // Catatan Tambahan (Patokan Kosan)
                    const Text(
                      'Patokan / Catatan Tambahan Kosan',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.text,
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _noteCtrl,
                      decoration: const InputDecoration(
                        hintText: 'Misal: Samping warung Ampera, lantai 2 kamar no. 8...',
                        prefixIcon: Icon(Icons.notes_outlined, color: AppColors.primary),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Tanggal Penjemputan
                    const Text(
                      'Pilih Tanggal Penjemputan',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.text,
                      ),
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
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
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
}
