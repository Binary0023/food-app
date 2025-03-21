import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'location.dart'; // Import LocationScreen, but no data passed

class ProfileScreen extends StatefulWidget {
  final Function toggleTheme;
  final bool isDarkMode;

  const ProfileScreen({
    super.key,
    required this.toggleTheme,
    required this.isDarkMode,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic> _profile = {};
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final String? profileJson = prefs.getString('profile');
    setState(() {
      if (profileJson != null && profileJson.isNotEmpty) {
        _profile = jsonDecode(profileJson);
        _nameController.text = _profile['name'] ?? '';
        _emailController.text = _profile['email'] ?? '';
        _phoneController.text = _profile['phone'] ?? '';
        _ageController.text = _profile['age']?.toString() ?? '';
      }
    });
  }

  Future<void> _saveProfile() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('profile', jsonEncode(_profile));
  }

  Future<void> _deleteAccount() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('profile');
    setState(() {
      _profile.clear();
      _nameController.clear();
      _emailController.clear();
      _phoneController.clear();
      _ageController.clear();
      _passwordController.clear();
    });
  }

  void _showProfileForm({bool isEditing = false}) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 0,
            title: Text(
              isEditing ? 'Edit Profile' : 'Create Profile',
              style: TextStyle(
                color: Theme.of(context).textTheme.bodyLarge?.color,
                fontWeight: FontWeight.w900,
              ),
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _nameController,
                    decoration: _textFieldDecoration(
                      'Full Name',
                      'Enter your name',
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: _textFieldDecoration(
                      'Email',
                      'Enter your email',
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: _textFieldDecoration(
                      'Phone Number',
                      '+92 300 1234567',
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _ageController,
                    keyboardType: TextInputType.number,
                    decoration: _textFieldDecoration('Age', 'Enter your age'),
                  ),
                  if (!isEditing) ...[
                    const SizedBox(height: 16),
                    TextField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: _textFieldDecoration(
                        'Password',
                        'Enter a password',
                      ),
                    ),
                  ],
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'Cancel',
                  style: TextStyle(color: Color(0xFF00B6B6)),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  if (_nameController.text.isNotEmpty &&
                      _emailController.text.isNotEmpty &&
                      _phoneController.text.isNotEmpty &&
                      _ageController.text.isNotEmpty &&
                      (isEditing || _passwordController.text.isNotEmpty)) {
                    setState(() {
                      _profile = {
                        'name': _nameController.text,
                        'email': _emailController.text,
                        'phone': _phoneController.text,
                        'age': int.tryParse(_ageController.text) ?? 0,
                        if (!isEditing || _profile.containsKey('password'))
                          'password': _passwordController.text,
                      };
                    });
                    _saveProfile();
                    Navigator.pop(context);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00B6B6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Save',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
    );
  }

  void _changePassword() {
    _passwordController.clear();
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 0,
            title: Text(
              'Change Password',
              style: TextStyle(
                color: Theme.of(context).textTheme.bodyLarge?.color,
                fontWeight: FontWeight.w900,
              ),
            ),
            content: TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: _textFieldDecoration(
                'New Password',
                'Enter new password',
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'Cancel',
                  style: TextStyle(color: Color(0xFF00B6B6)),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  if (_passwordController.text.isNotEmpty) {
                    setState(() {
                      _profile['password'] = _passwordController.text;
                    });
                    _saveProfile();
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Password changed successfully'),
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00B6B6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Change',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _ageController.dispose();
    _passwordController.dispose();
    super.dispose();
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
          icon: Icon(Icons.arrow_back_rounded, color: theme.iconTheme.color),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF00B6B6), width: 2),
                  image: const DecorationImage(
                    image: AssetImage('assets/images/pasta.png'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                _profile['name'] ?? 'Guest',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: theme.textTheme.bodyLarge?.color,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _profile['email'] ?? 'No email set',
                style: TextStyle(
                  fontSize: 16,
                  color: theme.textTheme.bodyMedium?.color,
                ),
              ),
              if (_profile.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  _profile['phone'] ?? 'No phone set',
                  style: TextStyle(
                    fontSize: 16,
                    color: theme.textTheme.bodyMedium?.color,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Age: ${_profile['age'] ?? 'Not set'}',
                  style: TextStyle(
                    fontSize: 16,
                    color: theme.textTheme.bodyMedium?.color,
                  ),
                ),
              ],
              const SizedBox(height: 30),
              if (_profile.isEmpty)
                _buildProfileItem(
                  'Create Profile',
                  Icons.person_add,
                  () => _showProfileForm(),
                )
              else ...[
                _buildProfileItem(
                  'Edit Profile',
                  Icons.edit,
                  () => _showProfileForm(isEditing: true),
                ),
                const SizedBox(height: 16),
                _buildProfileItem('Orders', Icons.shopping_bag_rounded, () {}),
                const SizedBox(height: 16),
                _buildProfileItem('Favorites', Icons.favorite_rounded, () {}),
                const SizedBox(height: 16),
                _buildProfileItem('Address', Icons.location_on_rounded, () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => LocationScreen(
                            toggleTheme:
                                widget.toggleTheme, // Pass from ProfileScreen
                            isDarkMode:
                                widget.isDarkMode, // Pass from ProfileScreen
                          ),
                    ),
                  );
                }),
                const SizedBox(height: 16),
                _buildProfileItem(
                  'Change Password',
                  Icons.lock,
                  _changePassword,
                ),
                const SizedBox(height: 16),
                _buildProfileItem('Logout', Icons.logout_rounded, () {
                  Navigator.popUntil(context, (route) => route.isFirst);
                }),
                const SizedBox(height: 16),
                _buildProfileItem(
                  'Delete Account',
                  Icons.delete_forever,
                  () {
                    showDialog(
                      context: context,
                      builder:
                          (context) => AlertDialog(
                            backgroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                            title: const Text(
                              'Confirm Delete',
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            content: const Text(
                              'Are you sure you want to delete your account? This action cannot be undone.',
                              style: TextStyle(color: Colors.black),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text(
                                  'Cancel',
                                  style: TextStyle(color: Color(0xFF00B6B6)),
                                ),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  _deleteAccount();
                                  Navigator.pop(context);
                                  Navigator.popUntil(
                                    context,
                                    (route) => route.isFirst,
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 0,
                                ),
                                child: const Text(
                                  'Delete',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                    );
                  },
                  color: Colors.red,
                  iconColor: Colors.red,
                ),
              ],
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _textFieldDecoration(String label, String hint) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      filled: true,
      fillColor: widget.isDarkMode ? Colors.grey[800] : Colors.grey[200],
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    );
  }

  Widget _buildProfileItem(
    String title,
    IconData icon,
    VoidCallback onTap, {
    Color? color,
    Color? iconColor,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color ?? const Color(0xFF00B6B6), width: 1),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: iconColor ?? (color ?? const Color(0xFF00B6B6)),
              size: 24,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: color ?? const Color(0xFF00B6B6),
                ),
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              color: Color(0xFF00B6B6),
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}
