/**
 * Model Lokasi, Koordinat, dan Perhitungan Ongkir Kosinaja
 * Ditulis untuk modul Alvin (Lokasi & History)
 */

class LocationCoordinate {
  final double latitude;
  final double longitude;
  final String? name;
  final String? address;

  const LocationCoordinate({
    required this.latitude,
    required this.longitude,
    this.name,
    this.address,
  });

  Map<String, dynamic> toJson() => {
    'latitude': latitude,
    'longitude': longitude,
    'name': name,
    'address': address,
  };

  factory LocationCoordinate.fromJson(Map<String, dynamic> json) {
    return LocationCoordinate(
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      name: json['name'] as String?,
      address: json['address'] as String?,
    );
  }
}

enum PresetCategory { kampus, kos, depo }

class PresetLocation {
  final String id;
  final String name;
  final String shortName;
  final PresetCategory category;
  final LocationCoordinate coordinate;
  final String address;
  final String? description;

  const PresetLocation({
    required this.id,
    required this.name,
    required this.shortName,
    required this.category,
    required this.coordinate,
    required this.address,
    this.description,
  });
}

class ShippingCalculation {
  final LocationCoordinate origin;
  final LocationCoordinate destination;
  final double straightDistanceKm;
  final double roadDistanceKm;
  final int durationMinutes;
  final int baseCost;
  final int distanceCost;
  final int categorySurcharge;
  final int totalCost;
  final bool isCustomQuotation;
  final String? quotationReason;
  final String googleMapsRouteUrl;
  final String formattedTotalCost;

  const ShippingCalculation({
    required this.origin,
    required this.destination,
    required this.straightDistanceKm,
    required this.roadDistanceKm,
    required this.durationMinutes,
    required this.baseCost,
    required this.distanceCost,
    required this.categorySurcharge,
    required this.totalCost,
    required this.isCustomQuotation,
    this.quotationReason,
    required this.googleMapsRouteUrl,
    required this.formattedTotalCost,
  });
}
