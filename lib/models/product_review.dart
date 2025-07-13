class ProductReview {
  final int id;
  final int productId;
  final String userName;
  final int rating;
  final String? comment;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool isVerified;
  final List<String>? images;

  ProductReview({
    required this.id,
    required this.productId,
    required this.userName,
    required this.rating,
    this.comment,
    required this.createdAt,
    this.updatedAt,
    this.isVerified = false,
    this.images,
  });

  factory ProductReview.fromJson(Map<String, dynamic> json) {
    return ProductReview(
      id: json['id'],
      productId: json['product_id'],
      userName: json['user_name'],
      rating: json['rating'],
      comment: json['comment'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at']) 
          : null,
      isVerified: json['is_verified'] ?? false,
      images: json['images'] != null 
          ? List<String>.from(json['images'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product_id': productId,
      'user_name': userName,
      'rating': rating,
      'comment': comment,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'is_verified': isVerified,
      'images': images,
    };
  }

  ProductReview copyWith({
    int? id,
    int? productId,
    String? userName,
    int? rating,
    String? comment,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isVerified,
    List<String>? images,
  }) {
    return ProductReview(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      userName: userName ?? this.userName,
      rating: rating ?? this.rating,
      comment: comment ?? this.comment,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isVerified: isVerified ?? this.isVerified,
      images: images ?? this.images,
    );
  }

  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(createdAt);
    
    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} ago';
    } else {
      return 'Just now';
    }
  }

  String get ratingText {
    switch (rating) {
      case 1: return 'Poor';
      case 2: return 'Fair';
      case 3: return 'Good';
      case 4: return 'Very Good';
      case 5: return 'Excellent';
      default: return 'Unknown';
    }
  }
}

class ProductRating {
  final int productId;
  final double averageRating;
  final int totalReviews;
  final Map<int, int> ratingDistribution; // rating -> count

  ProductRating({
    required this.productId,
    required this.averageRating,
    required this.totalReviews,
    required this.ratingDistribution,
  });

  factory ProductRating.fromJson(Map<String, dynamic> json) {
    final Map<int, int> distribution = {};
    final distributionData = json['rating_distribution'] as Map<String, dynamic>;
    
    distributionData.forEach((rating, count) {
      distribution[int.parse(rating)] = count;
    });
    
    return ProductRating(
      productId: json['product_id'],
      averageRating: json['average_rating'].toDouble(),
      totalReviews: json['total_reviews'],
      ratingDistribution: distribution,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> distributionData = {};
    ratingDistribution.forEach((rating, count) {
      distributionData[rating.toString()] = count;
    });
    
    return {
      'product_id': productId,
      'average_rating': averageRating,
      'total_reviews': totalReviews,
      'rating_distribution': distributionData,
    };
  }

  int getRatingCount(int rating) {
    return ratingDistribution[rating] ?? 0;
  }

  double getRatingPercentage(int rating) {
    if (totalReviews == 0) return 0;
    return (getRatingCount(rating) / totalReviews) * 100;
  }
} 