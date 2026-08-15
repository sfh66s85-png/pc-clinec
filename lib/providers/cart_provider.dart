import 'package:flutter/material.dart';
import '../models/medicine_model.dart';

class CartItem {
  final MedicineModel medicine;
  int quantity;

  CartItem({required this.medicine, this.quantity = 1});

  double get totalPrice => medicine.price * quantity;
}

class CartProvider with ChangeNotifier {
  final Map<String, CartItem> _items = {};

  Map<String, CartItem> get items => {..._items};

  int get itemCount => _items.length;

  double get totalAmount {
    var total = 0.0;
    _items.forEach((key, cartItem) {
      total += cartItem.totalPrice;
    });
    return total;
  }

  void addItem(MedicineModel medicine) {
    if (_items.containsKey(medicine.id)) {
      _items.update(
        medicine.id,
        (existingItem) => CartItem(
          medicine: existingItem.medicine,
          quantity: existingItem.quantity + 1,
        ),
      );
    } else {
      _items.putIfAbsent(
        medicine.id,
        () => CartItem(medicine: medicine),
      );
    }
    notifyListeners();
  }

  void removeItem(String medicineId) {
    _items.remove(medicineId);
    notifyListeners();
  }

  void removeSingleItem(String medicineId) {
    if (!_items.containsKey(medicineId)) return;

    if (_items[medicineId]!.quantity > 1) {
      _items.update(
        medicineId,
        (existingItem) => CartItem(
          medicine: existingItem.medicine,
          quantity: existingItem.quantity - 1,
        ),
      );
    } else {
      _items.remove(medicineId);
    }
    notifyListeners();
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }
}
