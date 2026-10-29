/**
 * Unit Test Layanan Ongkir & Lokasi Kosinaja
 * Ditulis untuk tugas Alvin (Lokasi & History)
 * Menguji logika kalkulasi jarak Haversine, durasi, ongkir, surcharge, dan rute
 */

import 'package:flutter_test/flutter_test.dart';
import 'package:kosinaja_flutter/core/services/shipping_calculator.dart';
import 'package:kosinaja_flutter/models/location_model.dart';

void main() {
  group('Unit Test: Perhitungan Jarak (Haversine Formula)', () {
    test('Jarak antar koordinat yang sama harus 0 km', () {
      final unp = ShippingCalculator.padangPresets.firstWhere((p) => p.id == 'unp-air-tawar');
      final dist = ShippingCalculator.calculateStraightDistanceKm(
        unp.coordinate,
        unp.coordinate,
      );
      expect(dist, 0.0);
    });

    test('Jarak dari Gudang Kosinaja (Air Tawar) ke Kampus UNP Air Tawar harus sangat dekat (< 1 km)', () {
      final unp = ShippingCalculator.padangPresets.firstWhere((p) => p.id == 'unp-air-tawar');
      final dist = ShippingCalculator.calculateStraightDistanceKm(
        ShippingCalculator.depoPadang,
        unp.coordinate,
      );
      expect(dist, lessThan(1.0));
      expect(dist, greaterThanOrEqualTo(0.0));
    });

    test('Jarak dari Gudang Kosinaja ke UNAND Limau Manis harus sekitar 11 - 14 km garis lurus', () {
      final unand = ShippingCalculator.padangPresets.firstWhere((p) => p.id == 'unand-limau-manis');
      final dist = ShippingCalculator.calculateStraightDistanceKm(
        ShippingCalculator.depoPadang,
        unand.coordinate,
      );
      expect(dist, greaterThanOrEqualTo(10.0));
      expect(dist, lessThanOrEqualTo(14.0));
    });

    test('Jarak bersifat simetris (A ke B sama dengan B ke A)', () {
      final pnp = ShippingCalculator.padangPresets.firstWhere((p) => p.id == 'pnp-limau-manis');
      final upi = ShippingCalculator.padangPresets.firstWhere((p) => p.id == 'upi-yptk');

      final distAB = ShippingCalculator.calculateStraightDistanceKm(pnp.coordinate, upi.coordinate);
      final distBA = ShippingCalculator.calculateStraightDistanceKm(upi.coordinate, pnp.coordinate);

      expect(distAB, equals(distBA));
    });
  });

  group('Unit Test: Estimasi Jarak Jalan & Durasi Perjalanan', () {
    test('Estimasi jarak jalan raya menerapkan winding factor 1.25x dan dibulatkan 1 desimal', () {
      const straightKm = 10.0;
      final roadKm = ShippingCalculator.calculateRoadDistanceKm(straightKm);
      expect(roadKm, 12.5);
    });

    test('Jarak 0 menghasilkan jarak jalan 0', () {
      expect(ShippingCalculator.calculateRoadDistanceKm(0.0), 0.0);
    });

    test('Durasi mencakup waktu tempuh (25 km/jam) ditambah buffer penjemputan 10 menit', () {
      // 12.5 km / 25 km/jam = 0.5 jam (30 menit) + 10 menit buffer = 40 menit
      final duration = ShippingCalculator.calculateDurationMinutes(12.5);
      expect(duration, 40);
    });

    test('Jarak 0 menghasilkan durasi 0 menit', () {
      expect(ShippingCalculator.calculateDurationMinutes(0.0), 0);
    });
  });

  group('Unit Test: Format Rupiah', () {
    test('Format nominal uang ke format Rupiah standar Indonesia', () {
      expect(ShippingCalculator.formatRupiah(10000), contains('10.000'));
      expect(ShippingCalculator.formatRupiah(15000), contains('15.000'));
      expect(ShippingCalculator.formatRupiah(1250000), contains('1.250.000'));
    });
  });

  group('Unit Test: Generator Tautan Rute Google Maps', () {
    test('Menghasilkan URL rute Google Maps resmi yang valid dengan parameter driving', () {
      const origin = LocationCoordinate(latitude: -0.898, longitude: 100.352);
      const destination = LocationCoordinate(latitude: -0.915, longitude: 100.4583);

      final url = ShippingCalculator.generateGoogleMapsRouteUrl(origin, destination);

      expect(url, startsWith('https://www.google.com/maps/dir/?api=1'));
      expect(url, contains('origin=-0.898,100.352'));
      expect(url, contains('destination=-0.915,100.4583'));
      expect(url, contains('travelmode=driving'));
    });
  });

  group('Unit Test: Perhitungan Ongkir Kosinaja (Skenario Bisnis)', () {
    test('Skenario 1: Penjemputan di radius <= 3 km (UNP Air Tawar) Kategori A', () {
      final unp = ShippingCalculator.padangPresets.firstWhere((p) => p.id == 'unp-air-tawar');
      final result = ShippingCalculator.calculateShipping(
        pickupLocation: unp.coordinate,
        category: 'A',
        itemCount: 2,
      );

      expect(result.isCustomQuotation, isFalse);
      expect(result.baseCost, 10000);
      expect(result.distanceCost, 0, reason: 'Jarak <= 3 km tidak ada biaya tambahan');
      expect(result.categorySurcharge, 0, reason: 'Kategori A tidak ada surcharge armada');
      expect(result.totalCost, 10000);
      expect(result.formattedTotalCost, contains('10.000'));
    });

    test('Skenario 2: Penjemputan jarak sedang/jauh (UNAND Limau Manis) Kategori A', () {
      final unand = ShippingCalculator.padangPresets.firstWhere((p) => p.id == 'unand-limau-manis');
      final result = ShippingCalculator.calculateShipping(
        pickupLocation: unand.coordinate,
        category: 'A',
        itemCount: 3,
      );

      expect(result.isCustomQuotation, isFalse);
      expect(result.baseCost, 10000);
      expect(result.roadDistanceKm, greaterThan(3.0));
      expect(result.distanceCost, greaterThan(0));
      expect(result.categorySurcharge, 0);

      final expectedExtraKm = (result.roadDistanceKm - 3.0).ceil();
      expect(result.distanceCost, expectedExtraKm * 2500);
      expect(result.totalCost, 10000 + result.distanceCost);
    });

    test('Skenario 3: Penjemputan Kategori B (Elektronik/Besar, kulkas/kasur busa) mendapat surcharge Rp 15.000', () {
      final unp = ShippingCalculator.padangPresets.firstWhere((p) => p.id == 'unp-air-tawar');
      final result = ShippingCalculator.calculateShipping(
        pickupLocation: unp.coordinate,
        category: 'B',
        itemCount: 2,
      );

      expect(result.isCustomQuotation, isFalse);
      expect(result.baseCost, 10000);
      expect(result.categorySurcharge, 15000);
      expect(result.totalCost, 25000);
      expect(result.formattedTotalCost, contains('25.000'));
    });

    test('Skenario 4: Kendaraan bermotor (hasVehicle = true) otomatis masuk Custom Quotation', () {
      final unp = ShippingCalculator.padangPresets.first;
      final result = ShippingCalculator.calculateShipping(
        pickupLocation: unp.coordinate,
        category: 'A',
        itemCount: 1,
        hasVehicle: true,
      );

      expect(result.isCustomQuotation, isTrue);
      expect(result.quotationReason, contains('kendaraan bermotor'));
      expect(result.formattedTotalCost, 'Custom Quotation (Hubungi Admin)');
    });

    test('Skenario 5: Volume besar (> 7 item) otomatis masuk Custom Quotation', () {
      final unp = ShippingCalculator.padangPresets.first;
      final result = ShippingCalculator.calculateShipping(
        pickupLocation: unp.coordinate,
        category: 'B',
        itemCount: 8,
      );

      expect(result.isCustomQuotation, isTrue);
      expect(result.quotationReason, contains('> 7 item'));
      expect(result.formattedTotalCost, 'Custom Quotation (Hubungi Admin)');
    });

    test('Skenario 6: Kategori Custom eksplisit menghasilkan flag custom quotation', () {
      final unp = ShippingCalculator.padangPresets.first;
      final result = ShippingCalculator.calculateShipping(
        pickupLocation: unp.coordinate,
        category: 'Custom',
        itemCount: 1,
      );

      expect(result.isCustomQuotation, isTrue);
    });
  });
}
