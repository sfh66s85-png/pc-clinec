import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'checkout_screen.dart';
import '../providers/cart_provider.dart';
import '../core/widgets/glass_container.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('سلة المشتريات'),
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
          child: Consumer<CartProvider>(
            builder: (context, cart, child) {
              if (cart.items.isEmpty) {
                return const Center(
                  child: Text(
                    'السلة فارغة',
                    style: TextStyle(color: Colors.white70, fontSize: 18),
                  ),
                );
              }
              return Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: cart.items.length,
                      itemBuilder: (context, index) {
                        final item = cart.items.values.toList()[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: GlassContainer(
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              children: [
                                Container(
                                  width: 70,
                                  height: 70,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    image: DecorationImage(
                                      image: NetworkImage(item.medicine.imageUrl.isNotEmpty
                                          ? item.medicine.imageUrl
                                          : 'https://via.placeholder.com/150'),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.medicine.name,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      Text(
                                        '${item.medicine.price} ج.م',
                                        style: const TextStyle(color: Colors.tealAccent),
                                      ),
                                    ],
                                  ),
                                ),
                                Row(
                                  children: [
                                    IconButton(
                                      onPressed: () => cart.removeSingleItem(item.medicine.id),
                                      icon: const Icon(Icons.remove_circle_outline, color: Colors.white70),
                                    ),
                                    Text(
                                      '${item.quantity}',
                                      style: const TextStyle(color: Colors.white, fontSize: 16),
                                    ),
                                    IconButton(
                                      onPressed: () => cart.addItem(item.medicine),
                                      icon: const Icon(Icons.add_circle_outline, color: Colors.tealAccent),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  _CheckoutSection(cart: cart),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _CheckoutSection extends StatelessWidget {
  final CartProvider cart;
  const _CheckoutSection({required this.cart});

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      borderRadius: 0,
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'الإجمالي:',
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text(
                '${cart.totalAmount} ج.م',
                style: const TextStyle(color: Colors.tealAccent, fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CheckoutScreen()),
                );
              },
              child: const Text('إتمام الطلب'),
            ),
          ),
        ],
      ),
    );
  }
}
