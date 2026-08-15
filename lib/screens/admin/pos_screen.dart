import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/medicine_provider.dart';
import '../../providers/order_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/medicine_model.dart';
import '../../models/order_model.dart';
import '../../core/widgets/glass_container.dart';
import '../../services/printing_service.dart';

class POSScreen extends StatefulWidget {
  const POSScreen({super.key});

  @override
  State<POSScreen> createState() => _POSScreenState();
}

class _POSScreenState extends State<POSScreen> {
  final Map<String, int> _cart = {};
  String _searchQuery = '';
  final TextEditingController _customerNameController = TextEditingController(text: 'عميل نقدي');
  final PrintingService _printingService = PrintingService();

  double _calculateTotal(List<MedicineModel> medicines) {
    double total = 0;
    _cart.forEach((id, qty) {
      final med = medicines.firstWhere((m) => m.id == id);
      total += med.price * qty;
    });
    return total;
  }

  void _completeSale(BuildContext context) async {
    if (_cart.isEmpty) return;

    final medProvider = context.read<MedicineProvider>();
    final orderProvider = context.read<OrderProvider>();
    final authProvider = context.read<AuthProvider>();

    final List<Map<String, dynamic>> items = [];
    _cart.forEach((id, qty) {
      final med = medProvider.medicines.firstWhere((m) => m.id == id);
      items.add({
        'id': id,
        'name': med.name,
        'price': med.price,
        'quantity': qty,
      });
    });

    final success = await orderProvider.placeOrder(
      userId: 'walk-in',
      userName: _customerNameController.text,
      items: items,
      totalAmount: _calculateTotal(medProvider.medicines),
      paymentMethod: 'Cash',
    );

    if (success && mounted) {
      // Create a valid order model for printing based on our OrderModel definition
      final orderForPrinting = OrderModel(
        orderId: DateTime.now().millisecondsSinceEpoch.toString(),
        customerId: 'walk-in',
        customerName: _customerNameController.text,
        items: items,
        totalAmount: _calculateTotal(medProvider.medicines),
        status: 'delivered',
        createdAt: DateTime.now(),
        paymentMethod: 'Cash',
      );

      // Print Receipt
      try {
        await _printingService.printReceipt(orderForPrinting);
      } catch (e) {
        print('Printing error: $e');
      }

      // Update stocks
      for (var item in items) {
        final med = medProvider.medicines.firstWhere((m) => m.id == item['id']);
        medProvider.updateMedicine(med.copyWith(
          stock: med.stock - (item['quantity'] as int),
        ));
      }

      setState(() {
        _cart.clear();
        _customerNameController.text = 'عميل نقدي';
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم إتمام البيع بنجاح'), backgroundColor: Colors.green),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MedicineProvider>(
      builder: (context, medProvider, child) {
        final filteredList = medProvider.medicines
            .where((m) => m.name.toLowerCase().contains(_searchQuery.toLowerCase()))
            .toList();

        return Row(
          children: [
            // Medicine Selection Area
            Expanded(
              flex: 2,
              child: Column(
                children: [
                  TextField(
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'بحث عن دواء...',
                      hintStyle: const TextStyle(color: Colors.white54),
                      prefixIcon: const Icon(Icons.search, color: Colors.tealAccent),
                      filled: true,
                      fillColor: Colors.white.withValues(alpha: 0.05),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                    ),
                    onChanged: (val) => setState(() => _searchQuery = val),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: GridView.builder(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        childAspectRatio: 0.8,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                      ),
                      itemCount: filteredList.length,
                      itemBuilder: (context, index) {
                        final med = filteredList[index];
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _cart[med.id] = (_cart[med.id] ?? 0) + 1;
                            });
                          },
                          child: GlassContainer(
                            padding: const EdgeInsets.all(8),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(med.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                                Text('${med.price} ج.م', style: const TextStyle(color: Colors.tealAccent)),
                                Text('المخزن: ${med.stock}', style: const TextStyle(color: Colors.white70, fontSize: 12)),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 20),
            // Cart / Checkout Area
            Expanded(
              flex: 1,
              child: GlassContainer(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('فاتورة جديدة', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 15),
                    TextField(
                      controller: _customerNameController,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        labelText: 'اسم العميل',
                        labelStyle: TextStyle(color: Colors.white70),
                      ),
                    ),
                    const Divider(color: Colors.white24, height: 30),
                    Expanded(
                      child: ListView(
                        children: _cart.entries.map((entry) {
                          final med = medProvider.medicines.firstWhere((m) => m.id == entry.key);
                          return ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text(med.name, style: const TextStyle(color: Colors.white, fontSize: 14)),
                            subtitle: Text('${med.price} x ${entry.value}', style: const TextStyle(color: Colors.white70)),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.remove_circle_outline, color: Colors.white70, size: 20),
                                  onPressed: () {
                                    setState(() {
                                      if (_cart[med.id]! > 1) {
                                        _cart[med.id] = _cart[med.id]! - 1;
                                      } else {
                                        _cart.remove(med.id);
                                      }
                                    });
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                                  onPressed: () => setState(() => _cart.remove(med.id)),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const Divider(color: Colors.white24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('الإجمالي', style: TextStyle(color: Colors.white, fontSize: 18)),
                        Text('${_calculateTotal(medProvider.medicines)} ج.م', 
                          style: const TextStyle(color: Colors.tealAccent, fontSize: 20, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _cart.isEmpty ? null : () => _completeSale(context),
                        child: const Text('إتمام البيع وطباعة'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
