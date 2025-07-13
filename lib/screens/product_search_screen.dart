import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wallmart_store_map/models/product.dart';
import 'package:wallmart_store_map/providers/shopping_provider.dart';
import 'package:wallmart_store_map/services/api_service.dart';
import 'package:wallmart_store_map/screens/product_detail_screen.dart';

class ProductSearchScreen extends StatefulWidget {
  final Function(Product)? onProductSelected;

  const ProductSearchScreen({
    super.key,
    this.onProductSelected,
  });

  @override
  State<ProductSearchScreen> createState() => _ProductSearchScreenState();
}

class _ProductSearchScreenState extends State<ProductSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Product> _products = [];
  List<Product> _filteredProducts = [];
  bool _isLoading = false;
  String _selectedCategory = 'All';

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadProducts() async {
    setState(() {
      _isLoading = true;
    });

    // Load mock data directly for demo (no API calls)
    _loadMockProducts();
    setState(() {
      _isLoading = false;
    });
  }

  void _loadMockProducts() {
    final mockProducts = [
      Product(
        id: 1,
        name: 'Organic Bananas',
        description: 'Fresh organic bananas from local farms',
        category: 'Fruits',
        price: 248.17, // 2.99 USD * 83 INR
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
        price: 289.67, // 3.49 USD * 83 INR
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
        price: 746.17, // 8.99 USD * 83 INR
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
        price: 206.67, // 2.49 USD * 83 INR
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
        price: 165.17, // 1.99 USD * 83 INR
        brand: 'Garden Fresh',
        sku: 'TOM005',
        createdAt: DateTime.now(),
        inStock: true,
        averageRating: 4.3,
        reviewCount: 10,
      ),
    ];

    setState(() {
      _products = mockProducts;
      _filteredProducts = mockProducts;
    });
  }

  void _filterProducts() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredProducts = _products.where((product) {
        final matchesSearch = product.name.toLowerCase().contains(query) ||
            (product.description?.toLowerCase().contains(query) ?? false) ||
            (product.brand?.toLowerCase().contains(query) ?? false);
        
        final matchesCategory = _selectedCategory == 'All' ||
            product.category == _selectedCategory;
        
        return matchesSearch && matchesCategory;
      }).toList();
    });
  }

  List<String> get _categories {
    final categories = _products.map((p) => p.category).whereType<String>().toSet().toList();
    categories.sort();
    return ['All', ...categories];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Search'),
        elevation: 0,
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildCategoryFilter(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredProducts.isEmpty
                    ? _buildEmptyState()
                    : _buildProductList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search products...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    _filterProducts();
                  },
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          filled: true,
          fillColor: Colors.grey[100],
        ),
        onChanged: (value) => _filterProducts(),
      ),
    );
  }

  Widget _buildCategoryFilter() {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final category = _categories[index];
          final isSelected = category == _selectedCategory;
          
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(category),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _selectedCategory = category;
                });
                _filterProducts();
              },
              selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
              checkmarkColor: Theme.of(context).primaryColor,
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No products found',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your search terms or category filter',
            style: TextStyle(
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildProductList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _filteredProducts.length,
      itemBuilder: (context, index) {
        final product = _filteredProducts[index];
        return _buildProductCard(product);
      },
    );
  }

  Widget _buildProductCard(Product product) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _onProductTap(product),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Product Image
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: product.imageUrl != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          product.imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(Icons.image, color: Colors.grey);
                          },
                        ),
                      )
                    : const Icon(Icons.image, color: Colors.grey),
              ),
              const SizedBox(width: 16),
              
              // Product Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    if (product.brand != null) ...[
                      Text(
                        product.brand!,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 4),
                    ],
                    if (product.price != null) ...[
                      Text(
                        '₹${product.price!.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                      const SizedBox(height: 4),
                    ],
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (product.averageRating != null) ...[
                          Row(
                            children: [
                              Row(
                                children: List.generate(5, (index) {
                                  return Icon(
                                    index < product.averageRating!.floor()
                                        ? Icons.star
                                        : index < product.averageRating!
                                            ? Icons.star_half
                                            : Icons.star_border,
                                    color: Colors.amber,
                                    size: 16,
                                  );
                                }),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '(${product.reviewCount ?? 0})',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                        ],
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: product.inStock ? Colors.green[100] : Colors.red[100],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            product.inStock ? 'In Stock' : 'Out of Stock',
                            style: TextStyle(
                              color: product.inStock ? Colors.green[700] : Colors.red[700],
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              // Action Buttons
              Column(
                children: [
                  Consumer<ShoppingProvider>(
                    builder: (context, shoppingProvider, child) {
                      final isFavorite = shoppingProvider.isFavorite(product.id);
                      return IconButton(
                        icon: Icon(
                          isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: isFavorite ? Colors.red : Colors.grey,
                        ),
                        onPressed: () {
                          shoppingProvider.toggleFavorite(product.id);
                        },
                      );
                    },
                  ),
                  if (widget.onProductSelected != null)
                    IconButton(
                      icon: const Icon(Icons.add_shopping_cart),
                      onPressed: () => widget.onProductSelected!(product),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onProductTap(Product product) {
    if (widget.onProductSelected != null) {
      widget.onProductSelected!(product);
    } else {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => ProductDetailScreen(product: product),
        ),
      );
    }
  }
} 