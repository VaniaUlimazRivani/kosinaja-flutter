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
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
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
                              borderRadius: BorderRadius.circular(12),
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
                              borderRadius: BorderRadius.circular(12),
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
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Simpan Barang', style: TextStyle(fontWeight: FontWeight.w700)),
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
        ),
      );
      return;
    }

    if (_booking.category == 'REJECT') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_booking.categoryReason),
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
    final cat = _booking.category;
    final totalCount = _booking.totalItemCount;
    final price = _booking.storageSubtotal;

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

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. HEADER LIST BARANG
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Daftar Barang Titipan ($totalCount item)',
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w800,
                                color: AppColors.text,
                              ),
                        ),
                        TextButton.icon(
                          onPressed: _showAddItemDialog,
                          icon: const Icon(Icons.add, size: 16, color: AppColors.primary),
                          label: const Text(
                            'Tambah Barang',
                            style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700, fontSize: 12),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    // LIST ITEM
                    if (_booking.items.isEmpty)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Center(
                          child: Column(
                            children: [
                              const Icon(Icons.inbox_outlined, size: 36, color: AppColors.textMuted),
                              const SizedBox(height: 8),
                              const Text('Belum ada barang ditambahkan', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                              const SizedBox(height: 8),
                              ElevatedButton(
                                onPressed: _showAddItemDialog,
                                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                                child: const Text('Tambah Barang Pertama', style: TextStyle(color: Colors.white)),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      ..._booking.items.map((item) {
                        final isBig = item.type == ItemType.besar;
                        return Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: isBig ? const Color(0xFFFFF3E0) : const Color(0xFFF1F5F9),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(
                                  isBig ? Icons.kitchen_outlined : Icons.inventory_2_outlined,
                                  color: isBig ? const Color(0xFFE65100) : AppColors.primary,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.name,
                                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppColors.text),
                                    ),
                                    const SizedBox(height: 2),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: isBig ? const Color(0xFFFFF3E0) : const Color(0xFFEFF6FF),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        isBig ? 'Barang Besar / Elektronik' : 'Barang Kecil / Sedang',
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w700,
                                          color: isBig ? const Color(0xFFE65100) : const Color(0xFF1D4ED8),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // Counter - & +
                              Row(
                                children: [
                                  IconButton(
                                    visualDensity: VisualDensity.compact,
                                    onPressed: () => _updateQuantity(item, -1),
                                    icon: const Icon(Icons.remove_circle_outline, size: 20, color: AppColors.textSecondary),
                                  ),
                                  Text(
                                    '${item.quantity}',
                                    style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
                                  ),
                                  IconButton(
                                    visualDensity: VisualDensity.compact,
                                    onPressed: () => _updateQuantity(item, 1),
                                    icon: const Icon(Icons.add_circle, size: 20, color: AppColors.primary),
                                  ),
                                  IconButton(
                                    visualDensity: VisualDensity.compact,
                                    onPressed: () => _removeItem(item),
                                    icon: const Icon(Icons.delete_outline, size: 18, color: Color(0xFFEF4444)),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      }).toList(),

                    const SizedBox(height: 14),

                    // 2. LIVE CLASSIFICATION BADGE CARD
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: cat == 'A'
                            ? const Color(0xFFF0FDF4)
                            : (cat == 'B' ? const Color(0xFFFFF7ED) : const Color(0xFFFEF2F2)),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: cat == 'A'
                              ? const Color(0xFF86EFAC)
                              : (cat == 'B' ? const Color(0xFFFDBA74) : const Color(0xFFFCA5A5)),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                cat == 'A'
                                    ? Icons.check_circle_outline
                                    : (cat == 'B' ? Icons.stars_outlined : Icons.warning_amber_rounded),
                                size: 18,
                                color: cat == 'A'
                                    ? const Color(0xFF15803D)
                                    : (cat == 'B' ? const Color(0xFFC2410C) : const Color(0xFFB91C1C)),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                cat == 'A'
                                    ? 'Klasifikasi: Kategori A (Hemat)'
                                    : (cat == 'B'
                                        ? 'Klasifikasi: Kategori B (Lengkap / Besar)'
                                        : 'Klasifikasi: $cat'),
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                  color: cat == 'A'
                                      ? const Color(0xFF15803D)
                                      : (cat == 'B' ? const Color(0xFFC2410C) : const Color(0xFFB91C1C)),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            _booking.categoryReason,
                            style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary, height: 1.35),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 22),

                    // 3. PILIHAN DURASI PENITIPAN
                    Text(
                      'Pilih Durasi Penitipan',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: AppColors.text,
                          ),
                    ),
                    const SizedBox(height: 10),

                    // Tab Pilihan: Harian | Mingguan | Bulanan
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          _buildDurationTab('Harian'),
                          _buildDurationTab('Mingguan'),
                          _buildDurationTab('Bulanan'),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Selector Count
                    if (_booking.durationType == 'Harian')
                      _buildCountChips(
                        label: 'Pilih Jumlah Hari',
                        options: [1, 2, 3, 4, 5, 6, 7],
                        suffix: 'Hari',
                      )
                    else if (_booking.durationType == 'Mingguan')
                      _buildCountChips(
                        label: 'Pilih Jumlah Minggu',
                        options: [1, 2, 3, 4],
                        suffix: 'Minggu',
                      )
                    else
                      _buildCountChips(
                        label: 'Pilih Jumlah Bulan',
                        options: [1, 2, 3],
                        suffix: 'Bulan',
                      ),

                    const SizedBox(height: 16),

                    // CARD RINCIAN HARGA PAKET RESMI
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Tarif Paket Kategori $cat (${_booking.durationCount} ${_booking.durationType})',
                                style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w600),
                              ),
                              Text(
                                currencyFormat.format(price),
                                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: AppColors.primary),
                              ),
                            ],
                          ),
                          const Divider(height: 16),
                          Row(
                            children: [
                              const Icon(Icons.info_outline, size: 14, color: AppColors.textMuted),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  cat == 'A'
                                      ? 'Maks 3 barang kecil • Bebas biaya per item'
                                      : 'Barang >3 item / Elektronik & Besar • Bebas biaya per item',
                                  style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
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

            // 4. STICKY BOTTOM CHECKOUT BAR
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 10,
                    offset: const Offset(0, -4),
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
                          'Paket Kategori $cat • ${_booking.durationCount} ${_booking.durationType}',
                          style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          currencyFormat.format(price),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: AppColors.text,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 48,
                    child: ElevatedButton(
                      onPressed: _proceedToStep2,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('Lanjut', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
                          SizedBox(width: 6),
                          Icon(Icons.arrow_forward_rounded, size: 16),
                        ],
                      ),
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

  Widget _buildDurationTab(String title) {
    final isSelected = _booking.durationType == title;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _booking.durationType = title;
            _booking.durationCount = 1;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              color: isSelected ? Colors.white : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCountChips({
    required String label,
    required List<int> options,
    required String suffix,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: options.map((val) {
            final isSelected = _booking.durationCount == val;
            return ChoiceChip(
              label: Text('$val $suffix'),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  setState(() {
                    _booking.durationCount = val;
                  });
                }
              },
              selectedColor: AppColors.primary,
              backgroundColor: Colors.white,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : AppColors.text,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                fontSize: 12,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: BorderSide(
                  color: isSelected ? AppColors.primary : AppColors.border,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
