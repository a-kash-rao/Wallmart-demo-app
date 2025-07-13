import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wallmart_store_map/models/product.dart';
import 'package:wallmart_store_map/models/product_review.dart';
import 'package:wallmart_store_map/providers/shopping_provider.dart';
import 'package:wallmart_store_map/services/api_service.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;

  const ProductDetailScreen({
    super.key,
    required this.product,
  });

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<ProductReview> _reviews = [];
  ProductRating? _rating;
  bool _isLoadingReviews = false;
  bool _isAddingToCart = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadReviews();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadReviews() async {
    setState(() {
      _isLoadingReviews = true;
    });

    try {
      // Mock data for now - replace with actual API calls
      await Future.delayed(const Duration(milliseconds: 500));
      _reviews = _createMockReviews();
      _rating = _createMockRating();
    } catch (e) {
      // Handle error
    } finally {
      setState(() {
        _isLoadingReviews = false;
      });
    }
  }

  List<ProductReview> _createMockReviews() {
    return [
      ProductReview(
        id: 1,
        productId: widget.product.id,
        userName: 'John D.',
        rating: 5,
        comment: 'Great product! Exactly what I was looking for. The quality is excellent and the price is reasonable.',
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        isVerified: true,
      ),
      ProductReview(
        id: 2,
        productId: widget.product.id,
        userName: 'Sarah M.',
        rating: 4,
        comment: 'Good product overall. Fast delivery and good packaging. Would recommend.',
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
        isVerified: true,
      ),
      ProductReview(
        id: 3,
        productId: widget.product.id,
        userName: 'Mike R.',
        rating: 3,
        comment: 'Product is okay, but could be better. The instructions were a bit unclear.',
        createdAt: DateTime.now().subtract(const Duration(days: 7)),
        isVerified: false,
      ),
    ];
  }

  ProductRating _createMockRating() {
    return ProductRating(
      productId: widget.product.id,
      averageRating: 4.0,
      totalReviews: 3,
      ratingDistribution: {
        1: 0,
        2: 0,
        3: 1,
        4: 1,
        5: 1,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildAppBar(),
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildProductImage(),
                _buildProductInfo(),
                _buildRatingSection(),
                _buildTabBar(),
                _buildTabBarView(),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        background: widget.product.imageUrl != null
            ? Image.network(
                widget.product.imageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey[300],
                    child: const Icon(Icons.image, size: 80, color: Colors.grey),
                  );
                },
              )
            : Container(
                color: Colors.grey[300],
                child: const Icon(Icons.image, size: 80, color: Colors.grey),
              ),
      ),
      actions: [
        Consumer<ShoppingProvider>(
          builder: (context, shoppingProvider, child) {
            final isFavorite = shoppingProvider.isFavorite(widget.product.id);
            return IconButton(
              icon: Icon(
                isFavorite ? Icons.favorite : Icons.favorite_border,
                color: isFavorite ? Colors.red : null,
              ),
              onPressed: () {
                shoppingProvider.toggleFavorite(widget.product.id);
              },
            );
          },
        ),
        IconButton(
          icon: const Icon(Icons.share),
          onPressed: _shareProduct,
        ),
      ],
    );
  }

  Widget _buildProductImage() {
    return Container(
      height: 200,
      width: double.infinity,
      color: Colors.grey[100],
      child: widget.product.imageUrl != null
          ? Image.network(
              widget.product.imageUrl!,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return const Center(
                  child: Icon(Icons.image, size: 80, color: Colors.grey),
                );
              },
            )
          : const Center(
              child: Icon(Icons.image, size: 80, color: Colors.grey),
            ),
    );
  }

  Widget _buildProductInfo() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.product.name,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          if (widget.product.brand != null) ...[
            Text(
              'Brand: ${widget.product.brand}',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
          ],
          if (widget.product.price != null) ...[
            Text(
                      '₹${widget.product.price!.toStringAsFixed(0)}',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 8),
          ],
          if (widget.product.description != null) ...[
            Text(
              widget.product.description!,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
          ],
          if (widget.product.category != null) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                widget.product.category!,
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
          if (widget.product.sku != null) ...[
            Text(
              'SKU: ${widget.product.sku}',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
          ],
          Row(
            children: [
              Icon(
                widget.product.inStock ? Icons.check_circle : Icons.cancel,
                color: widget.product.inStock ? Colors.green : Colors.red,
              ),
              const SizedBox(width: 8),
              Text(
                widget.product.inStock ? 'In Stock' : 'Out of Stock',
                style: TextStyle(
                  color: widget.product.inStock ? Colors.green : Colors.red,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRatingSection() {
    if (_rating == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Column(
                children: [
                  Text(
                    _rating!.averageRating.toStringAsFixed(1),
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Row(
                    children: List.generate(5, (index) {
                      return Icon(
                        index < _rating!.averageRating.floor()
                            ? Icons.star
                            : index < _rating!.averageRating
                                ? Icons.star_half
                                : Icons.star_border,
                        color: Colors.amber,
                        size: 20,
                      );
                    }),
                  ),
                  Text(
                    '${_rating!.totalReviews} reviews',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 24),
              Expanded(
                child: Column(
                  children: List.generate(5, (index) {
                    final rating = 5 - index;
                    final count = _rating!.getRatingCount(rating);
                    final percentage = _rating!.getRatingPercentage(rating);
                    
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        children: [
                          Text(
                            '$rating',
                            style: const TextStyle(fontSize: 12),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: LinearProgressIndicator(
                              value: percentage / 100,
                              backgroundColor: Colors.grey[300],
                              valueColor: const AlwaysStoppedAnimation<Color>(Colors.amber),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '$count',
                            style: const TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    );
                  }),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      color: Colors.white,
      child: TabBar(
        controller: _tabController,
        labelColor: Theme.of(context).primaryColor,
        unselectedLabelColor: Colors.grey,
        indicatorColor: Theme.of(context).primaryColor,
        tabs: const [
          Tab(text: 'Details'),
          Tab(text: 'Reviews'),
          Tab(text: 'Location'),
        ],
      ),
    );
  }

  Widget _buildTabBarView() {
    return SizedBox(
      height: 400,
      child: TabBarView(
        controller: _tabController,
        children: [
          _buildDetailsTab(),
          _buildReviewsTab(),
          _buildLocationTab(),
        ],
      ),
    );
  }

  Widget _buildDetailsTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Product Details',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildDetailRow('Product ID', widget.product.id.toString()),
          _buildDetailRow('Category', widget.product.category ?? 'N/A'),
          _buildDetailRow('Brand', widget.product.brand ?? 'N/A'),
          _buildDetailRow('SKU', widget.product.sku ?? 'N/A'),
          _buildDetailRow('Price', widget.product.price != null ? '₹${widget.product.price!.toStringAsFixed(0)}' : 'N/A'),
          _buildDetailRow('Stock Status', widget.product.inStock ? 'In Stock' : 'Out of Stock'),
          _buildDetailRow('Added', _formatDate(widget.product.createdAt)),
          if (widget.product.description != null) ...[
            const SizedBox(height: 16),
            const Text(
              'Description',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(widget.product.description!),
          ],
        ],
      ),
    );
  }

  Widget _buildReviewsTab() {
    if (_isLoadingReviews) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_reviews.isEmpty) {
      return const Center(
        child: Text('No reviews yet'),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _reviews.length,
      itemBuilder: (context, index) {
        final review = _reviews[index];
        return _buildReviewCard(review);
      },
    );
  }

  Widget _buildLocationTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Product Location',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          if (widget.product.sectionName != null) ...[
            _buildDetailRow('Section', widget.product.sectionName!),
            const SizedBox(height: 8),
          ],
          if (widget.product.locationDescription != null) ...[
            _buildDetailRow('Location', widget.product.locationDescription!),
            const SizedBox(height: 8),
          ],
          if (widget.product.xCoordinate != null && widget.product.yCoordinate != null) ...[
            _buildDetailRow('Coordinates', 'X: ${widget.product.xCoordinate}, Y: ${widget.product.yCoordinate}'),
            const SizedBox(height: 16),
          ],
          if (widget.product.qrCode != null) ...[
            const Text(
              'QR Code',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.qr_code, size: 40, color: Colors.grey[600]),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Scan this QR code',
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                        Text(
                          'Code: ${widget.product.qrCode}',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewCard(ProductReview review) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: Colors.grey[300],
                  child: Text(
                    review.userName[0].toUpperCase(),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            review.userName,
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                          if (review.isVerified) ...[
                            const SizedBox(width: 8),
                            Icon(Icons.verified, size: 16, color: Colors.blue),
                          ],
                        ],
                      ),
                      Text(
                        review.timeAgo,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: List.generate(5, (index) {
                    return Icon(
                      index < review.rating ? Icons.star : Icons.star_border,
                      color: Colors.amber,
                      size: 16,
                    );
                  }),
                ),
              ],
            ),
            if (review.comment != null && review.comment!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(review.comment!),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _isAddingToCart ? null : _addToShoppingList,
                icon: _isAddingToCart
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.shopping_cart),
                label: Text(_isAddingToCart ? 'Adding...' : 'Add to List'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            const SizedBox(width: 12),
            ElevatedButton.icon(
              onPressed: _findInStore,
              icon: const Icon(Icons.location_on),
              label: const Text('Find'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[600],
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _shareProduct() {
    // TODO: Implement share functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Share functionality coming soon!')),
    );
  }

  Future<void> _addToShoppingList() async {
    setState(() {
      _isAddingToCart = true;
    });

    try {
      final shoppingProvider = context.read<ShoppingProvider>();
      final activeList = shoppingProvider.activeShoppingList;
      
      if (activeList == null) {
        // Create a new shopping list
        await shoppingProvider.createShoppingList('My Shopping List');
        final newActiveList = shoppingProvider.activeShoppingList;
        if (newActiveList != null) {
          await shoppingProvider.addToShoppingList(
            newActiveList.id,
            widget.product.id,
            quantity: 1,
          );
        }
      } else {
        await shoppingProvider.addToShoppingList(
          activeList.id,
          widget.product.id,
          quantity: 1,
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Product added to shopping list!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add product: $e')),
        );
      }
    } finally {
      setState(() {
        _isAddingToCart = false;
      });
    }
  }

  void _findInStore() {
    // TODO: Navigate to store map with product location highlighted
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Navigate to product location')),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
} 