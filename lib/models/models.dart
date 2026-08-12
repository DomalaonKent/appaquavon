// ─── User ────────────────────────────────────────────────────────────────────
class UserModel {
  final int id;
  final String name;
  final String phone;
  final String address;
  final String? token;

  UserModel({
    required this.id,
    required this.name,
    required this.phone,
    required this.address,
    this.token,
  });

  factory UserModel.fromJson(Map<String, dynamic> j) => UserModel(
        id: j['id'],
        name: j['name'],
        phone: j['phone'],
        address: j['address'],
        token: j['token'],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'phone': phone,
        'address': address,
      };
}

// ─── Product ─────────────────────────────────────────────────────────────────
class Product {
  final int id;
  final String name;
  final double pricePerGallon;
  final String type; // purified / alkaline

  Product({
    required this.id,
    required this.name,
    required this.pricePerGallon,
    required this.type,
  });

  factory Product.fromJson(Map<String, dynamic> j) => Product(
        id: j['id'],
        name: j['name'],
        pricePerGallon: (j['price_per_gallon'] as num).toDouble(),
        type: j['type'] ?? 'purified',
      );
}

// ─── Order ───────────────────────────────────────────────────────────────────
class Order {
  final String orderId;
  final int customerId;
  final String customerName;
  final String customerPhone;
  final String deliveryAddress;
  final int productId;
  final String productName;
  final int gallons;
  final double pricePerGallon;
  final double deliveryFee;
  final double totalAmount;
  final String deliveryType; // delivery / pickup
  final String paymentMethod; // cash_on_delivery / gcash / paymaya
  final String status; // pending / confirmed / on_the_way / delivered / cancelled
  final String? notes;
  final DateTime createdAt;
  final String? driverName;
  final String? driverPhone;
  final String? vehiclePlate;

  Order({
    required this.orderId,
    required this.customerId,
    required this.customerName,
    required this.customerPhone,
    required this.deliveryAddress,
    required this.productId,
    required this.productName,
    required this.gallons,
    required this.pricePerGallon,
    required this.deliveryFee,
    required this.totalAmount,
    required this.deliveryType,
    required this.paymentMethod,
    required this.status,
    this.notes,
    required this.createdAt,
    this.driverName,
    this.driverPhone,
    this.vehiclePlate,
  });

  factory Order.fromJson(Map<String, dynamic> j) => Order(
        orderId: j['order_id'],
        customerId: j['customer_id'],
        customerName: j['customer_name'],
        customerPhone: j['customer_phone'],
        deliveryAddress: j['delivery_address'],
        productId: j['product_id'],
        productName: j['product_name'],
        gallons: j['gallons'],
        pricePerGallon: (j['price_per_gallon'] as num).toDouble(),
        deliveryFee: (j['delivery_fee'] as num).toDouble(),
        totalAmount: (j['total_amount'] as num).toDouble(),
        deliveryType: j['delivery_type'],
        paymentMethod: j['payment_method'],
        status: j['status'],
        notes: j['notes'],
        createdAt: DateTime.parse(j['created_at']),
        driverName: j['driver_name'],
        driverPhone: j['driver_phone'],
        vehiclePlate: j['vehicle_plate'],
      );

  String get statusLabel {
    switch (status) {
      case 'pending': return 'Pending';
      case 'confirmed': return 'Confirmed';
      case 'on_the_way': return 'On the Way';
      case 'delivered': return 'Delivered';
      case 'cancelled': return 'Cancelled';
      default: return status;
    }
  }
}