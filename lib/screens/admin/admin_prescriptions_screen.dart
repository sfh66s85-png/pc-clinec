import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/prescription_provider.dart';
import '../../models/prescription_model.dart';
import '../../core/widgets/glass_container.dart';

class AdminPrescriptionsScreen extends StatelessWidget {
  const AdminPrescriptionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PrescriptionProvider>();

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('إدارة الروشتات', style: TextStyle(fontFamily: 'Cairo')),
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
          child: StreamBuilder<List<PrescriptionModel>>(
            stream: provider.getAllPrescriptions(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(
                  child: Text(
                    'لا توجد روشتات حالياً',
                    style: TextStyle(color: Colors.white70),
                  ),
                );
              }

              final prescriptions = snapshot.data!;
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: prescriptions.length,
                itemBuilder: (context, index) {
                  final prescription = prescriptions[index];
                  return _PrescriptionTile(prescription: prescription);
                },
              );
            },
          ),
        ),
      ),
    );
  }
}

class _PrescriptionTile extends StatelessWidget {
  final PrescriptionModel prescription;

  const _PrescriptionTile({required this.prescription});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: GlassContainer(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        prescription.userName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      Text(
                        DateFormat('yyyy-MM-dd – kk:mm').format(prescription.createdAt),
                        style: const TextStyle(color: Colors.white60, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                _buildStatusChip(prescription.status),
              ],
            ),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () => _showImageDialog(context, prescription.imageUrl),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  prescription.imageUrl,
                  height: 150,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 150,
                    color: Colors.white10,
                    child: const Icon(Icons.broken_image, color: Colors.white30),
                  ),
                ),
              ),
            ),
            if (prescription.note.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                'ملاحظة: ${prescription.note}',
                style: const TextStyle(color: Colors.white70),
              ),
            ],
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.phone, color: Colors.white70, size: 16),
                const SizedBox(width: 8),
                Text(
                  prescription.userPhone,
                  style: const TextStyle(color: Colors.white70),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: () => _showStatusPicker(context),
                  icon: const Icon(Icons.edit, color: Colors.tealAccent),
                  label: const Text('تغيير الحالة', style: TextStyle(color: Colors.tealAccent)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    String text;
    switch (status) {
      case 'pending':
        color = Colors.orange;
        text = 'قيد الانتظار';
        break;
      case 'reviewed':
        color = Colors.blue;
        text = 'تمت المراجعة';
        break;
      case 'completed':
        color = Colors.green;
        text = 'تم التجهيز';
        break;
      default:
        color = Colors.grey;
        text = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        text,
        style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold),
      ),
    );
  }

  void _showImageDialog(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Stack(
          children: [
            InteractiveViewer(
              child: Image.network(imageUrl),
            ),
            Positioned(
              right: 0,
              top: 0,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showStatusPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF203A43),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('قيد الانتظار', style: TextStyle(color: Colors.white)),
              onTap: () {
                context.read<PrescriptionProvider>().updatePrescriptionStatus(prescription.id, 'pending');
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('تمت المراجعة', style: TextStyle(color: Colors.white)),
              onTap: () {
                context.read<PrescriptionProvider>().updatePrescriptionStatus(prescription.id, 'reviewed');
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('تم التجهيز', style: TextStyle(color: Colors.white)),
              onTap: () {
                context.read<PrescriptionProvider>().updatePrescriptionStatus(prescription.id, 'completed');
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
