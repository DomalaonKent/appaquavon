import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class OrderSuccessScreen extends StatelessWidget {
  const OrderSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final data = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 100, height: 100,
                decoration: const BoxDecoration(color: Color(0xFFDCFCE7), shape: BoxShape.circle),
                child: const Icon(Icons.check_circle, color: AppColors.success, size: 64),
              ),
              const SizedBox(height: 24),
              const Text('Order Placed!', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800)),
              const SizedBox(height: 8),
              const Text('Thank you! Your order has been\nplaced successfully.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.textMid, fontSize: 15)),
              const SizedBox(height: 32),
              if (data != null)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(color: AppColors.bgGray, borderRadius: BorderRadius.circular(16)),
                  child: Column(
                    children: [
                      _DetailRow('Order ID', data['order_id'] ?? '—'),
                      const SizedBox(height: 10),
                      _DetailRow('Estimated Delivery', data['estimated_delivery'] ?? '10:45 AM – 11:15 AM'),
                      const SizedBox(height: 10),
                      _DetailRow('Delivery Address', data['delivery_address'] ?? '—'),
                      const SizedBox(height: 10),
                      _DetailRow('Payment Method', _paymentLabel(data['payment_method'] ?? '')),
                      const SizedBox(height: 10),
                      _DetailRow('Total Amount', '₱${(data['total_amount'] ?? 0).toStringAsFixed(0)}', highlight: true),
                    ],
                  ),
                ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(12)),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline, color: AppColors.primary, size: 18),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text("We'll notify you when your order is on the way.",
                          style: TextStyle(color: AppColors.primary, fontSize: 13)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () => Navigator.pushReplacementNamed(context, '/my-orders'),
                child: const Text('View My Orders'),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () => Navigator.pushReplacementNamed(context, '/home'),
                child: const Text('Back to Home'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _paymentLabel(String method) {
    switch (method) {
      case 'cash_on_delivery': return 'Cash on Delivery';
      case 'gcash': return 'GCash';
      case 'paymaya': return 'PayMaya';
      default: return method;
    }
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final bool highlight;
  const _DetailRow(this.label, this.value, {this.highlight = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(width: 120, child: Text(label, style: const TextStyle(color: AppColors.textMid, fontSize: 13))),
        Expanded(
          child: Text(value, style: TextStyle(fontWeight: FontWeight.w600, color: highlight ? AppColors.primary : AppColors.textDark)),
        ),
      ],
    );
  }
}