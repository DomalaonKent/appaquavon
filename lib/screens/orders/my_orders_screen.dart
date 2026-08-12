import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/models.dart';
import '../../services/api_service.dart';
import '../../theme/app_theme.dart';

class MyOrdersScreen extends StatefulWidget {
  const MyOrdersScreen({super.key});

  @override
  State<MyOrdersScreen> createState() => _MyOrdersScreenState();
}

class _MyOrdersScreenState extends State<MyOrdersScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabs;
  List<Order> _orders = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 4, vsync: this);
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    final orders = await ApiService.getMyOrders();
    setState(() {
      _orders = orders;
      _loading = false;
    });
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  List<Order> _filtered(List<String> statuses) => _orders
      .where((o) => statuses.isEmpty || statuses.contains(o.status))
      .toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Orders'),
        bottom: TabBar(
          controller: _tabs,
          isScrollable: true,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textMid,
          indicatorColor: AppColors.primary,
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'To Deliver'),
            Tab(text: 'Completed'),
            Tab(text: 'Cancelled'),
          ],
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadOrders,
              child: TabBarView(
                controller: _tabs,
                children: [
                  _OrderList(orders: _filtered([])),
                  _OrderList(orders: _filtered(['pending', 'confirmed', 'on_the_way'])),
                  _OrderList(orders: _filtered(['delivered'])),
                  _OrderList(orders: _filtered(['cancelled'])),
                ],
              ),
            ),
    );
  }
}

class _OrderList extends StatelessWidget {
  final List<Order> orders;
  const _OrderList({required this.orders});

  @override
  Widget build(BuildContext context) {
    if (orders.isEmpty) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.receipt_long_outlined, size: 64, color: AppColors.textLight),
            SizedBox(height: 12),
            Text('No orders yet', style: TextStyle(color: AppColors.textMid, fontSize: 15)),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: orders.length,
      itemBuilder: (ctx, i) => _OrderCard(order: orders[i]),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final Order order;
  const _OrderCard({required this.order});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(order.orderId,
                    style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.primary)),
                _StatusChip(status: order.status),
              ],
            ),
            const SizedBox(height: 4),
            Text(DateFormat('MMM d, yyyy').format(order.createdAt),
                style: const TextStyle(fontSize: 12, color: AppColors.textMid)),
            const SizedBox(height: 12),
            Row(
              children: [
                Container(
                  width: 44, height: 44,
                  decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(10)),
                  child: const Icon(Icons.water_drop, color: AppColors.primary, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(order.productName, style: const TextStyle(fontWeight: FontWeight.w600)),
                      Text('${order.gallons} gallon${order.gallons > 1 ? 's' : ''}',
                          style: const TextStyle(fontSize: 12, color: AppColors.textMid)),
                    ],
                  ),
                ),
                Text('Total: ₱${order.totalAmount.toStringAsFixed(0)}',
                    style: const TextStyle(fontWeight: FontWeight.w600)),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => Navigator.pushNamed(context, '/order-detail', arguments: order.orderId),
                style: OutlinedButton.styleFrom(minimumSize: const Size(double.infinity, 40)),
                child: const Text('View Details'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String status;
  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    Color bg; Color fg; String label;
    switch (status) {
      case 'pending': bg = const Color(0xFFFFF3CD); fg = const Color(0xFF856404); label = 'Pending'; break;
      case 'confirmed': bg = AppColors.primaryLight; fg = AppColors.primary; label = 'Confirmed'; break;
      case 'on_the_way': bg = const Color(0xFFCFF4FC); fg = const Color(0xFF055160); label = 'On the Way'; break;
      case 'delivered': bg = const Color(0xFFD1E7DD); fg = const Color(0xFF0A3622); label = 'Completed'; break;
      case 'cancelled': bg = const Color(0xFFF8D7DA); fg = const Color(0xFF842029); label = 'Cancelled'; break;
      default: bg = AppColors.bgGray; fg = AppColors.textMid; label = status;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: fg)),
    );
  }
}