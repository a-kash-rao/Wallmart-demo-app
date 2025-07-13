import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wallmart_store_map/models/store_map.dart';
import 'package:wallmart_store_map/models/product.dart';
import 'package:wallmart_store_map/data/sample_store_map.dart';
import 'package:wallmart_store_map/providers/app_state.dart';
import 'package:wallmart_store_map/providers/shopping_provider.dart';
import 'package:wallmart_store_map/screens/product_detail_screen.dart';

class StoreMapScreen extends StatefulWidget {
  const StoreMapScreen({super.key});

  @override
  State<StoreMapScreen> createState() => _StoreMapScreenState();
}

class _StoreMapScreenState extends State<StoreMapScreen> {
  late StoreMap _storeMap;
  int _currentFloor = 0;

  Product? _selectedProduct;
  Set<int> _shoppingListProductIds = {};

  @override
  void initState() {
    super.initState();
    _storeMap = SampleStoreMap.createSampleMap();

    _loadShoppingListProducts();
  }

  void _loadShoppingListProducts() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final shoppingProvider = context.read<ShoppingProvider>();
      final activeList = shoppingProvider.activeShoppingList;
      if (activeList != null) {
        setState(() {
          _shoppingListProductIds = activeList.items
              .map((item) => item.productId)
              .toSet();
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentFloor = _storeMap.getFloor(_currentFloor);
    
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Store Map',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,

      ),
      body: Column(
        children: [
          _buildFloorSelector(),
          Expanded(
            child: currentFloor != null
                ? _buildFloorMap(currentFloor)
                : const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.map_outlined, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          'Floor not found',
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
          ),
          if (_selectedProduct != null) _buildProductInfo(),
        ],
      ),
    );
  }

  Widget _buildFloorSelector() {
    return Container(
      height: 80,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Select Floor',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _storeMap.floors.length,
              itemBuilder: (context, index) {
                final floor = _storeMap.floors[index];
                final isSelected = floor.floorNumber == _currentFloor;
                
                return Container(
                  margin: const EdgeInsets.only(right: 12),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          _currentFloor = floor.floorNumber;
                          
                        });
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.blue[600] : Colors.grey[100],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected ? Colors.blue[600]! : Colors.grey[300]!,
                            width: 2,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.layers,
                              size: 16,
                              color: isSelected ? Colors.white : Colors.grey[600],
                            ),
                            const SizedBox(width: 8),
                            Text(
                              floor.name,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: isSelected ? Colors.white : Colors.grey[700],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloorMap(Floor floor) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SingleChildScrollView(
            child: SizedBox(
              width: floor.width.toDouble() * 4, // Increased scale for better visibility
              height: floor.height.toDouble() * 4,
              child: Stack(
                children: [
                  // Floor background
                  Container(
                    width: double.infinity,
                    height: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      border: Border.all(color: Colors.grey[200]!, width: 1),
                    ),
                  ),
                  // Sections
                  ...floor.sections.map((section) => _buildSection(section)),
                  // Landmarks
                  ...floor.landmarks.map((landmark) => _buildLandmark(landmark)),
                  // Product locations
                  ...floor.sections
                      .expand((section) => section.locations)
                      .map((location) => _buildProductLocation(location)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSection(Section section) {
    return Positioned(
      left: section.x.toDouble() * 4,
      top: section.y.toDouble() * 4,
      child: Container(
        width: section.width.toDouble() * 4,
        height: section.height.toDouble() * 4,
        decoration: BoxDecoration(
          color: _parseColor(section.color).withOpacity(0.15),
          border: Border.all(
            color: _parseColor(section.color).withOpacity(0.8),
            width: 3,
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: _parseColor(section.color).withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: _parseColor(section.color).withOpacity(0.9),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              section.name,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLandmark(MapPoint landmark) {
    IconData icon;
    Color color;
    String label;
    
    switch (landmark.type) {
      case 'entrance':
        icon = Icons.door_front_door;
        color = Colors.green[600]!;
        label = 'Entrance';
        break;
      case 'exit':
        icon = Icons.exit_to_app;
        color = Colors.red[600]!;
        label = 'Exit';
        break;
      case 'elevator':
        icon = Icons.elevator;
        color = Colors.blue[600]!;
        label = 'Elevator';
        break;
      case 'stairs':
        icon = Icons.stairs;
        color = Colors.orange[600]!;
        label = 'Stairs';
        break;
      case 'escalator':
        icon = Icons.escalator;
        color = Colors.purple[600]!;
        label = 'Escalator';
        break;
      case 'restroom':
        icon = Icons.wc;
        color = Colors.teal[600]!;
        label = 'Restroom';
        break;
      case 'service':
        icon = Icons.help;
        color = Colors.indigo[600]!;
        label = 'Service';
        break;
      default:
        icon = Icons.place;
        color = Colors.grey[600]!;
        label = 'Landmark';
    }

    return Positioned(
      left: landmark.x.toDouble() * 4 - 20,
      top: landmark.y.toDouble() * 4 - 20,
      child: Column(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 3),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.4),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              icon,
              size: 20,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.black87,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 10,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }



  Widget _buildProductLocation(ProductLocation location) {
    if (location.product == null) return const SizedBox.shrink();
    
    // Check if this product is in shopping list
    final isInShoppingList = _shoppingListProductIds.contains(location.product!.id);
    
    return Positioned(
      left: location.x.toDouble() * 4 - 12,
      top: location.y.toDouble() * 4 - 12,
      child: GestureDetector(
        onTap: () => _showProductDetails(location.product!),
        child: Column(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: isInShoppingList ? Colors.green[600]! : Colors.blue[600]!,
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white,
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: (isInShoppingList ? Colors.green : Colors.blue).withOpacity(0.4),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                isInShoppingList ? Icons.shopping_cart : Icons.shopping_bag,
                size: 12,
                color: Colors.white,
              ),
            ),
            if (isInShoppingList) ...[
              const SizedBox(height: 2),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                decoration: BoxDecoration(
                  color: Colors.green[600],
                  borderRadius: BorderRadius.circular(2),
                ),
                child: const Text(
                  '✓',
                  style: TextStyle(
                    fontSize: 8,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildProductInfo() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.shopping_bag,
                  size: 30,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _selectedProduct!.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    if (_selectedProduct!.price != null)
                      Text(
                        '₹${_selectedProduct!.price!.toStringAsFixed(0)}',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.green[700],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    const SizedBox(height: 8),
                    if (_shoppingListProductIds.contains(_selectedProduct!.id))
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.green[50],
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.green[200]!),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.check_circle,
                              size: 16,
                              color: Colors.green[700],
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'In Shopping List',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.green[700],
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              ElevatedButton.icon(
                onPressed: () => _showProductDetails(_selectedProduct!),
                icon: const Icon(Icons.visibility),
                label: const Text('View'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[600],
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _parseColor(String? colorString) {
    if (colorString == null) return Colors.grey;
    try {
      return Color(int.parse(colorString.replaceAll('#', '0xFF')));
    } catch (e) {
      return Colors.grey;
    }
  }



  void _showProductDetails(Product product) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ProductDetailScreen(product: product),
      ),
    );
  }
} 