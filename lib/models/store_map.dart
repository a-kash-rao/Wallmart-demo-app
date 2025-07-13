import 'dart:math';
import 'package:wallmart_store_map/models/product.dart';

class StoreMap {
  final int id;
  final String name;
  final List<Floor> floors;
  final Map<String, dynamic> metadata;

  StoreMap({
    required this.id,
    required this.name,
    required this.floors,
    this.metadata = const {},
  });

  factory StoreMap.fromJson(Map<String, dynamic> json) {
    return StoreMap(
      id: json['id'],
      name: json['name'],
      floors: (json['floors'] as List<dynamic>)
          .map((floor) => Floor.fromJson(floor))
          .toList(),
      metadata: json['metadata'] ?? {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'floors': floors.map((floor) => floor.toJson()).toList(),
      'metadata': metadata,
    };
  }

  Floor? getFloor(int floorNumber) {
    try {
      return floors.firstWhere((floor) => floor.floorNumber == floorNumber);
    } catch (e) {
      return null;
    }
  }

  ProductLocation? findProductLocation(int productId) {
    for (final floor in floors) {
      for (final section in floor.sections) {
        for (final location in section.locations) {
          if (location.productId == productId) {
            return location;
          }
        }
      }
    }
    return null;
  }

  List<ProductLocation> findProductsByCategory(String category) {
    List<ProductLocation> locations = [];
    for (final floor in floors) {
      for (final section in floor.sections) {
        for (final location in section.locations) {
          if (location.product?.category == category) {
            locations.add(location);
          }
        }
      }
    }
    return locations;
  }

  // Get optimal route from current location to product
  List<MapPoint> getRouteToProduct(MapPoint currentLocation, int productId) {
    final productLocation = findProductLocation(productId);
    if (productLocation == null) return [];

    // Simple route calculation - in real app, use pathfinding algorithm
    return [
      currentLocation,
      MapPoint(
        x: productLocation.x,
        y: productLocation.y,
        floorNumber: productLocation.floorNumber,
        description: 'Product location',
      ),
    ];
  }
}

class Floor {
  final int floorNumber;
  final String name;
  final String description;
  final int width;
  final int height;
  final List<Section> sections;
  final List<MapPoint> landmarks;
  final String? imageUrl;

  Floor({
    required this.floorNumber,
    required this.name,
    required this.description,
    required this.width,
    required this.height,
    required this.sections,
    this.landmarks = const [],
    this.imageUrl,
  });

  factory Floor.fromJson(Map<String, dynamic> json) {
    return Floor(
      floorNumber: json['floor_number'],
      name: json['name'],
      description: json['description'],
      width: json['width'],
      height: json['height'],
      sections: (json['sections'] as List<dynamic>)
          .map((section) => Section.fromJson(section))
          .toList(),
      landmarks: (json['landmarks'] as List<dynamic>?)
          ?.map((landmark) => MapPoint.fromJson(landmark))
          .toList() ?? [],
      imageUrl: json['image_url'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'floor_number': floorNumber,
      'name': name,
      'description': description,
      'width': width,
      'height': height,
      'sections': sections.map((section) => section.toJson()).toList(),
      'landmarks': landmarks.map((landmark) => landmark.toJson()).toList(),
      'image_url': imageUrl,
    };
  }
}

class Section {
  final int id;
  final String name;
  final String description;
  final int x;
  final int y;
  final int width;
  final int height;
  final String category;
  final List<ProductLocation> locations;
  final String? color;

  Section({
    required this.id,
    required this.name,
    required this.description,
    required this.x,
    required this.y,
    required this.width,
    required this.height,
    required this.category,
    required this.locations,
    this.color,
  });

  factory Section.fromJson(Map<String, dynamic> json) {
    return Section(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      x: json['x'],
      y: json['y'],
      width: json['width'],
      height: json['height'],
      category: json['category'],
      locations: (json['locations'] as List<dynamic>)
          .map((location) => ProductLocation.fromJson(location))
          .toList(),
      color: json['color'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'x': x,
      'y': y,
      'width': width,
      'height': height,
      'category': category,
      'locations': locations.map((location) => location.toJson()).toList(),
      'color': color,
    };
  }
}

class ProductLocation {
  final int id;
  final int x;
  final int y;
  final int floorNumber;
  final int sectionId;
  final int? productId;
  final String qrCode;
  final String description;
  final Product? product;

  ProductLocation({
    required this.id,
    required this.x,
    required this.y,
    required this.floorNumber,
    required this.sectionId,
    this.productId,
    required this.qrCode,
    required this.description,
    this.product,
  });

  factory ProductLocation.fromJson(Map<String, dynamic> json) {
    return ProductLocation(
      id: json['id'],
      x: json['x'],
      y: json['y'],
      floorNumber: json['floor_number'],
      sectionId: json['section_id'],
      productId: json['product_id'],
      qrCode: json['qr_code'],
      description: json['description'],
      product: json['product'] != null ? Product.fromJson(json['product']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'x': x,
      'y': y,
      'floor_number': floorNumber,
      'section_id': sectionId,
      'product_id': productId,
      'qr_code': qrCode,
      'description': description,
      'product': product?.toJson(),
    };
  }

  ProductLocation copyWith({
    int? id,
    int? x,
    int? y,
    int? floorNumber,
    int? sectionId,
    int? productId,
    String? qrCode,
    String? description,
    Product? product,
  }) {
    return ProductLocation(
      id: id ?? this.id,
      x: x ?? this.x,
      y: y ?? this.y,
      floorNumber: floorNumber ?? this.floorNumber,
      sectionId: sectionId ?? this.sectionId,
      productId: productId ?? this.productId,
      qrCode: qrCode ?? this.qrCode,
      description: description ?? this.description,
      product: product ?? this.product,
    );
  }
}

class MapPoint {
  final int x;
  final int y;
  final int floorNumber;
  final String description;
  final String? type; // 'entrance', 'exit', 'elevator', 'stairs', 'product', etc.

  MapPoint({
    required this.x,
    required this.y,
    required this.floorNumber,
    required this.description,
    this.type,
  });

  factory MapPoint.fromJson(Map<String, dynamic> json) {
    return MapPoint(
      x: json['x'],
      y: json['y'],
      floorNumber: json['floor_number'],
      description: json['description'],
      type: json['type'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'x': x,
      'y': y,
      'floor_number': floorNumber,
      'description': description,
      'type': type,
    };
  }

  double distanceTo(MapPoint other) {
    if (floorNumber != other.floorNumber) {
      // Add penalty for different floors
      return 1000.0 + (x - other.x).abs() + (y - other.y).abs();
    }
    return sqrt((x - other.x) * (x - other.x) + (y - other.y) * (y - other.y));
  }
} 