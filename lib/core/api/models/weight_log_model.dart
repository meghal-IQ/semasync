class WeightLog {
  final String id;
  final String userId;
  final DateTime date;
  final double weight;
  final String unit;
  final double? bodyFat;
  final double? muscleMass;
  final String? notes;
  final String? photoUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  WeightLog({
    required this.id,
    required this.userId,
    required this.date,
    required this.weight,
    required this.unit,
    this.bodyFat,
    this.muscleMass,
    this.notes,
    this.photoUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  factory WeightLog.fromJson(Map<String, dynamic> json) {
    return WeightLog(
      id: json['id'] ?? json['_id'] ?? '',
      userId: json['userId'] ?? '',
      date: DateTime.parse(json['date']),
      weight: (json['weight'] ?? 0).toDouble(),
      unit: json['unit'] ?? 'lbs',
      bodyFat: json['bodyFat']?.toDouble(),
      muscleMass: json['muscleMass']?.toDouble(),
      notes: json['notes'],
      photoUrl: json['photoUrl'],
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'date': date.toIso8601String(),
      'weight': weight,
      'unit': unit,
      if (bodyFat != null) 'bodyFat': bodyFat,
      if (muscleMass != null) 'muscleMass': muscleMass,
      if (notes != null) 'notes': notes,
      if (photoUrl != null) 'photoUrl': photoUrl,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

class WeightLogRequest {
  final DateTime? date;
  final double weight;
  final String unit;
  final double? bodyFat;
  final double? muscleMass;
  final String? notes;
  final String? photoUrl;

  WeightLogRequest({
    this.date,
    required this.weight,
    required this.unit,
    this.bodyFat,
    this.muscleMass,
    this.notes,
    this.photoUrl,
  });

  Map<String, dynamic> toJson() {
    return {
      if (date != null) 'date': date!.toIso8601String(),
      'weight': weight,
      'unit': unit,
      if (bodyFat != null) 'bodyFat': bodyFat,
      if (muscleMass != null) 'muscleMass': muscleMass,
      if (notes != null && notes!.isNotEmpty) 'notes': notes,
      if (photoUrl != null && photoUrl!.isNotEmpty) 'photoUrl': photoUrl,
    };
  }
}

class WeightStats {
  final int totalEntries;
  final double? startingWeight;
  final double? currentWeight;
  final String unit;
  final double totalChange;
  final double percentChange;
  final double weekChange;
  final double monthChange;
  final DateTime? firstEntryDate;
  final DateTime? latestEntryDate;
  final double? averageBodyFat;
  final String? message;

  WeightStats({
    required this.totalEntries,
    this.startingWeight,
    this.currentWeight,
    required this.unit,
    required this.totalChange,
    required this.percentChange,
    required this.weekChange,
    required this.monthChange,
    this.firstEntryDate,
    this.latestEntryDate,
    this.averageBodyFat,
    this.message,
  });

  factory WeightStats.fromJson(Map<String, dynamic> json) {
    return WeightStats(
      totalEntries: json['totalEntries'] ?? 0,
      startingWeight: json['startingWeight']?.toDouble(),
      currentWeight: json['currentWeight']?.toDouble(),
      unit: json['unit'] ?? 'lbs',
      totalChange: (json['totalChange'] ?? 0).toDouble(),
      percentChange: (json['percentChange'] ?? 0).toDouble(),
      weekChange: (json['weekChange'] ?? 0).toDouble(),
      monthChange: (json['monthChange'] ?? 0).toDouble(),
      firstEntryDate: json['firstEntryDate'] != null 
          ? DateTime.parse(json['firstEntryDate'])
          : null,
      latestEntryDate: json['latestEntryDate'] != null 
          ? DateTime.parse(json['latestEntryDate'])
          : null,
      averageBodyFat: json['averageBodyFat']?.toDouble(),
      message: json['message'],
    );
  }
}

class WeightHistoryResponse {
  final List<WeightLog> weights;
  final PaginationInfo pagination;

  WeightHistoryResponse({
    required this.weights,
    required this.pagination,
  });

  factory WeightHistoryResponse.fromJson(Map<String, dynamic> json) {
    return WeightHistoryResponse(
      weights: (json['weights'] as List)
          .map((e) => WeightLog.fromJson(e))
          .toList(),
      pagination: PaginationInfo.fromJson(json['pagination']),
    );
  }
}

class PaginationInfo {
  final int total;
  final int page;
  final int limit;
  final int pages;

  PaginationInfo({
    required this.total,
    required this.page,
    required this.limit,
    required this.pages,
  });

  factory PaginationInfo.fromJson(Map<String, dynamic> json) {
    return PaginationInfo(
      total: json['total'] ?? 0,
      page: json['page'] ?? 1,
      limit: json['limit'] ?? 50,
      pages: json['pages'] ?? 1,
    );
  }
}
