import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wallmart_store_map/providers/app_state.dart';
import 'package:wallmart_store_map/services/api_service.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback? onNavigateToMap;
  final VoidCallback? onNavigateToSearch;
  final VoidCallback? onNavigateToShoppingList;

  const HomeScreen({
    super.key,
    this.onNavigateToMap,
    this.onNavigateToSearch,
    this.onNavigateToShoppingList,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  void _navigateToMap() {
    widget.onNavigateToMap?.call();
  }

  void _navigateToSearch() {
    widget.onNavigateToSearch?.call();
  }

  void _navigateToShoppingList() {
    widget.onNavigateToShoppingList?.call();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Wallmart Store Map'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF007BFF), Color(0xFF0056B3)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome to Wallmart Store Map',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Find products easily with our smart navigation system',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),


            // Features Section
            const Text(
              'Features',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildFeatureCard(
              'Interactive Store Map',
              'Navigate through the store with our interactive map showing product locations and optimal routes.',
              Icons.map,
              Colors.blue,
            ),
            const SizedBox(height: 12),
            _buildFeatureCard(
              'Product Search',
              'Find any product quickly with our powerful search functionality and get directions to its location.',
              Icons.search,
              Colors.green,
            ),
            const SizedBox(height: 12),
            _buildFeatureCard(
              'QR Code Scanner',
              'Scan QR codes placed around the store to get your current location and find nearby products.',
              Icons.qr_code_scanner,
              Colors.orange,
            ),
            const SizedBox(height: 12),
            _buildFeatureCard(
              'Product Scanner',
              'Scan product barcodes or take photos to get detailed nutritional information and product details.',
              Icons.camera_alt,
              Colors.teal,
            ),
            const SizedBox(height: 12),
            _buildFeatureCard(
              'Shopping Assistant',
              'Tell us what you want to cook and get a complete shopping list with ingredients and estimated costs.',
              Icons.assistant,
              Colors.indigo,
            ),
            const SizedBox(height: 12),
            _buildFeatureCard(
              'Shopping Lists',
              'Create and manage your shopping lists, track items, and never forget what you need to buy.',
              Icons.shopping_cart,
              Colors.purple,
            ),
            const SizedBox(height: 24),

            // How It Works Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'How It Works',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildStepItem(
                      '1',
                      'Scan QR Codes',
                      'QR codes are placed throughout the store at key locations. Scan them to mark your current position.',
                    ),
                    const SizedBox(height: 12),
                    _buildStepItem(
                      '2',
                      'Search Products',
                      'Use our search feature to find any product in the store. Get instant directions to its location.',
                    ),
                    const SizedBox(height: 12),
                    _buildStepItem(
                      '3',
                      'Follow Navigation',
                      'Our interactive map shows you the optimal route from your current location to the desired product.',
                    ),
                    const SizedBox(height: 12),
                    _buildStepItem(
                      '4',
                      'Find Products',
                      'Arrive at the exact location where your product is located, saving time and reducing frustration.',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Call to Action
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const Text(
                      'Ready to Start Shopping?',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Begin your shopping experience with our smart navigation system. Find products faster and enjoy a more convenient shopping trip.',
                      style: TextStyle(fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _navigateToMap,
                            icon: const Icon(Icons.map),
                            label: const Text('View Store Map'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _navigateToSearch,
                            icon: const Icon(Icons.search),
                            label: const Text('Search Products'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey[600],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _navigateToShoppingList,
                        icon: const Icon(Icons.shopping_cart),
                        label: const Text('Create Shopping List'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                        ),
                      ),
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



  Widget _buildFeatureCard(String title, String description, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 24),
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
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepItem(String step, String title, String description) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: const BoxDecoration(
            color: Color(0xFF007BFF),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              step,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
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
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
} 