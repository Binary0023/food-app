import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart'; // Add lottie package for animations

class BuyNowScreen extends StatefulWidget {
  final String name;
  final String price;
  final String imagePath;
  final VoidCallback toggleTheme;
  final bool isDarkMode;

  const BuyNowScreen({
    super.key,
    required this.name,
    required this.price,
    required this.imagePath,
    required this.toggleTheme,
    required this.isDarkMode,
  });

  @override
  State<BuyNowScreen> createState() => _BuyNowScreenState();
}

class _BuyNowScreenState extends State<BuyNowScreen> {
  String? _selectedPaymentMethod = 'Cash on Delivery'; // Default payment method
  bool _showSuccessAnimation = false;

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
          'Buy Now',
          style: TextStyle(color: theme.textTheme.bodyLarge?.color),
        ),
      ),
      body:
          _showSuccessAnimation
              ? _buildSuccessAnimation()
              : _buildCheckoutContent(theme),
    );
  }

  Widget _buildCheckoutContent(ThemeData theme) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image with Card
            Center(
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: widget.isDarkMode ? Colors.grey[850] : Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    widget.imagePath,
                    height: 120,
                    width: 120,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Item Details
            Text(
              widget.name,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: theme.textTheme.bodyLarge?.color,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              widget.price,
              style: TextStyle(
                fontSize: 20,
                color: theme.textTheme.bodyMedium?.color,
              ),
            ),
            const SizedBox(height: 20),
            // Payment Method Selection
            Text(
              'Payment Method',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: theme.textTheme.bodyLarge?.color,
              ),
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: _selectedPaymentMethod,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF777777)),
                ),
                filled: true,
                fillColor:
                    widget.isDarkMode ? Colors.grey[900] : Colors.grey[100],
              ),
              items:
                  ['Cash on Delivery', 'Credit Card', 'PayPal']
                      .map(
                        (method) => DropdownMenuItem(
                          value: method,
                          child: Text(
                            method,
                            style: TextStyle(
                              color: theme.textTheme.bodyLarge?.color,
                            ),
                          ),
                        ),
                      )
                      .toList(),
              onChanged: (value) {
                setState(() {
                  _selectedPaymentMethod = value;
                });
              },
            ),
            const SizedBox(height: 20),
            // Add More Button
            TextButton.icon(
              onPressed: () {
                Navigator.pop(context); // Go back to add more items
              },
              icon: const Icon(
                Icons.add_circle_outline,
                color: Color(0xFF00B6B6),
              ),
              label: const Text(
                'Add More Items',
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF00B6B6),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Confirm Purchase Button
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _showSuccessAnimation = true;
                });
                Future.delayed(const Duration(seconds: 2), () {
                  Navigator.pop(context); // Go back after animation
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00B6B6),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Center(
                child: Text(
                  'Confirm Purchase',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuccessAnimation() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Lottie.network(
            'https://assets5.lottiefiles.com/packages/lf20_jbrw3hcy.json', // Success checkmark animation
            width: 200,
            height: 200,
            fit: BoxFit.contain,
          ),
          const SizedBox(height: 20),
          Text(
            'Purchase Successful!',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
        ],
      ),
    );
  }
}
