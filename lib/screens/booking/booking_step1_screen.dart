import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../models/booking_model.dart';

class BookingStep1Screen extends StatefulWidget {
  final BookingData? initialBooking;
  const BookingStep1Screen({super.key, this.initialBooking});

  @override
  State<BookingStep1Screen> createState() => _BookingStep1ScreenState();
}

class _BookingStep1ScreenState extends State<BookingStep1Screen> {
  late BookingData _booking;
  final currencyFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

  final List<BookingItem> _presetItems = [
    BookingItem(
      id: 'item-1',
      name: 'Dus Pakaian & Buku',
      category: 'Kardus Sedang (40x30x30 cm)',
      monthlyPrice: 35000,
      quantity: 1,
    ),
    BookingItem(
      id: 'item-2',
      name: 'Kulkas Mini Portabel',
      category: 'Elektronik Kamar (Proteksi Bubble Wrap)',
      monthlyPrice: 50000,
      quantity: 1,
    ),
    BookingItem(
      id: 'item-3',
      name: 'Dus Besar / Koper 24"',
      category: 'Koper Baju / Bedcover',
      monthlyPrice: 45000,
      quantity: 0,
    ),
    BookingItem(
      id: 'item-4',
      name: 'Dispenser & Rice Cooker',
      category: 'Peralatan Masak Mahasiswa',
      monthlyPrice: 25000,
      quantity: 0,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _booking = widget.initialBooking ?? BookingData(items: _presetItems);
    if (_booking.items.isEmpty) {
      _booking.items = _presetItems;
    }
  }

  void _updateQuantity(BookingItem item, int delta) {
    setState(() {
      final newQty = item.quantity + delta;
      if (newQty >= 0 && newQty <= 20) {
        item.quantity = newQty;
      }
    });
  }

  void _showAddCustomItemDialog() {
    final nameCtrl = TextEditingController();
    final priceCtrl = TextEditingController(text: '30000');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Tambah Barang Kustom',
                    style: TextStyle(
                      fontSize: 16,
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
              const SizedBox(height: 12),
              const Text(
                'Nama Barang',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(
                  hintText: 'Misal: Rak Sepatu Kayu, Galon Aqua',
                ),
              ),
              const SizedBox(height: 14),
              const Text(
                'Estimasi Biaya Sewa/Bulan (Rp)',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: priceCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  hintText: '30000',
                ),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    final name = nameCtrl.text.trim();
                    final price = int.tryParse(priceCtrl.text) ?? 30000;
                    if (name.isNotEmpty) {
                      setState(() {
                        _booking.items.add(
                          BookingItem(
                            id: 'custom-${DateTime.now().millisecondsSinceEpoch}',
                            name: name,
                            category: 'Barang Kustom Mahasiswa',
                            monthlyPrice: price,
                            quantity: 1,
                          ),
                        );
                      });
                      Navigator.pop(ctx);
                    }
                  },
                  child: const Text('Simpan ke Daftar Penitipan'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _proceedToStep2() {
    final selectedCount = _booking.items.where((i) => i.quantity > 0).fold(0, (sum, i) => sum + i.quantity);
    if (selectedCount == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pilih minimal 1 barang untuk dititipkan.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    Navigator.pushNamed(
      context,
      '/booking-step2',
      arguments: _booking,
    );
  }

  @override
  Widget build(BuildContext context) {
    final totalItems = _booking.items.fold(0, (sum, i) => sum + i.quantity);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Pemesanan Penitipan'),
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
                        'Langkah 1 dari 3: Barang & Durasi',
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
                          '33%',
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
                  // Progress Bar Track
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 1,
                          child: Container(height: 6, color: AppColors.primary),
                        ),
                        Expanded(
                          flex: 2,
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
                    // Section Title
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Pilih Barang yang Dititip',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.text,
                          ),
                        ),
                        TextButton.icon(
                          onPressed: _showAddCustomItemDialog,
                          icon: const Icon(Icons.add, size: 16, color: AppColors.primary),
                          label: const Text(
                            'Kustom',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    // Preset Items List
                    Column(
                      children: _booking.items.map((item) {
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: AppColors.cardSurface,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: item.quantity > 0 ? AppColors.primary : AppColors.border,
                              width: item.quantity > 0 ? 1.5 : 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.02),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: item.quantity > 0
                                      ? AppColors.primarySoft
                                      : AppColors.surfaceContainerLow,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(
                                  item.name.contains('Kulkas')
                                      ? Icons.kitchen_outlined
                                      : item.name.contains('Koper')
                                          ? Icons.luggage_outlined
                                          : item.name.contains('Dispenser')
                                              ? Icons.water_drop_outlined
                                              : Icons.inventory_2_outlined,
                                  color: AppColors.primary,
                                  size: 22,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.name,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.text,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      item.category,
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${currencyFormat.format(item.monthlyPrice)} / bln',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // Counter Stepper
                              Row(
                                children: [
                                  IconButton(
                                    onPressed: item.quantity > 0
                                        ? () => _updateQuantity(item, -1)
                                        : null,
                                    icon: const Icon(Icons.remove_circle_outline),
                                    color: item.quantity > 0
                                        ? AppColors.primary
                                        : AppColors.textMuted,
                                    iconSize: 26,
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 10),
                                    child: Text(
                                      '${item.quantity}',
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w800,
                                        color: item.quantity > 0
                                            ? AppColors.primary
                                            : AppColors.textMuted,
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () => _updateQuantity(item, 1),
                                    icon: const Icon(Icons.add_circle),
                                    color: AppColors.primary,
                                    iconSize: 26,
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 20),

                    // Duration Selector
                    const Text(
                      'Pilih Durasi Penitipan',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.text,
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Duration Tabs
                    Row(
                      children: ['Bulanan', 'Mingguan', 'Harian'].map((type) {
                        final isSelected = _booking.durationType == type;
                        return Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _booking.durationType = type;
                              });
                            },
                            child: Container(
                              margin: const EdgeInsets.only(right: 8),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: isSelected ? AppColors.primary : AppColors.cardSurface,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: isSelected ? AppColors.primary : AppColors.border,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  type == 'Bulanan' ? 'Bulanan (Hemat)' : type,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: isSelected ? Colors.white : AppColors.text,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 14),

                    // Duration Count Card
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: AppColors.cardSurface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Jumlah ${_booking.durationType}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${_booking.durationCount} ${_booking.durationType}',
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.text,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              IconButton(
                                onPressed: _booking.durationCount > 1
                                    ? () {
                                        setState(() {
                                          _booking.durationCount--;
                                        });
                                      }
                                    : null,
                                icon: const Icon(Icons.remove_circle_outline),
                                color: _booking.durationCount > 1
                                    ? AppColors.primary
                                    : AppColors.textMuted,
                              ),
                              Text(
                                '${_booking.durationCount}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              IconButton(
                                onPressed: _booking.durationCount < 12
                                    ? () {
                                        setState(() {
                                          _booking.durationCount++;
                                        });
                                      }
                                    : null,
                                icon: const Icon(Icons.add_circle),
                                color: AppColors.primary,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Safety SOP Alert Box
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.warningSoft,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.warning.withOpacity(0.3)),
                      ),
                      child: const Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.warning_amber_rounded, color: AppColors.warning, size: 20),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Barang mudah terbakar, makanan basah/basi, hewan, & barang terlarang dilarang dititipkan demi SOP keamanan bersama di Hub Pauh.',
                              style: TextStyle(
                                fontSize: 11,
                                color: Color(0xFF78350F),
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),

            // Sticky Bottom CTA Bar
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
                        Text(
                          'Total $totalItems Barang (${_booking.durationCount} ${_booking.durationType})',
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          currencyFormat.format(_booking.storageSubtotal),
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
                    onPressed: _proceedToStep2,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('Lanjut: Lokasi'),
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
