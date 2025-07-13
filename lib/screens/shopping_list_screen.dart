import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wallmart_store_map/providers/shopping_provider.dart';
import 'package:wallmart_store_map/models/shopping_list.dart';
import 'package:wallmart_store_map/screens/product_search_screen.dart';

class ShoppingListScreen extends StatefulWidget {
  const ShoppingListScreen({super.key});

  @override
  State<ShoppingListScreen> createState() => _ShoppingListScreenState();
}

class _ShoppingListScreenState extends State<ShoppingListScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Initialize provider only once
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<ShoppingProvider>();
      // Only initialize if not already done
      if (provider.shoppingLists.isEmpty) {
        provider.initialize();
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shopping Lists'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showCreateListDialog,
          ),
        ],
      ),
      body: Consumer<ShoppingProvider>(
        builder: (context, shoppingProvider, child) {
          if (shoppingProvider.shoppingLists.isEmpty) {
            return _buildEmptyState();
          }

          return DefaultTabController(
            length: 2,
            child: Column(
              children: [
                const TabBar(
                  tabs: [
                    Tab(text: 'Active Lists'),
                    Tab(text: 'Completed Lists'),
                  ],
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      _buildActiveLists(shoppingProvider),
                      _buildCompletedLists(shoppingProvider),
                    ],
                  ),
                ),
              ],
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
            Icons.shopping_cart_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No shopping lists yet',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Create your first shopping list to get started',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _showCreateListDialog,
            icon: const Icon(Icons.add),
            label: const Text('Create Shopping List'),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveLists(ShoppingProvider shoppingProvider) {
    final activeLists = shoppingProvider.activeShoppingLists;
    
    if (activeLists.isEmpty) {
      return const Center(
        child: Text('No active shopping lists'),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: activeLists.length,
      itemBuilder: (context, index) {
        final list = activeLists[index];
        return _buildShoppingListCard(list, shoppingProvider);
      },
    );
  }

  Widget _buildCompletedLists(ShoppingProvider shoppingProvider) {
    final completedLists = shoppingProvider.completedShoppingLists;
    
    if (completedLists.isEmpty) {
      return const Center(
        child: Text('No completed shopping lists'),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: completedLists.length,
      itemBuilder: (context, index) {
        final list = completedLists[index];
        return _buildShoppingListCard(list, shoppingProvider);
      },
    );
  }

  Widget _buildShoppingListCard(ShoppingList list, ShoppingProvider shoppingProvider) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () => _showListDetails(list),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          list.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (list.description != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            list.description!,
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (!list.isCompleted) ...[
                    IconButton(
                      icon: const Icon(Icons.add_shopping_cart),
                      onPressed: () => _showAddItemDialog(list),
                    ),
                    IconButton(
                      icon: const Icon(Icons.check_circle_outline),
                      onPressed: () => _completeList(list, shoppingProvider),
                    ),
                  ],
                  PopupMenuButton<String>(
                    onSelected: (value) => _handleMenuAction(value, list, shoppingProvider),
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit),
                            SizedBox(width: 8),
                            Text('Edit'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Delete', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${list.completedItemsCount}/${list.totalItemsCount} items completed',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        LinearProgressIndicator(
                          value: list.completionPercentage / 100,
                          backgroundColor: Colors.grey[300],
                          valueColor: AlwaysStoppedAnimation<Color>(
                            list.isCompleted ? Colors.green : Theme.of(context).primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    '${list.completionPercentage.toStringAsFixed(0)}%',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Created: ${_formatDate(list.createdAt)}',
                style: TextStyle(
                  color: Colors.grey[500],
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showCreateListDialog() {
    _nameController.clear();
    _descriptionController.clear();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create Shopping List'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'List Name',
                hintText: 'Enter list name',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description (Optional)',
                hintText: 'Enter description',
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => _createList(),
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  void _createList() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a list name')),
      );
      return;
    }

    try {
      final shoppingProvider = context.read<ShoppingProvider>();
      
      await shoppingProvider.createShoppingList(
        name,
        description: _descriptionController.text.trim().isEmpty 
            ? null 
            : _descriptionController.text.trim(),
      );
      
      if (mounted) {
        try {
          Navigator.of(context).pop();
        } catch (e) {
          debugPrint('Error closing dialog: $e');
        }
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Shopping list created successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to create shopping list: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showAddItemDialog(ShoppingList list) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ProductSearchScreen(
          onProductSelected: (product) async {
            try {
              await context.read<ShoppingProvider>().addToShoppingList(
                list.id,
                product.id,
                quantity: 1,
              );
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Product added to shopping list')),
              );
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Failed to add product: $e')),
              );
            }
          },
        ),
      ),
    );
  }

  void _showListDetails(ShoppingList list) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ShoppingListDetailScreen(shoppingList: list),
      ),
    );
  }

  void _completeList(ShoppingList list, ShoppingProvider shoppingProvider) async {
    try {
      await shoppingProvider.completeShoppingList(list.id);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Shopping list completed')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to complete shopping list: $e')),
      );
    }
  }

  void _handleMenuAction(String action, ShoppingList list, ShoppingProvider shoppingProvider) {
    switch (action) {
      case 'edit':
        _editList(list);
        break;
      case 'delete':
        _deleteList(list, shoppingProvider);
        break;
    }
  }

  void _editList(ShoppingList list) {
    _nameController.text = list.name;
    _descriptionController.text = list.description ?? '';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Shopping List'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'List Name',
                hintText: 'Enter list name',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description (Optional)',
                hintText: 'Enter description',
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // TODO: Implement edit functionality
              Navigator.of(context).pop();
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _deleteList(ShoppingList list, ShoppingProvider shoppingProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Shopping List'),
        content: Text('Are you sure you want to delete "${list.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await shoppingProvider.deleteShoppingList(list.id);
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Shopping list deleted')),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Failed to delete shopping list: $e')),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

class ShoppingListDetailScreen extends StatelessWidget {
  final ShoppingList shoppingList;

  const ShoppingListDetailScreen({
    super.key,
    required this.shoppingList,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(shoppingList.name),
        actions: [
          if (!shoppingList.isCompleted)
            IconButton(
              icon: const Icon(Icons.add_shopping_cart),
              onPressed: () => _showAddItemDialog(context),
            ),
        ],
      ),
      body: shoppingList.items.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: shoppingList.items.length,
              itemBuilder: (context, index) {
                final item = shoppingList.items[index];
                return _buildItemCard(context, item);
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
            Icons.shopping_cart_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No items in this list',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add products to get started',
            style: TextStyle(
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemCard(BuildContext context, ShoppingListItem item) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: item.isCompleted ? Colors.green : Colors.grey[300],
          child: Icon(
            item.isCompleted ? Icons.check : Icons.shopping_cart,
            color: item.isCompleted ? Colors.white : Colors.grey[600],
          ),
        ),
        title: Text(
          item.productName ?? 'Unknown Product',
          style: TextStyle(
            decoration: item.isCompleted ? TextDecoration.lineThrough : null,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Quantity: ${item.quantity}'),
            if (item.productPrice != null)
                                      Text('Price: ₹${item.productPrice!.toStringAsFixed(0)}'),
            if (item.notes != null && item.notes!.isNotEmpty)
              Text('Notes: ${item.notes}'),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!shoppingList.isCompleted) ...[
              IconButton(
                icon: Icon(
                  item.isCompleted ? Icons.undo : Icons.check,
                  color: item.isCompleted ? Colors.orange : Colors.green,
                ),
                onPressed: () => _toggleItemCompletion(context, item),
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => _removeItem(context, item),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showAddItemDialog(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ProductSearchScreen(
          onProductSelected: (product) async {
            try {
              await context.read<ShoppingProvider>().addToShoppingList(
                shoppingList.id,
                product.id,
                quantity: 1,
              );
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Product added to shopping list')),
              );
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Failed to add product: $e')),
              );
            }
          },
        ),
      ),
    );
  }

  void _toggleItemCompletion(BuildContext context, ShoppingListItem item) async {
    try {
      await context.read<ShoppingProvider>().toggleItemCompletion(
        shoppingList.id,
        item.id,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update item: $e')),
      );
    }
  }

  void _removeItem(BuildContext context, ShoppingListItem item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Item'),
        content: Text('Are you sure you want to remove "${item.productName}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await context.read<ShoppingProvider>().removeFromShoppingList(
                  shoppingList.id,
                  item.id,
                );
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Item removed from shopping list')),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Failed to remove item: $e')),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }
} 