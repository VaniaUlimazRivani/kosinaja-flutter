import 'dart:math';
import 'package:latlong2/latlong.dart';

class WarehouseLocation {
  final String nama;
  final String alamat;
  final double lat;
  final double lng;

  const WarehouseLocation({
    required this.nama,
    required this.alamat,
    required this.lat,
    required this.lng,
  });

  LatLng get toLatLng => LatLng(lat, lng);
}

/// Pusat Patokan Penjemputan / Gudang Utama Kosinaja (Hotel Ibis Padang)
const KOSINAJA_WAREHOUSE = WarehouseLocation(
  nama: 'Kosinaja Central Hub (Patokan: Hotel Ibis Padang)',
  alamat: 'Jl. Tamansiswa No.1A (Area Hotel Ibis), Alai Parak Kopi, Kec. Padang Utara, Kota Padang',
  lat: -0.9294,
  lng: 100.3632,
);

class PresetLokasi {
  final String id;
  final String nama;
  final String area;
  final String kategori; // 'Kampus' | 'Kawasan Kos' | 'Area / Landmark'
  final String deskripsi;
  final double lat;
  final double lng;

  const PresetLokasi({
    required this.id,
    required this.nama,
    required this.area,
    required this.kategori,
    required this.deskripsi,
    required this.lat,
    required this.lng,
  });

  LatLng get toLatLng => LatLng(lat, lng);
}

const List<PresetLokasi> PRESET_LOKASI_PADANG = [
  // Kampus & Perguruan Tinggi
  PresetLokasi(
    id: 'unp_air_tawar',
    nama: 'Universitas Negeri Padang (UNP)',
    area: 'Padang Utara',
    kategori: 'Kampus',
    deskripsi: 'Kampus Utama UNP Air Tawar, Jl. Prof. Dr. Hamka',
    lat: -0.8970,
    lng: 100.3520,
  ),
  PresetLokasi(
    id: 'unand_limau_manis',
    nama: 'Universitas Andalas (UNAND)',
    area: 'Pauh',
    kategori: 'Kampus',
    deskripsi: 'Kampus Limau Manis, Gedung Perkuliahan & Asrama',
    lat: -0.9146,
    lng: 100.4586,
  ),
  PresetLokasi(
    id: 'upi_yptk',
    nama: 'UPI YPTK Padang',
    area: 'Lubuk Begalung',
    kategori: 'Kampus',
    deskripsi: 'Jl. Raya Lubuk Begalung No. 1',
    lat: -0.9620,
    lng: 100.3950,
  ),
  PresetLokasi(
    id: 'ubh_ulak_karang',
    nama: 'Universitas Bung Hatta (Kampus 1)',
    area: 'Padang Barat',
    kategori: 'Kampus',
    deskripsi: 'Jl. Sumatera, Ulak Karang',
    lat: -0.9150,
    lng: 100.3540,
  ),
  PresetLokasi(
    id: 'ubh_aiapacah',
    nama: 'Universitas Bung Hatta (Kampus 2)',
    area: 'Koto Tangah',
    kategori: 'Kampus',
    deskripsi: 'Jl. Bypass Aia Pacah',
    lat: -0.8520,
    lng: 100.3700,
  ),
  PresetLokasi(
    id: 'pnp_limau_manis',
    nama: 'Politeknik Negeri Padang (PNP)',
    area: 'Limau Manis',
    kategori: 'Kampus',
    deskripsi: 'Kampus Limau Manis Pauh',
    lat: -0.9135,
    lng: 100.4605,
  ),
  PresetLokasi(
    id: 'itp_gunung_pangilun',
    nama: 'Institut Teknologi Padang (ITP)',
    area: 'Padang Utara',
    kategori: 'Kampus',
    deskripsi: 'Jl. Gajah Mada, Gn. Pangilun',
    lat: -0.9090,
    lng: 100.3750,
  ),
  PresetLokasi(
    id: 'uin_lubuk_lintah',
    nama: 'UIN Imam Bonjol (Kampus 2)',
    area: 'Kuranji',
    kategori: 'Kampus',
    deskripsi: 'Jl. Prof. Mahmud Yunus, Lubuk Lintah',
    lat: -0.9320,
    lng: 100.3980,
  ),
  PresetLokasi(
    id: 'poltekkes_padang',
    nama: 'Poltekkes Kemenkes Padang',
    area: 'Nanggalo',
    kategori: 'Kampus',
    deskripsi: 'Jl. Simpang Pondok Kopi, Siteba',
    lat: -0.8920,
    lng: 100.3780,
  ),
  PresetLokasi(
    id: 'fk_unand_jati',
    nama: 'Fakultas Kedokteran UNAND (Jati)',
    area: 'Padang Timur',
    kategori: 'Kampus',
    deskripsi: 'Jl. Perintis Kemerdekaan, Jati (RSUP M. Djamil)',
    lat: -0.9380,
    lng: 100.3680,
  ),

  // Kawasan Kos Mahasiswa Populer
  PresetLokasi(
    id: 'kos_air_tawar_barat',
    nama: 'Kawasan Kos Air Tawar Barat (UNP)',
    area: 'Padang Utara',
    kategori: 'Kawasan Kos',
    deskripsi: 'Jl. Cendrawasih, Merpati, Belibis, Cendrawasih Baru',
    lat: -0.8950,
    lng: 100.3480,
  ),
  PresetLokasi(
    id: 'kos_air_tawar_timur',
    nama: 'Kawasan Kos Air Tawar Timur',
    area: 'Padang Utara',
    kategori: 'Kawasan Kos',
    deskripsi: 'Jl. Tunggul Hitam & belakang UNP',
    lat: -0.8980,
    lng: 100.3560,
  ),
  PresetLokasi(
    id: 'kos_pasar_baru_unand',
    nama: 'Kawasan Kos Pasar Baru (UNAND)',
    area: 'Pauh',
    kategori: 'Kawasan Kos',
    deskripsi: 'Gerbang Bawah Unand, sentra kos & kuliner mahasiswa',
    lat: -0.9250,
    lng: 100.4420,
  ),
  PresetLokasi(
    id: 'kos_kapalo_koto',
    nama: 'Kawasan Kos Kapalo Koto & Laluan',
    area: 'Pauh',
    kategori: 'Kawasan Kos',
    deskripsi: 'Kawasan kos perumahan mahasiswa Pauh',
    lat: -0.9310,
    lng: 100.4350,
  ),
  PresetLokasi(
    id: 'kos_piai_limau_manis',
    nama: 'Kawasan Kos Piai Tangah',
    area: 'Pauh',
    kategori: 'Kawasan Kos',
    deskripsi: 'Dekat kampus Unand & Politeknik',
    lat: -0.9350,
    lng: 100.4480,
  ),
  PresetLokasi(
    id: 'kos_lubeg_gurun_laweh',
    nama: 'Kawasan Kos Lubuk Begalung (UPI)',
    area: 'Lubuk Begalung',
    kategori: 'Kawasan Kos',
    deskripsi: 'Gurun Laweh, Banuaran dekat kampus UPI YPTK',
    lat: -0.9580,
    lng: 100.3920,
  ),
  PresetLokasi(
    id: 'kos_ulak_karang',
    nama: 'Kawasan Kos Ulak Karang (UBH)',
    area: 'Padang Barat',
    kategori: 'Kawasan Kos',
    deskripsi: 'Jl. Bahari, Medan, sekitar UBH Kampus 1',
    lat: -0.9170,
    lng: 100.3520,
  ),
  PresetLokasi(
    id: 'kos_gunung_pangilun',
    nama: 'Kawasan Kos Gunung Pangilun',
    area: 'Padang Utara',
    kategori: 'Kawasan Kos',
    deskripsi: 'Sekitar ITP, STIKES, dan RS Ibnu Sina',
    lat: -0.9120,
    lng: 100.3700,
  ),
  PresetLokasi(
    id: 'kos_siteba',
    nama: 'Kawasan Kos Siteba & Nanggalo',
    area: 'Nanggalo',
    kategori: 'Kawasan Kos',
    deskripsi: 'Jl. Raya Siteba & Pasar Nanggalo',
    lat: -0.8880,
    lng: 100.3800,
  ),
  PresetLokasi(
    id: 'kos_lapai',
    nama: 'Kawasan Kos Kampung Lapai',
    area: 'Nanggalo',
    kategori: 'Kawasan Kos',
    deskripsi: 'Kawasan strategis dekat Jl. Khatib Sulaiman',
    lat: -0.9020,
    lng: 100.3680,
  ),
  PresetLokasi(
    id: 'kos_kuranji',
    nama: 'Kawasan Kos Kuranji / Kalumbuk',
    area: 'Kuranji',
    kategori: 'Kawasan Kos',
    deskripsi: 'Korong Gadang & Kalumbuk',
    lat: -0.9180,
    lng: 100.4050,
  ),
  PresetLokasi(
    id: 'kos_tarandam_sawahan',
    nama: 'Kawasan Kos Sawahan / Tarandam',
    area: 'Padang Timur',
    kategori: 'Kawasan Kos',
    deskripsi: 'Pusat kota, Simpang Haru, Stasiun Padang',
    lat: -0.9450,
    lng: 100.3680,
  ),

  // Landmark Pusat
  PresetLokasi(
    id: 'hotel_ibis_area',
    nama: 'Area Hotel Ibis Padang (Hub Pusat)',
    area: 'Padang Utara',
    kategori: 'Area / Landmark',
    deskripsi: 'Jl. Tamansiswa No. 1A, Alai Parak Kopi (Gratis Ongkir)',
    lat: -0.9294,
    lng: 100.3632,
  ),
];

/// Menghitung jarak garis lurus (Haversine) dalam KM antara 2 koordinat
/// dikalikan faktor jalan berliku Kota Padang (~1.25)
double hitungJarakKm(double lat1, double lng1, double lat2, double lng2) {
  const double R = 6371.0; // Radius bumi dalam KM
  final double dLat = (lat2 - lat1) * (pi / 180.0);
  final double dLng = (lng2 - lng1) * (pi / 180.0);
  final double a = sin(dLat / 2) * sin(dLat / 2) +
      cos(lat1 * (pi / 180.0)) * cos(lat2 * (pi / 180.0)) * sin(dLng / 2) * sin(dLng / 2);
  final double c = 2 * atan2(sqrt(a), sqrt(1 - a));
  final double straightKm = R * c;

  final double roadKm = straightKm * 1.25;
  return (roadKm * 10).round() / 10.0;
}

/// Menghitung ongkir dasar berdasarkan jarak sesuai:
/// 💰 Daftar Harga Bike & Delivery Komah
/// - 100 m – 2,2 km ➜ 6k
/// - 2,3 – 3,0 km ➜ 7k
/// - 3,1 – 4,0 km ➜ 8k
/// - 4,1 – 4,5 km ➜ 9k
/// - 4,6 – 5,0 km ➜ 10k
/// - 5,1 – 5,5 km ➜ 11k
/// - 5,6 – 6,0 km ➜ 12k
/// - 6,1 – 6,5 km ➜ 13k
/// - 6,6 – 7,0 km ➜ 14k
/// - 7,1 – 7,5 km ➜ 15k
/// - 7,6 – 8,0 km ➜ 16k
/// - 8,1 – 8,5 km ➜ 17k
/// - 8,6 – 9,0 km ➜ 18k
/// - 9,1 – 9,5 km ➜ 19k
/// - 9,6 – 10 km ➜ 20k
/// - 11 km (10.1 - 11.0 km) ➜ 24k
/// - 12 km (11.1 - 12.0 km) ➜ 26k
/// - 13 km (12.1 - 13.0 km) ➜ 28k
/// - 14 km (13.1 - 14.0 km) ➜ 30k
/// - 15 km (14.1 - 15.0 km) ➜ 32k
/// - 16 km (15.1 - 16.0 km) ➜ 34k
/// - 17 km (16.1 - 17.0 km) ➜ 36k
/// - 18 km (17.1 - 18.0 km) ➜ 38k
/// - 19 km (18.1 - 19.0 km) ➜ 40k
/// - 20 km (19.1 - 20.0 km) ➜ 43k
/// - 21 km (20.1 - 21.0 km) ➜ 45k
/// - 22 km (21.1 - 22.0 km) ➜ 47k
/// - 23 km (22.1 - 23.0 km) ➜ 49k
/// - 24 km (23.1 - 24.0 km) ➜ 51k
/// - 25 km (24.1 - 25.0 km) ➜ 55k
/// - > 25 km ➜ 55k + 3k/km
int hitungTarifDasarOngkir(double jarakKm) {
  if (jarakKm <= 2.2) return 6000;
  if (jarakKm <= 3.0) return 7000;
  if (jarakKm <= 4.0) return 8000;
  if (jarakKm <= 4.5) return 9000;
  if (jarakKm <= 5.0) return 10000;
  if (jarakKm <= 5.5) return 11000;
  if (jarakKm <= 6.0) return 12000;
  if (jarakKm <= 6.5) return 13000;
  if (jarakKm <= 7.0) return 14000;
  if (jarakKm <= 7.5) return 15000;
  if (jarakKm <= 8.0) return 16000;
  if (jarakKm <= 8.5) return 17000;
  if (jarakKm <= 9.0) return 18000;
  if (jarakKm <= 9.5) return 19000;
  if (jarakKm <= 10.0) return 20000;
  if (jarakKm <= 11.0) return 24000;
  if (jarakKm <= 12.0) return 26000;
  if (jarakKm <= 13.0) return 28000;
  if (jarakKm <= 14.0) return 30000;
  if (jarakKm <= 15.0) return 32000;
  if (jarakKm <= 16.0) return 34000;
  if (jarakKm <= 17.0) return 36000;
  if (jarakKm <= 18.0) return 38000;
  if (jarakKm <= 19.0) return 40000;
  if (jarakKm <= 20.0) return 43000;
  if (jarakKm <= 21.0) return 45000;
  if (jarakKm <= 22.0) return 47000;
  if (jarakKm <= 23.0) return 49000;
  if (jarakKm <= 24.0) return 51000;
  if (jarakKm <= 25.0) return 55000;

  final double sisaKm = jarakKm - 25.0;
  return 55000 + (sisaKm.ceil() * 3000);
}

class KalkulasiOngkirResult {
  final double jarakKm;
  final int durasiMenit;
  final bool isRealRoute;
  final int ongkirPickup;
  final int ongkirDelivery;
  final int surchargeKategori;
  final int totalOngkir;
  final String deskripsiJarak;
  final List<LatLng> routeCoordinates;

  const KalkulasiOngkirResult({
    required this.jarakKm,
    required this.durasiMenit,
    required this.isRealRoute,
    required this.ongkirPickup,
    required this.ongkirDelivery,
    required this.surchargeKategori,
    required this.totalOngkir,
    required this.deskripsiJarak,
    this.routeCoordinates = const [],
  });
}

/// Menghitung ongkir lengkap (jemput, delivery, surcharge kategori)
KalkulasiOngkirResult kalkulasiOngkirLengkap({
  required double destLat,
  required double destLng,
  String kategori = 'A',
  String metodePickup = 'PICKUP', // 'PICKUP' | 'SELF_DROPOFF'
  String metodeDelivery = 'DELIVERY', // 'DELIVERY' | 'SELF_PICKUP'
  double? customDistanceKm,
  int? customDurationMin,
  bool isRealRoute = true,
  List<LatLng> routeCoords = const [],
}) {
  final double jarak = customDistanceKm ??
      hitungJarakKm(
        KOSINAJA_WAREHOUSE.lat,
        KOSINAJA_WAREHOUSE.lng,
        destLat,
        destLng,
      );

  final int durasi = customDurationMin ?? max(5, (jarak * 2.5).round());

  // Biaya dasar per perjalanan berdasarkan jarak (Daftar Harga Bike & Delivery Komah)
  final int tarifDasar = hitungTarifDasarOngkir(jarak);

  // Surcharge kategori per leg (Kategori B: 5k, Kategori C: 10k, Custom/D: 15k)
  final String katNorm = kategori.toUpperCase();
  int surchargePerLeg = 0;
  if (katNorm == 'B') {
    surchargePerLeg = 5000;
  } else if (katNorm == 'C') {
    surchargePerLeg = 10000;
  } else if (katNorm == 'CUSTOM' || katNorm == 'D') {
    surchargePerLeg = 15000;
  }

  // Hitung leg pickup
  final int ongkirPickup =
      metodePickup == 'PICKUP' ? (tarifDasar + surchargePerLeg) : 0;

  // Hitung leg delivery
  final int ongkirDelivery =
      metodeDelivery == 'DELIVERY' ? (tarifDasar + surchargePerLeg) : 0;

  final int totalSurcharge = (metodePickup == 'PICKUP' ? surchargePerLeg : 0) +
      (metodeDelivery == 'DELIVERY' ? surchargePerLeg : 0);

  final int totalOngkir = ongkirPickup + ongkirDelivery;

  final String deskripsiJarak = '$jarak km dari Hub (~$durasi Menit)';

  return KalkulasiOngkirResult(
    jarakKm: jarak,
    durasiMenit: durasi,
    isRealRoute: isRealRoute,
    ongkirPickup: ongkirPickup,
    ongkirDelivery: ongkirDelivery,
    surchargeKategori: totalSurcharge,
    totalOngkir: totalOngkir,
    deskripsiJarak: deskripsiJarak,
    routeCoordinates: routeCoords.isNotEmpty
        ? routeCoords
        : [
            KOSINAJA_WAREHOUSE.toLatLng,
            LatLng(destLat, destLng),
          ],
  );
}
