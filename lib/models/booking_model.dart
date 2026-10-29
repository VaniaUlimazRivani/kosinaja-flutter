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
  String pickupSession; // 'Pagi (08:30 - 11:30)', 'Siang (13:00 - 15:30)', 'Sore (16:00 - 18:00)'
  int deliveryFee;
  String paymentMethod;

  BookingData({
    List<BookingItem>? items,
    this.durationType = 'Bulanan',
    this.durationCount = 1,
    this.campus = 'UNAND Limau Manih',
    this.kosAddress = 'Kosan Melati, Blok B No. 4, Pasar Baru Pauh',
    this.kosNote = 'Pagar hitam samping warung nasi Ampera',
    DateTime? pickupDate,
    this.pickupSession = 'Pagi (08:30 - 11:30)',
    this.deliveryFee = 15000,
    this.paymentMethod = 'QRIS',
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
