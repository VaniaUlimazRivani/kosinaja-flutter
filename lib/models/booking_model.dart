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

  String get category {
    switch (type) {
      case ItemType.kecil:
        return 'A';
      case ItemType.besar:
        return 'B';
      case ItemType.custom:
        return 'CUSTOM';
      case ItemType.reject:
        return 'REJECT';
    }
  }

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
  String pickupSession; // 'Pagi (08:30 - 11:30 WIB)', 'Siang (13:00 - 15:30 WIB)', 'Sore (16:00 - 18:00 WIB)'
  int deliveryFee;
  String paymentMethod;

  // Koordinat & Metode Logistik Lengkap (seperti SafeTitip LocationPicker)
  double latitude;
  double longitude;
  String lokasiNama;
  double jarakKm;
  int durasiMenit;
  String metodePickup; // 'PICKUP' (Dijemput Kurir) | 'SELF_DROPOFF' (Antar ke Hub)
  String metodeDelivery; // 'DELIVERY' (Diantar Kurir) | 'SELF_PICKUP' (Ambil di Hub)
  int ongkirPickup;
  int ongkirDelivery;

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
    this.pickupSession = 'Pagi (08:30 - 11:30 WIB)',
    this.deliveryFee = 0,
    this.paymentMethod = 'QRIS',
    this.latitude = -0.9294,
    this.longitude = 100.3632,
    this.lokasiNama = 'Kawasan Kos Pasar Baru (UNAND)',
    this.jarakKm = 8.5,
    this.durasiMenit = 20,
    this.metodePickup = 'PICKUP',
    this.metodeDelivery = 'DELIVERY',
    this.ongkirPickup = 15000,
    this.ongkirDelivery = 15000,
    this.deliveryMethod = 'JEMPUT_KURIR',
    this.packingMethod = 'PACKING_SENDIRI',
    this.packingFee = 0,
    this.pickupDistanceKm = 8.5,
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

  int get effectiveDeliveryFee {
    int total = 0;
    if (metodePickup == 'PICKUP') {
      total += ongkirPickup;
    }
    if (metodeDelivery == 'DELIVERY') {
      total += ongkirDelivery;
    }
    return total;
  }

  int get effectivePackingFee =>
      (metodePickup == 'PICKUP' && packingMethod == 'JASA_PACKING') ? packingFee : 0;

  int get discount => 0;

  int get grandTotal {
    final sub = storageSubtotal;
    if (sub == 0) return 0;
    final total = sub + effectiveDeliveryFee + effectivePackingFee - discount;
    return total > 0 ? total : 0;
  }
}
