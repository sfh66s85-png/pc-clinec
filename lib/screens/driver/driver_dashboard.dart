import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import '../../providers/auth_provider.dart';
import '../../providers/order_provider.dart';
import '../../models/order_model.dart';
import 'dart:async';

class DriverDashboard extends StatefulWidget {
  const DriverDashboard({super.key});

  @override
  State<DriverDashboard> createState() => _DriverDashboardState();
}

class _DriverDashboardState extends State<DriverDashboard> {
  StreamSubscription<Position>? _positionStream;

  @override
  void initState() {
    super.initState();
    _startLocationUpdates();
  }

  @override
  void dispose() {
    _positionStream?.cancel();
    super.dispose();
  }

  Future<void> _startLocationUpdates() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }

    if (permission == LocationPermission.deniedForever) return;

    _positionStream = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      ),
    ).listen((Position position) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final orderProvider = Provider.of<OrderProvider>(context, listen: false);
      
      if (authProvider.user != null) {
        // Find orders assigned to this driver that are out for delivery
        final activeOrders = orderProvider.orders
            .where((o) => o.driverId == authProvider.user!.uid && o.status == 'out_for_delivery')
            .toList();
            
        for (var order in activeOrders) {
          orderProvider.updateDriverLocation(order.orderId, position.latitude, position.longitude);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final orderProvider = Provider.of<OrderProvider>(context);
    
    final driverOrders = orderProvider.orders
        .where((o) => o.driverId == authProvider.user?.uid)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('لوحة تحكم السائق'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => authProvider.signOut(),
          ),
        ],
      ),
      body: driverOrders.isEmpty
          ? const Center(child: Text('لا توجد طلبات مسندة إليك حالياً'))
          : ListView.builder(
              itemCount: driverOrders.length,
              itemBuilder: (context, index) {
                final order = driverOrders[index];
                return Card(
                  margin: const EdgeInsets.all(10),
                  child: ListTile(
                    title: Text('طلب #${order.orderId.substring(0, 8)}'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('العميل: ${order.customerName}'),
                        Text('الحالة: ${_getStatusArabic(order.status)}'),
                        Text('العنوان: ${order.address ?? "غير محدد"}'),
                      ],
                    ),
                    trailing: _buildActionButton(order, orderProvider),
                  ),
                );
              },
            ),
    );
  }

  Widget? _buildActionButton(OrderModel order, OrderProvider provider) {
    if (order.status == 'preparing') {
      return ElevatedButton(
        onPressed: () => provider.updateOrderStatus(order.orderId, 'out_for_delivery'),
        child: const Text('بدء التوصيل'),
      );
    } else if (order.status == 'out_for_delivery') {
      return ElevatedButton(
        style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
        onPressed: () => provider.updateOrderStatus(order.orderId, 'delivered'),
        child: const Text('تم التوصيل'),
      );
    }
    return null;
  }

  String _getStatusArabic(String status) {
    switch (status) {
      case 'pending': return 'قيد الانتظار';
      case 'preparing': return 'جاري التجهيز';
      case 'out_for_delivery': return 'خرج للتوصيل';
      case 'delivered': return 'تم التسليم';
      default: return status;
    }
  }
}
