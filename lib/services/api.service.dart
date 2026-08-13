import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';

class ApiService {
  // ─── Mock Data ───────────────────────────────────────────────────────────────

  static final _mockUser = UserModel(
    id: 1,
    name: 'Kent Domalaon',
    phone: '09123456789',
    address: 'Sorsogon City, Sorsogon',
  );

  static final _mockProducts = <Product>[
    Product(id: 1, name: 'Regular Water', pricePerGallon: 25, type: 'purified'),
    Product(id: 2, name: 'Purified Water', pricePerGallon: 35, type: 'purified'),
    Product(id: 3, name: 'Alkaline Water', pricePerGallon: 50, type: 'alkaline'),
  ];

  static final _mockOrders = <Order>[
    Order(
      orderId: '1001',
      customerId: 1,
      customerName: 'Kent Domalaon',
      customerPhone: '09123456789',
      deliveryAddress: 'Sorsogon City, Sorsogon',
      productId: 2,
      productName: 'Purified Water',
      gallons: 3,
      pricePerGallon: 35,
      deliveryFee: 20,
      totalAmount: 125,
      deliveryType: 'delivery',
      paymentMethod: 'cash_on_delivery',
      status: 'delivered',
      createdAt: DateTime(2025, 8, 10),
    ),
    Order(
      orderId: '1002',
      customerId: 1,
      customerName: 'Kent Domalaon',
      customerPhone: '09123456789',
      deliveryAddress: 'Sorsogon City, Sorsogon',
      productId: 1,
      productName: 'Regular Water',
      gallons: 5,
      pricePerGallon: 25,
      deliveryFee: 0,
      totalAmount: 125,
      deliveryType: 'pickup',
      paymentMethod: 'cash_on_delivery',
      status: 'pending',
      createdAt: DateTime(2025, 8, 12),
    ),
  ];

  // ─── Auth ─────────────────────────────────────────────────────────────────

  static Future<Map<String, dynamic>> login(String phone, String password) async {
    await Future.delayed(const Duration(seconds: 1));
    if (phone == '09123456789' && password == 'password') {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', 'mock-token-123');
      await prefs.setString('user', jsonEncode({
        'id': 1,
        'name': 'Kent Domalaon',
        'phone': '09123456789',
        'address': 'Sorsogon City, Sorsogon',
      }));
      return {'status': 200, 'data': {}};
    }
    return {'status': 401, 'data': {'message': 'Invalid credentials'}};
  }

  static Future<Map<String, dynamic>> register({
    required String name,
    required String phone,
    required String password,
    required String address,
  }) async {
    await Future.delayed(const Duration(seconds: 1));
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', 'mock-token-123');
    await prefs.setString('user', jsonEncode({
      'id': 1,
      'name': name,
      'phone': phone,
      'address': address,
    }));
    return {'status': 200, 'data': {'message': 'Registered successfully'}};
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('user');
  }

  static Future<UserModel?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('user');
    if (raw == null) return null;
    return UserModel.fromJson(jsonDecode(raw));
  }

  // ─── Products ─────────────────────────────────────────────────────────────

  static Future<List<Product>> getProducts() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _mockProducts;
  }

  // ─── Orders ───────────────────────────────────────────────────────────────

  static Future<Map<String, dynamic>> placeOrder({
    required int productId,
    required int gallons,
    required String deliveryAddress,
    required String deliveryType,
    required String paymentMethod,
    String? notes,
  }) async {
    await Future.delayed(const Duration(seconds: 1));
    return {'status': 200, 'data': {'order_id': '1003', 'message': 'Order placed!'}};
  }

  static Future<List<Order>> getMyOrders() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _mockOrders;
  }

  static Future<Order?> getOrderDetails(String orderId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    try {
      return _mockOrders.firstWhere((o) => o.orderId == orderId);
    } catch (_) {
      return _mockOrders.first;
    }
  }

  static Future<Map<String, dynamic>> updateProfile({
    required String name,
    required String address,
    String? phone,
  }) async {
    await Future.delayed(const Duration(seconds: 1));
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user', jsonEncode({
      'id': 1,
      'name': name,
      'phone': phone ?? '09123456789',
      'address': address,
    }));
    return {'status': 200, 'data': {'message': 'Profile updated'}};
  }
}