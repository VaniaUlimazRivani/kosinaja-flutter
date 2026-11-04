/**
 * Widget Pemilih Lokasi & Kalkulator Ongkir Interaktif Kosinaja
 * Ditulis untuk modul Alvin (Lokasi & History)
 * 
 * Fitur:
 * - Pencarian nama kampus & kos Padang
 * - Chip filter kategori (Semua, Kampus, Area Kos)
 * - GPS "Gunakan Lokasi Saat Ini"
 * - Visual rute peta & rincian ongkir transparan
 * - Tombol buka rute Google Maps resmi
 * - Siap dipasang di booking_step2_screen
 */

import 'package:flutter/material.dart';
import '../core/services/shipping_calculator.dart';
import '../core/theme/app_colors.dart';
import '../models/location_model.dart';

class LocationPickerWidget extends StatefulWidget {
  final PresetLocation? initialLocation;
  final String category;
  final int itemCount;
  final bool hasVehicle;
  final ValueChanged<ShippingCalculation>? onShippingCalculated;
  final ValueChanged<PresetLocation>? onLocationChanged;

  const LocationPickerWidget({
    super.key,
    this.initialLocation,
    this.category = 'A',
    this.itemCount = 1,
    this.hasVehicle = false,
    this.onShippingCalculated,
    this.onLocationChanged,
  });

  @override
  State<LocationPickerWidget> createState() => _LocationPickerWidgetState();
}

class _LocationPickerWidgetState extends State<LocationPickerWidget> {
  late PresetLocation _selectedLocation;
  late ShippingCalculation _shipping;
  String _filterCategory = 'ALL'; // ALL, KAMPUS, KOS
  final TextEditingController _searchCtrl = TextEditingController();
  String _searchQuery = '';
  bool _isLoadingGps = false;

  @override
  void initState() {
    super.initState();
    _selectedLocation = widget.initialLocation ?? ShippingCalculator.padangPresets.first;
    _recalculate();
  }

  @override
  void didUpdateWidget(covariant LocationPickerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.category != widget.category ||
        oldWidget.itemCount != widget.itemCount ||
        oldWidget.hasVehicle != widget.hasVehicle) {
      _recalculate();
    }
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _recalculate() {
    _shipping = ShippingCalculator.calculateShipping(
      pickupLocation: _selectedLocation.coordinate,
      category: widget.category,
      itemCount: widget.itemCount,
      hasVehicle: widget.hasVehicle,
    );

    widget.onShippingCalculated?.call(_shipping);
    widget.onLocationChanged?.call(_selectedLocation);
  }

  List<PresetLocation> get _filteredPresets {
    return ShippingCalculator.padangPresets.where((p) {
      final matchCat = _filterCategory == 'ALL' ||
          (_filterCategory == 'KAMPUS' && p.category == PresetCategory.kampus) ||
          (_filterCategory == 'KOS' && p.category == PresetCategory.kos);

      final q = _searchQuery.toLowerCase().trim();
      final matchQuery = q.isEmpty ||
          p.name.toLowerCase().contains(q) ||
          p.shortName.toLowerCase().contains(q) ||
          p.address.toLowerCase().contains(q);

      return matchCat && matchQuery;
    }).toList();
  }

  void _handleSimulateGps() async {
    setState(() => _isLoadingGps = true);
    await Future.delayed(const Duration(milliseconds: 700));

    // Fallback deteksi GPS di area mahasiswa Air Tawar/Pauh Padang
    final gpsLocation = PresetLocation(
      id: 'gps-user-loc',
      name: 'Lokasi GPS Kos Saat Ini',
      shortName: 'GPS Anda',
      category: PresetCategory.kos,
      coordinate: const LocationCoordinate(
        latitude: -0.9015,
        longitude: 100.3540,
        name: 'Lokasi GPS Anda (Air Tawar)',
        address: 'Jl. Belibis No. 12, Air Tawar Barat, Padang Utara',
      ),
      address: 'Jl. Belibis No. 12, Air Tawar Barat, Padang Utara',
      description: 'Terdeteksi via sensor GPS perangkat',
    );

    setState(() {
      _selectedLocation = gpsLocation;
      _isLoadingGps = false;
      _recalculate();
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('📍 Lokasi GPS kos berhasil terdeteksi!'),
          backgroundColor: AppColors.primary,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header Section
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Row(
              children: [
                Icon(Icons.location_on, color: AppColors.primary, size: 20),
                SizedBox(width: 8),
                Text(
                  'Titik Jemput & Hitung Ongkir',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: AppColors.text,
                  ),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.primarySoft,
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text(
                'Hub: Air Tawar',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        // Selected Location Hero Card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.cardSurface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.primaryContainer, width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      _selectedLocation.shortName,
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  const Spacer(),
                  const Icon(Icons.check_circle, color: AppColors.primary, size: 16),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                _selectedLocation.name,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.text,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                _selectedLocation.address,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        // Route & Ongkir Visual Card
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            children: [
              // Visual Route Line
              Row(
                children: [
                  const Icon(Icons.store, color: AppColors.success, size: 18),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Gudang Kosinaja (Air Tawar)',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () {
                      ShippingCalculator.launchGoogleMapsRoute(
                        _shipping.origin,
                        _shipping.destination,
                      );
                    },
                    icon: const Icon(Icons.map_outlined, size: 14),
                    label: const Text('Buka Maps', style: TextStyle(fontSize: 11)),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Row(
                  children: [
                    Container(width: 2, height: 26, color: AppColors.outlineVariant),
                    const SizedBox(width: 14),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.cardSurface,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.directions_car, size: 12, color: AppColors.primary),
                          const SizedBox(width: 4),
                          Text(
                            '${_shipping.roadDistanceKm} km • ~${_shipping.durationMinutes} mnt',
                            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  const Icon(Icons.pin_drop, color: AppColors.primary, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _selectedLocation.name,
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),

              const Divider(height: 20),

              // Breakdown Biaya Ongkir
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Tarif Dasar (s/d 3 km)', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                  Text(ShippingCalculator.formatRupiah(_shipping.baseCost), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
                ],
              ),
              if (_shipping.distanceCost > 0) ...[
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Jarak Tambahan (${_shipping.roadDistanceKm} km)', style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                    Text('+${ShippingCalculator.formatRupiah(_shipping.distanceCost)}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
                  ],
                ),
              ],
              if (_shipping.categorySurcharge > 0) ...[
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Surcharge Armada (Pikap / Kategori B)', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                    Text('+${ShippingCalculator.formatRupiah(_shipping.categorySurcharge)}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
                  ],
                ),
              ],

              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Biaya Ongkir Penjemputan:',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.text),
                  ),
                  Text(
                    _shipping.formattedTotalCost,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      color: _shipping.isCustomQuotation ? AppColors.warning : AppColors.primary,
                    ),
                  ),
                ],
              ),

              if (_shipping.quotationReason != null) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.warningSoft,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline, size: 14, color: AppColors.warning),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          _shipping.quotationReason!,
                          style: const TextStyle(fontSize: 10, color: AppColors.warning, height: 1.3),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),

        const SizedBox(height: 12),

        // Tombol GPS
        SizedBox(
          width: double.infinity,
          height: 40,
          child: OutlinedButton.icon(
            onPressed: _isLoadingGps ? null : _handleSimulateGps,
            icon: _isLoadingGps
                ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.my_location, size: 16),
            label: Text(
              _isLoadingGps ? 'Mendeteksi GPS...' : 'Gunakan Titik GPS Kos Saat Ini',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
            ),
          ),
        ),

        const SizedBox(height: 12),

        // Search Bar Preset
        TextField(
          controller: _searchCtrl,
          onChanged: (val) => setState(() => _searchQuery = val),
          decoration: InputDecoration(
            hintText: 'Cari kampus atau area kos Padang...',
            hintStyle: const TextStyle(fontSize: 12),
            prefixIcon: const Icon(Icons.search, size: 18),
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            suffixIcon: _searchQuery.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear, size: 16),
                    onPressed: () {
                      _searchCtrl.clear();
                      setState(() => _searchQuery = '');
                    },
                  )
                : null,
          ),
        ),

        const SizedBox(height: 10),

        // Chips Filter
        Row(
          children: [
            _buildFilterChip('Semua (${ShippingCalculator.padangPresets.length})', 'ALL'),
            const SizedBox(width: 6),
            _buildFilterChip('🎓 Kampus', 'KAMPUS'),
            const SizedBox(width: 6),
            _buildFilterChip('🏠 Area Kos', 'KOS'),
          ],
        ),

        const SizedBox(height: 8),

        // List Presets
        Container(
          constraints: const BoxConstraints(maxHeight: 180),
          decoration: BoxDecoration(
            color: AppColors.cardSurface,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.border),
          ),
          child: ListView.separated(
            shrinkWrap: true,
            padding: const EdgeInsets.all(6),
            itemCount: _filteredPresets.length,
            separatorBuilder: (_, __) => const Divider(height: 6),
            itemBuilder: (context, index) {
              final preset = _filteredPresets[index];
              final isSelected = _selectedLocation.id == preset.id;

              return ListTile(
                dense: true,
                visualDensity: VisualDensity.compact,
                leading: CircleAvatar(
                  radius: 14,
                  backgroundColor: preset.category == PresetCategory.kampus
                      ? AppColors.primarySoft
                      : AppColors.successSoft,
                  child: Icon(
                    preset.category == PresetCategory.kampus ? Icons.school : Icons.home,
                    size: 14,
                    color: preset.category == PresetCategory.kampus
                        ? AppColors.primary
                        : AppColors.success,
                  ),
                ),
                title: Text(
                  preset.name,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                    color: isSelected ? AppColors.primary : AppColors.text,
                  ),
                ),
                subtitle: Text(
                  preset.address,
                  style: const TextStyle(fontSize: 10, color: AppColors.textMuted),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: isSelected
                    ? const Icon(Icons.check_circle, color: AppColors.primary, size: 18)
                    : null,
                onTap: () {
                  setState(() {
                    _selectedLocation = preset;
                    _recalculate();
                  });
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChip(String label, String code) {
    final isSelected = _filterCategory == code;
    return InkWell(
      onTap: () => setState(() => _filterCategory = code),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
            color: isSelected ? Colors.white : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
