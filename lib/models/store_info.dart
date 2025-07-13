class StoreInfo {
  final int id;
  final String name;
  final String address;
  final String phone;
  final String email;
  final String website;
  final StoreHours hours;
  final List<String> amenities;
  final String? description;
  final double? latitude;
  final double? longitude;
  final DateTime lastUpdated;

  StoreInfo({
    required this.id,
    required this.name,
    required this.address,
    required this.phone,
    required this.email,
    required this.website,
    required this.hours,
    required this.amenities,
    this.description,
    this.latitude,
    this.longitude,
    required this.lastUpdated,
  });

  factory StoreInfo.fromJson(Map<String, dynamic> json) {
    return StoreInfo(
      id: json['id'],
      name: json['name'],
      address: json['address'],
      phone: json['phone'],
      email: json['email'],
      website: json['website'],
      hours: StoreHours.fromJson(json['hours']),
      amenities: List<String>.from(json['amenities'] ?? []),
      description: json['description'],
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
      lastUpdated: DateTime.parse(json['last_updated']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'phone': phone,
      'email': email,
      'website': website,
      'hours': hours.toJson(),
      'amenities': amenities,
      'description': description,
      'latitude': latitude,
      'longitude': longitude,
      'last_updated': lastUpdated.toIso8601String(),
    };
  }

  bool get isOpenNow {
    final now = DateTime.now();
    final currentDay = now.weekday;
    final currentTime = now.hour * 60 + now.minute; // Convert to minutes
    
    final todayHours = hours.getDayHours(currentDay);
    if (todayHours == null) return false;
    
    return currentTime >= todayHours.openMinutes && 
           currentTime <= todayHours.closeMinutes;
  }

  String get nextOpenTime {
    final now = DateTime.now();
    final currentDay = now.weekday;
    
    // Check today first
    final todayHours = hours.getDayHours(currentDay);
    if (todayHours != null && !todayHours.isClosed) {
      final currentTime = now.hour * 60 + now.minute;
      if (currentTime < todayHours.openMinutes) {
        return 'Opens today at ${todayHours.openTime}';
      }
    }
    
    // Check next few days
    for (int i = 1; i <= 7; i++) {
      final checkDay = (currentDay + i - 1) % 7 + 1;
      final dayHours = hours.getDayHours(checkDay);
      if (dayHours != null && !dayHours.isClosed) {
        final dayName = _getDayName(checkDay);
        return 'Opens $dayName at ${dayHours.openTime}';
      }
    }
    
    return 'Closed';
  }

  String _getDayName(int weekday) {
    switch (weekday) {
      case 1: return 'Monday';
      case 2: return 'Tuesday';
      case 3: return 'Wednesday';
      case 4: return 'Thursday';
      case 5: return 'Friday';
      case 6: return 'Saturday';
      case 7: return 'Sunday';
      default: return 'Unknown';
    }
  }
}

class StoreHours {
  final Map<int, DayHours> weeklyHours;

  StoreHours({required this.weeklyHours});

  factory StoreHours.fromJson(Map<String, dynamic> json) {
    final Map<int, DayHours> hours = {};
    final weeklyData = json['weekly_hours'] as Map<String, dynamic>;
    
    weeklyData.forEach((day, data) {
      hours[int.parse(day)] = DayHours.fromJson(data);
    });
    
    return StoreHours(weeklyHours: hours);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> weeklyData = {};
    weeklyHours.forEach((day, hours) {
      weeklyData[day.toString()] = hours.toJson();
    });
    
    return {
      'weekly_hours': weeklyData,
    };
  }

  DayHours? getDayHours(int weekday) {
    return weeklyHours[weekday];
  }
}

class DayHours {
  final String openTime;
  final String closeTime;
  final bool isClosed;
  final String? notes;

  DayHours({
    required this.openTime,
    required this.closeTime,
    this.isClosed = false,
    this.notes,
  });

  factory DayHours.fromJson(Map<String, dynamic> json) {
    return DayHours(
      openTime: json['open_time'] ?? '',
      closeTime: json['close_time'] ?? '',
      isClosed: json['is_closed'] ?? false,
      notes: json['notes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'open_time': openTime,
      'close_time': closeTime,
      'is_closed': isClosed,
      'notes': notes,
    };
  }

  int get openMinutes => _timeToMinutes(openTime);
  int get closeMinutes => _timeToMinutes(closeTime);

  int _timeToMinutes(String time) {
    if (time.isEmpty) return 0;
    final parts = time.split(':');
    if (parts.length != 2) return 0;
    
    final hours = int.tryParse(parts[0]) ?? 0;
    final minutes = int.tryParse(parts[1]) ?? 0;
    return hours * 60 + minutes;
  }
} 