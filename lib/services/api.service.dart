import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';

class ApiService {
  static const String baseUrl = 'http://192.168.1.100:8000';

  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  static Future<Map<String, String>> _headers({bool auth = true}) async {
    final headers = {'Content-Type': 'application/json'};
    if (auth) {
      final token = await _getToken();
      if (token != null) headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  static Future<Map<String, dynamic>> login(String phone, String password) async {
    final res = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: await _headers(auth: false),
      body: jsonEncode({'phone': phone, 'password': password}),
    );
    final data = jsonDecode(res.body);
    if (res.statusCode == 200) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', data['token']);
      await prefs.setString('user', jsonEncode(data['user']));
    }
    return {'status': res.statusCode, 'data': data};
  }

  static Future<Map<String, dynamic>> register({
    required String name,
    required String phone,
    required String password,
    required String address,
  }) async {
    final res = await http.post(
      Uri.parse('$baseUrl/auth/register'),
      headers: await _headers(auth: false),
      body: jsonEncode({
        'name': name,
        'phone': phone,
        'password': password,
        'address': address,
      }),
    );
    return {'status': res.statusCode, 'data': jsonDecode(res.body)};
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

  static Future<List<Product>> getProducts() async {
    final res = await http.get(
      Uri.parse('$baseUrl/products'),
      headers: await _headers(),
    );
    if (res.statusCode == 200) {
      final List data = jsonDecode(res.body);
      return data.map((e) => Product.fromJson(e)).toList();
    }
    return [];
  }

  static Future<Map<String, dynamic>> placeOrder({
    required int productId,
    required int gallons,
    required String deliveryAddress,
    required String deliveryType,
    required String paymentMethod,
    String? notes,
  }) async {
    final res = await http.post(
      Uri.parse('$baseUrl/orders'),
      headers: await _headers(),
      body: jsonEncode({
        'product_id': productId,
        'gallons': gallons,
        'delivery_address': deliveryAddress,
        'delivery_type': deliveryType,
        'payment_method': paymentMethod,
        'notes': notes,
      }),
    );
    return {'status': res.statusCode, 'data': jsonDecode(res.body)};
  }

  static Future<List<Order>> getMyOrders() async {
    final res = await http.get(
      Uri.parse('$baseUrl/orders/my'),
      headers: await _headers(),
    );
    if (res.statusCode == 200) {
      final List data = jsonDecode(res.body);
      return data.map((e) => Order.fromJson(e)).toList();
    }
    return [];
  }

  static Future<Order?> getOrderDetails(String orderId) async {
    final res = await http.get(
      Uri.parse('$baseUrl/orders/$orderId'),
      headers: await _headers(),
    );
    if (res.statusCode == 200) {
      return Order.fromJson(jsonDecode(res.body));
    }
    return null;
  }

  static Future<Map<String, dynamic>> updateProfile({
    required String name,
    required String address,
    String? phone,
  }) async {
    final res = await http.put(
      Uri.parse('$baseUrl/customers/me'),
      headers: await _headers(),
      body: jsonEncode({'name': name, 'address': address, 'phone': phone}),
    );
    return {'status': res.statusCode, 'data': jsonDecode(res.body)};
  }
}