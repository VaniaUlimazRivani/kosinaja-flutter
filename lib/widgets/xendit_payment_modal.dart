import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../core/services/api_service.dart';
import '../core/theme/app_colors.dart';

class XenditPaymentModal extends StatefulWidget {
  final String bookingId;
  final String kodeBooking;
  final String invoiceUrl;
  final int totalHarga;
  final VoidCallback? onSuccess;

  const XenditPaymentModal({
    super.key,
    required this.bookingId,
    required this.kodeBooking,
    required this.invoiceUrl,
    required this.totalHarga,
    this.onSuccess,
  });

  /// Helper statis untuk menampilkan pop-up pembayaran Xendit secara modal
  static Future<bool?> show({
    required BuildContext context,
    required String bookingId,
    required String kodeBooking,
    required String invoiceUrl,
    required int totalHarga,
  }) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.transparent,
      builder: (ctx) => XenditPaymentModal(
        bookingId: bookingId,
        kodeBooking: kodeBooking,
        invoiceUrl: invoiceUrl,
        totalHarga: totalHarga,
      ),
    );
  }

  @override
  State<XenditPaymentModal> createState() => _XenditPaymentModalState();
}

class _XenditPaymentModalState extends State<XenditPaymentModal> {
  late final WebViewController _controller;
  int _loadingProgress = 0;
  bool _isLoading = true;
  bool _isCheckingStatus = false;
  final _currencyFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

  @override
  void initState() {
    super.initState();
    _initWebViewController();
  }

  void _initWebViewController() {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            if (mounted) {
              setState(() {
                _loadingProgress = progress;
              });
            }
          },
          onPageStarted: (String url) {
            if (mounted) setState(() => _isLoading = true);
          },
          onPageFinished: (String url) {
            if (mounted) setState(() => _isLoading = false);
          },
          onNavigationRequest: (NavigationRequest request) async {
            final url = request.url;

            // Handle deep link aplikasi E-Wallet (GoPay, OVO, Dana, ShopeePay, dsb)
            if (!url.startsWith('http://') && !url.startsWith('https://')) {
              try {
                final uri = Uri.parse(url);
                await launchUrl(uri, mode: LaunchMode.externalApplication);
              } catch (e) {
                debugPrint('Gagal membuka deep link aplikasi pembayaran: $e');
              }
              return NavigationDecision.prevent;
            }

            // Jika URL redirect menunjukkan sukses atau profile
            if (url.contains('success') || url.contains('/profile') || url.contains('status=PAID')) {
              _checkPaymentStatus(autoCloseOnSuccess: true);
            }

            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.invoiceUrl));
  }

  Future<void> _checkPaymentStatus({bool autoCloseOnSuccess = false}) async {
    if (_isCheckingStatus) return;
    setState(() => _isCheckingStatus = true);

    try {
      final res = await ApiService.getPaymentStatus(widget.bookingId);
      if (!mounted) return;

      final status = (res['paymentStatus'] ?? '').toString().toUpperCase();
      if (status == 'PAID' || status == 'SETTLEMENT') {
        if (widget.onSuccess != null) widget.onSuccess!();
        Navigator.pop(context, true); // Return true = Lunas
      } else {
        if (!autoCloseOnSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Status saat ini: $status. Menunggu pembayaran Anda diselesaikan.'),
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
    } catch (_) {
      if (!autoCloseOnSuccess && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal memeriksa status pembayaran server.')),
        );
      }
    } finally {
      if (mounted) setState(() => _isCheckingStatus = false);
    }
  }

  void _confirmClose() {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Tutup Pembayaran?'),
        content: const Text(
          'Pembayaran belum diselesaikan. Anda tetap bisa melanjutkannya nanti di menu Riwayat.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('Lanjutkan Bayar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogCtx);
              Navigator.pop(context, false); // Return false = Belum lunas
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Tutup Saja'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final modalHeight = screenHeight * 0.90; // 90% tinggi layar pop-up

    return Container(
      height: modalHeight,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // 1. MODAL TOP HEADER
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              border: Border(bottom: BorderSide(color: AppColors.border, width: 1)),
            ),
            child: Row(
              children: [
                // Icon Xendit Badge
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0052CC).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.lock_outline, color: Color(0xFF0052CC), size: 18),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Text(
                            'Pembayaran Xendit',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: AppColors.text,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                            decoration: BoxDecoration(
                              color: const Color(0xFF2E7D52).withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'Enkripsi 256-bit',
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF2E7D52),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${widget.kodeBooking} • ${_currencyFormat.format(widget.totalHarga)}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                // Tombol Tutup Pop-up
                IconButton(
                  onPressed: _confirmClose,
                  icon: const Icon(Icons.close, color: AppColors.textSecondary),
                  tooltip: 'Tutup',
                ),
              ],
            ),
          ),

          // 2. LOADING PROGRESS BAR
          if (_isLoading)
            LinearProgressIndicator(
              value: _loadingProgress > 0 ? _loadingProgress / 100.0 : null,
              backgroundColor: AppColors.surfaceContainerLow,
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF0052CC)),
              minHeight: 2.5,
            ),

          // 3. IN-APP WEBVIEW EMBEDDED
          Expanded(
            child: Stack(
              children: [
                WebViewWidget(controller: _controller),
                if (_isLoading)
                  const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF0052CC)),
                        ),
                        SizedBox(height: 12),
                        Text(
                          'Memuat Antarmuka Pembayaran Xendit...',
                          style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),

          // 4. BOTTOM ACTION TOOLBAR
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: AppColors.border, width: 1)),
            ),
            child: SafeArea(
              top: false,
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _isCheckingStatus ? null : () => _checkPaymentStatus(autoCloseOnSuccess: false),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.primary),
                        foregroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      icon: _isCheckingStatus
                          ? const SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                            )
                          : const Icon(Icons.refresh, size: 16),
                      label: Text(_isCheckingStatus ? 'Memeriksa...' : 'Cek Status'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  IconButton(
                    onPressed: () async {
                      final uri = Uri.parse(widget.invoiceUrl);
                      try {
                        await launchUrl(uri, mode: LaunchMode.externalApplication);
                      } catch (_) {}
                    },
                    icon: const Icon(Icons.open_in_browser, color: AppColors.textSecondary),
                    tooltip: 'Buka di Browser Luar',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

