import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SearchScreen extends StatefulWidget {
  final VoidCallback toggleTheme;
  final bool isDarkMode;

  const SearchScreen({
    super.key,
    required this.toggleTheme,
    required this.isDarkMode,
  });

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<String> _searchHistory = [];
  List<String> _filteredFoods = [];
  final List<String> _allFoods = [
    'Fresh Salad',
    'Sushi Platter',
    'Pasta Primavera',
    'Special Combo',
    'Veggie Wrap',
    'Quinoa Bowl',
    'Grilled Salmon',
  ];

  @override
  void initState() {
    super.initState();
    _loadSearchHistory();
  }

  Future<void> _loadSearchHistory() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _searchHistory = prefs.getStringList('searchHistory') ?? [];
    });
  }

  Future<void> _saveSearchHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('searchHistory', _searchHistory);
  }

  void _addSearchQuery(String query) {
    if (query.isNotEmpty && !_searchHistory.contains(query)) {
      setState(() {
        _searchHistory.insert(0, query);
        if (_searchHistory.length > 5)
          _searchHistory.removeLast(); // Limit to 5
        _saveSearchHistory();
      });
    }
  }

  void _deleteSearchQuery(int index) {
    setState(() {
      _searchHistory.removeAt(index);
      _saveSearchHistory();
    });
  }

  void _searchFood(String query) {
    setState(() {
      _filteredFoods =
          _allFoods
              .where((food) => food.toLowerCase().contains(query.toLowerCase()))
              .toList();
    });
    if (query.isNotEmpty) _addSearchQuery(query);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 27),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.arrow_back_rounded,
                      color: theme.iconTheme.color,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Text(
                    'Search Food',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: theme.textTheme.bodyLarge?.color,
                      fontFamily: GoogleFonts.outfit().fontFamily,
                    ),
                  ),
                  const SizedBox(width: 48), // Placeholder for symmetry
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search for food...',
                  hintStyle: TextStyle(
                    color: theme.textTheme.bodyMedium?.color?.withOpacity(0.6),
                    fontFamily: GoogleFonts.outfit().fontFamily,
                  ),
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    color: theme.iconTheme.color,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF777777)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF777777)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF00B6B6)),
                  ),
                  filled: true,
                  fillColor:
                      widget.isDarkMode ? Colors.grey[900] : Colors.grey[100],
                ),
                style: TextStyle(
                  color: theme.textTheme.bodyLarge?.color,
                  fontFamily: GoogleFonts.outfit().fontFamily,
                ),
                onSubmitted: _searchFood,
              ),
              const SizedBox(height: 28),
              if (_filteredFoods.isNotEmpty) ...[
                Text(
                  'Search Results',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: theme.textTheme.bodyLarge?.color,
                    fontFamily: GoogleFonts.outfit().fontFamily,
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView.builder(
                    itemCount: _filteredFoods.length,
                    itemBuilder: (context, index) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color:
                              widget.isDarkMode
                                  ? Colors.grey[850]
                                  : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ListTile(
                          title: Text(
                            _filteredFoods[index],
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: theme.textTheme.bodyLarge?.color,
                              fontFamily: GoogleFonts.outfit().fontFamily,
                            ),
                          ),
                          onTap: () {
                            // Navigate to detail screen or handle tap
                          },
                        ),
                      );
                    },
                  ),
                ),
              ] else if (_searchHistory.isNotEmpty) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Search History',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: theme.textTheme.bodyLarge?.color,
                        fontFamily: GoogleFonts.outfit().fontFamily,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _searchHistory.clear();
                          _saveSearchHistory();
                        });
                      },
                      child: Text(
                        'Clear All',
                        style: TextStyle(
                          fontSize: 14,
                          color: const Color(0xFF00B6B6),
                          fontWeight: FontWeight.w500,
                          fontFamily: GoogleFonts.outfit().fontFamily,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView.builder(
                    itemCount: _searchHistory.length,
                    itemBuilder: (context, index) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color:
                              widget.isDarkMode
                                  ? Colors.grey[850]
                                  : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ListTile(
                          title: Text(
                            _searchHistory[index],
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: theme.textTheme.bodyLarge?.color,
                              fontFamily: GoogleFonts.outfit().fontFamily,
                            ),
                          ),
                          trailing: IconButton(
                            icon: const Icon(
                              Icons.delete_rounded,
                              color: Colors.red,
                            ),
                            onPressed: () => _deleteSearchQuery(index),
                          ),
                          onTap: () {
                            _searchController.text = _searchHistory[index];
                            _searchFood(_searchHistory[index]);
                          },
                        ),
                      );
                    },
                  ),
                ),
              ] else ...[
                Expanded(
                  child: Center(
                    child: Text(
                      'No search history yet.',
                      style: TextStyle(
                        fontSize: 16,
                        color: theme.textTheme.bodyLarge?.color?.withOpacity(
                          0.6,
                        ),
                        fontFamily: GoogleFonts.outfit().fontFamily,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
