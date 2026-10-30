/**
 * Layar Peta Interaktif & Kalkulator Ongkir Padang
 * Ditulis untuk modul Alvin (Lokasi & History)
 * 
 * Memudahkan pengujian dan demonstrasi:
 * - Peta & preset kampus/kos Padang (UNP, UNAND, UPI YPTK, UBH, PNP, ITP, UIN, dll.)
 * - GPS "Lokasi Saat Ini" & geocoding
 * - Hitung jarak Haversine, durasi, tarif ongkir dasar, surcharge kategori, dan custom quotation
 * - Tautan langsung rute Google Maps resmi
 */

import 'package:flutter/material.dart';
import '../../core/services/shipping_calculator.dart';
import '../../core/theme/app_colors.dart';
import '../../models/location_model.dart';
import '../../widgets/location_picker_widget.dart';

class LocationShippingScreen extends StatefulWidget {
  const LocationShippingScreen({super.key});

  @override
  State<LocationShippingScreen> createState() => _LocationShippingScreenState();
}

class _LocationShippingScreenState extends State<LocationShippingScreen> {
  String _category = 'A'; // 'A', 'B', 'Custom'
  int _itemCount = 2;
  bool _hasVehicle = false;
  PresetLocation? _selectedLocation;
  ShippingCalculation? _currentShipping;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Peta & Cek Ongkir Padang'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.history, color: AppColors.primary),
            tooltip: 'Riwayat Pesanan',
            onPressed: () => Navigator.pushNamed(context, '/orders'),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Role Banner Alvin
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.primarySoft,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.primaryContainer),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.explore, color: AppColors.primary, size: 24),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Modul Alvin: Lokasi, Peta & Ongkir Padang',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: AppColors.primaryDark,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Formula jarak Haversine, GPS presisi, preset kampus/kos, dan integrasi rute Google Maps.',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.textSecondary,
                              height: 1.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              // Simulation Parameters Card
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
                    const Text(
                      'SIMULASI PARAMETER BARANG:',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textMuted,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Kategori Barang Toggle
                    const Text(
                      'Kategori Muatan:',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        _buildCategoryBtn('A (Kecil/Sedang)', 'A'),
                        const SizedBox(width: 6),
                        _buildCategoryBtn('B (Elektronik/Pikap)', 'B'),
                        const SizedBox(width: 6),
                        _buildCategoryBtn('Custom', 'Custom'),
                      ],
                    ),

                    const SizedBox(height: 14),

                    // Counter Item Stepper
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Jumlah Barang Titipan:',
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                            ),
                            Text(
                              _itemCount > 7
                                  ? '⚠️ > 7 item auto-masuk Custom Quotation'
                                  : 'Maks. 7 item standar pikap',
                              style: const TextStyle(fontSize: 10, color: AppColors.textMuted),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            IconButton(
                              onPressed: () {
                                if (_itemCount > 1) {
                                  setState(() => _itemCount--);
                                }
                              },
                              icon: const Icon(Icons.remove_circle_outline, size: 22),
                              color: AppColors.primary,
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 10),
                              child: Text(
                                '$_itemCount',
                                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
                              ),
                            ),
                            IconButton(
                              onPressed: () => setState(() => _itemCount++),
                              icon: const Icon(Icons.add_circle_outline, size: 22),
                              color: AppColors.primary,
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                          ],
                        ),
                      ],
                    ),

                    const Divider(height: 20),

                    // Switch Kendaraan Bermotor
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Ada Kendaraan Bermotor?',
                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                              ),
                              Text(
                                'Motor / Sepeda Listrik (Memicu Custom Quotation admin)',
                                style: TextStyle(fontSize: 10, color: AppColors.textMuted),
                              ),
                            ],
                          ),
                        ),
                        Switch(
                          value: _hasVehicle,
                          activeColor: AppColors.primary,
                          onChanged: (val) => setState(() => _hasVehicle = val),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              // Reusable LocationPickerWidget
              LocationPickerWidget(
                category: _category,
                itemCount: _itemCount,
                hasVehicle: _hasVehicle,
                onLocationChanged: (loc) => setState(() => _selectedLocation = loc),
                onShippingCalculated: (ship) => setState(() => _currentShipping = ship),
              ),

              const SizedBox(height: 20),

              // CTA: Lanjut ke Form Booking
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pushNamed(context, '/booking-step1');
                  },
                  icon: const Icon(Icons.arrow_forward),
                  label: const Text(
                    'Lanjut Titip Barang dengan Lokasi Ini',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                  ),
                ),
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryBtn(String label, String cat) {
    final isSelected = _category == cat;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _category = cat),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : AppColors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.border,
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                color: isSelected ? Colors.white : AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}
