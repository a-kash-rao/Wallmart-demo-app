import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wallmart_store_map/providers/shopping_provider.dart';
import 'package:wallmart_store_map/data/sample_store_map.dart';
import 'package:wallmart_store_map/models/product.dart';
import 'package:wallmart_store_map/models/shopping_list.dart';

class ShoppingAssistantScreen extends StatefulWidget {
  const ShoppingAssistantScreen({super.key});

  @override
  State<ShoppingAssistantScreen> createState() => _ShoppingAssistantScreenState();
}

class _ShoppingAssistantScreenState extends State<ShoppingAssistantScreen> {
  final TextEditingController _recipeController = TextEditingController();
  final TextEditingController _dietaryController = TextEditingController();
  bool _isGenerating = false;
  List<Map<String, dynamic>> _suggestedItems = [];
  List<String> _recipeHistory = [];
  String? _currentRecipe;
  String? _currentDietary;

  // Mock local LLM responses for demo
  final Map<String, List<Map<String, dynamic>>> _recipeDatabase = {
    'pasta carbonara': [
      {'name': 'Bread', 'category': 'Bakery', 'quantity': '1 loaf', 'estimated_price': 206.67},
      {'name': 'Chicken Breast', 'category': 'Meat', 'quantity': '1 lb', 'estimated_price': 746.17},
      {'name': 'Whole Milk', 'category': 'Dairy', 'quantity': '1 gallon', 'estimated_price': 289.67},
      {'name': 'Tomatoes', 'category': 'Vegetables', 'quantity': '1 lb', 'estimated_price': 165.17},
      {'name': 'Organic Bananas', 'category': 'Fruits', 'quantity': '2 medium', 'estimated_price': 248.17},
    ],
    'chicken stir fry': [
      {'name': 'Chicken Breast', 'category': 'Meat', 'quantity': '1 lb', 'estimated_price': 746.17},
      {'name': 'Tomatoes', 'category': 'Vegetables', 'quantity': '1 lb', 'estimated_price': 165.17},
      {'name': 'Whole Milk', 'category': 'Dairy', 'quantity': '1 gallon', 'estimated_price': 289.67},
      {'name': 'Bread', 'category': 'Bakery', 'quantity': '1 loaf', 'estimated_price': 206.67},
      {'name': 'Organic Bananas', 'category': 'Fruits', 'quantity': '2 medium', 'estimated_price': 248.17},
    ],
    'vegetarian lasagna': [
      {'name': 'Bread', 'category': 'Bakery', 'quantity': '1 loaf', 'estimated_price': 206.67},
      {'name': 'Tomatoes', 'category': 'Vegetables', 'quantity': '2 lb', 'estimated_price': 330.34},
      {'name': 'Whole Milk', 'category': 'Dairy', 'quantity': '1 gallon', 'estimated_price': 289.67},
      {'name': 'Organic Bananas', 'category': 'Fruits', 'quantity': '3 medium', 'estimated_price': 372.26},
    ],
    'breakfast smoothie': [
      {'name': 'Organic Bananas', 'category': 'Fruits', 'quantity': '2 medium', 'estimated_price': 248.17},
      {'name': 'Whole Milk', 'category': 'Dairy', 'quantity': '1 gallon', 'estimated_price': 289.67},
      {'name': 'Bread', 'category': 'Bakery', 'quantity': '1 loaf', 'estimated_price': 206.67},
      {'name': 'Tomatoes', 'category': 'Vegetables', 'quantity': '1 lb', 'estimated_price': 165.17},
    ],
  };

  @override
  void initState() {
    super.initState();
    _loadRecipeHistory();
  }

  @override
  void dispose() {
    _recipeController.dispose();
    _dietaryController.dispose();
    super.dispose();
  }

  Future<void> _loadRecipeHistory() async {
    // Load recipe history from SharedPreferences
    // For demo, we'll use a simple list
    setState(() {
      _recipeHistory = [
        'pasta carbonara',
        'chicken stir fry',
        'vegetarian lasagna',
        'breakfast smoothie',
      ];
    });
  }

  Future<void> _generateShoppingList() async {
    final recipe = _recipeController.text.trim().toLowerCase();
    final dietary = _dietaryController.text.trim();
    
    if (recipe.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a recipe or dish')),
      );
      return;
    }

    setState(() {
      _isGenerating = true;
      _currentRecipe = recipe;
      _currentDietary = dietary.isNotEmpty ? dietary : null;
    });

    // Simulate local LLM processing
    await Future.delayed(const Duration(seconds: 2));

    // Get suggested items from our mock database
    List<Map<String, dynamic>> suggestedItems = [];
    
    // Try exact match first
    if (_recipeDatabase.containsKey(recipe)) {
      suggestedItems = _recipeDatabase[recipe]!;
    } else {
      // Try partial matches
      for (final entry in _recipeDatabase.entries) {
        if (entry.key.contains(recipe) || recipe.contains(entry.key)) {
          suggestedItems = entry.value;
          break;
        }
      }
    }

    // If no match found, generate generic suggestions
    if (suggestedItems.isEmpty) {
      suggestedItems = _generateGenericSuggestions(recipe, dietary);
    }

    // Apply dietary restrictions
    if (dietary.isNotEmpty) {
      suggestedItems = _applyDietaryRestrictions(suggestedItems, dietary);
    }

    setState(() {
      _suggestedItems = suggestedItems;
      _isGenerating = false;
    });

    // Add to recipe history
    if (!_recipeHistory.contains(recipe)) {
      setState(() {
        _recipeHistory.insert(0, recipe);
        if (_recipeHistory.length > 10) {
          _recipeHistory.removeLast();
        }
      });
    }
  }

  List<Map<String, dynamic>> _generateGenericSuggestions(String recipe, String dietary) {
    // Generate generic suggestions based on recipe keywords
    final suggestions = <Map<String, dynamic>>[];
    
    if (recipe.contains('pasta') || recipe.contains('noodle')) {
      suggestions.addAll([
        {'name': 'Bread', 'category': 'Bakery', 'quantity': '1 loaf', 'estimated_price': 206.67},
        {'name': 'Whole Milk', 'category': 'Dairy', 'quantity': '1 gallon', 'estimated_price': 289.67},
        {'name': 'Tomatoes', 'category': 'Vegetables', 'quantity': '1 lb', 'estimated_price': 165.17},
        {'name': 'Organic Bananas', 'category': 'Fruits', 'quantity': '2 medium', 'estimated_price': 248.17},
      ]);
    }
    
    if (recipe.contains('chicken') || recipe.contains('poultry')) {
      suggestions.addAll([
        {'name': 'Chicken Breast', 'category': 'Meat', 'quantity': '1 lb', 'estimated_price': 746.17},
        {'name': 'Bread', 'category': 'Bakery', 'quantity': '1 loaf', 'estimated_price': 206.67},
        {'name': 'Whole Milk', 'category': 'Dairy', 'quantity': '1 gallon', 'estimated_price': 289.67},
        {'name': 'Tomatoes', 'category': 'Vegetables', 'quantity': '1 lb', 'estimated_price': 165.17},
      ]);
    }
    
    if (recipe.contains('salad') || recipe.contains('vegetable')) {
      suggestions.addAll([
        {'name': 'Tomatoes', 'category': 'Vegetables', 'quantity': '2 lb', 'estimated_price': 330.34},
        {'name': 'Organic Bananas', 'category': 'Fruits', 'quantity': '3 medium', 'estimated_price': 372.26},
        {'name': 'Whole Milk', 'category': 'Dairy', 'quantity': '1 gallon', 'estimated_price': 289.67},
        {'name': 'Bread', 'category': 'Bakery', 'quantity': '1 loaf', 'estimated_price': 206.67},
      ]);
    }

    // Add some basic staples
    if (suggestions.isEmpty) {
      suggestions.addAll([
        {'name': 'Organic Bananas', 'category': 'Fruits', 'quantity': '2 medium', 'estimated_price': 248.17},
        {'name': 'Whole Milk', 'category': 'Dairy', 'quantity': '1 gallon', 'estimated_price': 289.67},
        {'name': 'Bread', 'category': 'Bakery', 'quantity': '1 loaf', 'estimated_price': 206.67},
        {'name': 'Tomatoes', 'category': 'Vegetables', 'quantity': '1 lb', 'estimated_price': 165.17},
        {'name': 'Chicken Breast', 'category': 'Meat', 'quantity': '1 lb', 'estimated_price': 746.17},
      ]);
    }

    return suggestions;
  }

  List<Map<String, dynamic>> _applyDietaryRestrictions(List<Map<String, dynamic>> items, String dietary) {
    final restrictions = dietary.toLowerCase();
    final filteredItems = <Map<String, dynamic>>[];

    for (final item in items) {
      bool shouldInclude = true;

      if (restrictions.contains('vegetarian') || restrictions.contains('vegan')) {
        if (item['category'] == 'Meat' || item['name'].toString().toLowerCase().contains('chicken') ||
            item['name'].toString().toLowerCase().contains('beef') ||
            item['name'].toString().toLowerCase().contains('pork')) {
          shouldInclude = false;
        }
      }

      if (restrictions.contains('vegan')) {
        if (item['category'] == 'Dairy' || item['name'].toString().toLowerCase().contains('cheese') ||
            item['name'].toString().toLowerCase().contains('milk') ||
            item['name'].toString().toLowerCase().contains('yogurt') ||
            item['name'].toString().toLowerCase().contains('egg')) {
          shouldInclude = false;
        }
      }

      if (restrictions.contains('gluten-free')) {
        if (item['name'].toString().toLowerCase().contains('pasta') ||
            item['name'].toString().toLowerCase().contains('bread') ||
            item['name'].toString().toLowerCase().contains('flour')) {
          shouldInclude = false;
        }
      }

      if (shouldInclude) {
        filteredItems.add(item);
      }
    }

    return filteredItems;
  }

  Future<void> _addAllToShoppingList() async {
    final shoppingProvider = Provider.of<ShoppingProvider>(context, listen: false);
    
    try {
      // Get or create active shopping list
      ShoppingList? activeList = shoppingProvider.activeShoppingList;
      if (activeList == null) {
        await shoppingProvider.createShoppingList('Recipe Shopping List');
        activeList = shoppingProvider.activeShoppingList;
      }

      if (activeList != null) {
        // Add each suggested item to the shopping list
        for (final item in _suggestedItems) {
          // Find matching product in our sample data
          final product = _findMatchingProduct(item['name']);
          if (product != null) {
            await shoppingProvider.addToShoppingList(
              activeList.id,
              product.id,
              quantity: _parseQuantity(item['quantity']),
              notes: 'From recipe: ${_currentRecipe}',
            );
          }
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Added ${_suggestedItems.length} items to shopping list'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error adding items: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Product? _findMatchingProduct(String itemName) {
    // Use the same product data as the shopping provider
    final mockProducts = [
      Product(
        id: 1,
        name: 'Organic Bananas',
        description: 'Fresh organic bananas from local farms',
        category: 'Fruits',
        price: 248.17,
        brand: 'Fresh Farms',
        sku: 'BAN001',
        createdAt: DateTime.now(),
        inStock: true,
        averageRating: 4.5,
        reviewCount: 12,
      ),
      Product(
        id: 2,
        name: 'Whole Milk',
        description: 'Fresh whole milk, 1 gallon',
        category: 'Dairy',
        price: 289.67,
        brand: 'Dairy Fresh',
        sku: 'MIL002',
        createdAt: DateTime.now(),
        inStock: true,
        averageRating: 4.2,
        reviewCount: 8,
      ),
      Product(
        id: 3,
        name: 'Chicken Breast',
        description: 'Boneless, skinless chicken breast, 1 lb',
        category: 'Meat',
        price: 746.17,
        brand: 'Farm Fresh',
        sku: 'CHK003',
        createdAt: DateTime.now(),
        inStock: true,
        averageRating: 4.7,
        reviewCount: 15,
      ),
      Product(
        id: 4,
        name: 'Bread',
        description: 'Fresh whole wheat bread',
        category: 'Bakery',
        price: 206.67,
        brand: 'Bakery Fresh',
        sku: 'BRD004',
        createdAt: DateTime.now(),
        inStock: true,
        averageRating: 4.0,
        reviewCount: 6,
      ),
      Product(
        id: 5,
        name: 'Tomatoes',
        description: 'Fresh vine-ripened tomatoes, 1 lb',
        category: 'Vegetables',
        price: 165.17,
        brand: 'Garden Fresh',
        sku: 'TOM005',
        createdAt: DateTime.now(),
        inStock: true,
        averageRating: 4.3,
        reviewCount: 10,
      ),
    ];
    
    final searchName = itemName.toLowerCase();
    
    // Try exact match first
    for (final product in mockProducts) {
      if (product.name.toLowerCase() == searchName) {
        return product;
      }
    }
    
    // Try partial matches
    for (final product in mockProducts) {
      final productName = product.name.toLowerCase();
      if (productName.contains(searchName) || searchName.contains(productName)) {
        return product;
      }
    }
    
    // Try category matches for common items
    for (final product in mockProducts) {
      final productCategory = product.category?.toLowerCase() ?? '';
      if (searchName.contains(productCategory) || productCategory.contains(searchName)) {
        return product;
      }
    }
    
    // If no match found, return a default product (use the first one)
    return mockProducts.isNotEmpty ? mockProducts.first : null;
  }

  int _parseQuantity(String quantity) {
    // Simple quantity parsing
    final numbers = RegExp(r'\d+').allMatches(quantity);
    if (numbers.isNotEmpty) {
      return int.parse(numbers.first.group(0)!);
    }
    return 1;
  }

  void _selectRecipeFromHistory(String recipe) {
    _recipeController.text = recipe;
    _generateShoppingList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shopping Assistant'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Recipe Input Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'What would you like to cook?',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _recipeController,
                      decoration: const InputDecoration(
                        labelText: 'Recipe or Dish',
                        hintText: 'e.g., pasta carbonara, chicken stir fry',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _dietaryController,
                      decoration: const InputDecoration(
                        labelText: 'Dietary Restrictions (Optional)',
                        hintText: 'e.g., vegetarian, vegan, gluten-free',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _isGenerating ? null : _generateShoppingList,
                        icon: _isGenerating 
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.search),
                        label: Text(_isGenerating ? 'Generating...' : 'Generate Shopping List'),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Recipe History
            if (_recipeHistory.isNotEmpty) ...[
              const Text(
                'Recent Recipes',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _recipeHistory.map((recipe) => ActionChip(
                  label: Text(recipe),
                  onPressed: () => _selectRecipeFromHistory(recipe),
                )).toList(),
              ),
              const SizedBox(height: 16),
            ],

            // Results Section
            if (_suggestedItems.isNotEmpty) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Shopping List for: ${_currentRecipe ?? "Recipe"}',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                if (_currentDietary != null)
                                  Text(
                                    'Dietary: $_currentDietary',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 14,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          ElevatedButton.icon(
                            onPressed: _addAllToShoppingList,
                            icon: const Icon(Icons.shopping_cart),
                            label: const Text('Add All'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      ...(_suggestedItems.map((item) => Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: _getCategoryIcon(item['category']),
                          title: Text(item['name']),
                          subtitle: Text('${item['quantity']} • ${item['category']}'),
                          trailing: Text(
                            '₹${item['estimated_price'].toStringAsFixed(0)}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                          onTap: () async {
                            // Add single item to shopping list
                            final shoppingProvider = Provider.of<ShoppingProvider>(context, listen: false);
                            final activeList = shoppingProvider.activeShoppingList;
                            if (activeList != null) {
                              final product = _findMatchingProduct(item['name']);
                              if (product != null) {
                                await shoppingProvider.addToShoppingList(
                                  activeList.id,
                                  product.id,
                                  quantity: _parseQuantity(item['quantity']),
                                );
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Added ${item['name']} to shopping list')),
                                  );
                                }
                              }
                            }
                          },
                        ),
                      )).toList()),
                      const SizedBox(height: 8),
                      Text(
                        'Total Estimated Cost: ₹${_suggestedItems.fold<double>(0, (sum, item) => sum + (item['estimated_price'] as double)).toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],

            // Tips Section
            if (_suggestedItems.isNotEmpty) ...[
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Shopping Tips',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text('• Check for sales and coupons before shopping'),
                      const Text('• Buy seasonal produce for better prices'),
                      const Text('• Consider store brands for similar quality at lower cost'),
                      const Text('• Plan your route in the store to save time'),
                      const Text('• Bring reusable bags to reduce waste'),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _getCategoryIcon(String category) {
    IconData icon;
    Color color;

    switch (category.toLowerCase()) {
      case 'produce':
        icon = Icons.eco;
        color = Colors.green;
        break;
      case 'meat':
        icon = Icons.restaurant;
        color = Colors.red;
        break;
      case 'dairy':
        icon = Icons.local_drink;
        color = Colors.blue;
        break;
      case 'pantry':
        icon = Icons.inventory;
        color = Colors.orange;
        break;
      default:
        icon = Icons.shopping_basket;
        color = Colors.grey;
    }

    return CircleAvatar(
      backgroundColor: color.withOpacity(0.2),
      child: Icon(icon, color: color, size: 20),
    );
  }
} 