import 'package:flutter/material.dart';
import '../../models/models.dart';
import '../../services/api.service.dart';  
import '../../theme/app.theme.dart';    

class PlaceOrderScreen extends StatefulWidget {
  const PlaceOrderScreen({super.key});

  @override
  State<PlaceOrderScreen> createState() => _PlaceOrderScreenState();
}

class _PlaceOrderScreenState extends State<PlaceOrderScreen> {
  List<Product> _products = [];
  Product? _selected;
  int _qty = 1;
  String _deliveryType = 'delivery';
  String _address = '';
  final _notesCtrl = TextEditingController();
  bool _loading = true;
  UserModel? _user;

  double get _productTotal => (_selected?.pricePerGallon ?? 0) * _qty;
  double get _deliveryFee => _deliveryType == 'delivery' ? 20.0 : 0.0;
  double get _total => _productTotal + _deliveryFee;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final products = await ApiService.getProducts();
    final user = await ApiService.getCurrentUser();
    setState(() {
      _products = products;
      _selected = products.isNotEmpty ? products.first : null;
      _user = user;
      _address = user?.address ?? '';
      _loading = false;
    });
  }

  @override
  void dispose() {
    _notesCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Place Order'),
        leading: const BackButton(),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionLabel('1. Select Product'),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: _products.map((p) {
                          final sel = _selected?.id == p.id;
                          return GestureDetector(
                            onTap: () => setState(() => _selected = p),
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 10),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: sel ? AppColors.primaryLight : AppColors.bgGray,
                                border: Border.all(
                                  color: sel ? AppColors.primary : Colors.transparent,
                                  width: 1.5,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 48,
                                    height: 48,
                                    decoration: BoxDecoration(
                                      color: AppColors.primaryLight,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Icon(Icons.water_drop, color: AppColors.primary),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(p.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                                        Text(
                                          '₱${p.pricePerGallon.toStringAsFixed(0)} / gallon',
                                          style: const TextStyle(color: AppColors.textMid, fontSize: 13),
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (sel)
                                    _QuantityStepper(
                                      value: _qty,
                                      onChanged: (v) => setState(() => _qty = v),
                                    ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(4, 4, 4, 0),
                    child: Text(
                      'Price: ₱${_productTotal.toStringAsFixed(0)}',
                      style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.primary),
                    ),
                  ),
                  const SizedBox(height: 20),
                  _sectionLabel('2. Delivery Address'),
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.location_on_outlined, color: AppColors.primary),
                      title: Text(
                        _address.isEmpty ? 'Set address' : _address,
                        style: TextStyle(color: _address.isEmpty ? AppColors.textMid : AppColors.textDark),
                      ),
                      trailing: TextButton(
                        onPressed: _changeAddress,
                        child: const Text('Change'),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  _sectionLabel('3. Delivery Type'),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        children: [
                          _DeliveryOption(
                            icon: Icons.local_shipping_outlined,
                            title: 'Delivery',
                            subtitle: 'We will deliver to your address',
                            selected: _deliveryType == 'delivery',
                            onTap: () => setState(() => _deliveryType = 'delivery'),
                          ),
                          const SizedBox(height: 8),
                          _DeliveryOption(
                            icon: Icons.storefront_outlined,
                            title: 'Pick-up',
                            subtitle: 'Pick up at our station',
                            selected: _deliveryType == 'pickup',
                            onTap: () => setState(() => _deliveryType = 'pickup'),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  _sectionLabel('4. Additional Notes (Optional)'),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: TextField(
                        controller: _notesCtrl,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          hintText: 'e.g. Gate is blue, Call when arriving...',
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.all(12),
                        ),
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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Total Amount', style: TextStyle(fontWeight: FontWeight.w600)),
                  Text(
                    '₱${_total.toStringAsFixed(0)}',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.primary),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: _selected == null ? null : _goToCheckout,
                child: const Text('Continue to Checkout'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionLabel(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(text, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
      );

  void _goToCheckout() {
    if (_address.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please set a delivery address')),
      );
      return;
    }
    Navigator.pushNamed(context, '/checkout', arguments: {
      'product': _selected,
      'qty': _qty,
      'deliveryType': _deliveryType,
      'address': _address,
      'notes': _notesCtrl.text,
      'deliveryFee': _deliveryFee,
      'total': _total,
      'user': _user,
    });
  }

  Future<void> _changeAddress() async {
    final ctrl = TextEditingController(text: _address);
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delivery Address'),
        content: TextField(
          controller: ctrl,
          maxLines: 3,
          decoration: const InputDecoration(hintText: 'Enter your address'),
        ),
        actions: [

          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.pop(ctx, ctrl.text), child: const Text('Save')),
        ],
      ),
    );
    if (result != null && result.isNotEmpty) setState(() => _address = result);
  }
}