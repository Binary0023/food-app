// location.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class LocationScreen extends StatefulWidget {
  final Function toggleTheme;
  final bool isDarkMode;

  const LocationScreen({
    super.key,
    required this.toggleTheme,
    required this.isDarkMode,
  });

  @override
  State<LocationScreen> createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> {
  List<Map<String, dynamic>> _locations = [];

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadLocations();
  }

  Future<void> _loadLocations() async {
    final prefs = await SharedPreferences.getInstance();
    final String? locationsJson = prefs.getString('locations');
    if (locationsJson != null) {
      setState(() {
        _locations = List<Map<String, dynamic>>.from(jsonDecode(locationsJson));
      });
    } else {
      _locations = [
        {
          'title': 'Home',
          'address': '123 Healthy Street, Food City',
          'isDefault': true,
        },
        {
          'title': 'Work',
          'address': '456 Business Avenue, Downtown',
          'isDefault': false,
        },
        {
          'title': 'Gym',
          'address': '789 Fitness Lane, Wellness Town',
          'isDefault': false,
        },
      ];
      _saveLocations();
    }
  }

  Future<void> _saveLocations() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('locations', jsonEncode(_locations));
  }

  void _addNewLocation() {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Add New Location',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    labelText: 'Title',
                    filled: true,
                    fillColor:
                        widget.isDarkMode ? Colors.grey[800] : Colors.grey[200],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _addressController,
                  decoration: InputDecoration(
                    labelText: 'Address',
                    filled: true,
                    fillColor:
                        widget.isDarkMode ? Colors.grey[800] : Colors.grey[200],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                          color: Color(0xFF00B6B6),
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: () {
                        if (_titleController.text.isNotEmpty &&
                            _addressController.text.isNotEmpty) {
                          setState(() {
                            _locations.add({
                              'title': _titleController.text,
                              'address': _addressController.text,
                              'isDefault': false,
                            });
                          });
                          _saveLocations();
                          _titleController.clear();
                          _addressController.clear();
                          Navigator.pop(context);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00B6B6),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Save',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _editLocation(int index) {
    _titleController.text = _locations[index]['title'];
    _addressController.text = _locations[index]['address'];
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Edit Location',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    labelText: 'Title',
                    filled: true,
                    fillColor:
                        widget.isDarkMode ? Colors.grey[800] : Colors.grey[200],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _addressController,
                  decoration: InputDecoration(
                    labelText: 'Address',
                    filled: true,
                    fillColor:
                        widget.isDarkMode ? Colors.grey[800] : Colors.grey[200],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                          color: Color(0xFF00B6B6),
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: () {
                        if (_titleController.text.isNotEmpty &&
                            _addressController.text.isNotEmpty) {
                          setState(() {
                            _locations[index]['title'] = _titleController.text;
                            _locations[index]['address'] =
                                _addressController.text;
                          });
                          _saveLocations();
                          _titleController.clear();
                          _addressController.clear();
                          Navigator.pop(context);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00B6B6),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Save',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _deleteLocation(int index) {
    setState(() {
      _locations.removeAt(index);
    });
    _saveLocations();
  }

  void _setDefaultLocation(int index) {
    setState(() {
      for (int i = 0; i < _locations.length; i++) {
        _locations[i]['isDefault'] = (i == index);
      }
    });
    _saveLocations();
  }

  void _showOptions(int index) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(
                  color: Colors.grey[400],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.edit, color: Color(0xFF00B6B6)),
                title: const Text(
                  'Edit',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _editLocation(index);
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text(
                  'Delete',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                onTap: () {
                  _deleteLocation(index);
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _addressController.dispose();
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
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Text(
                'My Locations',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: theme.textTheme.bodyLarge?.color,
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: ListView.builder(
                  itemCount: _locations.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: GestureDetector(
                        onTap:
                            () => _setDefaultLocation(
                              index,
                            ), // Tap to set default
                        onLongPress:
                            () => _showOptions(
                              index,
                            ), // Long press for edit/delete
                        child: _buildLocationItem(
                          _locations[index]['title'],
                          _locations[index]['address'],
                          _locations[index]['isDefault'],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: _addNewLocation,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00B6B6),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  minimumSize: const Size(double.infinity, 0),
                  elevation: 0,
                  shadowColor: Colors.transparent,
                ),
                child: const Text(
                  'Add New Location',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLocationItem(String title, String address, bool isDefault) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF777777), width: 1),
      ),
      child: Row(
        children: [
          Icon(
            Icons.location_on_rounded,
            color:
                isDefault ? const Color(0xFF00B6B6) : const Color(0xFF777777),
            size: 24,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  address,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF777777),
                  ),
                ),
              ],
            ),
          ),
          if (isDefault)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF00B6B6),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Default',
                style: TextStyle(fontSize: 12, color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }
}
