import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import '../core/services/api_service.dart';
import '../core/services/ongkir_service.dart';
import '../core/theme/app_colors.dart';
import '../models/booking_model.dart';

class LocationPickerResult {
  final LatLng coordinate;
  final String namaTempat;
  final String alamatDetail;
  final String patokan;
  final String metodePickup;
  final String metodeDelivery;
  final KalkulasiOngkirResult kalkulasi;

  const LocationPickerResult({
    required this.coordinate,
    required this.namaTempat,
    required this.alamatDetail,
    required this.patokan,
    required this.metodePickup,
    required this.metodeDelivery,
    required this.kalkulasi,
  });
}

class LocationPickerWidget extends StatefulWidget {
  final BookingData booking;
  final ValueChanged<LocationPickerResult>? onLocationChanged;

  const LocationPickerWidget({
    super.key,
    required this.booking,
    this.onLocationChanged,
  });

  @override
  State<LocationPickerWidget> createState() => _LocationPickerWidgetState();
}

class _LocationPickerWidgetState extends State<LocationPickerWidget> {
  final MapController _mapController = MapController();
  final TextEditingController _searchCtrl = TextEditingController();
  final TextEditingController _addressCtrl = TextEditingController();
  final TextEditingController _noteCtrl = TextEditingController();
  final FocusNode _searchFocus = FocusNode();

  final currencyFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

  // Status koordinat & nama lokasi terpilih
  late LatLng _selectedPoint;
  late String _selectedPlaceName;
  late String _metodePickup;
  late String _metodeDelivery;

  // Search autocomplete & routing state
  Timer? _debounceTimer;
  bool _isSearching = false;
  bool _isRouting = false;
  List<Map<String, dynamic>> _searchSuggestions = [];
  bool _showSuggestions = false;

  // Kategori filter preset chip
  String _selectedPresetCategory = 'Semua';

  // Hasil kalkulasi ongkir aktif
  late KalkulasiOngkirResult _ongkirResult;

  @override
  void initState() {
    super.initState();
    _selectedPoint = LatLng(widget.booking.latitude, widget.booking.longitude);
    _selectedPlaceName = widget.booking.lokasiNama.isNotEmpty
        ? widget.booking.lokasiNama
        : 'Kawasan Kos Pasar Baru (UNAND)';
    _addressCtrl.text = widget.booking.kosAddress;
    _noteCtrl.text = widget.booking.kosNote;
    _metodePickup = widget.booking.metodePickup;
    _metodeDelivery = widget.booking.metodeDelivery;

    _calculateAndRoute(isInitial: true);
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchCtrl.dispose();
    _addressCtrl.dispose();
    _noteCtrl.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  /// Menghitung ongkir dan mengambil rute jalan raya OSRM
  Future<void> _calculateAndRoute({bool isInitial = false}) async {
    // 1. Kalkulasi dasar cepat lokal (Haversine + tabel resmi)
    final localResult = kalkulasiOngkirLengkap(
      destLat: _selectedPoint.latitude,
      destLng: _selectedPoint.longitude,
      kategori: widget.booking.items.isNotEmpty ? widget.booking.items.first.category : 'A',
      metodePickup: _metodePickup,
      metodeDelivery: _metodeDelivery,
    );

    setState(() {
      _ongkirResult = localResult;
      _isRouting = true;
    });
    _notifyParent();

    // 2. Ambil rute jalan raya riil dari OSRM backend
    try {
      final routeRes = await ApiService.getRouting(
        originLat: KOSINAJA_WAREHOUSE.lat,
        originLng: KOSINAJA_WAREHOUSE.lng,
        destLat: _selectedPoint.latitude,
        destLng: _selectedPoint.longitude,
      );

      if (!mounted) return;

      if (routeRes['success'] == true) {
        final double distKm = routeRes['distanceKm'] ?? localResult.jarakKm;
        final int durMin = routeRes['durationMin'] ?? localResult.durasiMenit;
        final List coordsRaw = routeRes['coordinates'] ?? [];

        List<LatLng> polylinePoints = [];
        if (coordsRaw.isNotEmpty) {
          for (final c in coordsRaw) {
            if (c is List && c.length >= 2) {
              polylinePoints.add(LatLng(
                (c[0] as num).toDouble(),
                (c[1] as num).toDouble(),
              ));
            }
          }
        }

        final realResult = kalkulasiOngkirLengkap(
          destLat: _selectedPoint.latitude,
          destLng: _selectedPoint.longitude,
          kategori: widget.booking.items.isNotEmpty ? widget.booking.items.first.category : 'A',
          metodePickup: _metodePickup,
          metodeDelivery: _metodeDelivery,
          customDistanceKm: distKm,
          customDurationMin: durMin,
          isRealRoute: true,
          routeCoords: polylinePoints,
        );

        setState(() {
          _ongkirResult = realResult;
          _isRouting = false;
        });
        _notifyParent();
      } else {
        setState(() => _isRouting = false);
      }
    } catch (_) {
      if (mounted) setState(() => _isRouting = false);
    }
  }

  void _notifyParent() {
    // Sinkronkan ke objek booking induk
    widget.booking.latitude = _selectedPoint.latitude;
    widget.booking.longitude = _selectedPoint.longitude;
    widget.booking.lokasiNama = _selectedPlaceName;
    widget.booking.kosAddress = _addressCtrl.text.trim();
    widget.booking.kosNote = _noteCtrl.text.trim();
    widget.booking.metodePickup = _metodePickup;
    widget.booking.metodeDelivery = _metodeDelivery;
    widget.booking.deliveryFee = _ongkirResult.totalOngkir;
    widget.booking.ongkirPickup = _ongkirResult.ongkirPickup;
    widget.booking.ongkirDelivery = _ongkirResult.ongkirDelivery;
    widget.booking.jarakKm = _ongkirResult.jarakKm;
    widget.booking.durasiMenit = _ongkirResult.durasiMenit;

    if (widget.onLocationChanged != null) {
      widget.onLocationChanged!(
        LocationPickerResult(
          coordinate: _selectedPoint,
          namaTempat: _selectedPlaceName,
          alamatDetail: _addressCtrl.text.trim(),
          patokan: _noteCtrl.text.trim(),
          metodePickup: _metodePickup,
          metodeDelivery: _metodeDelivery,
          kalkulasi: _ongkirResult,
        ),
      );
    }
  }

  /// Menangani pemilihan titik koordinat baru dari klik peta / drag / autocomplete
  Future<void> _selectCoordinate(
    LatLng point, {
    String? customName,
    String? customAddress,
  }) async {
    setState(() {
      _selectedPoint = point;
      if (customName != null) {
        _selectedPlaceName = customName;
      }
      if (customAddress != null && customAddress.isNotEmpty) {
        _addressCtrl.text = customAddress;
      }
      _showSuggestions = false;
    });

    _mapController.move(point, 14.5);
    await _calculateAndRoute();

    // Reverse geocode jika belum ada nama lokasi kustom
    if (customName == null) {
      final geo = await ApiService.reverseGeocode(point.latitude, point.longitude);
      if (mounted && geo != null) {
        setState(() {
          _selectedPlaceName = geo['nama'] ?? 'Titik Lokasi (${point.latitude.toStringAsFixed(4)}, ${point.longitude.toStringAsFixed(4)})';
          if (_addressCtrl.text.isEmpty && geo['alamatLengkap'] != null) {
            _addressCtrl.text = geo['alamatLengkap'];
          }
        });
        _notifyParent();
      }
    }
  }

  /// Debounce input pencarian lokasi
  void _onSearchChanged(String query) {
    _debounceTimer?.cancel();
    if (query.trim().length < 3) {
      setState(() {
        _searchSuggestions = [];
        _showSuggestions = false;
        _isSearching = false;
      });
      return;
    }

    setState(() => _isSearching = true);
    _debounceTimer = Timer(const Duration(milliseconds: 400), () async {
      final q = query.trim().toLowerCase();

      // 1. Cari di daftar Preset Lokal Padang terlebih dahulu (cepat)
      final localMatches = PRESET_LOKASI_PADANG.where((p) {
        return p.nama.toLowerCase().includes(q) ||
            p.deskripsi.toLowerCase().includes(q) ||
            p.area.toLowerCase().includes(q);
      }).map((p) => {
            'nama': p.nama,
            'alamatLengkap': p.deskripsi,
            'lat': p.lat,
            'lng': p.lng,
            'isPreset': true,
          }).toList();

      // 2. Cari via backend Geocode API (Nominatim Padang)
      final apiResults = await ApiService.searchPlaces(query);

      if (!mounted) return;

      final combined = [...localMatches];
      for (final item in apiResults) {
        final lat = (item['lat'] as num?)?.toDouble();
        final lng = (item['lng'] as num?)?.toDouble();
        if (lat != null && lng != null) {
          // Hindari duplikasi jika sudah ada di preset
          final isDuplicate = combined.any(
            (c) => (((c['lat'] as num).toDouble() - lat).abs() < 0.001) && (((c['lng'] as num).toDouble() - lng).abs() < 0.001),
          );
          if (!isDuplicate) {
            combined.add({
              'nama': item['nama'] ?? 'Lokasi Terpilih',
              'alamatLengkap': item['alamatLengkap'] ?? '',
              'lat': lat,
              'lng': lng,
              'isPreset': false,
            });
          }
        }
      }

      setState(() {
        _searchSuggestions = combined;
        _showSuggestions = combined.isNotEmpty;
        _isSearching = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final filteredPresets = _selectedPresetCategory == 'Semua'
        ? PRESET_LOKASI_PADANG
        : PRESET_LOKASI_PADANG
            .where((p) => p.kategori == _selectedPresetCategory)
            .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. SEARCH BAR & AUTOCOMPLETE
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: _searchFocus.hasFocus ? AppColors.primary : AppColors.border,
              width: _searchFocus.hasFocus ? 1.5 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              TextField(
                controller: _searchCtrl,
                focusNode: _searchFocus,
                onChanged: _onSearchChanged,
                decoration: InputDecoration(
                  hintText: 'Cari kampus, kosan, atau jalan di Padang...',
                  hintStyle: const TextStyle(fontSize: 13, color: AppColors.textMuted),
                  prefixIcon: _isSearching
                      ? const Padding(
                          padding: EdgeInsets.all(12),
                          child: SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                          ),
                        )
                      : const Icon(Icons.search, color: AppColors.primary),
                  suffixIcon: _searchCtrl.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, size: 18, color: AppColors.textMuted),
                          onPressed: () {
                            _searchCtrl.clear();
                            setState(() {
                              _searchSuggestions = [];
                              _showSuggestions = false;
                            });
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                ),
              ),

              // Dropdown Hasil Pencarian
              if (_showSuggestions)
                Container(
                  constraints: const BoxConstraints(maxHeight: 220),
                  decoration: const BoxDecoration(
                    border: Border(top: BorderSide(color: AppColors.border)),
                  ),
                  child: ListView.separated(
                    shrinkWrap: true,
                    padding: EdgeInsets.zero,
                    itemCount: _searchSuggestions.length,
                    separatorBuilder: (_, __) => const Divider(height: 1, color: AppColors.border),
                    itemBuilder: (context, idx) {
                      final item = _searchSuggestions[idx];
                      final isPreset = item['isPreset'] == true;
                      return ListTile(
                        dense: true,
                        leading: CircleAvatar(
                          radius: 14,
                          backgroundColor: isPreset ? AppColors.primarySoft : AppColors.surfaceContainerHigh,
                          child: Icon(
                            isPreset ? Icons.stars_rounded : Icons.location_on,
                            size: 16,
                            color: isPreset ? AppColors.primary : AppColors.textSecondary,
                          ),
                        ),
                        title: Text(
                          item['nama'] ?? '',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                        ),
                        subtitle: Text(
                          item['alamatLengkap'] ?? '',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
                        ),
                        onTap: () {
                          final lat = item['lat'] as double;
                          final lng = item['lng'] as double;
                          _searchCtrl.text = item['nama'] ?? '';
                          _searchFocus.unfocus();
                          _selectCoordinate(
                            LatLng(lat, lng),
                            customName: item['nama'],
                            customAddress: item['alamatLengkap'],
                          );
                        },
                      );
                    },
                  ),
                ),
            ],
          ),
        ),

        const SizedBox(height: 14),

        // 2. QUICK PRESET CHIPS PADANG
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Preset Populer Mahasiswa Padang',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.text,
              ),
            ),
            Row(
              children: ['Semua', 'Kampus', 'Kawasan Kos'].map((cat) {
                final isSelected = _selectedPresetCategory == cat;
                return GestureDetector(
                  onTap: () => setState(() => _selectedPresetCategory = cat),
                  child: Container(
                    margin: const EdgeInsets.only(left: 6),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primary : AppColors.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      cat,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                        color: isSelected ? Colors.white : AppColors.textSecondary,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),

        const SizedBox(height: 8),

        SizedBox(
          height: 38,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: filteredPresets.length,
            itemBuilder: (context, idx) {
              final p = filteredPresets[idx];
              final isSelected = (_selectedPoint.latitude - p.lat).abs() < 0.0005 &&
                  (_selectedPoint.longitude - p.lng).abs() < 0.0005;

              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  label: Text(p.nama),
                  selected: isSelected,
                  selectedColor: AppColors.primary,
                  backgroundColor: AppColors.cardSurface,
                  labelStyle: TextStyle(
                    fontSize: 11,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected ? Colors.white : AppColors.text,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(
                      color: isSelected ? AppColors.primary : AppColors.border,
                    ),
                  ),
                  onSelected: (_) {
                    _selectCoordinate(
                      p.toLatLng,
                      customName: p.nama,
                      customAddress: p.deskripsi,
                    );
                  },
                ),
              );
            },
          ),
        ),

        const SizedBox(height: 16),

        // 3. PETA INTERAKTIF FLUTTERMAP DENGAN OPENSTREETMAP
        Container(
          height: 240,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Stack(
            children: [
              FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: _selectedPoint,
                  initialZoom: 13.5,
                  onTap: (tapPosition, point) {
                    _selectCoordinate(point);
                  },
                ),
                children: [
                  TileLayer(
                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.kosinaja.app.kosinaja_flutter',
                  ),

                  // Garis Polyline Rute Jalan Raya OSRM
                  PolylineLayer(
                    polylines: [
                      Polyline(
                        points: _ongkirResult.routeCoordinates,
                        color: _ongkirResult.isRealRoute
                            ? const Color(0xFFB86B35)
                            : const Color(0xFFD97706),
                        strokeWidth: 4.5,
                      ),
                    ],
                  ),

                  // Marker Layer: Hub Kosinaja & Titik Pelanggan
                  MarkerLayer(
                    markers: [
                      // 1. Central Hub Kosinaja (Hotel Ibis Padang)
                      Marker(
                        point: KOSINAJA_WAREHOUSE.toLatLng,
                        width: 140,
                        height: 40,
                        alignment: Alignment.topCenter,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: const Color(0xFF2A1B14),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: const Color(0xFFE69526), width: 1.5),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Colors.black38,
                                    blurRadius: 6,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: const Text(
                                '🏨 Hub KosinAja',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFFFAF6F0),
                                ),
                              ),
                            ),
                            const Icon(Icons.arrow_drop_down, color: Color(0xFF2A1B14), size: 14),
                          ],
                        ),
                      ),

                      // 2. Customer Destination Marker (Titik Kosan)
                      Marker(
                        point: _selectedPoint,
                        width: 50,
                        height: 50,
                        alignment: Alignment.topCenter,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 34,
                              height: 34,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: const Color(0xFFDC2626),
                                border: Border.all(color: Colors.white, width: 2.5),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Colors.black45,
                                    blurRadius: 8,
                                    offset: Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: const Icon(Icons.person_pin_circle, color: Colors.white, size: 20),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              // Floating Controls di Peta
              Positioned(
                top: 10,
                right: 10,
                child: Column(
                  children: [
                    // Zoom In
                    _buildMapIconButton(
                      icon: Icons.add,
                      onTap: () {
                        _mapController.move(
                          _mapController.camera.center,
                          _mapController.camera.zoom + 1,
                        );
                      },
                    ),
                    const SizedBox(height: 6),
                    // Zoom Out
                    _buildMapIconButton(
                      icon: Icons.remove,
                      onTap: () {
                        _mapController.move(
                          _mapController.camera.center,
                          _mapController.camera.zoom - 1,
                        );
                      },
                    ),
                    const SizedBox(height: 6),
                    // Re-center to Customer Pin
                    _buildMapIconButton(
                      icon: Icons.my_location,
                      color: AppColors.primary,
                      tooltip: 'Pusatkan ke Kosan',
                      onTap: () {
                        _mapController.move(_selectedPoint, 15);
                      },
                    ),
                    const SizedBox(height: 6),
                    // Re-center to Hub
                    _buildMapIconButton(
                      icon: Icons.warehouse_outlined,
                      tooltip: 'Pusatkan ke Hub Hotel Ibis',
                      onTap: () {
                        _mapController.move(KOSINAJA_WAREHOUSE.toLatLng, 15);
                      },
                    ),
                  ],
                ),
              ),

              // Floating Bottom Status Pill (Jarak & Estimasi Waktu)
              Positioned(
                bottom: 10,
                left: 10,
                right: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.95),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                    boxShadow: const [
                      BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2)),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: AppColors.primarySoft,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.route, color: AppColors.primary, size: 16),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _selectedPlaceName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
                            ),
                            Text(
                              'Jarak: ${_ongkirResult.jarakKm} km • Est: ~${_ongkirResult.durasiMenit} Menit',
                              style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                      if (_isRouting)
                        const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                        )
                      else
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: _ongkirResult.jarakKm <= 1.0
                                ? AppColors.successSoft
                                : AppColors.primarySoft,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            _ongkirResult.jarakKm <= 1.0 ? 'GRATIS' : 'TERCOVER',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              color: _ongkirResult.jarakKm <= 1.0
                                  ? AppColors.success
                                  : AppColors.primary,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 10),
        const Center(
          child: Text(
            '💡 Ketuk pada peta untuk menggeser pin lokasi penjemputan Anda',
            style: TextStyle(fontSize: 10.5, color: AppColors.textSecondary),
          ),
        ),

        const SizedBox(height: 20),

        // 4. METODE LOGISTIK PENJEMPUTAN & PENGANTARAN
        const Text(
          'Metode Penjemputan Barang',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.text),
        ),
        const SizedBox(height: 8),

        Row(
          children: [
            Expanded(
              child: _buildLogisticsOption(
                title: 'Jemput ke Kosan',
                subtitle: 'Driver KosinAja datang ke kos',
                icon: Icons.local_shipping,
                isSelected: _metodePickup == 'PICKUP',
                priceText: _ongkirResult.ongkirPickup == 0
                    ? 'Gratis'
                    : currencyFormat.format(_ongkirResult.ongkirPickup),
                onTap: () {
                  setState(() => _metodePickup = 'PICKUP');
                  _calculateAndRoute();
                },
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildLogisticsOption(
                title: 'Antar Sendiri',
                subtitle: 'Bawa langsung ke Hub Hotel Ibis',
                icon: Icons.store_mall_directory_outlined,
                isSelected: _metodePickup == 'SELF_DROPOFF',
                priceText: 'Gratis Rp 0',
                onTap: () {
                  setState(() => _metodePickup = 'SELF_DROPOFF');
                  _calculateAndRoute();
                },
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        const Text(
          'Metode Pengembalian Saat Liburan Usai',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.text),
        ),
        const SizedBox(height: 8),

        Row(
          children: [
            Expanded(
              child: _buildLogisticsOption(
                title: 'Diantar ke Kosan',
                subtitle: 'Diantar kembali saat semester baru',
                icon: Icons.delivery_dining,
                isSelected: _metodeDelivery == 'DELIVERY',
                priceText: _ongkirResult.ongkirDelivery == 0
                    ? 'Gratis'
                    : currencyFormat.format(_ongkirResult.ongkirDelivery),
                onTap: () {
                  setState(() => _metodeDelivery = 'DELIVERY');
                  _calculateAndRoute();
                },
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildLogisticsOption(
                title: 'Ambil Sendiri',
                subtitle: 'Ambil langsung di Hub Gudang',
                icon: Icons.hail_rounded,
                isSelected: _metodeDelivery == 'SELF_PICKUP',
                priceText: 'Gratis Rp 0',
                onTap: () {
                  setState(() => _metodeDelivery = 'SELF_PICKUP');
                  _calculateAndRoute();
                },
              ),
            ),
          ],
        ),

        const SizedBox(height: 20),

        // 5. RINCIAN ONGKIR & ESTIMASI JALUR
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.cardSurface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Rincian Biaya Ongkir',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.primarySoft,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '${_ongkirResult.jarakKm} km dari Hub',
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              _buildPriceRow(
                'Ongkir Penjemputan',
                _metodePickup == 'PICKUP'
                    ? currencyFormat.format(_ongkirResult.ongkirPickup)
                    : 'Antar Mandiri (Rp 0)',
              ),
              const SizedBox(height: 4),
              _buildPriceRow(
                'Ongkir Pengantaran Balik',
                _metodeDelivery == 'DELIVERY'
                    ? currencyFormat.format(_ongkirResult.ongkirDelivery)
                    : 'Ambil Mandiri (Rp 0)',
              ),
              if (_ongkirResult.jarakKm <= 1.0) ...[
                const SizedBox(height: 4),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Promo Hub Terdekat (<= 1.0 km)',
                      style: TextStyle(fontSize: 11, color: Color(0xFF2E7D52), fontWeight: FontWeight.w600),
                    ),
                    Text(
                      'Gratis Ongkir',
                      style: TextStyle(fontSize: 11, color: Color(0xFF2E7D52), fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ],
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Divider(height: 1, color: AppColors.border),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total Biaya Ongkir',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
                  ),
                  Text(
                    _ongkirResult.totalOngkir == 0
                        ? 'GRATIS'
                        : currencyFormat.format(_ongkirResult.totalOngkir),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // 6. FORM ALAMAT LENGKAP & CATATAN PATOKAN
        const Text(
          'Alamat Lengkap Kosan & Patokan',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.text),
        ),
        const SizedBox(height: 8),

        TextField(
          controller: _addressCtrl,
          maxLines: 2,
          onChanged: (_) => _notifyParent(),
          decoration: const InputDecoration(
            hintText: 'Nama kos, blok, nomor kamar, RT/RW, dan jalan...',
            prefixIcon: Padding(
              padding: EdgeInsets.only(bottom: 24),
              child: Icon(Icons.home_work_outlined, color: AppColors.primary),
            ),
          ),
        ),

        const SizedBox(height: 10),

        TextField(
          controller: _noteCtrl,
          onChanged: (_) => _notifyParent(),
          decoration: const InputDecoration(
            hintText: 'Patokan kurir (misal: samping warung nasi, lantai 2 kamar 8)',
            prefixIcon: Icon(Icons.notes_outlined, color: AppColors.primary),
          ),
        ),
      ],
    );
  }

  Widget _buildMapIconButton({
    required IconData icon,
    required VoidCallback onTap,
    Color color = AppColors.text,
    String? tooltip,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 1))],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(7),
            child: Icon(icon, size: 18, color: color),
          ),
        ),
      ),
    );
  }

  Widget _buildLogisticsOption({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isSelected,
    required String priceText,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primarySoft.withValues(alpha: 0.35)
              : AppColors.cardSurface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  size: 18,
                  color: isSelected ? AppColors.primary : AppColors.textSecondary,
                ),
                const Spacer(),
                Icon(
                  isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
                  size: 16,
                  color: isSelected ? AppColors.primary : AppColors.textMuted,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                color: AppColors.text,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              maxLines: 2,
              style: const TextStyle(fontSize: 10, color: AppColors.textSecondary, height: 1.2),
            ),
            const SizedBox(height: 6),
            Text(
              priceText,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
        Text(value, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
      ],
    );
  }
}

extension StringExtension on String {
  bool includes(String other) => toLowerCase().contains(other.toLowerCase());
}
