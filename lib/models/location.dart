class Location {
  final int id;
  final String qrCode;
  final int xCoordinate;
  final int yCoordinate;
  final String? sectionName;
  final String? description;
  final DateTime createdAt;

  Location({
    required this.id,
    required this.qrCode,
    required this.xCoordinate,
    required this.yCoordinate,
    this.sectionName,
    this.description,
    required this.createdAt,
  });

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      id: json['id'],
      qrCode: json['qr_code'],
      xCoordinate: json['x_coordinate'],
      yCoordinate: json['y_coordinate'],
      sectionName: json['section_name'],
      description: json['description'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'qr_code': qrCode,
      'x_coordinate': xCoordinate,
      'y_coordinate': yCoordinate,
      'section_name': sectionName,
      'description': description,
      'created_at': createdAt.toIso8601String(),
    };
  }

  Location copyWith({
    int? id,
    String? qrCode,
    int? xCoordinate,
    int? yCoordinate,
    String? sectionName,
    String? description,
    DateTime? createdAt,
  }) {
    return Location(
      id: id ?? this.id,
      qrCode: qrCode ?? this.qrCode,
      xCoordinate: xCoordinate ?? this.xCoordinate,
      yCoordinate: yCoordinate ?? this.yCoordinate,
      sectionName: sectionName ?? this.sectionName,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'Location(id: $id, qrCode: $qrCode, xCoordinate: $xCoordinate, yCoordinate: $yCoordinate, sectionName: $sectionName, description: $description)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Location && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
} 