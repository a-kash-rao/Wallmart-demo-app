import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wallmart_store_map/models/shopping_list.dart';
import 'package:wallmart_store_map/models/product.dart';
import 'package:wallmart_store_map/services/api_service.dart';

class ShoppingProvider extends ChangeNotifier {
  List<ShoppingList> _shoppingLists = [];
  List<int> _favoriteProductIds = [];
  bool _isDarkMode = false;
  bool _notificationsEnabled = true;
  String _userName = 'Guest';
  
  // Getters
  List<ShoppingList> get shoppingLists => _shoppingLists;
  List<int> get favoriteProductIds => _favoriteProductIds;
  bool get isDarkMode => _isDarkMode;
  bool get notificationsEnabled => _notificationsEnabled;
  String get userName => _userName;
  
  ShoppingList? get activeShoppingList => 
      _shoppingLists.where((list) => !list.isCompleted).firstOrNull;

  // Initialize provider
  Future<void> initialize() async {
    await _loadPreferences();
    await _loadShoppingLists();
    await _loadFavorites();
  }

  // Load user preferences from SharedPreferences
  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool('isDarkMode') ?? false;
    _notificationsEnabled = prefs.getBool('notificationsEnabled') ?? true;
    _userName = prefs.getString('userName') ?? 'Guest';
    notifyListeners();
  }

  // Save user preferences
  Future<void> _savePreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', _isDarkMode);
    await prefs.setBool('notificationsEnabled', _notificationsEnabled);
    await prefs.setString('userName', _userName);
  }

  // Load shopping lists from API
  Future<void> _loadShoppingLists() async {
    // For demo purposes, start with empty list (no API calls)
    _shoppingLists = [];
    notifyListeners();
  }

  // Load favorites from SharedPreferences
  Future<void> _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final favorites = prefs.getStringList('favoriteProductIds') ?? [];
    _favoriteProductIds = favorites.map((id) => int.parse(id)).toList();
    notifyListeners();
  }

  // Save favorites to SharedPreferences
  Future<void> _saveFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final favorites = _favoriteProductIds.map((id) => id.toString()).toList();
    await prefs.setStringList('favoriteProductIds', favorites);
  }

  // Toggle dark mode
  Future<void> toggleDarkMode() async {
    _isDarkMode = !_isDarkMode;
    await _savePreferences();
    notifyListeners();
  }

  // Toggle notifications
  Future<void> toggleNotifications() async {
    _notificationsEnabled = !_notificationsEnabled;
    await _savePreferences();
    notifyListeners();
  }

  // Update user name
  Future<void> updateUserName(String name) async {
    _userName = name;
    await _savePreferences();
    notifyListeners();
  }

  // Toggle product favorite
  Future<void> toggleFavorite(int productId) async {
    if (_favoriteProductIds.contains(productId)) {
      _favoriteProductIds.remove(productId);
    } else {
      _favoriteProductIds.add(productId);
    }
    await _saveFavorites();
    notifyListeners();
  }

  // Check if product is favorite
  bool isFavorite(int productId) {
    return _favoriteProductIds.contains(productId);
  }

  // Create new shopping list
  Future<void> createShoppingList(String name, {String? description}) async {
    // Create a local shopping list directly (no API calls for demo)
    final localList = ShoppingList(
      id: DateTime.now().millisecondsSinceEpoch,
      name: name,
      description: description,
      items: [],
      isCompleted: false,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    _shoppingLists.add(localList);
    notifyListeners();
  }

  // Add product to shopping list
  Future<void> addToShoppingList(int listId, int productId, {int quantity = 1, String? notes}) async {
    // Create a local shopping list item directly (no API calls for demo)
    final listIndex = _shoppingLists.indexWhere((list) => list.id == listId);
    if (listIndex != -1) {
      // Get product details from mock data
      final product = _getProductById(productId);
      final localItem = ShoppingListItem(
        id: DateTime.now().millisecondsSinceEpoch,
        shoppingListId: listId,
        productId: productId,
        productName: product?.name ?? 'Unknown Product',
        productPrice: product?.price,
        quantity: quantity,
        notes: notes,
        isCompleted: false,
        createdAt: DateTime.now(),
      );
      final updatedList = _shoppingLists[listIndex].copyWith(
        items: [..._shoppingLists[listIndex].items, localItem],
      );
      _shoppingLists[listIndex] = updatedList;
      notifyListeners();
    }
  }

  // Helper method to get product by ID from mock data
  Product? _getProductById(int productId) {
    // Mock product data - in a real app, this would come from a database or API
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
    
    try {
      return mockProducts.firstWhere((product) => product.id == productId);
    } catch (e) {
      return null;
    }
  }

  // Remove product from shopping list
  Future<void> removeFromShoppingList(int listId, int itemId) async {
    // Remove item locally (no API calls for demo)
    final listIndex = _shoppingLists.indexWhere((list) => list.id == listId);
    if (listIndex != -1) {
      final updatedItems = _shoppingLists[listIndex].items
          .where((item) => item.id != itemId)
          .toList();
      final updatedList = _shoppingLists[listIndex].copyWith(items: updatedItems);
      _shoppingLists[listIndex] = updatedList;
      notifyListeners();
    }
  }

  // Toggle item completion in shopping list
  Future<void> toggleItemCompletion(int listId, int itemId) async {
    // Toggle item locally (no API calls for demo)
    final listIndex = _shoppingLists.indexWhere((list) => list.id == listId);
    if (listIndex != -1) {
      final updatedItems = _shoppingLists[listIndex].items.map((item) {
        if (item.id == itemId) {
          return item.copyWith(isCompleted: !item.isCompleted);
        }
        return item;
      }).toList();
      final updatedList = _shoppingLists[listIndex].copyWith(items: updatedItems);
      _shoppingLists[listIndex] = updatedList;
      notifyListeners();
    }
  }

  // Complete shopping list
  Future<void> completeShoppingList(int listId) async {
    // Complete list locally (no API calls for demo)
    final listIndex = _shoppingLists.indexWhere((list) => list.id == listId);
    if (listIndex != -1) {
      final updatedList = _shoppingLists[listIndex].copyWith(
        isCompleted: true,
        updatedAt: DateTime.now(),
      );
      _shoppingLists[listIndex] = updatedList;
      notifyListeners();
    }
  }

  // Delete shopping list
  Future<void> deleteShoppingList(int listId) async {
    // Delete list locally (no API calls for demo)
    _shoppingLists.removeWhere((list) => list.id == listId);
    notifyListeners();
  }

  // Get shopping list by ID
  ShoppingList? getShoppingList(int listId) {
    try {
      return _shoppingLists.firstWhere((list) => list.id == listId);
    } catch (e) {
      return null;
    }
  }

  // Get completed shopping lists
  List<ShoppingList> get completedShoppingLists => 
      _shoppingLists.where((list) => list.isCompleted).toList();

  // Get active shopping lists
  List<ShoppingList> get activeShoppingLists => 
      _shoppingLists.where((list) => !list.isCompleted).toList();

  // Clear all data (for testing or logout)
  Future<void> clearAllData() async {
    _shoppingLists.clear();
    _favoriteProductIds.clear();
    await _saveFavorites();
    notifyListeners();
  }
} 