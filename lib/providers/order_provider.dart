import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/order_model.dart';
import '../services/order_service.dart';
import 'package:uuid/uuid.dart';

class OrderProvider with ChangeNotifier {
  final OrderService _orderService = OrderService();
  bool _isProcessing = false;
  List<OrderModel> _orders = [];

  bool get isProcessing => _isProcessing;
  List<OrderModel> get orders => _orders;

  OrderProvider() {
    _initOrdersSubscription();
  }

  void _initOrdersSubscription() {
    _orderService.getAllOrders().listen((newOrders) {
      _orders = newOrders;
      notifyListeners();
    });
  }

  Future<void> updateOrderStatus(String orderId, String status) async {
    await _orderService.updateOrderStatus(orderId, status);
  }

  Future<void> updateDriverLocation(String orderId, double lat, double lng) async {
    await _orderService.updateDriverLocation(orderId, lat, lng);
  }

  Future<void> assignDriver(String orderId, String driverId, String driverName) async {
    await _orderService.assignDriver(orderId, driverId, driverName);
  }

  Future<bool> placeOrder({
    required String userId,
    required String userName,
    required List<Map<String, dynamic>> items,
    required double totalAmount,
    required String paymentMethod,
    String? address,
    double? lat,
    double? lng,
    int? pointsUsed,
    String? receiptUrl,
  }) async {
    _isProcessing = true;
    notifyListeners();

    try {
      final orderId = const Uuid().v4();
      final finalAmount = pointsUsed != null ? totalAmount - (pointsUsed / 10) : totalAmount;

      final newOrder = OrderModel(
        orderId: orderId,
        customerId: userId,
        customerName: userName,
        items: items,
        totalAmount: finalAmount > 0 ? finalAmount : 0,
        paymentMethod: paymentMethod,
        address: address,
        deliveryLat: lat,
        deliveryLng: lng,
        status: 'pending',
        createdAt: DateTime.now(),
        receiptUrl: receiptUrl,
      );

      await _orderService.createOrder(newOrder);

      // تحديث نقاط الولاء
      if (userId != 'walk-in') {
        int earnedPoints = (finalAmount / 10).floor();
        final userRef = FirebaseFirestore.instance.collection('users').doc(userId);
        
        if (pointsUsed != null && pointsUsed > 0) {
          await userRef.update({'points': FieldValue.increment(earnedPoints - pointsUsed)});
        } else {
          await userRef.update({'points': FieldValue.increment(earnedPoints)});
        }
      }

      _isProcessing = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isProcessing = false;
      notifyListeners();
      return false;
    }
  }

  Stream<List<OrderModel>> watchUserOrders(String userId) {
    return _orderService.getCustomerOrders(userId);
  }

  Stream<List<OrderModel>> watchAllOrders() {
    return _orderService.getAllOrders();
  }
}
