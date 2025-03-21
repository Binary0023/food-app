import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: theme.iconTheme.color),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'About Healthy Food',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w900,
            color: theme.textTheme.bodyLarge?.color,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0), // Consistent padding
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // App icon/logo placeholder
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(
                        0xFF00B6B6,
                      ).withOpacity(0.1), // Filled with light teal
                      border: Border.all(
                        color: const Color(0xFF00B6B6),
                        width: 1,
                      ),
                    ),
                    child: const Icon(
                      Icons.local_dining_rounded,
                      size: 50,
                      color: Color(0xFF00B6B6),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // Mission section
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: const Color(
                      0xFF00B6B6,
                    ).withOpacity(0.1), // Filled background
                    border: Border.all(
                      color: const Color(0xFF777777),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Our Mission',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: theme.textTheme.bodyLarge?.color,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Healthy Food App is dedicated to helping you discover nutritious and delicious meals. '
                        'We believe that eating healthy should be enjoyable and accessible for everyone. '
                        'Our app provides a curated collection of recipes, nutritional information, and easy-to-follow guides '
                        'to support your journey towards a healthier lifestyle.',
                        style: TextStyle(
                          fontSize: 16,
                          color: theme.textTheme.bodyMedium?.color,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // App details section
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: const Color(
                      0xFF00B6B6,
                    ).withOpacity(0.1), // Filled background
                    border: Border.all(
                      color: const Color(0xFF777777),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'App Details',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: theme.textTheme.bodyLarge?.color,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildInfoItem(
                        'Version',
                        '1.0.0',
                        Icons.info_rounded,
                        theme.textTheme.bodyMedium?.color,
                      ),
                      const SizedBox(height: 12),
                      _buildInfoItem(
                        'Developed by',
                        'Your Team',
                        Icons.code_rounded,
                        theme.textTheme.bodyMedium?.color,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Contact section
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: const Color(
                      0xFF00B6B6,
                    ).withOpacity(0.1), // Filled background
                    border: Border.all(
                      color: const Color(0xFF777777),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Get in Touch',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: theme.textTheme.bodyLarge?.color,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildContactButton(Icons.email_rounded, () {}),
                          _buildContactButton(Icons.language_rounded, () {}),
                          _buildContactButton(Icons.phone_rounded, () {}),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoItem(
    String label,
    String value,
    IconData icon,
    Color? textColor,
  ) {
    return Row(
      children: [
        Icon(icon, size: 18, color: const Color(0xFF00B6B6)),
        const SizedBox(width: 8),
        Text(
          '$label: $value',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: textColor,
          ),
        ),
      ],
    );
  }

  Widget _buildContactButton(IconData icon, VoidCallback onPressed) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: const Color(
            0xFF00B6B6,
          ).withOpacity(0.2), // Filled with slightly darker teal
          border: Border.all(color: const Color(0xFF00B6B6), width: 1),
        ),
        child: Icon(icon, color: const Color(0xFF00B6B6), size: 24),
      ),
    );
  }
}
