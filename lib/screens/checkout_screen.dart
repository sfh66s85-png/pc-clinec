import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import '../providers/order_provider.dart';
import '../providers/auth_provider.dart';
import '../core/widgets/glass_container.dart';
import 'map_picker_screen.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:ui';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  String _selectedPaymentMethod = 'Cash';
  final _addressController = TextEditingController();
  LatLng? _deliveryLocation;
  bool _usePoints = false;

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final auth = context.watch<AuthProvider>();
    final userPoints = auth.user?.points ?? 0;
    final pointsDiscount = _usePoints ? (userPoints / 10) : 0.0;
    final finalTotal = cart.totalAmount - pointsDiscount;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('إتمام الطلب', style: TextStyle(fontFamily: 'Cairo')),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0F2027), Color(0xFF203A43), Color(0xFF2C5364)],
          ),
        ),
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              _buildSectionTitle('ملخص الطلب'),
              GlassContainer(
                padding: const EdgeInsets.all(15),
                child: Column(
                  children: [
                    ...cart.items.values.map((item) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('${item.medicine.name} x ${item.quantity}', style: const TextStyle(color: Colors.white70)),
                          Text('${(item.medicine.price * item.quantity).toStringAsFixed(2)} ج.م', style: const TextStyle(color: Colors.white)),
                        ],
                      ),
                    )),
                    if (_usePoints && pointsDiscount > 0) ...[
                      const Divider(color: Colors.white24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('خصم النقاط', style: TextStyle(color: Colors.orangeAccent)),
                          Text('-${pointsDiscount.toStringAsFixed(2)} ج.م', style: const TextStyle(color: Colors.orangeAccent)),
                        ],
                      ),
                    ],
                    const Divider(color: Colors.white24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('الإجمالي النهائي', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                        Text('${(finalTotal > 0 ? finalTotal : 0).toStringAsFixed(2)} ج.م', style: const TextStyle(color: Colors.tealAccent, fontWeight: FontWeight.bold, fontSize: 18)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              if (userPoints > 0)
                GlassContainer(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      const Icon(Icons.stars, color: Colors.orangeAccent),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'لديك $userPoints نقطة (${(userPoints / 10).toStringAsFixed(2)} ج.م)',
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      Switch(
                        value: _usePoints,
                        onChanged: (val) => setState(() => _usePoints = val),
                        activeColor: Colors.tealAccent,
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 25),
              _buildSectionTitle('عنوان التوصيل'),
              TextField(
                controller: _addressController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'أدخل العنوان بالتفصيل...',
                  hintStyle: const TextStyle(color: Colors.white38),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.05),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                ),
              ),
              const SizedBox(height: 10),
              ElevatedButton.icon(
                onPressed: () async {
                  final LatLng? result = await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const MapPickerScreen()),
                  );
                  if (result != null) {
                    setState(() {
                      _deliveryLocation = result;
                    });
                  }
                },
                icon: const Icon(Icons.map),
                label: Text(_deliveryLocation == null ? 'تحديد الموقع على الخريطة' : 'تم تحديد الموقع بنجاح'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _deliveryLocation == null ? Colors.teal[800] : Colors.green[800],
                ),
              ),
              const SizedBox(height: 25),
              _buildSectionTitle('طريقة الدفع'),
              _buildPaymentOption('Cash', 'نقداً عند الاستلام', Icons.money),
              _buildPaymentOption('InstaPay', 'InstaPay', Icons.account_balance_wallet),
              _buildPaymentOption('Wallet', 'محفظة إلكترونية', Icons.phone_android),
              const SizedBox(height: 40),
              Consumer<OrderProvider>(
                builder: (context, orderProvider, child) {
                  return ElevatedButton(
                    onPressed: orderProvider.isProcessing || cart.items.isEmpty || _addressController.text.isEmpty
                        ? null
                        : () async {
                            final success = await orderProvider.placeOrder(
                              userId: auth.user?.uid ?? 'unknown',
                              userName: auth.user?.name ?? 'Guest',
                              items: cart.items.values.map((i) => {
                                'id': i.medicine.id,
                                'name': i.medicine.name,
                                'price': i.medicine.price,
                                'quantity': i.quantity,
                              }).toList(),
                              totalAmount: cart.totalAmount,
                              paymentMethod: _selectedPaymentMethod,
                              address: _addressController.text,
                              lat: _deliveryLocation?.latitude,
                              lng: _deliveryLocation?.longitude,
                              pointsUsed: _usePoints ? userPoints : 0,
                            );

                            if (success && mounted) {
                              cart.clearCart();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('تم إرسال طلبك بنجاح!')),
                              );
                              Navigator.popUntil(context, (route) => route.isFirst);
                            }
                          },
                    child: orderProvider.isProcessing
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('تأكيد الطلب الآن'),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, right: 5),
      child: Text(title, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'Cairo')),
    );
  }

  Widget _buildPaymentOption(String value, String label, IconData icon) {
    bool isSelected = _selectedPaymentMethod == value;
    return GestureDetector(
      onTap: () => setState(() => _selectedPaymentMethod = value),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.tealAccent.withOpacity(0.15) : Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: isSelected ? Colors.tealAccent : Colors.white12),
        ),
        child: Row(
          children: [
            Icon(icon, color: isSelected ? Colors.tealAccent : Colors.white70),
            const SizedBox(width: 15),
            Text(label, style: TextStyle(color: isSelected ? Colors.tealAccent : Colors.white70, fontSize: 16)),
            const Spacer(),
            if (isSelected) const Icon(Icons.check_circle, color: Colors.tealAccent),
          ],
        ),
      ),
    );
  }
}
