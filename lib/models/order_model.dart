import 'package:cloud_firestore/cloud_firestore.dart';

class OrderModel {
  final String orderId;
  final String customerId;
  final String customerName;
  final List<Map<String, dynamic>> items;
  final double totalAmount;
  final String? receiptUrl;
  final String? address;
  final double? deliveryLat;
  final double? deliveryLng;
  final String paymentMethod; // 'Cash', 'InstaPay', 'Wallet'
  final String status; // 'pending', 'preparing', 'out_for_delivery', 'delivered'
  final String? driverId;
  final String? driverName;
  final double? driverLat;
  final double? driverLng;
  final DateTime createdAt;

  OrderModel({
    required this.orderId,
    required this.customerId,
    required this.customerName,
    required this.items,
    required this.totalAmount,
    this.receiptUrl,
    required this.paymentMethod,
    this.address,
    this.deliveryLat,
    this.deliveryLng,
    required this.status,
    this.driverId,
    this.driverName,
    this.driverLat,
    this.driverLng,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'orderId': orderId,
      'customerId': customerId,
      'customerName': customerName,
      'items': items,
      'totalAmount': totalAmount,
      'receiptUrl': receiptUrl,
      'address': address,
      'deliveryLat': deliveryLat,
      'deliveryLng': deliveryLng,
      'paymentMethod': paymentMethod,
      'status': status,
      'driverId': driverId,
      'driverName': driverName,
      'driverLat': driverLat,
      'driverLng': driverLng,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory OrderModel.fromMap(Map<String, dynamic> map) {
    return OrderModel(
      orderId: map['orderId'] ?? '',
      customerId: map['customerId'] ?? '',
      customerName: map['customerName'] ?? '',
      items: List<Map<String, dynamic>>.from(map['items'] ?? []),
      totalAmount: (map['totalAmount'] ?? 0.0).toDouble(),
      receiptUrl: map['receiptUrl'],
      address: map['address'],
      deliveryLat: (map['deliveryLat'] as num?)?.toDouble(),
      deliveryLng: (map['deliveryLng'] as num?)?.toDouble(),
      paymentMethod: map['paymentMethod'] ?? 'Cash',
      status: map['status'] ?? 'pending',
      driverId: map['driverId'],
      driverName: map['driverName'],
      driverLat: map['driverLat']?.toDouble(),
      driverLng: map['driverLng']?.toDouble(),
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }
}
