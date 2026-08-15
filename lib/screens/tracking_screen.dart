import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import '../models/order_model.dart';
import '../core/widgets/glass_container.dart';
import '../providers/order_provider.dart';

class TrackingScreen extends StatefulWidget {
  final String orderId;
  const TrackingScreen({super.key, required this.orderId});

  @override
  State<TrackingScreen> createState() => _TrackingScreenState();
}

class _TrackingScreenState extends State<TrackingScreen> {
  late GoogleMapController _mapController;
  final LatLng _pharmacyLocation = const LatLng(30.0444, 31.2357); 

  @override
  Widget build(BuildContext context) {
    final orderProvider = Provider.of<OrderProvider>(context);
    final order = orderProvider.orders.firstWhere((o) => o.orderId == widget.orderId);

    final customerLocation = LatLng(
      order.deliveryLat ?? 30.0444,
      order.deliveryLng ?? 31.2357,
    );

    final driverLocation = order.driverLat != null && order.driverLng != null
        ? LatLng(order.driverLat!, order.driverLng!)
        : null;

    return Scaffold(
      appBar: AppBar(
        title: Text('تتبع الطلب #${order.orderId.substring(0, 8)}', 
          style: const TextStyle(fontFamily: 'Cairo')),
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: driverLocation ?? customerLocation,
              zoom: 15,
            ),
            onMapCreated: (controller) => _mapController = controller,
            markers: {
              Marker(
                markerId: const MarkerId('pharmacy'),
                position: _pharmacyLocation,
                infoWindow: const InfoWindow(title: 'الصيدلية'),
                icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueCyan),
              ),
              Marker(
                markerId: const MarkerId('customer'),
                position: customerLocation,
                infoWindow: const InfoWindow(title: 'موقع التوصيل'),
              ),
              if (driverLocation != null)
                Marker(
                  markerId: const MarkerId('driver'),
                  position: driverLocation,
                  infoWindow: const InfoWindow(title: 'المندوب'),
                  icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
                ),
            },
          ),
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: GlassContainer(
              padding: const EdgeInsets.all(15),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.delivery_dining, color: Colors.tealAccent, size: 30),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _getStatusMessage(order.status),
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                            if (order.driverName != null)
                              Text(
                                'السائق: ${order.driverName}',
                                style: const TextStyle(color: Colors.white70, fontSize: 13),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getStatusMessage(String status) {
    switch (status) {
      case 'pending': return 'في انتظار التأكيد';
      case 'preparing': return 'جاري تحضير دواءك';
      case 'out_for_delivery': return 'المندوب في الطريق إليك';
      case 'delivered': return 'تم التسليم بنجاح';
      default: return 'جاري معالجة الطلب';
    }
  }
}
