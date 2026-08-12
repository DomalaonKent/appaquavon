import 'package:flutter/material.dart';
import '../../models/models.dart';
import '../../services/api.service.dart'; 
import '../../theme/app.theme.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  String _payment = 'cash_on_delivery';
  bool _loading = false;

  final _payments = [
    {'id': 'cash_on_delivery', 'label': 'Cash on Delivery', 'icon': Icons.payments_outlined},
    {'id': 'gcash', 'label': 'GCash', 'icon': Icons.account_balance_wallet_outlined},
    {'id': 'paymaya', 'label': 'PayMaya', 'icon': Icons.credit_card_outlined},
  ];

  Future<void> _placeOrder(Map<String, dynamic> args) async {
    final product = args['product'] as Product;
    setState(() => _loading = true);
    final res = await ApiService.placeOrder(
      productId: product.id,
      gallons: args['qty'] as int,
      deliveryAddress: args['address'] as String,
      deliveryType: args['deliveryType'] as String,
      paymentMethod: _payment,
      notes: args['notes'] as String?,
    );
    setState(() => _loading = false);
    if (!mounted) return;
    if (res['status'] == 201) {
      Navigator.pushReplacementNamed(context, '/order-success', arguments: res['data']);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(res['data']['detail'] ?? 'Failed to place order'),
          backgroundColor: AppColors.danger,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final product = args['product'] as Product;
    final qty = args['qty'] as int;
    final deliveryFee = args['deliveryFee'] as double;
    final total = args['total'] as double;
    final user = args['user'] as UserModel?;

    return Scaffold(
      appBar: AppBar(title: const Text('Checkout'), leading: const BackButton()),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Order Summary', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Container(
                          width: 50, height: 50,
                          decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(10)),
                          child: const Icon(Icons.water_drop, color: AppColors.primary),
                        ),
                        const SizedBox(width: 12),
                        Expanded(child: Text(product.name, style: const TextStyle(fontWeight: FontWeight.w600))),
                        Text('× $qty', style: const TextStyle(color: AppColors.textMid)),
                        const SizedBox(width: 12),
                        Text('₱${(product.pricePerGallon * qty).toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.w600)),
                      ],
                    ),
                    const Divider(height: 24),
                    _Row('Delivery Fee', '₱${deliveryFee.toStringAsFixed(0)}'),
                    const SizedBox(height: 8),
                    _Row('Total Amount', '₱${total.toStringAsFixed(0)}', bold: true, color: AppColors.primary),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: ListTile(
                leading: const Icon(Icons.phone_outlined, color: AppColors.primary),
                title: const Text('Contact Number'),
                subtitle: Text(user?.phone ?? 'Not set'),
                trailing: TextButton(onPressed: () {}, child: const Text('Change')),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Payment Method', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                    const SizedBox(height: 12),
                    ..._payments.map((p) {
                      final sel = _payment == p['id'];
                      return GestureDetector(
                        onTap: () => setState(() => _payment = p['id'] as String),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: sel ? AppColors.primaryLight : AppColors.bgGray,
                            border: Border.all(color: sel ? AppColors.primary : Colors.transparent, width: 1.5),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Icon(p['icon'] as IconData, color: sel ? AppColors.primary : AppColors.textMid),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(p['label'] as String,
                                    style: TextStyle(fontWeight: sel ? FontWeight.w600 : FontWeight.normal, color: sel ? AppColors.primary : AppColors.textDark)),
                              ),
                              if (sel) const Icon(Icons.check_circle, color: AppColors.primary),
                            ],
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        color: AppColors.white,
        padding: const EdgeInsets.all(16),
        child: SafeArea(
          child: ElevatedButton(
            onPressed: _loading ? null : () => _placeOrder(args),
            child: _loading
                ? const SizedBox(height: 22, width: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : const Text('Place Order'),
          ),
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final String label;
  final String value;
  final bool bold;
  final Color? color;
  const _Row(this.label, this.value, {this.bold = false, this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontWeight: bold ? FontWeight.w700 : FontWeight.normal, fontSize: bold ? 16 : 14)),
        Text(value, style: TextStyle(fontWeight: bold ? FontWeight.w700 : FontWeight.normal, fontSize: bold ? 16 : 14, color: color)),
      ],
    );
  }
}