import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../providers/medicine_provider.dart';
import '../../models/medicine_model.dart';
import '../../core/widgets/glass_container.dart';

class MedicineManagementScreen extends StatefulWidget {
  const MedicineManagementScreen({super.key});

  @override
  State<MedicineManagementScreen> createState() => _MedicineManagementScreenState();
}

class _MedicineManagementScreenState extends State<MedicineManagementScreen> {
  void _showMedicineDialog(BuildContext context, [MedicineModel? medicine]) {
    final nameController = TextEditingController(text: medicine?.name);
    final descController = TextEditingController(text: medicine?.description);
    final priceController = TextEditingController(text: medicine?.price.toString());
    final catController = TextEditingController(text: medicine?.category);
    final stockController = TextEditingController(text: medicine?.stock.toString());
    final imageController = TextEditingController(text: medicine?.imageUrl);
    DateTime? selectedExpiryDate = medicine?.expiryDate;
    dynamic selectedImage;
    bool isUploading = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: const Color(0xFF203A43),
          title: Text(
            medicine == null ? 'إضافة دواء جديد' : 'تعديل دواء',
            style: const TextStyle(color: Colors.white),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  onTap: () async {
                    final picker = ImagePicker();
                    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
                    if (pickedFile != null) {
                      setDialogState(() {
                        if (kIsWeb) {
                          pickedFile.readAsBytes().then((value) {
                            setDialogState(() {
                              selectedImage = value;
                            });
                          });
                        } else {
                          selectedImage = File(pickedFile.path);
                        }
                      });
                    }
                  },
                  child: Container(
                    height: 150,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white10,
                      borderRadius: BorderRadius.circular(10),
                      image: selectedImage != null
                          ? DecorationImage(
                              image: kIsWeb
                                  ? MemoryImage(selectedImage as Uint8List)
                                  : FileImage(selectedImage as File) as ImageProvider,
                              fit: BoxFit.cover,
                            )
                          : (medicine?.imageUrl != null && medicine!.imageUrl.isNotEmpty)
                              ? DecorationImage(image: NetworkImage(medicine.imageUrl), fit: BoxFit.cover)
                              : null,
                    ),
                    child: selectedImage == null && (medicine?.imageUrl == null || medicine!.imageUrl.isEmpty)
                        ? const Icon(Icons.add_a_photo, color: Colors.white70, size: 50)
                        : null,
                  ),
                ),
                const SizedBox(height: 10),
                _buildDialogField(nameController, 'اسم الدواء'),
                _buildDialogField(descController, 'الوصف'),
                _buildDialogField(priceController, 'السعر', keyboardType: TextInputType.number),
                _buildDialogField(catController, 'التصنيف'),
                _buildDialogField(stockController, 'الكمية في المخزن', keyboardType: TextInputType.number),
                // _buildDialogField(imageController, 'رابط الصورة'), // Removed in favor of upload
                ListTile(
                  title: const Text('تاريخ انتهاء الصلاحية', style: TextStyle(color: Colors.white70)),
                  subtitle: Text(
                    selectedExpiryDate == null ? 'لم يتم التحديد' : DateFormat('yyyy-MM-dd').format(selectedExpiryDate!),
                    style: const TextStyle(color: Colors.white),
                  ),
                  trailing: const Icon(Icons.calendar_today, color: Colors.tealAccent),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: selectedExpiryDate ?? DateTime.now().add(const Duration(days: 365)),
                      firstDate: DateTime.now().subtract(const Duration(days: 365)),
                      lastDate: DateTime.now().add(const Duration(days: 3650)),
                    );
                    if (picked != null) {
                      setDialogState(() {
                        selectedExpiryDate = picked;
                      });
                    }
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('إلغاء', style: TextStyle(color: Colors.white70)),
            ),
            ElevatedButton(
              onPressed: isUploading
                  ? null
                  : () async {
                      setDialogState(() => isUploading = true);
                      
                      String imageUrl = medicine?.imageUrl ?? '';
                      if (selectedImage != null) {
                        imageUrl = await Provider.of<MedicineProvider>(context, listen: false).uploadImage(selectedImage);
                      }

                      final newMedicine = MedicineModel(
                        id: medicine?.id ?? '',
                        name: nameController.text,
                        description: descController.text,
                        price: double.tryParse(priceController.text) ?? 0.0,
                        category: catController.text,
                        stock: int.tryParse(stockController.text) ?? 0,
                        imageUrl: imageUrl,
                        isActive: medicine?.isActive ?? true,
                        expiryDate: selectedExpiryDate,
                      );

                      if (medicine == null) {
                        await Provider.of<MedicineProvider>(context, listen: false).addMedicine(newMedicine);
                      } else {
                        await Provider.of<MedicineProvider>(context, listen: false).updateMedicine(newMedicine);
                      }
                      
                      if (Navigator.of(ctx).canPop()) {
                        Navigator.of(ctx).pop();
                      }
                    },
              child: isUploading
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text('حفظ'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDialogField(TextEditingController controller, String label, {TextInputType keyboardType = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white70),
          enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'قائمة الأدوية',
              style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
            ),
            ElevatedButton.icon(
              onPressed: () => _showMedicineDialog(context),
              icon: const Icon(Icons.add),
              label: const Text('إضافة دواء'),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Expanded(
          child: Consumer<MedicineProvider>(
            builder: (context, provider, child) {
              if (provider.isLoading) return const Center(child: CircularProgressIndicator());
              
              return ListView.builder(
                itemCount: provider.medicines.length,
                itemBuilder: (ctx, i) {
                  final med = provider.medicines[i];
                  return Card(
                    color: Colors.white.withOpacity(0.05),
                    margin: const EdgeInsets.only(bottom: 10),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundImage: NetworkImage(med.imageUrl.isNotEmpty ? med.imageUrl : 'https://via.placeholder.com/150'),
                      ),
                      title: Text(med.name, style: const TextStyle(color: Colors.white)),
                      subtitle: Text('${med.price} ج.م | المخزن: ${med.stock}', style: const TextStyle(color: Colors.white70)),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.tealAccent),
                            onPressed: () => _showMedicineDialog(context, med),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.redAccent),
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  backgroundColor: const Color(0xFF203A43),
                                  title: const Text('حذف الدواء', style: TextStyle(color: Colors.white)),
                                  content: const Text('هل أنت متأكد من حذف هذا الدواء؟', style: TextStyle(color: Colors.white70)),
                                  actions: [
                                    TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
                                    TextButton(
                                      onPressed: () {
                                        provider.deleteMedicine(med.id);
                                        Navigator.pop(ctx);
                                      },
                                      child: const Text('حذف', style: TextStyle(color: Colors.redAccent)),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
