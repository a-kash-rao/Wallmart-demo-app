import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:wallmart_store_map/models/location.dart';
import 'package:wallmart_store_map/models/product.dart';
import 'package:wallmart_store_map/models/shopping_list.dart';
import 'package:flutter/foundation.dart'; // Added for debugPrint

class ApiService {
  static const String baseUrl = 'http://10.0.2.2:5000/api'; // For Android emulator
  // static const String baseUrl = 'http://localhost:5000/api'; // For iOS simulator
  // static const String baseUrl = 'http://your-server-ip:5000/api'; // For physical device

  // Headers
  static Map<String, String> get _headers => {
    'Content-Type': 'application/json',
  };

  // Products API
  static Future<List<Product>> getProducts() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/products'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Product.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load products: ${response.statusCode}');
      }
    } catch (e) {
      // Return mock data for demo purposes when API is not available
      debugPrint('API not available, using mock data: $e');
      return _getMockProducts();
    }
  }

  static Future<Product> getProduct(int id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/products/$id'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return Product.fromJson(data);
      } else {
        throw Exception('Failed to load product: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  static Future<List<Product>> searchProducts(String query) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/products/search/$query'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Product.fromJson(json)).toList();
      } else {
        throw Exception('Failed to search products: ${response.statusCode}');
      }
    } catch (e) {
      // Return filtered mock data for demo purposes when API is not available
      debugPrint('Search API not available, using mock data: $e');
      final mockProducts = _getMockProducts();
      return mockProducts.where((product) => 
        product.name.toLowerCase().contains(query.toLowerCase()) ||
        (product.description?.toLowerCase().contains(query.toLowerCase()) ?? false) ||
        (product.brand?.toLowerCase().contains(query.toLowerCase()) ?? false) ||
        (product.category?.toLowerCase().contains(query.toLowerCase()) ?? false)
      ).toList();
    }
  }

  static Future<Product> addProduct(Product product) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/products'),
        headers: _headers,
        body: json.encode(product.toJson()),
      );

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        return Product.fromJson(data);
      } else {
        throw Exception('Failed to add product: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  static Future<Product> updateProduct(Product product) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/products/${product.id}'),
        headers: _headers,
        body: json.encode(product.toJson()),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return Product.fromJson(data);
      } else {
        throw Exception('Failed to update product: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  static Future<void> deleteProduct(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/products/$id'),
        headers: _headers,
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to delete product: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Locations API
  static Future<List<Location>> getLocations() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/locations'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Location.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load locations: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  static Future<Location> getLocation(int id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/locations/$id'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return Location.fromJson(data);
      } else {
        throw Exception('Failed to load location: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  static Future<Location> getLocationByQR(String qrCode) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/locations/qr/$qrCode'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return Location.fromJson(data);
      } else {
        throw Exception('Failed to load location: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  static Future<Location> addLocation(Location location) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/locations'),
        headers: _headers,
        body: json.encode(location.toJson()),
      );

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        return Location.fromJson(data);
      } else {
        throw Exception('Failed to add location: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  static Future<Location> updateLocation(Location location) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/locations/${location.id}'),
        headers: _headers,
        body: json.encode(location.toJson()),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return Location.fromJson(data);
      } else {
        throw Exception('Failed to update location: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  static Future<void> deleteLocation(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/locations/$id'),
        headers: _headers,
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to delete location: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // QR Code API
  static Future<Map<String, dynamic>> generateQRCode(String qrCode) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/qr/generate/$qrCode'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to generate QR code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  static Future<Map<String, dynamic>> decodeQRCode(String qrData) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/qr/decode'),
        headers: _headers,
        body: json.encode({'qrData': qrData}),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to decode QR code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Store API
  static Future<Map<String, dynamic>> getStoreLayout() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/store/layout'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load store layout: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  static Future<Map<String, dynamic>> getStoreOverview() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/store/overview'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load store overview: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Shopping Lists API
  static Future<List<ShoppingList>> getShoppingLists() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/shopping-lists'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => ShoppingList.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load shopping lists: ${response.statusCode}');
      }
    } catch (e) {
      // Return empty list if backend is not available (for demo purposes)
      return [];
    }
  }

  static Future<ShoppingList> createShoppingList(String name, {String? description}) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/shopping-lists'),
        headers: _headers,
        body: json.encode({
          'name': name,
          'description': description,
        }),
      );

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        return ShoppingList.fromJson(data);
      } else {
        throw Exception('Failed to create shopping list: ${response.statusCode}');
      }
    } catch (e) {
      // Throw exception so ShoppingProvider can create local list
      throw Exception('API not available: $e');
    }
  }

  static Future<ShoppingListItem> addToShoppingList(int listId, int productId, int quantity, String? notes) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/shopping-lists/$listId/items'),
        headers: _headers,
        body: json.encode({
          'product_id': productId,
          'quantity': quantity,
          'notes': notes,
        }),
      );

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        return ShoppingListItem.fromJson(data);
      } else {
        throw Exception('Failed to add item to shopping list: ${response.statusCode}');
      }
    } catch (e) {
      // Throw exception so ShoppingProvider can create local item
      throw Exception('API not available: $e');
    }
  }

  static Future<void> removeFromShoppingList(int listId, int itemId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/shopping-lists/$listId/items/$itemId'),
        headers: _headers,
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to remove item from shopping list: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  static Future<void> toggleShoppingListItem(int listId, int itemId) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/shopping-lists/$listId/items/$itemId/toggle'),
        headers: _headers,
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to toggle item: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  static Future<void> completeShoppingList(int listId) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/shopping-lists/$listId/complete'),
        headers: _headers,
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to complete shopping list: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  static Future<void> deleteShoppingList(int listId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/shopping-lists/$listId'),
        headers: _headers,
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to delete shopping list: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Mock data for demo purposes
  static List<Product> _getMockProducts() {
    return [
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
    ];
  }
} 