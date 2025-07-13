class ShoppingList {
  final int id;
  final String name;
  final String? description;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool isCompleted;
  final List<ShoppingListItem> items;

  ShoppingList({
    required this.id,
    required this.name,
    this.description,
    required this.createdAt,
    this.updatedAt,
    this.isCompleted = false,
    this.items = const [],
  });

  factory ShoppingList.fromJson(Map<String, dynamic> json) {
    return ShoppingList(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at']) 
          : null,
      isCompleted: json['is_completed'] ?? false,
      items: (json['items'] as List<dynamic>?)
          ?.map((item) => ShoppingListItem.fromJson(item))
          .toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'is_completed': isCompleted,
      'items': items.map((item) => item.toJson()).toList(),
    };
  }

  ShoppingList copyWith({
    int? id,
    String? name,
    String? description,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isCompleted,
    List<ShoppingListItem>? items,
  }) {
    return ShoppingList(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isCompleted: isCompleted ?? this.isCompleted,
      items: items ?? this.items,
    );
  }

  int get completedItemsCount => items.where((item) => item.isCompleted).length;
  int get totalItemsCount => items.length;
  double get completionPercentage => 
      totalItemsCount > 0 ? (completedItemsCount / totalItemsCount) * 100 : 0;
}

class ShoppingListItem {
  final int id;
  final int shoppingListId;
  final int productId;
  final int quantity;
  final bool isCompleted;
  final String? notes;
  final DateTime createdAt;
  
  // Product information (from join)
  final String? productName;
  final String? productImageUrl;
  final double? productPrice;
  final String? productCategory;

  ShoppingListItem({
    required this.id,
    required this.shoppingListId,
    required this.productId,
    required this.quantity,
    this.isCompleted = false,
    this.notes,
    required this.createdAt,
    this.productName,
    this.productImageUrl,
    this.productPrice,
    this.productCategory,
  });

  factory ShoppingListItem.fromJson(Map<String, dynamic> json) {
    return ShoppingListItem(
      id: json['id'],
      shoppingListId: json['shopping_list_id'],
      productId: json['product_id'],
      quantity: json['quantity'],
      isCompleted: json['is_completed'] ?? false,
      notes: json['notes'],
      createdAt: DateTime.parse(json['created_at']),
      productName: json['product_name'],
      productImageUrl: json['product_image_url'],
      productPrice: json['product_price']?.toDouble(),
      productCategory: json['product_category'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'shopping_list_id': shoppingListId,
      'product_id': productId,
      'quantity': quantity,
      'is_completed': isCompleted,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
    };
  }

  ShoppingListItem copyWith({
    int? id,
    int? shoppingListId,
    int? productId,
    int? quantity,
    bool? isCompleted,
    String? notes,
    DateTime? createdAt,
    String? productName,
    String? productImageUrl,
    double? productPrice,
    String? productCategory,
  }) {
    return ShoppingListItem(
      id: id ?? this.id,
      shoppingListId: shoppingListId ?? this.shoppingListId,
      productId: productId ?? this.productId,
      quantity: quantity ?? this.quantity,
      isCompleted: isCompleted ?? this.isCompleted,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      productName: productName ?? this.productName,
      productImageUrl: productImageUrl ?? this.productImageUrl,
      productPrice: productPrice ?? this.productPrice,
      productCategory: productCategory ?? this.productCategory,
    );
  }
} 