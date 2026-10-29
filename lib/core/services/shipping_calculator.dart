/**
 * Layanan Kalkulator Jarak, Estimasi Durasi, Ongkir, dan Google Maps Kosinaja
 * Ditulis untuk modul Alvin (Lokasi & History)
 */

import 'dart:math' as math;
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/location_model.dart';

class ShippingCalculator {
  // Radius bumi dalam kilometer
  static const double earthRadiusKm = 6371.0;
  // Faktor kelokan jalan raya perkotaan Padang
  static const double roadWindingFactor = 1.25;
  // Kecepatan rata-rata kurir penjemputan (km/jam)
  static const double averageSpeedKmh = 25.0;
  // Buffer penjemputan & muat barang (menit)
  static const int pickupBufferMinutes = 10;
  // Batas jarak dasar (km)
  static const double baseDistanceKm = 3.0;
  // Tarif dasar penjemputan (Rp)
  static const int baseCostIdr = 10000;
  // Tarif per km tambahan di atas 3 km (Rp)
  static const int perKmCostIdr = 2500;
  // Surcharge Kategori B (pikap / armada besar)
  static const int categoryBSurcharge = 15000;
  // Batas maksimal item standar sebelum masuk Custom Quotation
  static const int maxStandardItems = 7;

  /// Gudang Pusat Kosinaja Padang (Air Tawar)
  static const LocationCoordinate depoPadang = LocationCoordinate(
    latitude: -0.8980,
    longitude: 100.3520,
    name: 'Gudang Pusat Kosinaja Padang',
    address: 'Jl. Prof. Dr. Hamka No. 42, Air Tawar Barat, Kec. Padang Utara, Kota Padang',
  );

  /// Daftar Preset Kampus dan Area Kos Populer di Kota Padang
  static const List<PresetLocation> padangPresets = [
    // --- KAMPUS UTAMA PADANG ---
    PresetLocation(
      id: 'unp-air-tawar',
      name: 'Universitas Negeri Padang (UNP)',
      shortName: 'UNP',
      category: PresetCategory.kampus,
      coordinate: LocationCoordinate(
        latitude: -0.8971,
        longitude: 100.3507,
        name: 'UNP Air Tawar',
        address: 'Jl. Prof. Dr. Hamka, Air Tawar Barat, Kec. Padang Utara, Kota Padang',
      ),
      address: 'Jl. Prof. Dr. Hamka, Air Tawar Barat, Kec. Padang Utara, Kota Padang',
      description: 'Kampus Utama Air Tawar Padang',
    ),
    PresetLocation(
      id: 'unand-limau-manis',
      name: 'Universitas Andalas (UNAND)',
      shortName: 'UNAND',
      category: PresetCategory.kampus,
      coordinate: LocationCoordinate(
        latitude: -0.9150,
        longitude: 100.4583,
        name: 'UNAND Limau Manis',
        address: 'Limau Manis, Kec. Pauh, Kota Padang, Sumatera Barat',
      ),
      address: 'Limau Manis, Kec. Pauh, Kota Padang, Sumatera Barat',
      description: 'Kampus Limau Manis, Pauh',
    ),
    PresetLocation(
      id: 'upi-yptk',
      name: 'Universitas Putra Indonesia "YPTK"',
      shortName: 'UPI YPTK',
      category: PresetCategory.kampus,
      coordinate: LocationCoordinate(
        latitude: -0.9760,
        longitude: 100.3957,
        name: 'UPI YPTK Lubuk Begalung',
        address: 'Jl. Raya Lubuk Begalung, Kec. Lubuk Begalung, Kota Padang',
      ),
      address: 'Jl. Raya Lubuk Begalung, Kec. Lubuk Begalung, Kota Padang',
      description: 'Kampus Lubuk Begalung',
    ),
    PresetLocation(
      id: 'ubh-ulak-karang',
      name: 'Universitas Bung Hatta (UBH) - Kampus 1',
      shortName: 'UBH Kampus 1',
      category: PresetCategory.kampus,
      coordinate: LocationCoordinate(
        latitude: -0.9022,
        longitude: 100.3542,
        name: 'UBH Ulak Karang',
        address: 'Jl. Sumatera, Ulak Karang Utara, Kec. Padang Utara, Kota Padang',
      ),
      address: 'Jl. Sumatera, Ulak Karang Utara, Kec. Padang Utara, Kota Padang',
      description: 'Kampus 1 Ulak Karang',
    ),
    PresetLocation(
      id: 'ubh-aie-pacah',
      name: 'Universitas Bung Hatta (UBH) - Kampus 2',
      shortName: 'UBH Kampus 2',
      category: PresetCategory.kampus,
      coordinate: LocationCoordinate(
        latitude: -0.8719,
        longitude: 100.3846,
        name: 'UBH Aie Pacah',
        address: 'Jl. Bagindo Aziz Chan By Pass, Aie Pacah, Koto Tangah, Kota Padang',
      ),
      address: 'Jl. Bagindo Aziz Chan By Pass, Aie Pacah, Koto Tangah, Kota Padang',
      description: 'Kampus 2 By Pass Aie Pacah',
    ),
    PresetLocation(
      id: 'pnp-limau-manis',
      name: 'Politeknik Negeri Padang (PNP)',
      shortName: 'PNP',
      category: PresetCategory.kampus,
      coordinate: LocationCoordinate(
        latitude: -0.9133,
        longitude: 100.4650,
        name: 'PNP Limau Manis',
        address: 'Kampus Limau Manis, Kec. Pauh, Kota Padang',
      ),
      address: 'Kampus Limau Manis, Kec. Pauh, Kota Padang',
      description: 'Kawasan Kampus Limau Manis',
    ),
    PresetLocation(
      id: 'itp-nanggalo',
      name: 'Institut Teknologi Padang (ITP)',
      shortName: 'ITP',
      category: PresetCategory.kampus,
      coordinate: LocationCoordinate(
        latitude: -0.9064,
        longitude: 100.3664,
        name: 'ITP Gajah Mada',
        address: 'Jl. Gajah Mada, Kandis, Nanggalo, Kota Padang',
      ),
      address: 'Jl. Gajah Mada, Kandis, Nanggalo, Kota Padang',
      description: 'Kampus Jl. Gajah Mada',
    ),
    PresetLocation(
      id: 'uin-sungai-bangek',
      name: 'UIN Imam Bonjol - Kampus 3',
      shortName: 'UIN Kampus 3',
      category: PresetCategory.kampus,
      coordinate: LocationCoordinate(
        latitude: -0.8197,
        longitude: 100.3644,
        name: 'UIN Imam Bonjol Sungai Bangek',
        address: 'Sungai Bangek, Balai Gadang, Koto Tangah, Kota Padang',
      ),
      address: 'Sungai Bangek, Balai Gadang, Koto Tangah, Kota Padang',
      description: 'Kampus III Sungai Bangek',
    ),
    PresetLocation(
      id: 'uin-lubuk-lintah',
      name: 'UIN Imam Bonjol - Kampus 2',
      shortName: 'UIN Kampus 2',
      category: PresetCategory.kampus,
      coordinate: LocationCoordinate(
        latitude: -0.9250,
        longitude: 100.3820,
        name: 'UIN Imam Bonjol Lubuk Lintah',
        address: 'Jl. Prof. Mahmud Yunus, Lubuk Lintah, Kec. Kuranji, Kota Padang',
      ),
      address: 'Jl. Prof. Mahmud Yunus, Lubuk Lintah, Kec. Kuranji, Kota Padang',
      description: 'Kampus II Lubuk Lintah',
    ),

    // --- AREA KOS POPULER PADANG ---
    PresetLocation(
      id: 'kos-air-tawar-barat',
      name: 'Area Kos Air Tawar Barat (UNP & Pantai)',
      shortName: 'Kos Air Tawar Barat',
      category: PresetCategory.kos,
      coordinate: LocationCoordinate(
        latitude: -0.8995,
        longitude: 100.3485,
        name: 'Kos Air Tawar Barat',
        address: 'Jl. Cenderawasih / Belibis, Air Tawar Barat, Kec. Padang Utara, Kota Padang',
      ),
      address: 'Jl. Cenderawasih / Belibis, Air Tawar Barat, Kec. Padang Utara, Kota Padang',
      description: 'Pusat kos mahasiswa UNP & UBH',
    ),
    PresetLocation(
      id: 'kos-air-tawar-timur',
      name: 'Area Kos Air Tawar Timur (Belakang UNP)',
      shortName: 'Kos Air Tawar Timur',
      category: PresetCategory.kos,
      coordinate: LocationCoordinate(
        latitude: -0.8942,
        longitude: 100.3541,
        name: 'Kos Air Tawar Timur',
        address: 'Jl. Merpati / Enggang, Air Tawar Timur, Kec. Padang Utara, Kota Padang',
      ),
      address: 'Jl. Merpati / Enggang, Air Tawar Timur, Kec. Padang Utara, Kota Padang',
      description: 'Area kos timur rel UNP',
    ),
    PresetLocation(
      id: 'kos-pasar-baru-unand',
      name: 'Area Kos Pasar Baru (Gerbang Utama UNAND)',
      shortName: 'Kos Pasar Baru UNAND',
      category: PresetCategory.kos,
      coordinate: LocationCoordinate(
        latitude: -0.9231,
        longitude: 100.4385,
        name: 'Kos Pasar Baru Pauh',
        address: 'Jl. Pasar Baru, Cupak Tangah, Kec. Pauh, Kota Padang',
      ),
      address: 'Jl. Pasar Baru, Cupak Tangah, Kec. Pauh, Kota Padang',
      description: 'Hunian utama mahasiswa UNAND & PNP',
    ),
    PresetLocation(
      id: 'kos-bandar-buat',
      name: 'Area Kos Bandar Buat / Simpang Gadut',
      shortName: 'Kos Bandar Buat',
      category: PresetCategory.kos,
      coordinate: LocationCoordinate(
        latitude: -0.9452,
        longitude: 100.4180,
        name: 'Kos Bandar Buat',
        address: 'Jl. Raya Bandar Buat, Kec. Lubuk Kilangan, Kota Padang',
      ),
      address: 'Jl. Raya Bandar Buat, Kec. Lubuk Kilangan, Kota Padang',
      description: 'Akses ke arah kampus UNAND dan Indarung',
    ),
    PresetLocation(
      id: 'kos-lubeg-aru',
      name: 'Area Kos Lubuk Begalung / Aru (Dekat UPI YPTK)',
      shortName: 'Kos Lubeg / Aru',
      category: PresetCategory.kos,
      coordinate: LocationCoordinate(
        latitude: -0.9725,
        longitude: 100.3921,
        name: 'Kos Aru Lubuk Begalung',
        address: 'Jl. Aru Indah / Kampung Jua, Kec. Lubuk Begalung, Kota Padang',
      ),
      address: 'Jl. Aru Indah / Kampung Jua, Kec. Lubuk Begalung, Kota Padang',
      description: 'Kawasan kos mahasiswa UPI YPTK',
    ),
    PresetLocation(
      id: 'kos-siteba-nanggalo',
      name: 'Area Kos Siteba & Surau Gadang (Dekat ITP)',
      shortName: 'Kos Siteba / Nanggalo',
      category: PresetCategory.kos,
      coordinate: LocationCoordinate(
        latitude: -0.8920,
        longitude: 100.3712,
        name: 'Kos Siteba',
        address: 'Jl. Raya Siteba, Surau Gadang, Kec. Nanggalo, Kota Padang',
      ),
      address: 'Jl. Raya Siteba, Surau Gadang, Kec. Nanggalo, Kota Padang',
      description: 'Kawasan kos kuliner mahasiswa',
    ),
    PresetLocation(
      id: 'kos-gunung-pangilun',
      name: 'Area Kos Gunung Pangilun',
      shortName: 'Kos Gng. Pangilun',
      category: PresetCategory.kos,
      coordinate: LocationCoordinate(
        latitude: -0.9175,
        longitude: 100.3648,
        name: 'Kos Gunung Pangilun',
        address: 'Jl. Gunung Pangilun, Kec. Padang Utara, Kota Padang',
      ),
      address: 'Jl. Gunung Pangilun, Kec. Padang Utara, Kota Padang',
      description: 'Akses Khatib Sulaiman dan Air Tawar',
    ),
    PresetLocation(
      id: 'kos-ulak-karang',
      name: 'Area Kos Ulak Karang (Dekat UBH)',
      shortName: 'Kos Ulak Karang',
      category: PresetCategory.kos,
      coordinate: LocationCoordinate(
        latitude: -0.9068,
        longitude: 100.3556,
        name: 'Kos Ulak Karang',
        address: 'Jl. S. Parman / Lolong Belanti, Kec. Padang Utara, Kota Padang',
      ),
      address: 'Jl. S. Parman / Lolong Belanti, Kec. Padang Utara, Kota Padang',
      description: 'Kawasan kos pinggir kota & dekat pantai',
    ),
  ];

  static double _deg2rad(double deg) => deg * (math.pi / 180.0);

  /// Menghitung jarak garis lurus menggunakan Rumus Haversine
  static double calculateStraightDistanceKm(
    LocationCoordinate p1,
    LocationCoordinate p2,
  ) {
    if (p1.latitude == p2.latitude && p1.longitude == p2.longitude) {
      return 0.0;
    }

    final dLat = _deg2rad(p2.latitude - p1.latitude);
    final dLon = _deg2rad(p2.longitude - p1.longitude);

    final lat1 = _deg2rad(p1.latitude);
    final lat2 = _deg2rad(p2.latitude);

    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.sin(dLon / 2) * math.sin(dLon / 2) * math.cos(lat1) * math.cos(lat2);

    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    final distance = earthRadiusKm * c;

    return (distance * 100).round() / 100.0;
  }

  /// Menghitung estimasi jarak rute jalan raya (faktor kelokan 1.25x)
  static double calculateRoadDistanceKm(double straightKm) {
    if (straightKm <= 0) return 0.0;
    return ((straightKm * roadWindingFactor) * 10).round() / 10.0;
  }

  /// Menghitung estimasi durasi tempuh penjemputan (dalam menit)
  static int calculateDurationMinutes(double roadKm) {
    if (roadKm <= 0) return 0;
    final travelHours = roadKm / averageSpeedKmh;
    final travelMinutes = travelHours * 60;
    return (travelMinutes + pickupBufferMinutes).ceil();
  }

  /// Format nominal mata uang ke Rupiah Indonesia
  static String formatRupiah(num amount) {
    return NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(amount);
  }

  /// Menghasilkan URL resmi Google Maps Directions
  static String generateGoogleMapsRouteUrl(
    LocationCoordinate origin,
    LocationCoordinate destination,
  ) {
    final orig = '${origin.latitude},${origin.longitude}';
    final dest = '${destination.latitude},${destination.longitude}';
    return 'https://www.google.com/maps/dir/?api=1&origin=$orig&destination=$dest&travelmode=driving';
  }

  /// Membuka rute Google Maps secara langsung di HP/Browser
  static Future<bool> launchGoogleMapsRoute(
    LocationCoordinate origin,
    LocationCoordinate destination,
  ) async {
    final urlStr = generateGoogleMapsRouteUrl(origin, destination);
    final uri = Uri.parse(urlStr);
    try {
      if (await canLaunchUrl(uri)) {
        return await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        final searchUri = Uri.parse(
          'https://www.google.com/maps/search/?api=1&query=${destination.latitude},${destination.longitude}',
        );
        return await launchUrl(searchUri, mode: LaunchMode.externalApplication);
      }
    } catch (_) {
      return false;
    }
  }

  /// Fungsi Utama: Menghitung ongkir dan rincian penjemputan Kosinaja
  static ShippingCalculation calculateShipping({
    required LocationCoordinate pickupLocation,
    LocationCoordinate? warehouseLocation,
    String category = 'A',
    int itemCount = 1,
    bool hasVehicle = false,
  }) {
    final origin = warehouseLocation ?? depoPadang;
    final destination = pickupLocation;

    // 1. Jarak
    final straightDistanceKm = calculateStraightDistanceKm(origin, destination);
    final roadDistanceKm = calculateRoadDistanceKm(straightDistanceKm);

    // 2. Durasi
    final durationMinutes = calculateDurationMinutes(roadDistanceKm);

    // 3. Cek Custom Quotation (> 7 item atau ada kendaraan)
    final bool isCustomQuotation =
        category == 'Custom' || hasVehicle || itemCount > maxStandardItems;

    String? quotationReason;
    if (isCustomQuotation) {
      if (hasVehicle) {
        quotationReason =
            'Terdapat kendaraan bermotor. Membutuhkan armada pikap/towing khusus dan penawaran langsung admin.';
      } else if (itemCount > maxStandardItems) {
        quotationReason =
            'Total $itemCount barang melebihi kapasitas standar (> 7 item / lebih dari 1 pikap). Membutuhkan penawaran khusus admin.';
      } else {
        quotationReason = 'Penawaran kustom berdasarkan permintaan khusus.';
      }
    }

    // 4. Hitung Komponen Biaya
    final baseCost = baseCostIdr;
    int distanceCost = 0;

    if (roadDistanceKm > baseDistanceKm) {
      final extraDistance = roadDistanceKm - baseDistanceKm;
      final extraKm = extraDistance.ceil();
      distanceCost = extraKm * perKmCostIdr;
    }

    int categorySurcharge = 0;
    if (category == 'B' && !isCustomQuotation) {
      categorySurcharge = categoryBSurcharge;
    }

    final totalCost = baseCost + distanceCost + categorySurcharge;
    final googleMapsRouteUrl = generateGoogleMapsRouteUrl(origin, destination);

    return ShippingCalculation(
      origin: origin,
      destination: destination,
      straightDistanceKm: straightDistanceKm,
      roadDistanceKm: roadDistanceKm,
      durationMinutes: durationMinutes,
      baseCost: baseCost,
      distanceCost: distanceCost,
      categorySurcharge: categorySurcharge,
      totalCost: totalCost,
      isCustomQuotation: isCustomQuotation,
      quotationReason: quotationReason,
      googleMapsRouteUrl: googleMapsRouteUrl,
      formattedTotalCost: isCustomQuotation
          ? 'Custom Quotation (Hubungi Admin)'
          : formatRupiah(totalCost),
    );
  }
}
