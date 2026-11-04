enum ItemType { kecil, besar, custom, reject }

class BookingItem {
  final String id;
  String name;
  ItemType type;
  int quantity;

  BookingItem({
    required this.id,
    required this.name,
    this.type = ItemType.kecil,
    this.quantity = 1,
  });

  BookingItem copyWith({
    String? id,
    String? name,
    ItemType? type,
    int? quantity,
  }) {
    return BookingItem(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      quantity: quantity ?? this.quantity,
    );
  }
}

class BookingData {
  List<BookingItem> items;
  String durationType; // 'Harian', 'Mingguan', 'Bulanan'
  int durationCount; // e.g. 1, 2, 3
  String campus;
  String kosAddress;
  String kosNote;
  DateTime pickupDate;
  String pickupSession;
  int deliveryFee;
  String paymentMethod;

  // Layanan Pengantaran & Pengemasan
  String deliveryMethod; // 'JEMPUT_KURIR' atau 'ANTAR_SENDIRI'
  String packingMethod; // 'PACKING_SENDIRI' atau 'JASA_PACKING'
  int packingFee; // 15000 jika JASA_PACKING, 0 jika PACKING_SENDIRI
  double pickupDistanceKm;
  String pickupHubName;
  double? userLatitude;
  double? userLongitude;

  BookingData({
    List<BookingItem>? items,
    this.durationType = 'Bulanan',
    this.durationCount = 1,
    this.campus = 'Padang Barat / Pusat Kota',
    this.kosAddress = '',
    this.kosNote = '',
    DateTime? pickupDate,
    this.pickupSession = 'Pagi (08:30 - 11:30)',
    this.deliveryFee = 0,
    this.paymentMethod = 'QRIS',
    this.deliveryMethod = 'JEMPUT_KURIR',
    this.packingMethod = 'PACKING_SENDIRI',
    this.packingFee = 0,
    this.pickupDistanceKm = 0.0,
    this.pickupHubName = 'Gudang Pusat Kosinaja Padang',
    this.userLatitude,
    this.userLongitude,
  })  : items = items ?? [],
        pickupDate = pickupDate ?? DateTime.now().add(const Duration(days: 1));

  // Menghitung total seluruh item yang dipilih
  int get totalItemCount => items.fold(0, (sum, i) => sum + i.quantity);

  // Auto-Klasifikasi Pintar
  String get category {
    final total = totalItemCount;
    if (total == 0) return 'A';

    // Cek barang terlarang
    if (items.any((i) => i.type == ItemType.reject && i.quantity > 0)) {
      return 'REJECT';
    }

    // Cek custom (kendaraan atau jumlah > 7 item)
    if (items.any((i) => i.type == ItemType.custom && i.quantity > 0) || total > 7) {
      return 'CUSTOM';
    }

    // Cek Kategori B (ada barang besar/elektronik ATAU total item > 3)
    if (items.any((i) => i.type == ItemType.besar && i.quantity > 0) || total > 3) {
      return 'B';
    }

    // Kategori A (barang kecil/sedang maksimal 3 item)
    return 'A';
  }

  // Label penjelasan klasifikasi
  String get categoryReason {
    final cat = category;
    final total = totalItemCount;
    if (cat == 'REJECT') {
      return 'Mengandung barang yang dilarang (senjata, narkoba, makanan basah, hewan, dll).';
    }
    if (cat == 'CUSTOM') {
      return 'Kendaraan bermotor atau volume barang lebih dari 7 item (Konsultasi khusus admin).';
    }
    if (cat == 'B') {
      final hasBig = items.any((i) => i.type == ItemType.besar && i.quantity > 0);
      if (hasBig && total > 3) {
        return 'Terdapat barang besar/elektronik dan total barang melebihi 3 item.';
      } else if (hasBig) {
        return 'Terdapat barang besar atau peralatan elektronik.';
      } else {
        return 'Total barang ($total item) melebihi batas 3 item barang kecil.';
      }
    }
    return 'Barang kecil/sedang dengan jumlah maksimal 3 item.';
  }

  // Menghitung Tarif Sesuai Matriks Resmi Kosinaja
  int get storageSubtotal {
    final cat = category;
    if (cat == 'REJECT' || cat == 'CUSTOM') return 0;

    if (cat == 'A') {
      if (durationType == 'Harian') {
        final days = durationCount.clamp(1, 7);
        return days * 10000;
      } else if (durationType == 'Mingguan') {
        final weeks = durationCount.clamp(1, 4);
        return weeks * 55000;
      } else {
        // Bulanan
        if (durationCount == 1) return 199000;
        if (durationCount == 2) return 379000;
        return 499000;
      }
    } else {
      // Kategori B
      if (durationType == 'Harian') {
        final days = durationCount.clamp(1, 7);
        return days * 18000;
      } else if (durationType == 'Mingguan') {
        final weeks = durationCount.clamp(1, 4);
        return weeks * 95000;
      } else {
        // Bulanan
        if (durationCount == 1) return 299000;
        if (durationCount == 2) return 499000;
        return 699000;
      }
    }
  }

  int get effectiveDeliveryFee => deliveryMethod == 'ANTAR_SENDIRI' ? 0 : deliveryFee;

  int get effectivePackingFee =>
      (deliveryMethod == 'JEMPUT_KURIR' && packingMethod == 'JASA_PACKING') ? packingFee : 0;

  int get discount => 0;

  int get grandTotal {
    final sub = storageSubtotal;
    if (sub == 0) return 0;
    final total = sub + effectiveDeliveryFee + effectivePackingFee - discount;
    return total > 0 ? total : 0;
  }
}
