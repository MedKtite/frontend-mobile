enum NotificationCategory {
  readingReminder,
  streakUpdate,
  quoteSaved,
  newRecommendation,
  chapterMilestone,
  weeklyInsights,
  quoteOfTheDay,
  challengeProgress,
  systemActivity,
  billing,
  other;

  static NotificationCategory fromString(String? val) {
    switch (val?.toLowerCase()) {
      case 'reading_reminder':
      case 'ritual':
        return NotificationCategory.readingReminder;
      case 'streak_update':
        return NotificationCategory.streakUpdate;
      case 'quote_saved':
        return NotificationCategory.quoteSaved;
      case 'new_recommendation':
      case 'passage':
        return NotificationCategory.newRecommendation;
      case 'chapter_milestone':
      case 'milestone':
        return NotificationCategory.chapterMilestone;
      case 'weekly_insights':
        return NotificationCategory.weeklyInsights;
      case 'quote_of_the_day':
        return NotificationCategory.quoteOfTheDay;
      case 'challenge_progress':
        return NotificationCategory.challengeProgress;
      case 'system_activity':
      case 'sync':
      case 'listening_resume':
        return NotificationCategory.systemActivity;
      case 'billing':
        return NotificationCategory.billing;
      default:
        return NotificationCategory.other;
    }
  }

  String toCategoryString() {
    switch (this) {
      case NotificationCategory.readingReminder:
        return 'reading_reminder';
      case NotificationCategory.streakUpdate:
        return 'streak_update';
      case NotificationCategory.quoteSaved:
        return 'quote_saved';
      case NotificationCategory.newRecommendation:
        return 'new_recommendation';
      case NotificationCategory.chapterMilestone:
        return 'chapter_milestone';
      case NotificationCategory.weeklyInsights:
        return 'weekly_insights';
      case NotificationCategory.quoteOfTheDay:
        return 'quote_of_the_day';
      case NotificationCategory.challengeProgress:
        return 'challenge_progress';
      case NotificationCategory.systemActivity:
        return 'system_activity';
      case NotificationCategory.billing:
        return 'billing';
      case NotificationCategory.other:
        return 'other';
    }
  }
}

class NotificationItemModel {
  final String id;
  final String category;
  final NotificationCategory parsedCategory;
  final String title;
  final String body;
  final Map<String, dynamic>? data;
  final bool isUnread;
  final DateTime? readAt;
  final DateTime createdAt;

  NotificationItemModel({
    required this.id,
    required this.category,
    required this.parsedCategory,
    required this.title,
    required this.body,
    this.data,
    required this.isUnread,
    this.readAt,
    required this.createdAt,
  });

  factory NotificationItemModel.fromJson(Map<String, dynamic> json) {
    final catStr = json['category'] as String? ?? 'other';
    final isUnreadVal = json['is_unread'] as bool? ?? (json['read_at'] == null);
    DateTime parsedCreated;
    try {
      parsedCreated = json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now();
    } catch (_) {
      parsedCreated = DateTime.now();
    }

    DateTime? parsedRead;
    if (json['read_at'] != null) {
      try {
        parsedRead = DateTime.parse(json['read_at'] as String);
      } catch (_) {}
    }

    return NotificationItemModel(
      id: json['id'] as String? ?? '',
      category: catStr,
      parsedCategory: NotificationCategory.fromString(catStr),
      title: json['title'] as String? ?? '',
      body: json['body'] as String? ?? '',
      data: json['data'] as Map<String, dynamic>?,
      isUnread: isUnreadVal,
      readAt: parsedRead,
      createdAt: parsedCreated,
    );
  }

  NotificationItemModel copyWith({
    String? id,
    String? category,
    NotificationCategory? parsedCategory,
    String? title,
    String? body,
    Map<String, dynamic>? data,
    bool? isUnread,
    DateTime? readAt,
    DateTime? createdAt,
  }) {
    return NotificationItemModel(
      id: id ?? this.id,
      category: category ?? this.category,
      parsedCategory: parsedCategory ?? this.parsedCategory,
      title: title ?? this.title,
      body: body ?? this.body,
      data: data ?? this.data,
      isUnread: isUnread ?? this.isUnread,
      readAt: readAt ?? this.readAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'category': category,
    'title': title,
    'body': body,
    'data': data,
    'is_unread': isUnread,
    'read_at': readAt?.toIso8601String(),
    'created_at': createdAt.toIso8601String(),
  };
}
