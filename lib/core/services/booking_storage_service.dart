import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';

class BookingStorageService {
  static const String _ordersKey = 'kosinaja_orders_history';
  static const String _receiptsKey = 'kosinaja_saved_receipts';

  /// Menyimpan atau memperbarui pesanan ke database lokal (persisten di memori perangkat)
  /// dan otomatis mencoba sinkronisasi ke server API
  static Future<bool> saveOrder(Map<String, dynamic> order) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final existingRaw = prefs.getString(_ordersKey);
      List<dynamic> list = [];
      if (existingRaw != null && existingRaw.isNotEmpty) {
        try {
          list = jsonDecode(existingRaw) as List<dynamic>;
        } catch (_) {
          list = [];
        }
      }

      final orderCode = order['orderCode'] ?? order['kodeBooking'] ?? '';
      if (orderCode.isEmpty) return false;

      // Cek apakah sudah ada di list
      final index = list.indexWhere((it) => (it['orderCode'] ?? it['kodeBooking']) == orderCode);
      if (index >= 0) {
        // Gabungkan data lama dengan update baru
        final oldData = Map<String, dynamic>.from(list[index] as Map);
        oldData.addAll(order);
        oldData['updatedAt'] = DateTime.now().toIso8601String();
        list[index] = oldData;
      } else {
        final newOrder = Map<String, dynamic>.from(order);
        newOrder['createdAt'] = newOrder['createdAt'] ?? DateTime.now().toIso8601String();
        newOrder['updatedAt'] = DateTime.now().toIso8601String();
        list.insert(0, newOrder);
      }

      await prefs.setString(_ordersKey, jsonEncode(list));

      // Upayakan kirim/sinkron ke database API backend jika payload valid
      _syncToBackend(order);

      return true;
    } catch (e) {
      debugPrint('[BookingStorageService] Gagal menyimpan pesanan: $e');
      return false;
    }
  }

  /// Mengambil semua pesanan riil pengguna dari database lokal
  static Future<List<Map<String, dynamic>>> getOrders() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_ordersKey);
      if (raw != null && raw.isNotEmpty) {
        final List<dynamic> decoded = jsonDecode(raw);
        if (decoded.isNotEmpty) {
          return decoded.map((e) => Map<String, dynamic>.from(e as Map)).toList();
        }
      }

      // Inisialisasi awal dengan pesanan aktif berbasis user saat ini jika database masih kosong
      final user = ApiService.currentUser;
      final userName = (user != null && user.nama.isNotEmpty) ? user.nama : 'Pelanggan KosinAja';
      final userPhone = (user != null && user.noWa.isNotEmpty) ? user.noWa : '082169393475';
      final userAddr = (user != null && user.alamat != null && user.alamat!.isNotEmpty)
          ? user.alamat!
          : 'Kawasan Kos Pasar Baru, Padang';

      final initialOrder = {
        'orderCode': 'KOS-782941',
        'nama': userName,
        'noWa': userPhone,
        'userId': user?.id,
        'title': '2x Koper Pakaian, 1x Kipas Angin Standar',
        'subtitle': 'Kategori A • Hub Hotel Ibis Padang',
        'kategori': 'A',
        'status': 'Menunggu Penjemputan',
        'statusType': 'active',
        'paymentStatus': 'PAID',
        'totalHarga': 199000,
        'price': 'Rp 199.000',
        'date': DateFormat('d MMM yyyy', 'id_ID').format(DateTime.now()),
        'schedule': '1 Bulan (30 Hari)',
        'startDate': DateTime.now().toIso8601String(),
        'durationCount': 1,
        'durationType': 'Bulanan',
        'pickupSession': 'Pagi (08:30 - 11:30 WIB)',
        'metodePickup': 'PICKUP',
        'metodeDelivery': 'DELIVERY',
        'paymentMethod': 'QRIS Instant',
        'alamat': userAddr,
        'items': [
          {'nama': 'Koper Pakaian (Sedang)', 'jumlah': 2, 'tipe': 'kecil'},
          {'nama': 'Kipas Angin Standar', 'jumlah': 1, 'tipe': 'kecil'},
        ],
      };

      await saveOrder(initialOrder);
      return [initialOrder];
    } catch (e) {
      debugPrint('[BookingStorageService] Gagal membaca pesanan: $e');
      return [];
    }
  }

  /// Mengambil detail pesanan tertentu berdasarkan kode resi / orderCode
  static Future<Map<String, dynamic>?> getOrderByCode(String orderCode) async {
    final list = await getOrders();
    for (final item in list) {
      if ((item['orderCode'] ?? item['kodeBooking']) == orderCode) {
        return item;
      }
    }
    return null;
  }

  /// Memperbarui status perpanjangan durasi & batas waktu di database
  static Future<bool> updateOrderExtension({
    required String orderCode,
    required int additionalDays,
    required String newExpiryDateStr,
    required String priceStr,
    required String paymentMethod,
  }) async {
    final existing = await getOrderByCode(orderCode) ?? {};
    existing['orderCode'] = orderCode;
    existing['additionalDays'] = (existing['additionalDays'] ?? 0) + additionalDays;
    existing['expiryDate'] = newExpiryDateStr;
    existing['paymentStatus'] = 'PAID';
    existing['lastExtensionPrice'] = priceStr;
    existing['lastPaymentMethod'] = paymentMethod;
    existing['status'] = 'Aktif Disimpan (Diperpanjang)';
    existing['updatedAt'] = DateTime.now().toIso8601String();

    return await saveOrder(existing);
  }

  /// Menyimpan bukti resi digital ke database perangkat (koleksi resi tersimpan)
  static Future<bool> saveReceipt({
    required String orderCode,
    required String receiptText,
    required Map<String, dynamic> receiptMeta,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final rawReceipts = prefs.getString(_receiptsKey);
      List<dynamic> receipts = [];
      if (rawReceipts != null && rawReceipts.isNotEmpty) {
        try {
          receipts = jsonDecode(rawReceipts) as List<dynamic>;
        } catch (_) {}
      }

      final now = DateTime.now().toIso8601String();
      final receiptItem = {
        'orderCode': orderCode,
        'receiptText': receiptText,
        'savedAt': now,
        'meta': receiptMeta,
      };

      final idx = receipts.indexWhere((r) => r['orderCode'] == orderCode);
      if (idx >= 0) {
        receipts[idx] = receiptItem;
      } else {
        receipts.insert(0, receiptItem);
      }

      await prefs.setString(_receiptsKey, jsonEncode(receipts));

      // Update flag di order history
      final order = await getOrderByCode(orderCode) ?? {};
      order['orderCode'] = orderCode;
      order['isReceiptSaved'] = true;
      order['receiptSavedAt'] = now;
      await saveOrder(order);

      return true;
    } catch (e) {
      debugPrint('[BookingStorageService] Gagal menyimpan resi: $e');
      return false;
    }
  }

  /// Memeriksa apakah resi pesanan ini sudah pernah disimpan
  static Future<bool> isReceiptSaved(String orderCode) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_receiptsKey);
      if (raw == null || raw.isEmpty) return false;
      final List<dynamic> list = jsonDecode(raw);
      return list.any((r) => r['orderCode'] == orderCode);
    } catch (_) {
      return false;
    }
  }

  /// Sinkronisasi latar belakang ke API backend KosinAja jika payload lengkap
  static Future<void> _syncToBackend(Map<String, dynamic> order) async {
    try {
      if (order['backendSynced'] == true) return;
      if (order['payload'] is Map<String, dynamic>) {
        final res = await ApiService.createBooking(order['payload']);
        if (res['success'] == true) {
          order['backendSynced'] = true;
        }
      }
    } catch (_) {}
  }

  /// Format teks resi resmi yang elegan, rapi, dan siap dibagikan ke WhatsApp / dicetak
  static String formatReceiptShareText({
    required String orderCode,
    required String userName,
    required String userPhone,
    required String warehouse,
    required String itemsSummary,
    required String periodStr,
    required String totalCost,
    required String paymentMethod,
    required String logistics,
    String? status,
  }) {
    return '''📦 *RESI PENITIPAN RESMI KOSINAJA* 📦
----------------------------------------
No. Resi       : #$orderCode
Status         : ${status ?? 'Aktif Disimpan'}
Penyimpan      : $userName ($userPhone)
Gudang Hub     : $warehouse
Barang         : $itemsSummary
Masa Simpan    : $periodStr
Total Biaya    : $totalCost (LUNAS)
Metode Bayar   : $paymentMethod
Logistik       : $logistics
----------------------------------------
📍 *Lacak Penitipan Real-Time:*
https://www.kosinaja.id/track/$orderCode

_Disimpan & Dikelola Aman oleh KosinAja Padang_
_Layanan CS WhatsApp: 0821-6939-3475_''';
  }
}

