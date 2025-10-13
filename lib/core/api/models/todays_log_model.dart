class TodaysLogEntry {
  final String id;
  final String type;
  final String category;
  final String title;
  final String subtitle;
  final DateTime time;
  final String icon;
  final Map<String, dynamic> data;

  TodaysLogEntry({
    required this.id,
    required this.type,
    required this.category,
    required this.title,
    required this.subtitle,
    required this.time,
    required this.icon,
    required this.data,
  });

  factory TodaysLogEntry.fromJson(Map<String, dynamic> json) {
    return TodaysLogEntry(
      id: json['id'] ?? '',
      type: json['type'] ?? '',
      category: json['category'] ?? '',
      title: json['title'] ?? '',
      subtitle: json['subtitle'] ?? '',
      time: DateTime.parse(json['time']),
      icon: json['icon'] ?? '',
      data: Map<String, dynamic>.from(json['data'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'category': category,
      'title': title,
      'subtitle': subtitle,
      'time': time.toIso8601String(),
      'icon': icon,
      'data': data,
    };
  }
}

class TodaysLogSummary {
  final int totalEntries;
  final int mealEntries;
  final int waterEntries;
  final int shotEntries;
  final int weightEntries;
  final int activityEntries;
  final int sideEffectEntries;
  final int photoEntries;

  TodaysLogSummary({
    required this.totalEntries,
    required this.mealEntries,
    required this.waterEntries,
    required this.shotEntries,
    required this.weightEntries,
    required this.activityEntries,
    required this.sideEffectEntries,
    required this.photoEntries,
  });

  factory TodaysLogSummary.fromJson(Map<String, dynamic> json) {
    return TodaysLogSummary(
      totalEntries: json['totalEntries'] ?? 0,
      mealEntries: json['mealEntries'] ?? 0,
      waterEntries: json['waterEntries'] ?? 0,
      shotEntries: json['shotEntries'] ?? 0,
      weightEntries: json['weightEntries'] ?? 0,
      activityEntries: json['activityEntries'] ?? 0,
      sideEffectEntries: json['sideEffectEntries'] ?? 0,
      photoEntries: json['photoEntries'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalEntries': totalEntries,
      'mealEntries': mealEntries,
      'waterEntries': waterEntries,
      'shotEntries': shotEntries,
      'weightEntries': weightEntries,
      'activityEntries': activityEntries,
      'sideEffectEntries': sideEffectEntries,
      'photoEntries': photoEntries,
    };
  }
}

class TodaysLogResponse {
  final List<TodaysLogEntry> logs;
  final TodaysLogSummary summary;

  TodaysLogResponse({
    required this.logs,
    required this.summary,
  });

  factory TodaysLogResponse.fromJson(Map<String, dynamic> json) {
    return TodaysLogResponse(
      logs: (json['logs'] as List)
          .map((log) => TodaysLogEntry.fromJson(log))
          .toList(),
      summary: TodaysLogSummary.fromJson(json['summary']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'logs': logs.map((log) => log.toJson()).toList(),
      'summary': summary.toJson(),
    };
  }
}
