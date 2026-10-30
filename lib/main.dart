import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'core/services/api_service.dart';
import 'core/theme/app_theme.dart';
import 'models/booking_model.dart';
import 'screens/onboarding/onboarding_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/booking/booking_step1_screen.dart';
import 'screens/booking/booking_step2_screen.dart';
import 'screens/booking/booking_step3_screen.dart';
import 'screens/tracking/tracking_screen.dart';
import 'screens/orders/orders_screen.dart';
import 'screens/help/help_screen.dart';
import 'screens/profile/profile_screen.dart';
import 'screens/notifications/notifications_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID', null);
  // Pulihkan sesi user & konfigurasi aplikasi dari penyimpanan lokal persisten
  await ApiService.initSession();
  runApp(const KosinAjaApp());
}

class KosinAjaApp extends StatelessWidget {
  const KosinAjaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'KosinAja Student Storage',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: '/',
      routes: {
        '/': (context) {
          // 1. Jika sudah ada sesi aktif -> langsung masuk Dashboard Home
          if (ApiService.isLoggedIn) {
            return const HomeScreen();
          }
          // 2. Jika belum login tapi sudah pernah lewati onboarding -> langsung Login
          if (ApiService.hasSeenOnboarding) {
            return const LoginScreen();
          }
          // 3. User baru pertama kali buka app -> Tampilkan Onboarding
          return const OnboardingScreen();
        },
        '/onboarding': (context) => const OnboardingScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/home': (context) => const HomeScreen(),
        '/booking-step1': (context) => const BookingStep1Screen(),
        '/tracking': (context) => const TrackingScreen(),
        '/orders': (context) => const OrdersScreen(),
        '/help': (context) => const HelpScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/notifications': (context) => const NotificationsScreen(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/booking-step2') {
          final data = settings.arguments as BookingData?;
          return MaterialPageRoute(
            builder: (context) => BookingStep2Screen(bookingData: data),
          );
        } else if (settings.name == '/booking-step3') {
          final data = settings.arguments as BookingData?;
          return MaterialPageRoute(
            builder: (context) => BookingStep3Screen(bookingData: data),
          );
        }
        return null;
      },
    );
  }
}
