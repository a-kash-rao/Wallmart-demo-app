import 'package:flutter/foundation.dart';
import 'package:wallmart_store_map/models/location.dart';
import 'package:wallmart_store_map/models/product.dart';
import 'package:wallmart_store_map/services/api_service.dart';

class AppState extends ChangeNotifier {
  Location? _currentLocation;
  List<Product> _products = [];
  List<Location> _locations = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  Location? get currentLocation => _currentLocation;
  List<Product> get products => _products;
  List<Location> get locations => _locations;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Set current location
  void setCurrentLocation(Location location) {
    _currentLocation = location;
    notifyListeners();
  }

  // Clear current location
  void clearCurrentLocation() {
    _currentLocation = null;
    notifyListeners();
  }

  // Load products
  Future<void> loadProducts() async {
    _setLoading(true);
    try {
      final products = await ApiService.getProducts();
      _products = products;
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  // Load locations
  Future<void> loadLocations() async {
    _setLoading(true);
    try {
      final locations = await ApiService.getLocations();
      _locations = locations;
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  // Search products
  Future<void> searchProducts(String query) async {
    _setLoading(true);
    try {
      final products = await ApiService.searchProducts(query);
      _products = products;
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  // Get products by category
  List<Product> getProductsByCategory(String category) {
    return _products.where((product) => product.category == category).toList();
  }

  // Get products at location
  List<Product> getProductsAtLocation(int locationId) {
    return _products.where((product) => product.locationId == locationId).toList();
  }

  // Get locations by section
  List<Location> getLocationsBySection(String section) {
    return _locations.where((location) => location.sectionName == section).toList();
  }

  // Add product
  Future<void> addProduct(Product product) async {
    _setLoading(true);
    try {
      final newProduct = await ApiService.addProduct(product);
      _products.add(newProduct);
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  // Add location
  Future<void> addLocation(Location location) async {
    _setLoading(true);
    try {
      final newLocation = await ApiService.addLocation(location);
      _locations.add(newLocation);
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  // Update product
  Future<void> updateProduct(Product product) async {
    _setLoading(true);
    try {
      final updatedProduct = await ApiService.updateProduct(product);
      final index = _products.indexWhere((p) => p.id == product.id);
      if (index != -1) {
        _products[index] = updatedProduct;
      }
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  // Delete product
  Future<void> deleteProduct(int productId) async {
    _setLoading(true);
    try {
      await ApiService.deleteProduct(productId);
      _products.removeWhere((product) => product.id == productId);
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  // Delete location
  Future<void> deleteLocation(int locationId) async {
    _setLoading(true);
    try {
      await ApiService.deleteLocation(locationId);
      _locations.removeWhere((location) => location.id == locationId);
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Set loading state
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // Initialize app data
  Future<void> initialize() async {
    await Future.wait([
      loadProducts(),
      loadLocations(),
    ]);
  }
} 