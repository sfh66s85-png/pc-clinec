import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/prescription_model.dart';
import '../services/storage_service.dart';
import 'package:uuid/uuid.dart';

class PrescriptionProvider with ChangeNotifier {
  final StorageService _storageService = StorageService();
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  bool _isLoading = false;

  bool get isLoading => _isLoading;

  Future<bool> uploadPrescription({
    required String userId,
    required String userName,
    required String userPhone,
    required File imageFile,
    required String note,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final imageUrl = await _storageService.uploadPrescription(imageFile);
      final id = const Uuid().v4();
      
      final prescription = PrescriptionModel(
        id: id,
        userId: userId,
        userName: userName,
        userPhone: userPhone,
        imageUrl: imageUrl,
        note: note,
        status: 'pending',
        createdAt: DateTime.now(),
      );

      await _db.collection('prescriptions').doc(id).set(prescription.toMap());
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Stream<List<PrescriptionModel>> getUserPrescriptions(String userId) {
    return _db
        .collection('prescriptions')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => PrescriptionModel.fromMap(doc.data()))
            .toList());
  }

  Stream<List<PrescriptionModel>> getAllPrescriptions() {
    return _db
        .collection('prescriptions')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => PrescriptionModel.fromMap(doc.data()))
            .toList());
  }

  Future<void> updatePrescriptionStatus(String id, String newStatus) async {
    try {
      await _db.collection('prescriptions').doc(id).update({'status': newStatus});
    } catch (e) {
      rethrow;
    }
  }
}
