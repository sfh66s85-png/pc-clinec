import 'package:cloud_firestore/cloud_firestore.dart';

class PrescriptionModel {
  final String id;
  final String userId;
  final String userName;
  final String userPhone;
  final String imageUrl;
  final String note;
  final String status; // 'pending', 'reviewed', 'completed'
  final DateTime createdAt;

  PrescriptionModel({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userPhone,
    required this.imageUrl,
    required this.note,
    required this.status,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'userPhone': userPhone,
      'imageUrl': imageUrl,
      'note': note,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory PrescriptionModel.fromMap(Map<String, dynamic> map) {
    return PrescriptionModel(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? '',
      userPhone: map['userPhone'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      note: map['note'] ?? '',
      status: map['status'] ?? 'pending',
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }
}
