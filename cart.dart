import 'package:flutter/material.dart';

class CartScreen extends StatefulWidget {
  final VoidCallback toggleTheme;
  final bool isDarkMode;

  const CartScreen({
    super.key,
    required this.toggleTheme,
    required this.isDarkMode,
  });

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final List<Map<String, dynamic>> _cartItems = [];

  void _addToCart(String name, String price, String imagePath) {
    setState(() {
      _cartItems.add({
        'name': name,
        'price': price,
        'imagePath': imagePath,
        'quantity': 1,
      });
    });
  }

  void _removeFromCart(int index) {
    setState(() {
      _cartItems.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.iconTheme.color),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Cart',
          style: TextStyle(color: theme.textTheme.bodyLarge?.color),
        ),
      ),
      body:
          _cartItems.isEmpty
              ? Center(
                child: Text(
                  'Your cart is empty.',
                  style: TextStyle(color: theme.textTheme.bodyLarge?.color),
                ),
              )
              : ListView.builder(
                padding: const EdgeInsets.all(16.0),
                itemCount: _cartItems.length,
                itemBuilder: (context, index) {
                  final item = _cartItems[index];
                  return ListTile(
                    leading: Image.asset(
                      item['imagePath'],
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                    ),
                    title: Text(
                      item['name'],
                      style: TextStyle(color: theme.textTheme.bodyLarge?.color),
                    ),
                    subtitle: Text(
                      item['price'],
                      style: TextStyle(
                        color: theme.textTheme.bodyMedium?.color,
                      ),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.remove_circle, color: Colors.red),
                      onPressed: () => _removeFromCart(index),
                    ),
                  );
                },
              ),
      floatingActionButton:
          _cartItems.isNotEmpty
              ? FloatingActionButton.extended(
                onPressed: () {
                  // Proceed to checkout or BuyNowScreen
                },
                label: const Text('Checkout'),
                icon: const Icon(Icons.payment),
                backgroundColor: const Color(0xFF00B6B6),
              )
              : null,
    );
  }
}
