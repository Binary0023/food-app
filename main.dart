import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Added for persistence
import 'about_screen.dart';
import 'profile.dart';
import 'wallet.dart';
import 'settings.dart';
import 'location.dart';
import 'dart:ui';
import 'search.dart'; // Import SearchScreen
import 'cart.dart'; // Import CartScreen
import 'buynow.dart'; // Import BuyNowScreen

void main() {
  runApp(const FoodApp());
}

class FoodApp extends StatefulWidget {
  const FoodApp({super.key});

  @override
  State<FoodApp> createState() => _FoodAppState();
}

class _FoodAppState extends State<FoodApp> {
  bool _isDarkMode = false;

  @override
  void initState() {
    super.initState();
    _loadTheme(); // Load saved theme on startup
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isDarkMode =
          prefs.getBool('isDarkMode') ?? false; // Default to false if not set
    });
  }

  Future<void> _saveTheme(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', value);
  }

  void toggleTheme() {
    setState(() {
      _isDarkMode = !_isDarkMode;
      _saveTheme(_isDarkMode); // Save the new theme state
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: _isDarkMode ? darkTheme : lightTheme,
      home: HomeScreen(toggleTheme: toggleTheme, isDarkMode: _isDarkMode),
    );
  }
}

final lightTheme = ThemeData(
  brightness: Brightness.light,
  scaffoldBackgroundColor: Colors.white,
  appBarTheme: const AppBarTheme(backgroundColor: Colors.white, elevation: 0),
  textTheme: GoogleFonts.outfitTextTheme().apply(
    bodyColor: Colors.black,
    displayColor: Colors.black,
  ),
  iconTheme: const IconThemeData(color: Colors.black),
);

final darkTheme = ThemeData(
  brightness: Brightness.dark,
  scaffoldBackgroundColor: Colors.black,
  appBarTheme: const AppBarTheme(backgroundColor: Colors.black, elevation: 0),
  textTheme: GoogleFonts.outfitTextTheme().apply(
    bodyColor: Colors.white,
    displayColor: Colors.white,
  ),
  iconTheme: const IconThemeData(color: Colors.white),
);

class HomeScreen extends StatefulWidget {
  final VoidCallback toggleTheme;
  final bool isDarkMode;

  const HomeScreen({
    super.key,
    required this.toggleTheme,
    required this.isDarkMode,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedTabIndex = 0;
  int _selectedNavIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _navigateToScreen(int index) {
    setState(() => _selectedNavIndex = index);
    if (index == 0) return; // Stay on Home, no navigation needed

    Widget screen;
    switch (index) {
      case 1: // Profile
        screen = ProfileScreen(
          toggleTheme: widget.toggleTheme,
          isDarkMode: widget.isDarkMode,
        );
        break;
      case 2: // Wallet
        screen = WalletScreen(
          toggleTheme: widget.toggleTheme,
          isDarkMode: widget.isDarkMode,
        );
        break;
      case 3: // Settings
        screen = SettingsScreen(
          toggleTheme: widget.toggleTheme,
          isDarkMode: widget.isDarkMode,
        );
        break;
      case 4: // Location
        screen = LocationScreen(
          toggleTheme: widget.toggleTheme,
          isDarkMode: widget.isDarkMode,
        );
        break;
      default:
        return;
    }

    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => screen,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return ScaleTransition(
            scale: Tween<double>(begin: 0.0, end: 1.0).animate(
              CurvedAnimation(parent: animation, curve: Curves.easeInOut),
            ),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    ).then((_) {
      setState(() => _selectedNavIndex = 0);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: theme.scaffoldBackgroundColor,
      drawer: Drawer(
        child: Container(
          color: theme.scaffoldBackgroundColor,
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              DrawerHeader(
                decoration: const BoxDecoration(color: Color(0xFF00B6B6)),
                child: Text(
                  'Menu',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              ListTile(
                leading: Icon(Icons.info_outline, color: theme.iconTheme.color),
                title: Text(
                  'About',
                  style: TextStyle(
                    color: theme.textTheme.bodyLarge?.color,
                    fontSize: 16,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AboutScreen(),
                    ),
                  );
                },
              ),
              ListTile(
                leading: Icon(
                  widget.isDarkMode ? Icons.light_mode : Icons.dark_mode,
                  color: theme.iconTheme.color,
                ),
                title: Text(
                  widget.isDarkMode ? 'Light Mode' : 'Dark Mode',
                  style: TextStyle(
                    color: theme.textTheme.bodyLarge?.color,
                    fontSize: 16,
                  ),
                ),
                onTap: () {
                  widget.toggleTheme();
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              controller: _scrollController,
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
                            Icons.menu_rounded,
                            color: theme.iconTheme.color,
                          ),
                          onPressed:
                              () => _scaffoldKey.currentState?.openDrawer(),
                        ),
                        Row(
                          children: [
                            IconButton(
                              icon: Icon(
                                Icons.search_rounded,
                                color: theme.iconTheme.color,
                              ),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (context) => SearchScreen(
                                          toggleTheme: widget.toggleTheme,
                                          isDarkMode: widget.isDarkMode,
                                        ),
                                  ),
                                );
                              },
                            ),
                            IconButton(
                              icon: Icon(
                                Icons.shopping_cart_rounded,
                                color: theme.iconTheme.color,
                              ),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (context) => CartScreen(
                                          toggleTheme: widget.toggleTheme,
                                          isDarkMode: widget.isDarkMode,
                                        ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Healthy Food',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: theme.textTheme.bodyLarge?.color,
                      ),
                    ),
                    const SizedBox(height: 34),
                    Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildTab('Featured', 0),
                          const SizedBox(width: 16),
                          _buildTab('Popular', 1),
                          const SizedBox(width: 16),
                          _buildTab('Asian', 2),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),
                    SizedBox(
                      height: 240,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        children: [
                          _buildDishCard(
                            'Fresh Salad',
                            'PKR 250',
                            4.5,
                            'assets/images/pasta.png',
                          ),
                          _buildDishCard(
                            'Sushi Platter',
                            'PKR 350',
                            4.8,
                            'assets/images/pasta.png',
                          ),
                          _buildDishCard(
                            'Pasta Primavera',
                            'PKR 300',
                            4.6,
                            'assets/images/pasta.png',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      'Recommended',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: theme.textTheme.bodyLarge?.color,
                      ),
                    ),
                    const SizedBox(height: 28),
                    _buildRecommendedCard('Special Combo', 'PKR 450', 4.9),
                    const SizedBox(height: 16),
                    _buildRecommendedCard('Veggie Wrap', 'PKR 280', 4.7),
                    const SizedBox(height: 16),
                    _buildRecommendedCard('Quinoa Bowl', 'PKR 320', 4.8),
                    const SizedBox(height: 16),
                    _buildRecommendedCard('Grilled Salmon', 'PKR 550', 4.9),
                    const SizedBox(height: 120),
                  ],
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    height: 0,
                    color:
                        widget.isDarkMode ? Colors.grey[900] : Colors.grey[200],
                    width: double.infinity,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(70),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 19),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildBottomNavItem(Icons.home_rounded, 0),
                          _buildBottomNavItem(Icons.person_rounded, 1),
                          _buildBottomNavItem(
                            Icons.account_balance_wallet_rounded,
                            2,
                          ),
                          _buildBottomNavItem(Icons.settings_rounded, 3),
                          _buildBottomNavItem(Icons.location_on_rounded, 4),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTab(String title, int index) {
    bool isSelected = _selectedTabIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedTabIndex = index),
      child: SizedBox(
        width: 80,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                color:
                    isSelected
                        ? Theme.of(context).textTheme.bodyLarge?.color
                        : const Color(0xFF4C4C4C),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color:
                    isSelected ? const Color(0xFF00B6B6) : Colors.transparent,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDishCard(
    String name,
    String price,
    double rating,
    String imagePath,
  ) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) => FoodDetailScreen(
                  name: name,
                  price: price,
                  rating: rating,
                  imagePath: imagePath,
                  toggleTheme: widget.toggleTheme,
                  isDarkMode: widget.isDarkMode,
                ),
          ),
        );
      },
      child: Container(
        width: 170,
        margin: const EdgeInsets.only(right: 1),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Theme.of(context).scaffoldBackgroundColor,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              height: 150,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                image: DecorationImage(
                  image: AssetImage(imagePath),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  name,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      price,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xB3626262),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(
                      Icons.star_rounded,
                      size: 16,
                      color: Colors.amber,
                    ),
                    Text(
                      rating.toString(),
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xB3626262),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendedCard(String name, String price, double rating) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) => FoodDetailScreen(
                  name: name,
                  price: price,
                  rating: rating,
                  imagePath: 'assets/images/pasta.png',
                  toggleTheme: widget.toggleTheme,
                  isDarkMode: widget.isDarkMode,
                ),
          ),
        );
      },
      child: AnimatedBuilder(
        animation: _scrollController,
        builder: (context, child) {
          double opacity = 1.0;
          double scale = 1.0;
          if (_scrollController.hasClients) {
            final double screenHeight = MediaQuery.of(context).size.height;
            final double navbarHeight = 80.0;
            final double offset = _scrollController.offset;
            final double widgetPosition = screenHeight - navbarHeight - 200;
            if (offset > widgetPosition) {
              double factor = ((offset - widgetPosition) / 100).clamp(0.0, 1.0);
              opacity = 1.0 - factor;
              scale = 1.0 - (factor * 0.5);
            }
          }
          return Transform.scale(
            scale: scale,
            child: Opacity(
              opacity: opacity,
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF00B6B6),
                        borderRadius: BorderRadius.circular(26),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 70,
                            height: 70,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              image: const DecorationImage(
                                image: AssetImage('assets/images/pasta.png'),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  name,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  price,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.star_rounded,
                                      size: 16,
                                      color: Color.fromARGB(255, 225, 250, 84),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      rating.toString(),
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF00B6B6),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.add_rounded,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBottomNavItem(IconData icon, int index) {
    bool isSelected = _selectedNavIndex == index;
    return GestureDetector(
      onTap: () => _navigateToScreen(index),
      child: SizedBox(
        width: 50,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 26),
            const SizedBox(height: 2.9),
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color:
                    isSelected ? const Color(0xFF00B6B6) : Colors.transparent,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FoodDetailScreen extends StatefulWidget {
  final String name;
  final String price;
  final double rating;
  final String imagePath;
  final VoidCallback toggleTheme;
  final bool isDarkMode;

  const FoodDetailScreen({
    super.key,
    required this.name,
    required this.price,
    required this.rating,
    required this.imagePath,
    required this.toggleTheme,
    required this.isDarkMode,
  });

  @override
  State<FoodDetailScreen> createState() => _FoodDetailScreenState();
}

class _FoodDetailScreenState extends State<FoodDetailScreen> {
  int _currentImageIndex = 0;
  bool _isDescriptionExpanded = false;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final List<String> _images = [
    'assets/images/pasta.png',
    'assets/images/pasta.png',
    'assets/images/pasta.png',
    'assets/images/pasta.png',
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: theme.scaffoldBackgroundColor,
      drawer: Drawer(
        child: Container(
          color: theme.scaffoldBackgroundColor,
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              DrawerHeader(
                decoration: const BoxDecoration(color: Color(0xFF00B6B6)),
                child: Text(
                  'Menu',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              ListTile(
                leading: Icon(Icons.info_outline, color: theme.iconTheme.color),
                title: Text(
                  'About',
                  style: TextStyle(
                    color: theme.textTheme.bodyLarge?.color,
                    fontSize: 16,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AboutScreen(),
                    ),
                  );
                },
              ),
              ListTile(
                leading: Icon(
                  widget.isDarkMode ? Icons.light_mode : Icons.dark_mode,
                  color: theme.iconTheme.color,
                ),
                title: Text(
                  widget.isDarkMode ? 'Light Mode' : 'Dark Mode',
                  style: TextStyle(
                    color: theme.textTheme.bodyLarge?.color,
                    fontSize: 16,
                  ),
                ),
                onTap: () {
                  widget.toggleTheme();
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24.0,
                  vertical: 27.0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.arrow_back_rounded,
                        color: theme.iconTheme.color,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.menu_rounded,
                        color: theme.iconTheme.color,
                      ),
                      onPressed: () => _scaffoldKey.currentState?.openDrawer(),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 120,
                child: PageView.builder(
                  itemCount: _images.length,
                  onPageChanged:
                      (index) => setState(() => _currentImageIndex = index),
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.asset(
                          _images[index],
                          fit: BoxFit.contain,
                          width: double.infinity,
                          height: 120,
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _images.length,
                  (index) => Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color:
                          _currentImageIndex == index
                              ? (widget.isDarkMode
                                  ? Colors.white
                                  : Colors.black)
                              : (widget.isDarkMode
                                  ? Colors.white.withOpacity(0.4)
                                  : Colors.black.withOpacity(0.4)),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      widget.name,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: theme.textTheme.bodyLarge?.color,
                      ),
                    ),
                    Text(
                      widget.price,
                      style: TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.w900,
                        color: theme.textTheme.bodyLarge?.color,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Text(
                  _isDescriptionExpanded
                      ? 'A delicious pasta dish made with fresh spring vegetables, olive oil, and a hint of garlic. Perfect for a healthy and flavorful meal. This dish is crafted with the finest ingredients to ensure a burst of flavor in every bite, making it a favorite among health-conscious foodies.'
                      : 'A delicious pasta dish made with fresh spring vegetables, olive oil, and a hint of garlic.',
                  style: TextStyle(
                    fontSize: 14,
                    color: theme.textTheme.bodyMedium?.color,
                  ),
                ),
              ),
              const SizedBox(height: 3),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: TextButton(
                  onPressed:
                      () => setState(
                        () => _isDescriptionExpanded = !_isDescriptionExpanded,
                      ),
                  child: Text(
                    _isDescriptionExpanded ? 'Read Less' : 'Read More',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF00B6B6),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: Container(
                  width: 350,
                  height: 88,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: const Color(0xFF777777),
                      width: 0.91,
                    ),
                    borderRadius: BorderRadius.circular(26.5),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildNutritionItem('Calories', '265 kcal'),
                      VerticalDivider(
                        color: const Color(0xFF777777),
                        thickness: 0.91,
                      ),
                      _buildNutritionItem('Sugar', '20 g'),
                      VerticalDivider(
                        color: const Color(0xFF777777),
                        thickness: 0.91,
                      ),
                      _buildNutritionItem('Protein', '40 g'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: Container(
                  width: 350,
                  height: 80,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: const Color(0xFF777777),
                      width: 0.91,
                    ),
                    borderRadius: BorderRadius.circular(26.5),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Positioned.fill(
                        left: 5,
                        right: 5,
                        top: 5,
                        bottom: 5,
                        child: Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFF00B6B6),
                            borderRadius: BorderRadius.circular(21),
                          ),
                          child: const Center(
                            child: Text(
                              'POST A REVIEW',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: const Color(0xFF00B6B6),
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(17),
                      ),
                      child: const Icon(
                        Icons.favorite_border_rounded,
                        color: Color(0xFF00B6B6),
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => BuyNowScreen(
                                  name: widget.name,
                                  price: widget.price,
                                  imagePath: widget.imagePath,
                                  toggleTheme: widget.toggleTheme,
                                  isDarkMode: widget.isDarkMode,
                                ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00B6B6),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 80,
                          vertical: 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(17),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Buy Now',
                        style: TextStyle(
                          fontSize: 21,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNutritionItem(String title, String value) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            color: Theme.of(context).textTheme.bodyMedium?.color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).textTheme.bodyMedium?.color,
          ),
        ),
      ],
    );
  }
}
