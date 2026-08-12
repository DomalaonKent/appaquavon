import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/models.dart';
import '../../services/api.service.dart'; 
import '../../theme/app.theme.dart';

class OrderTrackingScreen extends StatefulWidget {
  final String orderId;
  const OrderTrackingScreen({super.key, required this.orderId});

  @override
  State<OrderTrackingScreen> createState() => _OrderTrackingScreenState();
}

class _OrderTrackingScreenState extends State<OrderTrackingScreen> {
  Order? _order;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadOrder();
    _startPolling();
  }

  void _startPolling() {
    Future.delayed(const Duration(seconds: 30), () {
      if (mounted) { _loadOrder(); _startPolling(); }
    });
  }

  Future<void> _loadOrder() async {
    final order = await ApiService.getOrderDetails(widget.orderId);
    setState(() { _order = order; _loading = false; });
  }

  Future<void> _callDriver() async {
    if (_order?.driverPhone == null) return;
    final uri = Uri.parse('tel:${_order!.driverPhone}');
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Order Tracking'), leading: const BackButton()),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Container(
                  width: double.infinity,
                  color: AppColors.primaryLight,
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      const Text('Your order is on the way!',
                          style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.primary, fontSize: 16)),
                      const SizedBox(height: 4),
                      Text('Estimated time: 10:45 AM – 11:15 AM',
                          style: TextStyle(color: AppColors.primary.withOpacity(0.7), fontSize: 13)),
                    ],
                  ),
                ),
                Expanded(
                  child: Container(
                    color: const Color(0xFFE0E8F0),
                    child: Stack(
                      children: [
                        Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.map_outlined, size: 80, color: AppColors.textLight),
                              const SizedBox(height: 8),
                              const Text('Live map tracking', style: TextStyle(color: AppColors.textMid)),
                              const SizedBox(height: 4),
                              Text('Google Maps integration\nrequires API key',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: AppColors.textLight, fontSize: 12)),
                            ],
                          ),
                        ),
                        Positioned(
                          bottom: 80, left: 80,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(8)),
                            child: const Icon(Icons.local_shipping, color: Colors.white, size: 28),
                          ),
                        ),
                        const Positioned(
                          top: 80, right: 60,
                          child: Icon(Icons.location_pin, color: AppColors.danger, size: 40),
                        ),
                      ],
                    ),
                  ),
                ),
                if (_order?.driverName != null)
                  Container(
                    color: AppColors.white,
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        const CircleAvatar(
                          radius: 28,
                          backgroundColor: AppColors.primaryLight,
                          child: Icon(Icons.person, color: AppColors.primary, size: 32),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(_order!.driverName!, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                              const Text('Your Driver', style: TextStyle(color: AppColors.textMid, fontSize: 12)),
                              if (_order?.vehiclePlate != null)
                                Text('Vehicle: ${_order!.vehiclePlate}',
                                    style: const TextStyle(fontSize: 12, color: AppColors.textMid)),
                            ],
                          ),
                        ),
                        IconButton.filled(
                          onPressed: _callDriver,
                          icon: const Icon(Icons.phone),
                          style: IconButton.styleFrom(backgroundColor: AppColors.primary),
                        ),
                      ],
                    ),
                  ),
                Container(
                  color: AppColors.bgGray,
                  padding: const EdgeInsets.all(12),
                  child: const Text("We'll notify you when your order arrives.",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.textMid, fontSize: 13)),
                ),
              ],
            ),
    );
  }
}