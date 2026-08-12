import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/models.dart';
import '../../services/api.service.dart'; 
import '../../theme/app.theme.dart';

class OrderDetailScreen extends StatefulWidget {
  final String orderId;
  const OrderDetailScreen({super.key, required this.orderId});

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  Order? _order;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadOrder();
  }

  Future<void> _loadOrder() async {
    final order = await ApiService.getOrderDetails(widget.orderId);
    setState(() { _order = order; _loading = false; });
  }

  String _paymentLabel(String m) {
    switch (m) {
      case 'cash_on_delivery': return 'Cash on Delivery';
      case 'gcash': return 'GCash';
      case 'paymaya': return 'PayMaya';
      default: return m;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Order Details'), leading: const BackButton()),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _order == null
              ? const Center(child: Text('Order not found'))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(_order!.orderId,
                                        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: AppColors.primary)),
                                    Text(DateFormat('MMM d, yyyy | h:mm a').format(_order!.createdAt),
                                        style: const TextStyle(color: AppColors.textMid, fontSize: 12)),
                                  ],
                                ),
                              ),
                              _StatusBadge(_order!.status),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Order Items', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Container(
                                    width: 48, height: 48,
                                    decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(10)),
                                    child: const Icon(Icons.water_drop, color: AppColors.primary),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(_order!.productName, style: const TextStyle(fontWeight: FontWeight.w600)),
                                        Text('₱${_order!.pricePerGallon.toStringAsFixed(0)} / gallon',
                                            style: const TextStyle(color: AppColors.textMid, fontSize: 13)),
                                      ],
                                    ),
                                  ),
                                  Text('× ${_order!.gallons}'),
                                  const SizedBox(width: 12),
                                  Text('₱${(_order!.pricePerGallon * _order!.gallons).toStringAsFixed(0)}',
                                      style: const TextStyle(fontWeight: FontWeight.w600)),
                                ],
                              ),
                              const Divider(height: 20),
                              _SumRow('Subtotal', '₱${(_order!.pricePerGallon * _order!.gallons).toStringAsFixed(0)}'),
                              _SumRow('Delivery Fee', '₱${_order!.deliveryFee.toStringAsFixed(0)}'),
                              const SizedBox(height: 4),
                              _SumRow('Total Amount', '₱${_order!.totalAmount.toStringAsFixed(0)}', bold: true, color: AppColors.primary),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Delivery Details', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                              const SizedBox(height: 12),
                              _InfoRow(Icons.location_on_outlined, _order!.deliveryAddress),
                              const SizedBox(height: 8),
                              _InfoRow(Icons.calendar_today_outlined, DateFormat('MMMM d, yyyy').format(_order!.createdAt)),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Card(
                        child: ListTile(
                          leading: const Icon(Icons.payments_outlined, color: AppColors.primary),
                          title: const Text('Payment Method'),
                          subtitle: Text(_paymentLabel(_order!.paymentMethod)),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Order Status', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                              const SizedBox(height: 12),
                              _Timeline(status: _order!.status, createdAt: _order!.createdAt),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (_order!.status == 'on_the_way')
                        ElevatedButton.icon(
                          onPressed: () => Navigator.pushNamed(context, '/order-tracking', arguments: _order!.orderId),
                          icon: const Icon(Icons.map_outlined),
                          label: const Text('Track Order'),
                        ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
      bottomNavigationBar: Container(
        color: AppColors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: SafeArea(
          child: OutlinedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.headset_mic_outlined),
            label: const Text('Contact Us'),
          ),
        ),
      ),
    );
  }
}

class _Timeline extends StatelessWidget {
  final String status;
  final DateTime createdAt;
  const _Timeline({required this.status, required this.createdAt});

  static const _steps = [
    {'key': 'pending', 'label': 'Order Placed'},
    {'key': 'confirmed', 'label': 'Confirmed'},
    {'key': 'on_the_way', 'label': 'On the Way'},
    {'key': 'delivered', 'label': 'Delivered'},
  ];

  @override
  Widget build(BuildContext context) {
    final order = ['pending', 'confirmed', 'on_the_way', 'delivered'];
    final current = order.indexOf(status);
    return Column(
      children: List.generate(_steps.length, (i) {
        final done = i <= current;
        final active = i == current;
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                Container(
                  width: 24, height: 24,
                  decoration: BoxDecoration(shape: BoxShape.circle, color: done ? AppColors.primary : AppColors.divider),
                  child: Icon(done ? Icons.check : Icons.circle, size: 14, color: done ? Colors.white : AppColors.textLight),
                ),
                if (i < _steps.length - 1)
                  Container(width: 2, height: 32, color: i < current ? AppColors.primary : AppColors.divider),
              ],
            ),
            const SizedBox(width: 12),
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_steps[i]['label']!,
                      style: TextStyle(fontWeight: active ? FontWeight.w700 : FontWeight.normal,
                          color: done ? AppColors.textDark : AppColors.textLight)),
                  if (active)
                    Text(DateFormat('MMM d, yyyy | h:mm a').format(createdAt),
                        style: const TextStyle(fontSize: 11, color: AppColors.textMid)),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge(this.status);

  @override
  Widget build(BuildContext context) {
    final map = {
      'pending': [const Color(0xFFFFF3CD), const Color(0xFF856404), 'Pending'],
      'confirmed': [AppColors.primaryLight, AppColors.primary, 'Confirmed'],
      'on_the_way': [const Color(0xFFCFF4FC), const Color(0xFF055160), 'On the Way'],
      'delivered': [const Color(0xFFD1E7DD), const Color(0xFF0A3622), 'Completed'],
      'cancelled': [const Color(0xFFF8D7DA), const Color(0xFF842029), 'Cancelled'],
    };
    final colors = map[status] ?? [AppColors.bgGray, AppColors.textMid, status];
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: colors[0] as Color, borderRadius: BorderRadius.circular(20)),
      child: Text(colors[2] as String,
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: colors[1] as Color)),
    );
  }
}

class _SumRow extends StatelessWidget {
  final String l; final String v; final bool bold; final Color? color;
  const _SumRow(this.l, this.v, {this.bold = false, this.color});

  @override
  Widget build(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(l, style: TextStyle(fontWeight: bold ? FontWeight.w700 : FontWeight.normal, fontSize: bold ? 15 : 13, color: AppColors.textMid)),
      Text(v, style: TextStyle(fontWeight: bold ? FontWeight.w700 : FontWeight.normal, fontSize: bold ? 15 : 13, color: color ?? AppColors.textDark)),
    ],
  );
}

class _InfoRow extends StatelessWidget {
  final IconData icon; final String text;
  const _InfoRow(this.icon, this.text);

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Icon(icon, size: 16, color: AppColors.textMid),
      const SizedBox(width: 8),
      Expanded(child: Text(text, style: const TextStyle(fontSize: 13))),
    ],
  );
}