import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../providers/medicine_provider.dart';
import '../../providers/order_provider.dart';
import '../../models/order_model.dart';
import '../../core/widgets/glass_container.dart';

class AdminStatsScreen extends StatelessWidget {
  const AdminStatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'نظرة عامة على الإحصائيات',
            style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          StreamBuilder<List<OrderModel>>(
            stream: context.read<OrderProvider>().watchAllOrders(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              final orders = snapshot.data ?? [];
              return _StatsGrid(orders: orders);
            },
          ),
          const SizedBox(height: 30),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'أدوية منخفضة المخزن',
                      style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    const _LowStockList(),
                  ],
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'أدوية قريبة من انتهاء الصلاحية',
                      style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    const _ExpiringSoonList(),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ExpiringSoonList extends StatelessWidget {
  const _ExpiringSoonList();

  @override
  Widget build(BuildContext context) {
    return Consumer<MedicineProvider>(
      builder: (context, provider, child) {
        final expiringItems = provider.expiringMedicines;
        
        if (expiringItems.isEmpty) {
          return GlassContainer(
            padding: const EdgeInsets.all(20),
            child: const Center(child: Text('لا توجد أدوية قاربت على الانتهاء', style: TextStyle(color: Colors.white70))),
          );
        }

        return GlassContainer(
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: expiringItems.length,
            separatorBuilder: (context, index) => const Divider(color: Colors.white12, height: 1),
            itemBuilder: (context, index) {
              final med = expiringItems[index];
              final isExpired = med.expiryDate != null && med.expiryDate!.isBefore(DateTime.now());
              return ListTile(
                title: Text(med.name, style: const TextStyle(color: Colors.white)),
                subtitle: Text(
                  'تاريخ الانتهاء: ${med.expiryDate != null ? DateFormat('yyyy-MM-dd').format(med.expiryDate!) : '-'}',
                  style: TextStyle(color: isExpired ? Colors.redAccent : Colors.orangeAccent),
                ),
                trailing: Icon(
                  isExpired ? Icons.dangerous : Icons.warning_rounded,
                  color: isExpired ? Colors.redAccent : Colors.orangeAccent,
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class _StatsGrid extends StatelessWidget {
  final List<OrderModel> orders;
  const _StatsGrid({required this.orders});

  @override
  Widget build(BuildContext context) {
    final totalSales = orders
        .where((o) => o.status == 'delivered')
        .fold(0.0, (sum, o) => sum + o.totalAmount);
    
    final now = DateTime.now();
    final todayOrders = orders.where((o) {
      return o.createdAt.day == now.day &&
          o.createdAt.month == now.month &&
          o.createdAt.year == now.year;
    }).length;

    final pendingOrders = orders.where((o) => o.status == 'pending').length;
    
    return Consumer<MedicineProvider>(
      builder: (context, medProvider, child) {
        return GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: MediaQuery.of(context).size.width > 900 ? 4 : 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.5,
          children: [
            _buildStatCard('إجمالي المبيعات', '${totalSales.toStringAsFixed(0)} ج.م', Icons.monetization_on, Colors.greenAccent),
            _buildStatCard('طلبات اليوم', '$todayOrders', Icons.shopping_cart, Colors.orangeAccent),
            _buildStatCard('الطلبات المعلقة', '$pendingOrders', Icons.pending_actions, Colors.blueAccent),
            _buildStatCard('إجمالي الأدوية', '${medProvider.medicines.length}', Icons.medical_services, Colors.purpleAccent),
          ],
        );
      },
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return GlassContainer(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 30),
          const SizedBox(height: 8),
          Text(title, style: const TextStyle(color: Colors.white70, fontSize: 14)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class _LowStockList extends StatelessWidget {
  const _LowStockList();

  @override
  Widget build(BuildContext context) {
    return Consumer<MedicineProvider>(
      builder: (context, provider, child) {
        final lowStockItems = provider.lowStockMedicines;
        
        if (lowStockItems.isEmpty) {
          return GlassContainer(
            padding: const EdgeInsets.all(20),
            child: const Center(child: Text('كل الأصناف متوفرة بشكل جيد', style: TextStyle(color: Colors.white70))),
          );
        }

        return GlassContainer(
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: lowStockItems.length,
            separatorBuilder: (context, index) => const Divider(color: Colors.white12, height: 1),
            itemBuilder: (context, index) {
              final med = lowStockItems[index];
              return ListTile(
                title: Text(med.name, style: const TextStyle(color: Colors.white)),
                subtitle: Text('الكمية المتبقية: ${med.stock}', style: const TextStyle(color: Colors.redAccent)),
                trailing: const Icon(Icons.warning_amber_rounded, color: Colors.redAccent),
              );
            },
          ),
        );
      },
    );
  }
}
