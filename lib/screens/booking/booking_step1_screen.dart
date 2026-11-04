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

  final List<BookingItem> _defaultItems = [
    BookingItem(
      id: 'item-1',
      name: 'Dus Pakaian & Buku',
      type: ItemType.kecil,
      quantity: 1,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _booking = widget.initialBooking ?? BookingData(items: List.from(_defaultItems));
    if (_booking.items.isEmpty) {
      _booking.items = List.from(_defaultItems);
    }
  }

  void _updateQuantity(BookingItem item, int delta) {
    setState(() {
      final newQty = item.quantity + delta;
      if (newQty > 0 && newQty <= 20) {
        item.quantity = newQty;
      }
    });
  }

  void _removeItem(BookingItem item) {
    setState(() {
      _booking.items.removeWhere((i) => i.id == item.id);
    });
  }

  void _showAddItemDialog() {
    final nameCtrl = TextEditingController();
    ItemType selectedType = ItemType.kecil;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
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
                        'Tambah Barang Titipan',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: AppColors.text,
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(ctx),
                        icon: const Icon(Icons.close, size: 20),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Input Nama Barang
                  const Text(
                    'Nama Barang',
                    style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: AppColors.text),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: nameCtrl,
                    decoration: InputDecoration(
                      hintText: 'Misal: Kulkas Mini, Dus Buku, Koper...',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Pilihan Jenis Barang
                  const Text(
                    'Jenis Barang',
                    style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: AppColors.text),
                  ),
                  const SizedBox(height: 8),

                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setModalState(() => selectedType = ItemType.kecil);
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
                            decoration: BoxDecoration(
                              color: selectedType == ItemType.kecil ? const Color(0xFFF6ECE1) : Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: selectedType == ItemType.kecil ? AppColors.primary : AppColors.border,
                                width: selectedType == ItemType.kecil ? 1.5 : 1,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.inventory_2_outlined,
                                      size: 16,
                                      color: selectedType == ItemType.kecil ? AppColors.primary : AppColors.textSecondary,
                                    ),
                                    const SizedBox(width: 6),
                                    const Text('Barang Kecil', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                const Text('Dus pakaian, tas, koper kecil', style: TextStyle(fontSize: 10.5, color: AppColors.textSecondary)),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setModalState(() => selectedType = ItemType.besar);
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
                            decoration: BoxDecoration(
                              color: selectedType == ItemType.besar ? const Color(0xFFF6ECE1) : Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: selectedType == ItemType.besar ? AppColors.primary : AppColors.border,
                                width: selectedType == ItemType.besar ? 1.5 : 1,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.kitchen_outlined,
                                      size: 16,
                                      color: selectedType == ItemType.besar ? AppColors.primary : AppColors.textSecondary,
                                    ),
                                    const SizedBox(width: 6),
                                    const Text('Besar / Elektronik', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                const Text('Kulkas mini, kasur, kipas, lemari', style: TextStyle(fontSize: 10.5, color: AppColors.textSecondary)),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () {
                        final name = nameCtrl.text.trim();
                        if (name.isNotEmpty) {
                          setState(() {
                            _booking.items.add(
                              BookingItem(
                                id: 'item-${DateTime.now().millisecondsSinceEpoch}',
                                name: name,
                                type: selectedType,
                                quantity: 1,
                              ),
                            );
                          });
                          Navigator.pop(ctx);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      child: const Text('Simpan Barang', style: TextStyle(fontWeight: FontWeight.w800)),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _proceedToStep2() {
    if (_booking.items.isEmpty || _booking.totalItemCount == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Harap tambahkan minimal 1 barang titipan.'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (_booking.category == 'REJECT') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_booking.categoryReason),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
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
    final cat = _booking.category;
    final totalCount = _booking.totalItemCount;
    final price = _booking.storageSubtotal;
    final canPop = Navigator.canPop(context);

    return Scaffold(
      backgroundColor: const Color(0xFFFAF7F2),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFAF7F2),
        elevation: 0,
        titleSpacing: canPop ? 0 : 20,
        automaticallyImplyLeading: false,
        leading: canPop
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios_new, size: 20, color: AppColors.text),
                onPressed: () => Navigator.pop(context),
              )
            : null,
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
            // Stepper Progress Header
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
                        'Langkah 1 dari 3: Barang & Durasi',
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
                          'Langkah 1/3',
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
                            color: const Color(0xFFE8DACB),
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

            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Auto-Klasifikasi Pintar Card (Aturan Asli)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: cat == 'A'
                            ? const Color(0xFFF0FDF4)
                            : (cat == 'B' ? const Color(0xFFFFF7ED) : const Color(0xFFFEF2F2)),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: cat == 'A'
                              ? const Color(0xFF86EFAC)
                              : (cat == 'B' ? const Color(0xFFFDBA74) : const Color(0xFFFCA5A5)),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: cat == 'A'
                                  ? const Color(0xFFDCFCE7)
                                  : (cat == 'B' ? const Color(0xFFFFEDD5) : const Color(0xFFFEE2E2)),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              cat == 'A'
                                  ? Icons.check_circle_outline
                                  : (cat == 'B' ? Icons.stars_rounded : Icons.warning_amber_rounded),
                              size: 20,
                              color: cat == 'A'
                                  ? const Color(0xFF15803D)
                                  : (cat == 'B' ? const Color(0xFFC2410C) : const Color(0xFFB91C1C)),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      cat == 'A'
                                          ? 'Kategori A (Hemat)'
                                          : (cat == 'B' ? 'Kategori B (Lengkap)' : 'Kategori: $cat'),
                                      style: TextStyle(
                                        fontSize: 12.5,
                                        fontWeight: FontWeight.w800,
                                        color: cat == 'A'
                                            ? const Color(0xFF15803D)
                                            : (cat == 'B' ? const Color(0xFFC2410C) : const Color(0xFFB91C1C)),
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                                      decoration: BoxDecoration(
                                        color: cat == 'A'
                                            ? const Color(0xFF15803D).withOpacity(0.12)
                                            : const Color(0xFFC2410C).withOpacity(0.12),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        cat == 'A' ? 'Maks 3 Item Kecil' : 'Barang Besar / >3 Item',
                                        style: TextStyle(
                                          fontSize: 9,
                                          fontWeight: FontWeight.w700,
                                          color: cat == 'A' ? const Color(0xFF15803D) : const Color(0xFFC2410C),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  _booking.categoryReason,
                                  style: TextStyle(
                                    fontSize: 10.5,
                                    color: cat == 'A' ? const Color(0xFF4B7355) : const Color(0xFF7C5035),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Header List Barang
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Daftar Barang Titipan ($totalCount item)',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF2E2018),
                          ),
                        ),
                        GestureDetector(
                          onTap: _showAddItemDialog,
                          child: const Text(
                            '+ Tambah Barang',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w800,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    // List Item Barang
                    if (_booking.items.isEmpty)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8F3EC),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: const Color(0xFFECE2D5)),
                        ),
                        child: Center(
                          child: Column(
                            children: [
                              const Text('📦', style: TextStyle(fontSize: 32)),
                              const SizedBox(height: 8),
                              const Text(
                                'Belum ada barang ditambahkan',
                                style: TextStyle(color: Color(0xFF8C7A70), fontSize: 12, fontWeight: FontWeight.w500),
                              ),
                              const SizedBox(height: 10),
                              ElevatedButton(
                                onPressed: _showAddItemDialog,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                ),
                                child: const Text('Tambah Barang Pertama', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700)),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      ..._booking.items.map((item) {
                        final isBig = item.type == ItemType.besar;
                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8F3EC),
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: const Color(0xFFECE2D5)),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: isBig ? const Color(0xFFFFEDD5) : const Color(0xFFEFE3D3),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Center(
                                  child: Text(isBig ? '🛋️' : '📦', style: const TextStyle(fontSize: 18)),
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
                                        fontWeight: FontWeight.w800,
                                        fontSize: 13,
                                        color: Color(0xFF3B2C24),
                                      ),
                                    ),
                                    const SizedBox(height: 1),
                                    Text(
                                      isBig ? 'Barang Besar / Elektronik' : 'Barang Kecil / Sedang',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600,
                                        color: isBig ? const Color(0xFFC2410C) : const Color(0xFF8C7A70),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // Counter Qty
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: const Color(0xFFE0D3C5)),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        if (item.quantity == 1) {
                                          _removeItem(item);
                                        } else {
                                          _updateQuantity(item, -1);
                                        }
                                      },
                                      child: Container(
                                        width: 26,
                                        height: 26,
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFF5EDE4),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Icon(
                                          item.quantity == 1 ? Icons.delete_outline : Icons.remove,
                                          size: 15,
                                          color: item.quantity == 1 ? AppColors.error : AppColors.primary,
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      width: 24,
                                      child: Text(
                                        '${item.quantity}',
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w800,
                                          color: Color(0xFF2E2018),
                                        ),
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () => _updateQuantity(item, 1),
                                      child: Container(
                                        width: 26,
                                        height: 26,
                                        decoration: BoxDecoration(
                                          color: AppColors.primary,
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: const Icon(
                                          Icons.add,
                                          size: 15,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      }),

                    const SizedBox(height: 18),

                    // Pilihan Tipe Durasi (Harian / Mingguan / Bulanan)
                    const Text(
                      'Pilihan Durasi Penitipan',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF2E2018),
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Segmented Tipe Selector
                    Container(
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1EDE7),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFFE5DDD2)),
                      ),
                      child: Row(
                        children: ['Harian', 'Mingguan', 'Bulanan'].map((type) {
                          final isSelected = _booking.durationType == type;
                          return Expanded(
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _booking.durationType = type;
                                  _booking.durationCount = 1;
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                decoration: BoxDecoration(
                                  color: isSelected ? AppColors.primary : Colors.transparent,
                                  borderRadius: BorderRadius.circular(11),
                                  boxShadow: isSelected
                                      ? [
                                          BoxShadow(
                                            color: AppColors.primary.withOpacity(0.25),
                                            blurRadius: 4,
                                            offset: const Offset(0, 2),
                                          ),
                                        ]
                                      : null,
                                ),
                                child: Text(
                                  type,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                                    color: isSelected ? Colors.white : const Color(0xFF66554B),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),

                    const SizedBox(height: 10),

                    // Pilihan Nilai Durasi Berdasarkan Tipe
                    if (_booking.durationType == 'Harian')
                      _buildDurationOptions(
                        options: [1, 2, 3, 4, 5, 6, 7],
                        suffix: 'Hari',
                      )
                    else if (_booking.durationType == 'Mingguan')
                      _buildDurationOptions(
                        options: [1, 2, 3, 4],
                        suffix: 'Minggu',
                      )
                    else
                      _buildDurationOptions(
                        options: [1, 2, 3],
                        suffix: 'Bulan',
                        labels: {
                          1: '1 Bulan',
                          2: '2 Bulan',
                          3: '3 Bulan (Semester)',
                        },
                      ),

                    const SizedBox(height: 16),

                    // Benefit Gudang KosinAja Mini Card
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5EDE4).withOpacity(0.7),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFE8DACB)),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Row(
                            children: [
                              Text('🛡️', style: TextStyle(fontSize: 13)),
                              SizedBox(width: 4),
                              Text('Asuransi Resmi', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: Color(0xFF3B2C24))),
                            ],
                          ),
                          Text('•', style: TextStyle(color: Color(0xFFD4C2B0))),
                          Row(
                            children: [
                              Text('📹', style: TextStyle(fontSize: 13)),
                              SizedBox(width: 4),
                              Text('CCTV 24/7', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: Color(0xFF3B2C24))),
                            ],
                          ),
                          Text('•', style: TextStyle(color: Color(0xFFD4C2B0))),
                          Row(
                            children: [
                              Text('🚚', style: TextStyle(fontSize: 13)),
                              SizedBox(width: 4),
                              Text('Jemput ke Kos', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: Color(0xFF3B2C24))),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 10),
                  ],
                ),
              ),
            ),

            // Sticky Bottom Checkout Bar (Melayang di atas Bottom Nav Bar)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFFDFBF8),
                border: const Border(
                  top: BorderSide(color: Color(0xFFEDE5DA)),
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
                          'Subtotal Kat. $cat (${_booking.durationCount} ${_booking.durationType})',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF8C7A70),
                          ),
                        ),
                        const SizedBox(height: 1),
                        Text(
                          currencyFormat.format(price),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFFB86B35),
                          ),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: _proceedToStep2,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFB86B35),
                      foregroundColor: Colors.white,
                      elevation: 2,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Lanjut Jadwal',
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
      // Persistent Bottom Navigation Bar (Tab Booking Selalu Aktif)
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1,
        onTap: (index) {
          if (index == 0) {
            Navigator.pushReplacementNamed(context, '/home');
          } else if (index == 2) {
            Navigator.pushReplacementNamed(context, '/orders');
          } else if (index == 3) {
            Navigator.pushReplacementNamed(context, '/profile');
          }
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textSecondary,
        items: const [
          BottomNavigationBarItem(
            icon: ImageIcon(AssetImage('assets/images/icon_home.png')),
            activeIcon: ImageIcon(AssetImage('assets/images/icon_home_active.png')),
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

  Widget _buildDurationOptions({
    required List<int> options,
    required String suffix,
    Map<int, String>? labels,
  }) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: options.map((val) {
        final isSelected = _booking.durationCount == val;
        final displayText = labels != null && labels.containsKey(val) ? labels[val]! : '$val $suffix';

        return GestureDetector(
          onTap: () {
            setState(() {
              _booking.durationCount = val;
            });
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFFFDFBF8) : Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isSelected ? AppColors.primary : const Color(0xFFE5DDD2),
                width: isSelected ? 1.8 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(isSelected ? 0.04 : 0.01),
                  blurRadius: 4,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Text(
              displayText,
              style: TextStyle(
                color: isSelected ? const Color(0xFF985322) : const Color(0xFF3B2C24),
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
