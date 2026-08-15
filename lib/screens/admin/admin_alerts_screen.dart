import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/medicine_provider.dart';
import '../../models/medicine_model.dart';
import '../../core/widgets/glass_container.dart';

class AdminAlertsScreen extends StatelessWidget {
  const AdminAlertsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MedicineProvider>();
    final lowStock = provider.lowStockMedicines;
    final expiring = provider.expiringMedicines;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('تنبيهات المخزون', style: TextStyle(fontFamily: 'Cairo')),
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
            padding: const EdgeInsets.all(16),
            children: [
              _buildSectionHeader('أدوية أوشكت على النفاذ', Icons.warning_amber_rounded, Colors.orangeAccent),
              if (lowStock.isEmpty)
                const _EmptyState(message: 'لا توجد أدوية منخفضة المخزون')
              else
                ...lowStock.map((m) => _AlertTile(
                      medicine: m,
                      subtitle: 'الكمية المتبقية: ${m.stock}',
                      color: Colors.orangeAccent,
                    )),
              const SizedBox(height: 24),
              _buildSectionHeader('أدوية تقترب من انتهاء الصلاحية', Icons.timer_outlined, Colors.redAccent),
              if (expiring.isEmpty)
                const _EmptyState(message: 'لا توجد أدوية منتهية الصلاحية قريباً')
              else
                ...expiring.map((m) => _AlertTile(
                      medicine: m,
                      subtitle: 'تاريخ الانتهاء: ${m.expiryDate != null ? DateFormat('yyyy-MM-dd').format(m.expiryDate!) : "غير محدد"}',
                      color: Colors.redAccent,
                    )),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 10),
          Text(
            title,
            style: TextStyle(
              color: color,
              fontSize: 18,
              fontWeight: FontWeight.bold,
              fontFamily: 'Cairo',
            ),
          ),
        ],
      ),
    );
  }
}

class _AlertTile extends StatelessWidget {
  final MedicineModel medicine;
  final String subtitle;
  final Color color;

  const _AlertTile({
    required this.medicine,
    required this.subtitle,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: GlassContainer(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                medicine.imageUrl,
                width: 60,
                height: 60,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  width: 60,
                  height: 60,
                  color: Colors.white10,
                  child: const Icon(Icons.medication, color: Colors.white30),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    medicine.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(color: color.withOpacity(0.8), fontSize: 13),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () {
                // Future: Navigate to edit medicine
              },
              icon: const Icon(Icons.edit, color: Colors.white54, size: 20),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String message;
  const _EmptyState({required this.message});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Center(
        child: Text(
          message,
          style: const TextStyle(color: Colors.white38, fontSize: 14),
        ),
      ),
    );
  }
}
