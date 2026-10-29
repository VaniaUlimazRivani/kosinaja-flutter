import 'dart:async';
import 'dart:convert';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class ApiUser {
  final String id;
  final String nama;
  final String email;
  final String noWa;
  final String? alamat;
  final String role;
  final String? createdAt;

  ApiUser({
    required this.id,
    required this.nama,
    required this.email,
    required this.noWa,
    this.alamat,
    this.role = 'USER',
    this.createdAt,
  });

  factory ApiUser.fromJson(Map<String, dynamic> json) {
    return ApiUser(
      id: json['id'] ?? '',
      nama: json['nama'] ?? '',
      email: json['email'] ?? '',
      noWa: json['noWa'] ?? '',
      alamat: json['alamat'],
      role: json['role'] ?? 'USER',
      createdAt: json['createdAt'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nama': nama,
      'email': email,
      'noWa': noWa,
      'alamat': alamat,
      'role': role,
      'createdAt': createdAt,
    };
  }

  ApiUser copyWith({
    String? id,
    String? nama,
    String? email,
    String? noWa,
    String? alamat,
    String? role,
    String? createdAt,
  }) {
    return ApiUser(
      id: id ?? this.id,
      nama: nama ?? this.nama,
      email: email ?? this.email,
      noWa: noWa ?? this.noWa,
      alamat: alamat ?? this.alamat,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

enum ApiEnvironment {
  production, // Vercel online: https://www.kosinaja.id/api
  localEmulator, // Android Emulator: http://10.0.2.2:3000/api
  localHost, // iOS Simulator / Web / Desktop: http://localhost:3000/api
}

class ApiService {
  // Environment saat ini - Default ke Production (kosinaja.id di Vercel)
  static ApiEnvironment environment = ApiEnvironment.production;

  // URL Dasar untuk masing-masing environment
  static const String productionUrl = 'https://www.kosinaja.id/api';
  static const String localEmulatorUrl = 'http://10.0.2.2:3000/api';
  static const String localHostUrl = 'http://localhost:3000/api';

  // Custom base URL jika ingin override manual
  static String? customBaseUrl;

  /// Mengambil Base URL aktif
  static String get baseUrl {
    if (customBaseUrl != null && customBaseUrl!.isNotEmpty) {
      return customBaseUrl!;
    }

    switch (environment) {
      case ApiEnvironment.production:
        return productionUrl;
      case ApiEnvironment.localEmulator:
        return localEmulatorUrl;
      case ApiEnvironment.localHost:
        if (!kIsWeb && Platform.isAndroid) {
          return localEmulatorUrl;
        }
        return localHostUrl;
    }
  }

  /// Timeout standar untuk request HTTP (15 detik)
  static const Duration requestTimeout = Duration(seconds: 15);

  /// Header standar untuk setiap panggilan API
  static Map<String, String> get headers => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (currentUser != null && currentUser!.id.isNotEmpty) 'x-user-id': currentUser!.id,
      };

  // Session pengguna yang sedang aktif/login di aplikasi
  static ApiUser? currentUser;

  /// Helper untuk merespon error koneksi yang ramah pengguna
  static String _formatConnectionError(Object e) {
    if (e is TimeoutException) {
      return 'Koneksi ke server ($baseUrl) melebihi batas waktu (timeout). Periksa koneksi internet Anda.';
    }
    return 'Gagal terhubung ke server ($baseUrl). Pastikan internet aktif dan backend dapat diakses.';
  }

  // ===========================================================================
  // 1. AUTENTIKASI (AUTH)
  // ===========================================================================

  /// Registrasi Akun Mahasiswa Baru ke MongoDB (via Next.js backend)
  static Future<Map<String, dynamic>> register({
    required String nama,
    required String email,
    required String noWa,
    required String password,
    String? alamat,
  }) async {
    final url = Uri.parse('$baseUrl/auth/register');

    try {
      final response = await http
          .post(
            url,
            headers: headers,
            body: jsonEncode({
              'nama': nama.trim(),
              'email': email.trim().toLowerCase(),
              'noWa': noWa.trim(),
              'password': password,
              'alamat': alamat?.trim(),
            }),
          )
          .timeout(requestTimeout);

      final data = jsonDecode(response.body);

      if (response.statusCode == 201) {
        if (data['user'] != null) {
          currentUser = ApiUser.fromJson(data['user']);
        }
        return {
          'success': true,
          'message': data['message'] ?? 'Registrasi akun berhasil!',
          'user': currentUser,
        };
      } else {
        return {
          'success': false,
          'error': data['error'] ?? 'Gagal mendaftar (Status ${response.statusCode})',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': _formatConnectionError(e),
      };
    }
  }

  /// Login Mahasiswa / Petugas ke MongoDB (via Next.js backend)
  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
    String accountType = 'USER',
  }) async {
    final url = Uri.parse('$baseUrl/auth/login');

    try {
      final response = await http
          .post(
            url,
            headers: headers,
            body: jsonEncode({
              'email': email.trim().toLowerCase(),
              'password': password,
              'accountType': accountType,
            }),
          )
          .timeout(requestTimeout);

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        if (data['user'] != null) {
          currentUser = ApiUser.fromJson(data['user']);
        }
        return {
          'success': true,
          'message': data['message'] ?? 'Login berhasil!',
          'user': currentUser,
        };
      } else {
        return {
          'success': false,
          'error': data['error'] ?? 'Email atau password salah',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': _formatConnectionError(e),
      };
    }
  }

  /// Keluar dari sesi aplikasi
  static void logout() {
    currentUser = null;
  }

  // ===========================================================================
  // 2. PROFIL PENGGUNA (USER PROFILE)
  // ===========================================================================

  /// Mengambil profil dan statistik penitipan pengguna
  static Future<Map<String, dynamic>> getProfile({String? userId}) async {
    final targetId = userId ?? currentUser?.id;
    if (targetId == null || targetId.isEmpty) {
      return {'success': false, 'error': 'User ID tidak ditemukan. Harap login terlebih dahulu.'};
    }

    final url = Uri.parse('$baseUrl/user/profile?userId=$targetId');

    try {
      final response = await http.get(url, headers: headers).timeout(requestTimeout);
      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        if (data['user'] != null) {
          currentUser = ApiUser.fromJson(data['user']);
        }
        return {
          'success': true,
          'user': currentUser,
          'stats': data['stats'] ?? {},
        };
      } else {
        return {
          'success': false,
          'error': data['error'] ?? 'Gagal memuat profil (Status ${response.statusCode})',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': _formatConnectionError(e),
      };
    }
  }

  /// Memperbarui profil akun (Nama, No WA, Alamat, atau Kata Sandi)
  static Future<Map<String, dynamic>> updateProfile({
    required String userId,
    String? nama,
    String? noWa,
    String? alamat,
    String? currentPassword,
    String? newPassword,
  }) async {
    final url = Uri.parse('$baseUrl/user/profile');

    final Map<String, dynamic> payload = {
      'userId': userId,
      if (nama != null) 'nama': nama.trim(),
      if (noWa != null) 'noWa': noWa.trim(),
      if (alamat != null) 'alamat': alamat.trim(),
      if (currentPassword != null && currentPassword.isNotEmpty) 'currentPassword': currentPassword,
      if (newPassword != null && newPassword.isNotEmpty) 'newPassword': newPassword,
    };

    try {
      final response = await http
          .put(
            url,
            headers: headers,
            body: jsonEncode(payload),
          )
          .timeout(requestTimeout);

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        if (data['user'] != null) {
          currentUser = ApiUser.fromJson(data['user']);
        }
        return {
          'success': true,
          'message': data['message'] ?? 'Profil berhasil diperbarui!',
          'user': currentUser,
        };
      } else {
        return {
          'success': false,
          'error': data['error'] ?? 'Gagal memperbarui profil (Status ${response.statusCode})',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': _formatConnectionError(e),
      };
    }
  }

  // ===========================================================================
  // 3. BOOKINGS / PENITIPAN BARANG
  // ===========================================================================

  /// Mengambil daftar riwayat booking penitipan user
  static Future<Map<String, dynamic>> getBookings({
    String? userId,
    String? status,
  }) async {
    final queryParams = <String, String>{};
    final targetId = userId ?? currentUser?.id;
    if (targetId != null && targetId.isNotEmpty) {
      queryParams['userId'] = targetId;
    }
    if (status != null && status.isNotEmpty) {
      queryParams['status'] = status;
    }

    final uri = Uri.parse('$baseUrl/bookings').replace(
      queryParameters: queryParams.isNotEmpty ? queryParams : null,
    );

    try {
      final response = await http.get(uri, headers: headers).timeout(requestTimeout);
      final dynamic data = jsonDecode(response.body);

      if (response.statusCode == 200 && data is List) {
        return {
          'success': true,
          'bookings': data,
        };
      } else if (data is Map && data['error'] != null) {
        return {
          'success': false,
          'error': data['error'],
        };
      } else {
        return {
          'success': false,
          'error': 'Gagal mengambil data booking (Status ${response.statusCode})',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': _formatConnectionError(e),
      };
    }
  }

  /// Mengambil detail satu booking beserta logs dan condition report
  static Future<Map<String, dynamic>> getBookingById(String bookingId) async {
    final url = Uri.parse('$baseUrl/bookings/$bookingId');

    try {
      final response = await http.get(url, headers: headers).timeout(requestTimeout);
      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'booking': data,
        };
      } else {
        return {
          'success': false,
          'error': data['error'] ?? 'Booking tidak ditemukan',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': _formatConnectionError(e),
      };
    }
  }

  /// Membuat booking baru ke backend SafeTitip
  static Future<Map<String, dynamic>> createBooking(Map<String, dynamic> bookingData) async {
    final url = Uri.parse('$baseUrl/bookings');

    try {
      final response = await http
          .post(
            url,
            headers: headers,
            body: jsonEncode(bookingData),
          )
          .timeout(requestTimeout);

      final data = jsonDecode(response.body);

      if (response.statusCode == 201) {
        return {
          'success': true,
          'message': data['message'] ?? 'Booking berhasil dibuat!',
          'booking': data['booking'],
          'quotation': data['quotation'],
          'klasifikasi': data['klasifikasi'],
        };
      } else {
        final errMsg = data['error'] ??
            (data['errors'] is List ? (data['errors'] as List).join(', ') : 'Gagal membuat booking');
        return {
          'success': false,
          'error': errMsg,
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': _formatConnectionError(e),
      };
    }
  }

  // ===========================================================================
  // 4. PEMBAYARAN MIDTRANS (PAYMENTS)
  // ===========================================================================

  /// Meminta Snap Token Midtrans untuk pembayaran penitipan
  static Future<Map<String, dynamic>> createPaymentSnapToken(String bookingId) async {
    final url = Uri.parse('$baseUrl/payments/snap-token');

    try {
      final response = await http
          .post(
            url,
            headers: headers,
            body: jsonEncode({'bookingId': bookingId}),
          )
          .timeout(requestTimeout);

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        return {
          'success': true,
          'data': data['data'],
        };
      } else {
        return {
          'success': false,
          'error': data['error'] ?? 'Gagal membuat token pembayaran Midtrans',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': _formatConnectionError(e),
      };
    }
  }

  /// Mengecek status pembayaran booking realtime
  static Future<Map<String, dynamic>> getPaymentStatus(String bookingId) async {
    final url = Uri.parse('$baseUrl/payments/$bookingId');

    try {
      final response = await http.get(url, headers: headers).timeout(requestTimeout);
      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        return {
          'success': true,
          'paymentStatus': data['paymentStatus'],
          'payment': data['payment'],
          'bookingId': data['bookingId'],
          'kodeBooking': data['kodeBooking'],
        };
      } else {
        return {
          'success': false,
          'error': data['error'] ?? 'Gagal memeriksa status pembayaran',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': _formatConnectionError(e),
      };
    }
  }
}
