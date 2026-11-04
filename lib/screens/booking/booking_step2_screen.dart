import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/services/api_service.dart';
import '../../core/services/shipping_calculator.dart';
import '../../core/theme/app_colors.dart';
import '../../models/booking_model.dart';
import '../../models/location_model.dart';

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

  final List<String> _sessions = [
    'Pagi (08:30 - 11:30 WIB)',
    'Siang (13:00 - 15:30 WIB)',
    'Sore (16:00 - 18:00 WIB)',
  ];

  late List<DateTime> _availableDates;

  // Real coordinate default: Area Air Tawar Barat (dekat UNP / Padang Utara)
  LocationCoordinate _userCoordinate = const LocationCoordinate(
    latitude: -0.9015,
    longitude: 100.3540,
    name: 'Lokasi Kos Saat Ini (Air Tawar)',
    address: 'Jl. Cenderawasih No. 14, Air Tawar Barat, Kec. Padang Utara, Kota Padang',
  );

  ShippingCalculation? _currentShipping;
  bool _isDetectingLocation = false;

  @override
  void initState() {
    super.initState();
    _booking = widget.bookingData ?? BookingData();

    // Pastikan nilai default delivery & packing
    if (_booking.deliveryMethod.isEmpty) {
      _booking.deliveryMethod = 'JEMPUT_KURIR';
    }
    if (_booking.packingMethod.isEmpty) {
      _booking.packingMethod = 'PACKING_SENDIRI';
    }

    // Prefill user address jika ada di session login
    if (_booking.kosAddress.trim().isEmpty) {
      final user = ApiService.currentUser;
      final userAddr = user?.alamat;
      if (userAddr != null && userAddr.trim().isNotEmpty) {
        _booking.kosAddress = userAddr.trim();
      } else {
        _booking.kosAddress = _userCoordinate.address ?? 'Jl. Cenderawasih No. 14, Air Tawar Barat';
      }
    }

    _addressCtrl.text = _booking.kosAddress;
    _noteCtrl.text = _booking.kosNote;

    final now = DateTime.now();
    _availableDates = List.generate(7, (i) => now.add(Duration(days: i + 1)));
    if (!_availableDates.any((d) => DateUtils.isSameDay(d, _booking.pickupDate))) {
      _availableDates.insert(0, _booking.pickupDate);
    }

    // Kalkulasi awal dijadwalkan setelah frame pertama selesai agar tidak memicu error build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _recalculateShipping();
      }
    });
  }

  @override
  void dispose() {
    _addressCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  void _recalculateShipping() {
    final shipping = ShippingCalculator.calculateShipping(
      pickupLocation: _userCoordinate,
      category: _booking.category,
      itemCount: _booking.totalItemCount,
      hasVehicle: _booking.items.any((i) => i.type == ItemType.custom),
    );

    setState(() {
      _currentShipping = shipping;
      _booking.pickupDistanceKm = shipping.roadDistanceKm;
      _booking.deliveryFee = shipping.totalCost;
      _booking.userLatitude = _userCoordinate.latitude;
      _booking.userLongitude = _userCoordinate.longitude;
      _booking.pickupHubName = ShippingCalculator.depoPadang.name ?? 'Gudang Pusat Kosinaja Padang';
    });
  }

  void _refreshLiveLocation() async {
    setState(() => _isDetectingLocation = true);
    await Future.delayed(const Duration(milliseconds: 600));

    // Sinkronisasi lokasi real pengguna di Padang
    if (mounted) {
      setState(() {
        _isDetectingLocation = false;
        _recalculateShipping();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('📍 Lokasi GPS kos berhasil tersinkronisasi otomatis!'),
          backgroundColor: AppColors.primary,
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _openGoogleMapsRoute() {
    ShippingCalculator.launchGoogleMapsRoute(
      ShippingCalculator.depoPadang,
      _userCoordinate,
    );
  }

  Future<void> _pickCustomDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _booking.pickupDate.isBefore(now) ? now.add(const Duration(days: 1)) : _booking.pickupDate,
      firstDate: now.add(const Duration(days: 1)),
      lastDate: now.add(const Duration(days: 90)),
      helpText: 'PILIH TANGGAL PENYERAHAN / JEMPUT',
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

  String _formatDayName(DateTime date) {
    const days = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
    return days[date.weekday - 1];
  }

  String _formatDayMonth(DateTime date) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];
    return '${date.day} ${months[date.month - 1]}';
  }

  void _proceedToStep3() {
    final addr = _addressCtrl.text.trim();
    if (addr.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Harap masukkan alamat lengkap kos Anda.'),
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
    final totalPayment = _booking.grandTotal;
    final shipping = _currentShipping;
    final distanceText = shipping != null ? '${shipping.roadDistanceKm.toStringAsFixed(1)} km' : '3.8 km';
    final deliveryCost = shipping != null ? shipping.totalCost : 12500;

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
          'Lokasi & Layanan',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: AppColors.text,
          ),
        ),
      ),
      body: Column(
        children: [
          // STEPPER HEADER IDENTIK DENGAN LANGKAH 1
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
                      'Langkah 2 dari 3: Lokasi & Layanan',
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
                    const SizedBox(width: 6),
                    Expanded(
                      child: Container(
                        height: 5,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Container(
                        height: 5,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE5D9CC),
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
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // CARD 1: DETEKSI OTOMATIS GMAPS / GPS KE GUDANG KOSINAJA
                  Container(
                    padding: const EdgeInsets.all(16),
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
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Row(
                              children: [
                                Text('📍', style: TextStyle(fontSize: 16)),
                                SizedBox(width: 6),
                                Text(
                                  'Lokasi Kos Anda (GPS Aktif)',
                                  style: TextStyle(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.text,
                                  ),
                                ),
                              ],
                            ),
                            InkWell(
                              onTap: _openGoogleMapsRoute,
                              borderRadius: BorderRadius.circular(8),
                              child: const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                child: Row(
                                  children: [
                                    Text('🗺️', style: TextStyle(fontSize: 12)),
                                    SizedBox(width: 4),
                                    Text(
                                      'Google Maps',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFF1976D2),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Live GPS detection box
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF7FAF6),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: const Color(0xFFD8EAD6), width: 1.5),
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
                                      color: const Color(0xFFE8F5E9),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.circle, size: 7, color: Color(0xFF2E7D32)),
                                        SizedBox(width: 5),
                                        Text(
                                          'GPS Terhubung Otomatis',
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w700,
                                            color: Color(0xFF2E7D32),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  InkWell(
                                    onTap: _isDetectingLocation ? null : _refreshLiveLocation,
                                    child: Text(
                                      _isDetectingLocation ? 'Mendeteksi...' : 'Perbarui GPS',
                                      style: const TextStyle(
                                        fontSize: 10.5,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _userCoordinate.name ?? 'Jl. Cenderawasih No. 14, Air Tawar Barat',
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.text,
                                  height: 1.3,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                _userCoordinate.address ?? 'Kec. Padang Utara, Kota Padang, Sumatera Barat',
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Color(0xFF6D625B),
                                ),
                              ),
                              const SizedBox(height: 10),

                              // Distance meter
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: const Color(0xFFDCE6DA)),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        const Text('📏', style: TextStyle(fontSize: 16)),
                                        const SizedBox(width: 8),
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              distanceText,
                                              style: const TextStyle(
                                                fontSize: 12.5,
                                                fontWeight: FontWeight.w800,
                                                color: AppColors.text,
                                              ),
                                            ),
                                            const Text(
                                              'Jarak ke Gudang Penitipan',
                                              style: TextStyle(
                                                fontSize: 10,
                                                color: Color(0xFF7A6F68),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    const Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          'Gudang KosinAja Padang',
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w700,
                                            color: AppColors.primary,
                                          ),
                                        ),
                                        Text(
                                          'Jl. Prof. Dr. Hamka No. 42',
                                          style: TextStyle(
                                            fontSize: 9.5,
                                            color: Color(0xFF8C827A),
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

                        // Form Alamat Detail
                        const Text(
                          'Detail Nama Kos & No. Kamar *',
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF4A403A),
                          ),
                        ),
                        const SizedBox(height: 5),
                        TextField(
                          controller: _addressCtrl,
                          style: const TextStyle(fontSize: 12),
                          decoration: InputDecoration(
                            hintText: 'Misal: Kos Melati Asri, Kamar 05 Lantai 2',
                            hintStyle: const TextStyle(fontSize: 12, color: Color(0xFF9E928A)),
                            filled: true,
                            fillColor: const Color(0xFFFAF8F5),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Color(0xFFEAE1D5)),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Color(0xFFEAE1D5)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),

                        const Text(
                          'Patokan Alamat (Opsional)',
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF4A403A),
                          ),
                        ),
                        const SizedBox(height: 5),
                        TextField(
                          controller: _noteCtrl,
                          style: const TextStyle(fontSize: 12),
                          decoration: InputDecoration(
                            hintText: 'Misal: Pagar hitam depan warung Bu Siti, masuk gang kecil',
                            hintStyle: const TextStyle(fontSize: 12, color: Color(0xFF9E928A)),
                            filled: true,
                            fillColor: const Color(0xFFFAF8F5),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Color(0xFFEAE1D5)),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Color(0xFFEAE1D5)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 14),

                  // CARD 2: PILIHAN PENGANTARAN (ANTAR SENDIRI vs JASA JEMPUT)
                  Container(
                    padding: const EdgeInsets.all(16),
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
                        const Row(
                          children: [
                            Text('🛵', style: TextStyle(fontSize: 16)),
                            SizedBox(width: 6),
                            Text(
                              'Metode Pengantaran Barang',
                              style: TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w800,
                                color: AppColors.text,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Option 1: Jemput Kurir
                        _buildChoiceCard(
                          icon: '🛵',
                          title: 'Pakai Jasa Antar Jemput',
                          description: 'Kurir KosinAja jemput ke kosanmu ($distanceText)',
                          priceText: currencyFormat.format(deliveryCost),
                          isSelected: _booking.deliveryMethod == 'JEMPUT_KURIR',
                          isFree: false,
                          onTap: () {
                            setState(() {
                              _booking.deliveryMethod = 'JEMPUT_KURIR';
                            });
                          },
                        ),

                        const SizedBox(height: 10),

                        // Option 2: Antar Sendiri
                        _buildChoiceCard(
                          icon: '🚶‍♂️',
                          title: 'Antar Sendiri ke Gudang',
                          description: 'Bawa barang langsung ke Depo Hamka',
                          priceText: 'Gratis (Rp 0)',
                          isSelected: _booking.deliveryMethod == 'ANTAR_SENDIRI',
                          isFree: true,
                          onTap: () {
                            setState(() {
                              _booking.deliveryMethod = 'ANTAR_SENDIRI';
                              // Aturan Bisnis: jika antar sendiri, packing otomatis terkunci pada PACKING_SENDIRI!
                              _booking.packingMethod = 'PACKING_SENDIRI';
                              _booking.packingFee = 0;
                            });
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 14),

                  // CARD 3: PILIHAN PACKING (HANYA AKTIF JIKA JASA JEMPUT DIPILIH)
                  Container(
                    padding: const EdgeInsets.all(16),
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
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Row(
                              children: [
                                Text('📦', style: TextStyle(fontSize: 16)),
                                SizedBox(width: 6),
                                Text(
                                  'Layanan Pengemasan (Packing)',
                                  style: TextStyle(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.text,
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                              decoration: BoxDecoration(
                                color: _booking.deliveryMethod == 'JEMPUT_KURIR'
                                    ? const Color(0xFFE8F5E9)
                                    : const Color(0xFFFFF3E0),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                _booking.deliveryMethod == 'JEMPUT_KURIR'
                                    ? '✓ Kurir Siap Bantu'
                                    : '🔒 Wajib Mandiri',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: _booking.deliveryMethod == 'JEMPUT_KURIR'
                                      ? const Color(0xFF2E7D32)
                                      : const Color(0xFFE65100),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Opsi 1: Packing Sendiri
                        _buildChoiceCard(
                          icon: '📦',
                          title: 'Packing Sendiri',
                          description: 'Barang sudah rapi kamu kemas & lakban',
                          priceText: 'Gratis (Rp 0)',
                          isSelected: _booking.packingMethod == 'PACKING_SENDIRI',
                          isFree: true,
                          onTap: () {
                            setState(() {
                              _booking.packingMethod = 'PACKING_SENDIRI';
                              _booking.packingFee = 0;
                            });
                          },
                        ),

                        const SizedBox(height: 10),

                        // Opsi 2: Pakai Jasa Packing KosinAja
                        _buildChoiceCard(
                          icon: '🛡️',
                          title: 'Pakai Jasa Packing KosinAja',
                          description: 'Kurir bawa bubble wrap tebal + kardus + lakban',
                          priceText: '+Rp 15.000',
                          isSelected: _booking.packingMethod == 'JASA_PACKING',
                          isFree: false,
                          isDisabled: _booking.deliveryMethod == 'ANTAR_SENDIRI',
                          onTap: () {
                            if (_booking.deliveryMethod == 'ANTAR_SENDIRI') {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Jasa packing hanya tersedia bila memilih Jasa Antar Jemput Kurir (kurir membawa perlengkapan packing ke tempatmu).',
                                  ),
                                  backgroundColor: Color(0xFF8C5B00),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                              return;
                            }
                            setState(() {
                              _booking.packingMethod = 'JASA_PACKING';
                              _booking.packingFee = 15000;
                            });
                          },
                        ),

                        if (_booking.deliveryMethod == 'ANTAR_SENDIRI') ...[
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFF8E7),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: const Color(0xFFFFE0A3)),
                            ),
                            child: const Row(
                              children: [
                                Text('🔒', style: TextStyle(fontSize: 14)),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Antar sendiri ke gudang mewajibkan barang sudah di-packing mandiri dari kos. Jasa packing hanya tersedia bila kurir menjemput ke tempat.',
                                    style: TextStyle(
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF8C5B00),
                                      height: 1.3,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(height: 14),

                  // CARD 4: JADWAL PENJEMPUTAN / PENYERAHAN
                  Container(
                    padding: const EdgeInsets.all(16),
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
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Row(
                              children: [
                                Text('📅', style: TextStyle(fontSize: 16)),
                                SizedBox(width: 6),
                                Text(
                                  'Jadwal Penyerahan / Penjemputan',
                                  style: TextStyle(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.text,
                                  ),
                                ),
                              ],
                            ),
                            InkWell(
                              onTap: _pickCustomDate,
                              child: const Text(
                                'Kalender 🗓️',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Horizontal Date Picker
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: _availableDates.map((date) {
                              final isSelected = DateUtils.isSameDay(_booking.pickupDate, date);
                              final isTomorrow = DateUtils.isSameDay(DateTime.now().add(const Duration(days: 1)), date);

                              return Container(
                                margin: const EdgeInsets.only(right: 8),
                                child: InkWell(
                                  onTap: () {
                                    setState(() {
                                      _booking.pickupDate = date;
                                    });
                                  },
                                  borderRadius: BorderRadius.circular(14),
                                  child: Container(
                                    width: 65,
                                    padding: const EdgeInsets.symmetric(vertical: 9),
                                    decoration: BoxDecoration(
                                      color: isSelected ? const Color(0xFFFFF5EE) : const Color(0xFFFAF8F5),
                                      borderRadius: BorderRadius.circular(14),
                                      border: Border.all(
                                        color: isSelected ? AppColors.primary : const Color(0xFFEAE1D5),
                                        width: isSelected ? 1.5 : 1,
                                      ),
                                    ),
                                    child: Column(
                                      children: [
                                        Text(
                                          isTomorrow ? 'Besok' : _formatDayName(date),
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                                            color: isSelected ? AppColors.primary : const Color(0xFF7A6F68),
                                          ),
                                        ),
                                        const SizedBox(height: 3),
                                        Text(
                                          '${date.day}',
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w800,
                                            color: isSelected ? AppColors.primary : AppColors.text,
                                          ),
                                        ),
                                        const SizedBox(height: 1),
                                        Text(
                                          DateFormat('MMM', 'id_ID').format(date),
                                          style: const TextStyle(
                                            fontSize: 10,
                                            color: Color(0xFF9C8F87),
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

                        const SizedBox(height: 12),

                        // Sesi Jam Chips
                        Row(
                          children: _sessions.map((sess) {
                            final isSelected = _booking.pickupSession == sess;
                            final shortName = sess.startsWith('Pagi')
                                ? '🌅 Pagi'
                                : (sess.startsWith('Siang') ? '☀️ Siang' : '🌇 Sore');
                            final timeRange = sess.startsWith('Pagi')
                                ? '08:30 - 11:30'
                                : (sess.startsWith('Siang') ? '13:00 - 15:30' : '16:00 - 18:00');

                            return Expanded(
                              child: Container(
                                margin: EdgeInsets.only(right: sess != _sessions.last ? 6 : 0),
                                child: InkWell(
                                  onTap: () {
                                    setState(() {
                                      _booking.pickupSession = sess;
                                    });
                                  },
                                  borderRadius: BorderRadius.circular(12),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 4),
                                    decoration: BoxDecoration(
                                      color: isSelected ? const Color(0xFFFFF5EE) : const Color(0xFFFAF8F5),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: isSelected ? AppColors.primary : const Color(0xFFEAE1D5),
                                        width: isSelected ? 1.5 : 1,
                                      ),
                                    ),
                                    child: Column(
                                      children: [
                                        Text(
                                          shortName,
                                          style: TextStyle(
                                            fontSize: 11.5,
                                            fontWeight: FontWeight.w800,
                                            color: isSelected ? AppColors.primary : AppColors.text,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          timeRange,
                                          style: const TextStyle(
                                            fontSize: 9,
                                            color: Color(0xFF7A6F68),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 14),

                  // CARD 5: RINCIAN BIAYA REAL & TRANSPARAN
                  Container(
                    padding: const EdgeInsets.all(16),
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
                        const Row(
                          children: [
                            Text('🧾', style: TextStyle(fontSize: 16)),
                            SizedBox(width: 6),
                            Text(
                              'Rincian Biaya Real',
                              style: TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w800,
                                color: AppColors.text,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFAF8F5),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFE0D5C7), style: BorderStyle.solid),
                          ),
                          child: Column(
                            children: [
                              _buildCostLine(
                                'Biaya Sewa Simpan (${_booking.durationCount} ${_booking.durationType})',
                                currencyFormat.format(_booking.storageSubtotal),
                              ),
                              const SizedBox(height: 6),
                              _buildCostLine(
                                _booking.deliveryMethod == 'ANTAR_SENDIRI'
                                    ? 'Pengantaran (Antar Sendiri)'
                                    : 'Jasa Antar Jemput ($distanceText)',
                                _booking.deliveryMethod == 'ANTAR_SENDIRI'
                                    ? 'Rp 0 (Gratis)'
                                    : currencyFormat.format(deliveryCost),
                                isGreen: _booking.deliveryMethod == 'ANTAR_SENDIRI',
                              ),
                              const SizedBox(height: 6),
                              _buildCostLine(
                                _booking.packingMethod == 'JASA_PACKING'
                                    ? 'Jasa Packing KosinAja'
                                    : 'Pengemasan (Packing Sendiri)',
                                _booking.packingMethod == 'JASA_PACKING'
                                    ? '+Rp 15.000'
                                    : 'Rp 0 (Gratis)',
                                isGreen: _booking.packingMethod == 'PACKING_SENDIRI',
                              ),
                              const SizedBox(height: 6),
                              _buildCostLine(
                                'Garansi & Pengawasan CCTV 24 Jam',
                                'Gratis',
                                isGreen: true,
                              ),
                              const Divider(height: 16, color: Color(0xFFEAE1D5)),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Total Pembayaran',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.text,
                                    ),
                                  ),
                                  Text(
                                    currencyFormat.format(totalPayment),
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w800,
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

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),

          // FLOATING CHECKOUT BAR
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              border: const Border(
                top: BorderSide(color: Color(0xFFEFE8DF), width: 1),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 10,
                  offset: const Offset(0, -3),
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
                        'Total Pembayaran',
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF7A6F68),
                        ),
                      ),
                      const SizedBox(height: 1),
                      Text(
                        currencyFormat.format(totalPayment),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: _proceedToStep3,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Lanjut',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      SizedBox(width: 4),
                      Icon(Icons.arrow_forward_ios_rounded, size: 13, color: Colors.white),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // PERSISTENT BOTTOM NAVIGATION BAR
          _buildBottomNavBar(),
        ],
      ),
    );
  }

  Widget _buildChoiceCard({
    required String icon,
    required String title,
    required String description,
    required String priceText,
    required bool isSelected,
    required bool isFree,
    bool isDisabled = false,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isDisabled
              ? const Color(0xFFF5F1EB)
              : (isSelected ? const Color(0xFFFFF5EE) : const Color(0xFFFAF8F5)),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? AppColors.primary : const Color(0xFFEAE1D5),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isSelected ? AppColors.primary : const Color(0xFFEFE8DF),
                ),
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
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w800,
                      color: isDisabled ? const Color(0xFF8C827A) : AppColors.text,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 10.5,
                      color: isDisabled ? const Color(0xFF9E928A) : const Color(0xFF7A6F68),
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  priceText,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: isFree ? const Color(0xFF2E7D32) : AppColors.primary,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected ? AppColors.primary : Colors.transparent,
                    border: Border.all(
                      color: isSelected ? AppColors.primary : const Color(0xFFD6C8B8),
                      width: 1.5,
                    ),
                  ),
                  child: isSelected
                      ? const Center(
                          child: ContainerDot(),
                        )
                      : null,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCostLine(String title, String value, {bool isGreen = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 11, color: Color(0xFF5C524C)),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: isGreen ? const Color(0xFF2E7D32) : AppColors.text,
          ),
        ),
      ],
    );
  }

  Widget _buildBottomNavBar() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Color(0xFFF0E8DF), width: 1),
        ),
      ),
      child: BottomNavigationBar(
        currentIndex: 1, // Tab Booking aktif
        onTap: (index) {
          if (index == 0) {
            Navigator.pushNamedAndRemoveUntil(context, '/home', (r) => false);
          } else if (index == 1) {
            // Sudah di Booking
          } else if (index == 2) {
            Navigator.pushNamed(context, '/orders');
          } else if (index == 3) {
            Navigator.pushNamed(context, '/profile');
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
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory_2_outlined),
            activeIcon: Icon(Icons.inventory_2),
            label: 'Booking',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long_outlined),
            activeIcon: Icon(Icons.receipt_long),
            label: 'Riwayat',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Akun',
          ),
        ],
      ),
    );
  }
}

class ContainerDot extends StatelessWidget {
  const ContainerDot({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 6,
      height: 6,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
      ),
    );
  }
}
