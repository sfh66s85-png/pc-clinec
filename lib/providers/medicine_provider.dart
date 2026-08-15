import 'package:flutter/material.dart';
import '../models/medicine_model.dart';
import '../services/medicine_service.dart';

class MedicineProvider with ChangeNotifier {
  final MedicineService _medicineService = MedicineService();
  List<MedicineModel> _medicines = [];
  String _selectedCategory = 'الكل';
  bool _isLoading = false;

  List<MedicineModel> get medicines => _medicines;
  String get selectedCategory => _selectedCategory;
  bool get isLoading => _isLoading;

  MedicineProvider() {
    _fetchMedicines();
  }

  void _fetchMedicines() {
    _isLoading = true;
    notifyListeners();

    _medicineService.getAllMedicines().listen((medicineList) {
      _medicines = medicineList;
      _isLoading = false;
      notifyListeners();
    });
  }

  Future<String> uploadImage(dynamic imageFile) async {
    return await _medicineService.uploadMedicineImage(imageFile);
  }

  Future<void> addMedicine(MedicineModel medicine) async {
    await _medicineService.addMedicine(medicine);
  }

  Future<void> updateMedicine(MedicineModel medicine) async {
    await _medicineService.updateMedicine(medicine);
  }

  Future<void> deleteMedicine(String id) async {
    await _medicineService.deleteMedicine(id);
  }

  void setCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  List<MedicineModel> get filteredMedicines {
    if (_selectedCategory == 'الكل') {
      return _medicines;
    }
    return _medicines.where((m) => m.category == _selectedCategory).toList();
  }

  List<String> get categories {
    final cats = _medicines.map((m) => m.category).toSet().toList();
    cats.insert(0, 'الكل');
    return cats;
  }

  List<MedicineModel> get lowStockMedicines {
    return _medicines.where((m) => m.stock <= m.lowStockThreshold).toList();
  }

  List<MedicineModel> get expiringMedicines {
    final now = DateTime.now();
    final nextMonth = now.add(const Duration(days: 60)); // تنبيه قبل شهرين
    return _medicines.where((m) {
      if (m.expiryDate == null) return false;
      return m.expiryDate!.isBefore(nextMonth);
    }).toList();
  }
}
