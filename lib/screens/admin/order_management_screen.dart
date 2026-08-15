import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../providers/order_provider.dart';
import '../../models/order_model.dart';
import '../../core/widgets/glass_container.dart';
import '../../services/order_service.dart';

class OrderManagementScreen extends StatelessWidget {
  const OrderManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final orderService = OrderService();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'إدارة الطلبات',
          style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),
        Expanded(
          child: StreamBuilder<List<OrderModel>>(
            stream: orderService.getAllOrders(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text('لا يوجد طلبات حالياً', style: TextStyle(color: Colors.white70)));
              }

              final orders = snapshot.data!;
              return ListView.builder(
                itemCount: orders.length,
                itemBuilder: (context, index) {
                  final order = orders[index];
                  return _AdminOrderCard(order: order, orderService: orderService);
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

class _AdminOrderCard extends StatelessWidget {
  final OrderModel order;
  final OrderService orderService;

  const _AdminOrderCard({required this.order, required this.orderService});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white.withOpacity(0.05),
      margin: const EdgeInsets.only(bottom: 15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ExpansionTile(
        title: Text(
          'طلب #${order.orderId.substring(0, 8)} - ${order.customerName}',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          'إجمالي: ${order.totalAmount} ج.م | الحالة: ${_getStatusText(order.status)}',
          style: TextStyle(color: _getStatusColor(order.status)),
        ),
        iconColor: Colors.white,
        collapsedIconColor: Colors.white70,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('الأصناف:', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ...order.items.map((item) => Text(
                      '- ${item['name']} (x${item['quantity']})',
                      style: const TextStyle(color: Colors.white70),
                    )),
                const SizedBox(height: 10),
                Text('طريقة الدفع: ${order.paymentMethod}', style: const TextStyle(color: Colors.white70)),
                Text('التاريخ: ${DateFormat('yyyy-MM-dd – kk:mm').format(order.createdAt)}',
                    style: const TextStyle(color: Colors.white70)),
                const SizedBox(height: 15),
                const Text('تحديث الحالة:', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  children: [
                    _statusButton(context, 'pending', 'قيد الانتظار'),
                    _statusButton(context, 'preparing', 'جاري التجهيز'),
                    _statusButton(context, 'out_for_delivery', 'خرج للتوصيل'),
                    _statusButton(context, 'delivered', 'تم التوصيل'),
                  ],
                ),
                const SizedBox(height: 15),
                if (order.driverId != null)
                  Text('السائق المسند: ${order.driverName}',
                      style: const TextStyle(color: Colors.tealAccent, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                ElevatedButton.icon(
                  onPressed: () => _showDriverAssignmentDialog(context),
                  icon: const Icon(Icons.delivery_dining),
                  label: const Text('إسناد لسائق'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showDriverAssignmentDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .where('role', isEqualTo: 'driver')
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
            final drivers = snapshot.data!.docs;

            return AlertDialog(
              title: const Text('اختر سائقاً'),
              content: SizedBox(
                width: double.maxFinite,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: drivers.length,
                  itemBuilder: (context, index) {
                    final driver = drivers[index].data() as Map<String, dynamic>;
                    return ListTile(
                      title: Text(driver['name']),
                      subtitle: Text(driver['phone'] ?? ''),
                      onTap: () {
                        orderService.assignDriver(
                          order.orderId,
                          drivers[index].id,
                          driver['name'],
                        );
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _statusButton(BuildContext context, String status, String label) {
    final isSelected = order.status == status;
    return ElevatedButton(
      onPressed: () => orderService.updateOrderStatus(order.orderId, status),
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? _getStatusColor(status) : Colors.white12,
        foregroundColor: isSelected ? Colors.white : Colors.white70,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        minimumSize: Size.zero,
      ),
      child: Text(label, style: const TextStyle(fontSize: 12)),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending': return Colors.orange;
      case 'preparing': return Colors.blue;
      case 'out_for_delivery': return Colors.purple;
      case 'delivered': return Colors.green;
      default: return Colors.grey;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'pending': return 'قيد الانتظار';
      case 'preparing': return 'جاري التجهيز';
      case 'out_for_delivery': return 'خرج للتوصيل';
      case 'delivered': return 'تم التوصيل';
      default: return status;
    }
  }
}
