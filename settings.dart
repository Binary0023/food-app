import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class SettingsScreen extends StatefulWidget {
  final VoidCallback toggleTheme; // Changed to VoidCallback for clarity
  final bool isDarkMode;

  const SettingsScreen({
    super.key,
    required this.toggleTheme,
    required this.isDarkMode,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  String _language = 'English';
  bool _soundEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _notificationsEnabled = prefs.getBool('notifications') ?? true;
      _language = prefs.getString('language') ?? 'English';
      _soundEnabled = prefs.getBool('sound') ?? true;
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications', _notificationsEnabled);
    await prefs.setString('language', _language);
    await prefs.setBool('sound', _soundEnabled);
  }

  void _toggleNotifications(bool value) {
    setState(() {
      _notificationsEnabled = value;
    });
    _saveSettings();
  }

  void _toggleSound(bool value) {
    setState(() {
      _soundEnabled = value;
    });
    _saveSettings();
  }

  void _changeLanguage() {
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
              'Select Language',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w900,
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children:
                  ['English', 'Spanish', 'French'].map((lang) {
                    return ListTile(
                      title: Text(lang),
                      onTap: () {
                        setState(() {
                          _language = lang;
                        });
                        _saveSettings();
                        Navigator.pop(context);
                      },
                    );
                  }).toList(),
            ),
          ),
    );
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
        title: Text(
          'Settings',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w900,
            color: theme.textTheme.bodyLarge?.color,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                _buildSettingsItem(
                  'Theme',
                  Icons.brightness_6_rounded,
                  _buildModernToggle(
                    widget.isDarkMode,
                    (_) => widget.toggleTheme(),
                  ),
                  onTap: widget.toggleTheme, // Fixed type issue
                ),
                const SizedBox(height: 16),
                _buildSettingsItem(
                  'Notifications',
                  Icons.notifications_rounded,
                  _buildModernToggle(
                    _notificationsEnabled,
                    _toggleNotifications,
                  ),
                ),
                const SizedBox(height: 16),
                _buildSettingsItem(
                  'Sound',
                  Icons.volume_up_rounded,
                  _buildModernToggle(_soundEnabled, _toggleSound),
                ),
                const SizedBox(height: 16),
                _buildSettingsItem(
                  'Language',
                  Icons.language_rounded,
                  Text(
                    _language,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Color(0xFF777777),
                    ),
                  ),
                  onTap: _changeLanguage,
                ),
                const SizedBox(height: 16),
                _buildSettingsItem(
                  'Privacy Policy',
                  Icons.privacy_tip_rounded,
                  const Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: Color(0xFF00B6B6),
                    size: 16,
                  ),
                  onTap:
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const PrivacyPolicyScreen(),
                        ),
                      ),
                ),
                const SizedBox(height: 16),
                _buildSettingsItem(
                  'Account Info',
                  Icons.account_circle_rounded,
                  const Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: Color(0xFF00B6B6),
                    size: 16,
                  ),
                  onTap:
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AccountInfoScreen(),
                        ),
                      ),
                ),
                const SizedBox(height: 16),
                _buildSettingsItem(
                  'Data Usage',
                  Icons.data_usage_rounded,
                  const Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: Color(0xFF00B6B6),
                    size: 16,
                  ),
                  onTap:
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const DataUsageScreen(),
                        ),
                      ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsItem(
    String title,
    IconData icon,
    Widget trailing, {
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF777777), width: 1),
        ),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFF00B6B6), size: 24),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            trailing,
          ],
        ),
      ),
    );
  }

  Widget _buildModernToggle(bool value, Function(bool) onChanged) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: Container(
        width: 52,
        height: 32,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: value ? const Color(0xFF00B6B6) : Colors.grey[300],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            AnimatedPositioned(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              left: value ? 22 : 2,
              child: Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Privacy Policy Screen (Real Content)
class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

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
          'Privacy Policy',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w900,
            color: theme.textTheme.bodyLarge?.color,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Privacy Policy',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 16),
              Text(
                'Last updated: March 16, 2025\n\n'
                'We value your privacy. This Privacy Policy explains how we collect, use, and protect your personal information when you use our app.\n\n'
                '1. **Information We Collect**\n'
                '   - Personal Info: Name, email, phone number, and age (if provided).\n'
                '   - Usage Data: App interactions and preferences.\n\n'
                '2. **How We Use Your Information**\n'
                '   - To personalize your experience.\n'
                '   - To improve our app’s functionality.\n\n'
                '3. **Data Sharing**\n'
                '   - We do not share your data with third parties except as required by law.\n\n'
                '4. **Security**\n'
                '   - We use encryption and secure storage to protect your data.\n\n'
                '5. **Your Rights**\n'
                '   - You can delete your account anytime via the app.\n\n'
                'Contact us at support@example.com for questions.',
                style: TextStyle(
                  fontSize: 16,
                  color: theme.textTheme.bodyLarge?.color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Account Info Screen (Real, based on ProfileScreen)
class AccountInfoScreen extends StatefulWidget {
  const AccountInfoScreen({super.key});

  @override
  State<AccountInfoScreen> createState() => _AccountInfoScreenState();
}

class _AccountInfoScreenState extends State<AccountInfoScreen> {
  Map<String, dynamic> _profile = {};

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final String? profileJson = prefs.getString('profile');
    if (profileJson != null && profileJson.isNotEmpty) {
      setState(() {
        _profile = jsonDecode(profileJson);
      });
    }
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
        title: Text(
          'Account Info',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w900,
            color: theme.textTheme.bodyLarge?.color,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Account Details',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 16),
              _buildInfoItem(
                'Name',
                _profile['name'] ?? 'Not set',
                Icons.person,
              ),
              const SizedBox(height: 16),
              _buildInfoItem(
                'Email',
                _profile['email'] ?? 'Not set',
                Icons.email,
              ),
              const SizedBox(height: 16),
              _buildInfoItem(
                'Phone',
                _profile['phone'] ?? 'Not set',
                Icons.phone,
              ),
              const SizedBox(height: 16),
              _buildInfoItem(
                'Age',
                _profile['age']?.toString() ?? 'Not set',
                Icons.cake,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoItem(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF777777), width: 1),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF00B6B6), size: 24),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF777777),
                ),
              ),
              const SizedBox(height: 4),
              Text(value, style: const TextStyle(fontSize: 16)),
            ],
          ),
        ],
      ),
    );
  }
}

// Data Usage Screen (Mock Data)
class DataUsageScreen extends StatefulWidget {
  const DataUsageScreen({super.key});

  @override
  State<DataUsageScreen> createState() => _DataUsageScreenState();
}

class _DataUsageScreenState extends State<DataUsageScreen> {
  bool _dataSaver = false;
  String _dataLimit = 'Unlimited';

  @override
  void initState() {
    super.initState();
    _loadDataSettings();
  }

  Future<void> _loadDataSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _dataSaver = prefs.getBool('dataSaver') ?? false;
      _dataLimit = prefs.getString('dataLimit') ?? 'Unlimited';
    });
  }

  Future<void> _saveDataSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('dataSaver', _dataSaver);
    await prefs.setString('dataLimit', _dataLimit);
  }

  void _toggleDataSaver(bool value) {
    setState(() {
      _dataSaver = value;
    });
    _saveDataSettings();
  }

  void _changeDataLimit() {
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
              'Set Data Limit',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w900,
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children:
                  ['Unlimited', '1 GB', '5 GB', '10 GB'].map((limit) {
                    return ListTile(
                      title: Text(limit),
                      onTap: () {
                        setState(() {
                          _dataLimit = limit;
                        });
                        _saveDataSettings();
                        Navigator.pop(context);
                      },
                    );
                  }).toList(),
            ),
          ),
    );
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
        title: Text(
          'Data Usage',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w900,
            color: theme.textTheme.bodyLarge?.color,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Data Usage Settings',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 16),
              _buildSettingsItem(
                'Data Saver',
                Icons.battery_saver,
                _buildModernToggle(_dataSaver, _toggleDataSaver),
              ),
              const SizedBox(height: 16),
              _buildSettingsItem(
                'Data Limit',
                Icons.data_usage,
                Text(
                  _dataLimit,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Color(0xFF777777),
                  ),
                ),
                onTap: _changeDataLimit,
              ),
              const SizedBox(height: 16),
              const Text(
                'Usage This Month: 2.3 GB', // Mock data
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsItem(
    String title,
    IconData icon,
    Widget trailing, {
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF777777), width: 1),
        ),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFF00B6B6), size: 24),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            trailing,
          ],
        ),
      ),
    );
  }

  Widget _buildModernToggle(bool value, Function(bool) onChanged) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: Container(
        width: 52,
        height: 32,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: value ? const Color(0xFF00B6B6) : Colors.grey[300],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            AnimatedPositioned(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              left: value ? 22 : 2,
              child: Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
