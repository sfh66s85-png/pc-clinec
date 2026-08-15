import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import '../models/medicine_model.dart';

class MedicineService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Upload image to Firebase Storage
  Future<String> uploadMedicineImage(dynamic imageFile) async {
    try {
      String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      Reference ref = _storage.ref().child('medicines/$fileName');
      
      UploadTask uploadTask;
      if (kIsWeb) {
        uploadTask = ref.putData(imageFile as Uint8List);
      } else {
        uploadTask = ref.putFile(imageFile as File);
      }
      
      TaskSnapshot snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      print('Error uploading image: $e');
      return '';
    }
  }

  // جلب قائمة الأدوية لحظياً
  Stream<List<MedicineModel>> getMedicines() {
    return _db
        .collection('medicines')
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => MedicineModel.fromMap(doc.data()..['id'] = doc.id))
            .toList());
  }

  // جلب الأدوية حسب التصنيف
  Stream<List<MedicineModel>> getMedicinesByCategory(String category) {
    return _db
        .collection('medicines')
        .where('category', isEqualTo: category)
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => MedicineModel.fromMap(doc.data()..['id'] = doc.id))
            .toList());
  }

  // جلب كل الأدوية (للمسؤول)
  Stream<List<MedicineModel>> getAllMedicines() {
    return _db
        .collection('medicines')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => MedicineModel.fromMap(doc.data()..['id'] = doc.id))
            .toList());
  }

  // إضافة دواء جديد (للمسؤول)
  Future<void> addMedicine(MedicineModel medicine) async {
    await _db.collection('medicines').add(medicine.toMap());
  }

  // تحديث دواء (للمسؤول)
  Future<void> updateMedicine(MedicineModel medicine) async {
    await _db.collection('medicines').doc(medicine.id).update(medicine.toMap());
  }

  // حذف دواء أو تعطيله (للمسؤول)
  Future<void> deleteMedicine(String id) async {
    await _db.collection('medicines').doc(id).delete();
  }
}
