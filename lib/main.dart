import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'theme/app_theme.dart';
import 'screens/auth/splash_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/orders/place_order_screen.dart';
import 'screens/orders/checkout_screen.dart';
import 'screens/orders/order_success_screen.dart';
import 'screens/orders/my_orders_screen.dart';
import 'screens/orders/order_detail_screen.dart';
import 'screens/orders/order_tracking_screen.dart';
import 'screens/account/account_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const AquavonApp());
}

class AquavonApp extends StatelessWidget {
  const AquavonApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aquavon',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      initialRoute: '/splash',
      routes: {
        '/splash': (_) => const SplashScreen(),
        '/login': (_) => const LoginScreen(),
        '/register': (_) => const RegisterScreen(),
        '/home': (_) => const HomeScreen(),
        '/place-order': (_) => const PlaceOrderScreen(),
        '/checkout': (_) => const CheckoutScreen(),
        '/order-success': (_) => const OrderSuccessScreen(),
        '/my-orders': (_) => const MyOrdersScreen(),
        '/account': (_) => const AccountScreen(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/order-detail') {
          final orderId = settings.arguments as String;
          return MaterialPageRoute(
            builder: (_) => OrderDetailScreen(orderId: orderId),
          );
        }
        if (settings.name == '/order-tracking') {
          final orderId = settings.arguments as String;
          return MaterialPageRoute(
            builder: (_) => OrderTrackingScreen(orderId: orderId),
          );
        }
        return null;
      },
    );
  }
}