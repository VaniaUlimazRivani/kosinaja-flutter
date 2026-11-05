import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
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
import 'screens/location/location_shipping_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp();
  } catch (e) {
    debugPrint('Firebase init info: $e');
  }
  try {
    await initializeDateFormatting('id_ID', null);
  } catch (e) {
    debugPrint('Locale init info: $e');
  }
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
        '/': (context) => const OnboardingScreen(),
        '/onboarding': (context) => const OnboardingScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/home': (context) => const HomeScreen(),
        '/orders': (context) => const OrdersScreen(),
        '/help': (context) => const HelpScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/notifications': (context) => const NotificationsScreen(),
        '/location-shipping': (context) => const LocationShippingScreen(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/booking-step1') {
          final data = settings.arguments as BookingData?;
          return MaterialPageRoute(
            builder: (context) => BookingStep1Screen(initialBooking: data),
          );
        } else if (settings.name == '/booking-step2') {
          final data = settings.arguments as BookingData?;
          return MaterialPageRoute(
            builder: (context) => BookingStep2Screen(bookingData: data),
          );
        } else if (settings.name == '/booking-step3') {
          final data = settings.arguments as BookingData?;
          return MaterialPageRoute(
            builder: (context) => BookingStep3Screen(bookingData: data),
          );
        } else if (settings.name == '/tracking') {
          final args = settings.arguments;
          if (args is Map<String, dynamic>) {
            return MaterialPageRoute(
              builder: (context) => TrackingScreen(
                orderCode: args['orderCode'] as String?,
                bookingData: args['booking'] as BookingData?,
              ),
            );
          } else if (args is BookingData) {
            return MaterialPageRoute(
              builder: (context) => TrackingScreen(bookingData: args),
            );
          } else if (args is String) {
            return MaterialPageRoute(
              builder: (context) => TrackingScreen(orderCode: args),
            );
          }
          return MaterialPageRoute(
            builder: (context) => const TrackingScreen(),
          );
        }
        return null;
      },
    );
  }
}
