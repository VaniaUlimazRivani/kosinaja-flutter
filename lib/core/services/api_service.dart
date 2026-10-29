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

  ApiUser({
    required this.id,
    required this.nama,
    required this.email,
    required this.noWa,
    this.alamat,
    this.role = 'USER',
  });

  factory ApiUser.fromJson(Map<String, dynamic> json) {
    return ApiUser(
      id: json['id'] ?? '',
      nama: json['nama'] ?? '',
      email: json['email'] ?? '',
      noWa: json['noWa'] ?? '',
      alamat: json['alamat'],
      role: json['role'] ?? 'USER',
    );
  }
}

class ApiService {
  // Base URL otomatis mendeteksi platform (Web/Windows = localhost, Android Emulator = 10.0.2.2)
  static String get baseUrl {
    if (kIsWeb || !Platform.isAndroid) {
      return 'http://localhost:3000/api';
    } else {
      return 'http://10.0.2.2:3000/api';
    }
  }

  // Session user yang sedang login di aplikasi
  static ApiUser? currentUser;

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
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'nama': nama.trim(),
          'email': email.trim().toLowerCase(),
          'noWa': noWa.trim(),
          'password': password,
          'alamat': alamat?.trim(),
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 201) {
        if (data['user'] != null) {
          currentUser = ApiUser.fromJson(data['user']);
        }
        return {
          'success': true,
          'message': data['message'] ?? 'Registrasi akun berhasil tersimpan ke MongoDB!',
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
        'error':
            'Gagal menghubungi server MongoDB ($baseUrl). Pastikan server backend sedang berjalan (jalankan "npm run dev" di safetitip-app).',
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
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email.trim().toLowerCase(),
          'password': password,
          'accountType': accountType,
        }),
      );

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
        'error':
            'Gagal menghubungi server MongoDB ($baseUrl). Pastikan server backend sedang berjalan (jalankan "npm run dev" di safetitip-app).',
      };
    }
  }
}
