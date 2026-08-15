import 'package:cloud_firestore/cloud_firestore.dart';

class MedicineModel {
  final String id;
  final String name;
  final String description;
  final double price;
  final String category;
  final int stock;
  final int lowStockThreshold;
  final DateTime? expiryDate;
  final String imageUrl;
  final bool isActive;

  MedicineModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.category,
    required this.stock,
    this.lowStockThreshold = 5,
    this.expiryDate,
    required this.imageUrl,
    this.isActive = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'category': category,
      'stock': stock,
      'lowStockThreshold': lowStockThreshold,
      'expiryDate': expiryDate != null ? Timestamp.fromDate(expiryDate!) : null,
      'imageUrl': imageUrl,
      'isActive': isActive,
    };
  }

  MedicineModel copyWith({
    String? id,
    String? name,
    String? description,
    double? price,
    String? category,
    int? stock,
    int? lowStockThreshold,
    DateTime? expiryDate,
    String? imageUrl,
    bool? isActive,
  }) {
    return MedicineModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      category: category ?? this.category,
      stock: stock ?? this.stock,
      lowStockThreshold: lowStockThreshold ?? this.lowStockThreshold,
      expiryDate: expiryDate ?? this.expiryDate,
      imageUrl: imageUrl ?? this.imageUrl,
      isActive: isActive ?? this.isActive,
    );
  }

  factory MedicineModel.fromMap(Map<String, dynamic> map) {
    return MedicineModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      price: (map['price'] ?? 0.0).toDouble(),
      category: map['category'] ?? '',
      stock: map['stock'] ?? 0,
      lowStockThreshold: map['lowStockThreshold'] ?? 5,
      expiryDate: map['expiryDate'] != null ? (map['expiryDate'] as Timestamp).toDate() : null,
      imageUrl: map['imageUrl'] ?? '',
      isActive: map['isActive'] ?? true,
    );
  }
}
