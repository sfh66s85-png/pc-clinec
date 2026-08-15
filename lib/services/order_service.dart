import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/order_model.dart';

class OrderService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // إنشاء طلب جديد
  Future<void> createOrder(OrderModel order) async {
    await _db.collection('orders').doc(order.orderId).set(order.toMap());
  }

  // جلب طلبات مستخدم معين
  Stream<List<OrderModel>> getCustomerOrders(String customerId) {
    return _db
        .collection('orders')
        .where('customerId', isEqualTo: customerId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => OrderModel.fromMap(doc.data()))
            .toList());
  }

  // جلب كافة الطلبات (للمسؤول)
  Stream<List<OrderModel>> getAllOrders() {
    return _db
        .collection('orders')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => OrderModel.fromMap(doc.data()))
            .toList());
  }

  // جلب طلبات فترة زمنية محددة للتقارير
  Future<List<OrderModel>> getOrdersInDateRange(DateTime start, DateTime end) async {
    QuerySnapshot snapshot = await _db
        .collection('orders')
        .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where('createdAt', isLessThanOrEqualTo: Timestamp.fromDate(end))
        .get();

    return snapshot.docs
        .map((doc) => OrderModel.fromMap(doc.data() as Map<String, dynamic>))
        .toList();
  }

  // تحديث حالة الطلب (للمسؤول)
  Future<void> updateOrderStatus(String orderId, String status) async {
    await _db.collection('orders').doc(orderId).update({'status': status});
  }

  // إسناد طلب لسائق
  Future<void> assignDriver(String orderId, String driverId, String driverName) async {
    await _db.collection('orders').doc(orderId).update({
      'driverId': driverId,
      'driverName': driverName,
      'status': 'preparing', // أو حالة مخصصة مثل 'assigned'
    });
  }

  // تحديث موقع السائق الحي
  Future<void> updateDriverLocation(String orderId, double lat, double lng) async {
    await _db.collection('orders').doc(orderId).update({
      'driverLat': lat,
      'driverLng': lng,
    });
  }

  // جلب الطلبات المسندة لسائق معين
  Stream<List<OrderModel>> getDriverOrders(String driverId) {
    return _db
        .collection('orders')
        .where('driverId', isEqualTo: driverId)
        .where('status', whereIn: ['preparing', 'out_for_delivery'])
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => OrderModel.fromMap(doc.data()))
            .toList());
  }
}
