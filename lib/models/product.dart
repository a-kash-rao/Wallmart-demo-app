class Product {
  final int id;
  final String name;
  final String? description;
  final String? category;
  final double? price;
  final String? imageUrl;
  final int? locationId;
  final DateTime createdAt;
  final bool isFavorite;
  final double? averageRating;
  final int? reviewCount;
  final bool inStock;
  final String? brand;
  final String? sku;
  
  // Location information (from join)
  final String? qrCode;
  final int? xCoordinate;
  final int? yCoordinate;
  final String? sectionName;
  final String? locationDescription;

  Product({
    required this.id,
    required this.name,
    this.description,
    this.category,
    this.price,
    this.imageUrl,
    this.locationId,
    required this.createdAt,
    this.isFavorite = false,
    this.averageRating,
    this.reviewCount,
    this.inStock = true,
    this.brand,
    this.sku,
    this.qrCode,
    this.xCoordinate,
    this.yCoordinate,
    this.sectionName,
    this.locationDescription,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      category: json['category'],
      price: json['price']?.toDouble(),
      imageUrl: json['image_url'],
      locationId: json['location_id'],
      createdAt: DateTime.parse(json['created_at']),
      isFavorite: json['is_favorite'] ?? false,
      averageRating: json['average_rating']?.toDouble(),
      reviewCount: json['review_count'],
      inStock: json['in_stock'] ?? true,
      brand: json['brand'],
      sku: json['sku'],
      qrCode: json['qr_code'],
      xCoordinate: json['x_coordinate'],
      yCoordinate: json['y_coordinate'],
      sectionName: json['section_name'],
      locationDescription: json['location_description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'category': category,
      'price': price,
      'image_url': imageUrl,
      'location_id': locationId,
      'created_at': createdAt.toIso8601String(),
      'is_favorite': isFavorite,
      'average_rating': averageRating,
      'review_count': reviewCount,
      'in_stock': inStock,
      'brand': brand,
      'sku': sku,
    };
  }

  Product copyWith({
    int? id,
    String? name,
    String? description,
    String? category,
    double? price,
    String? imageUrl,
    int? locationId,
    DateTime? createdAt,
    bool? isFavorite,
    double? averageRating,
    int? reviewCount,
    bool? inStock,
    String? brand,
    String? sku,
    String? qrCode,
    int? xCoordinate,
    int? yCoordinate,
    String? sectionName,
    String? locationDescription,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      category: category ?? this.category,
      price: price ?? this.price,
      imageUrl: imageUrl ?? this.imageUrl,
      locationId: locationId ?? this.locationId,
      createdAt: createdAt ?? this.createdAt,
      isFavorite: isFavorite ?? this.isFavorite,
      averageRating: averageRating ?? this.averageRating,
      reviewCount: reviewCount ?? this.reviewCount,
      inStock: inStock ?? this.inStock,
      brand: brand ?? this.brand,
      sku: sku ?? this.sku,
      qrCode: qrCode ?? this.qrCode,
      xCoordinate: xCoordinate ?? this.xCoordinate,
      yCoordinate: yCoordinate ?? this.yCoordinate,
      sectionName: sectionName ?? this.sectionName,
      locationDescription: locationDescription ?? this.locationDescription,
    );
  }

  @override
  String toString() {
    return 'Product(id: $id, name: $name, category: $category, price: $price, locationId: $locationId)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Product && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
} 