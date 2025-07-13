import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wallmart_store_map/providers/app_state.dart';
import 'package:wallmart_store_map/providers/shopping_provider.dart';
import 'package:wallmart_store_map/screens/home_screen.dart';
import 'package:wallmart_store_map/screens/store_map_screen.dart';
import 'package:wallmart_store_map/screens/product_search_screen.dart';
import 'package:wallmart_store_map/screens/qr_scanner_screen.dart';
import 'package:wallmart_store_map/screens/shopping_list_screen.dart';
import 'package:wallmart_store_map/screens/settings_screen.dart';

import 'package:wallmart_store_map/screens/product_scanner_screen.dart';
import 'package:wallmart_store_map/screens/shopping_assistant_screen.dart';

void main() {
  runApp(const WallmartStoreMapApp());
}

class WallmartStoreMapApp extends StatelessWidget {
  const WallmartStoreMapApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AppState()),
        ChangeNotifierProvider(create: (context) => ShoppingProvider()),
      ],
      child: MaterialApp(
        title: 'Wallmart Store Map',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          primaryColor: const Color(0xFF007BFF),
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF007BFF),
            brightness: Brightness.light,
          ),
          useMaterial3: true,
          fontFamily: 'Roboto',
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF007BFF),
            foregroundColor: Colors.white,
            elevation: 0,
            centerTitle: true,
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF007BFF),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          cardTheme: CardTheme(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        home: const MainNavigationScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;
  
  final List<Widget> _screens = [
    const HomeScreen(),
    const StoreMapScreen(),
    const ProductSearchScreen(),
    const ShoppingListScreen(),
    const QRScannerScreen(),
    const ProductScannerScreen(),
    const ShoppingAssistantScreen(),
    const SettingsScreen(),
  ];

  void setCurrentIndex(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens.map((screen) {
          // Pass navigation callback to HomeScreen
          if (screen is HomeScreen) {
            return HomeScreenWithNavigation(
              onNavigateToMap: () => setCurrentIndex(1),
              onNavigateToSearch: () => setCurrentIndex(2),
              onNavigateToShoppingList: () => setCurrentIndex(3),
            );
          }
          return screen;
        }).toList(),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        selectedItemColor: const Color(0xFF007BFF),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: 'Map',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Lists',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.qr_code_scanner),
            label: 'QR',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.camera_alt),
            label: 'Scan',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assistant),
            label: 'Assistant',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}

// Wrapper for HomeScreen to pass navigation callbacks
class HomeScreenWithNavigation extends StatelessWidget {
  final VoidCallback onNavigateToMap;
  final VoidCallback onNavigateToSearch;
  final VoidCallback onNavigateToShoppingList;

  const HomeScreenWithNavigation({
    super.key,
    required this.onNavigateToMap,
    required this.onNavigateToSearch,
    required this.onNavigateToShoppingList,
  });

  @override
  Widget build(BuildContext context) {
    return HomeScreen(
      onNavigateToMap: onNavigateToMap,
      onNavigateToSearch: onNavigateToSearch,
      onNavigateToShoppingList: onNavigateToShoppingList,
    );
  }
} 