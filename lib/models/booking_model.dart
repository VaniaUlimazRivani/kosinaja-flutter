class BookingItem {
  final String id;
  final String name;
  final String category;
  final int monthlyPrice;
  int quantity;

  BookingItem({
    required this.id,
    required this.name,
    required this.category,
    required this.monthlyPrice,
    this.quantity = 0,
  });

  BookingItem copyWith({
    String? id,
    String? name,
    String? category,
    int? monthlyPrice,
    int? quantity,
  }) {
    return BookingItem(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      monthlyPrice: monthlyPrice ?? this.monthlyPrice,
      quantity: quantity ?? this.quantity,
    );
  }
}

class BookingData {
  List<BookingItem> items;
  String durationType; // 'Bulanan', 'Mingguan', 'Harian'
  int durationCount; // e.g. 1
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

  BookingData({
    List<BookingItem>? items,
    this.durationType = 'Bulanan',
    this.durationCount = 1,
    this.campus = 'UNAND Limau Manih',
    this.kosAddress = 'Kosan Melati, Blok B No. 4, Pasar Baru Pauh',
    this.kosNote = 'Pagar hitam samping warung nasi Ampera',
    DateTime? pickupDate,
    this.pickupSession = 'Pagi (08:30 - 11:30 WIB)',
    this.deliveryFee = 15000,
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
  })  : items = items ?? [],
        pickupDate = pickupDate ?? DateTime.now().add(const Duration(days: 1));

  int get storageSubtotal {
    int total = 0;
    for (final item in items) {
      if (durationType == 'Bulanan') {
        total += item.monthlyPrice * item.quantity * durationCount;
      } else if (durationType == 'Mingguan') {
        total += ((item.monthlyPrice / 3).round()) * item.quantity * durationCount;
      } else {
        total += ((item.monthlyPrice / 15).round()) * item.quantity * durationCount;
      }
    }
    return total;
  }

  int get discount => 10000;

  int get grandTotal {
    final sub = storageSubtotal;
    if (sub == 0) return 0;
    final total = sub + deliveryFee - discount;
    return total > 0 ? total : 0;
  }
}
