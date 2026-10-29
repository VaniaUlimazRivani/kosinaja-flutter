import 'package:flutter/material.dart';
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

void main() {
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
        '/': (context) => const OnboardingScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/home': (context) => const HomeScreen(),
        '/booking-step1': (context) => const BookingStep1Screen(),
        '/tracking': (context) => const TrackingScreen(),
        '/orders': (context) => const OrdersScreen(),
        '/help': (context) => const HelpScreen(),
        '/profile': (context) => const ProfileScreen(),
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
