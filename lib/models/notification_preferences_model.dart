class NotificationPreferencesModel {
  final bool enabled;
  final Map<String, bool> categories;
  final int ritualTimeLocal;
  final int passageTimeLocal;
  final int quietStartLocal;
  final int quietEndLocal;

  NotificationPreferencesModel({
    required this.enabled,
    required this.categories,
    required this.ritualTimeLocal,
    required this.passageTimeLocal,
    required this.quietStartLocal,
    required this.quietEndLocal,
  });

  factory NotificationPreferencesModel.defaults() {
    return NotificationPreferencesModel(
      enabled: true,
      categories: {
        'reading_reminder': true,
        'streak_update': true,
        'quote_saved': true,
        'new_recommendation': true,
        'chapter_milestone': true,
        'weekly_insights': true,
        'quote_of_the_day': true,
        'challenge_progress': true,
        'ritual': true,
        'passage': true,
      },
      ritualTimeLocal: 19,
      passageTimeLocal: 8,
      quietStartLocal: 22,
      quietEndLocal: 8,
    );
  }

  factory NotificationPreferencesModel.fromJson(Map<String, dynamic> json) {
    final rawCats = json['categories'];
    final Map<String, bool> parsedCats = {};
    if (rawCats is Map) {
      rawCats.forEach((k, v) {
        parsedCats[k.toString()] = v == true;
      });
    }

    return NotificationPreferencesModel(
      enabled: json['enabled'] as bool? ?? true,
      categories: parsedCats.isNotEmpty
          ? parsedCats
          : NotificationPreferencesModel.defaults().categories,
      ritualTimeLocal: (json['ritual_time_local'] as num?)?.toInt() ?? 19,
      passageTimeLocal: (json['passage_time_local'] as num?)?.toInt() ?? 8,
      quietStartLocal: (json['quiet_start_local'] as num?)?.toInt() ?? 22,
      quietEndLocal: (json['quiet_end_local'] as num?)?.toInt() ?? 8,
    );
  }

  Map<String, dynamic> toJson() => {
    'enabled': enabled,
    'categories': categories,
    'ritual_time_local': ritualTimeLocal,
    'passage_time_local': passageTimeLocal,
    'quiet_start_local': quietStartLocal,
    'quiet_end_local': quietEndLocal,
  };

  NotificationPreferencesModel copyWith({
    bool? enabled,
    Map<String, bool>? categories,
    int? ritualTimeLocal,
    int? passageTimeLocal,
    int? quietStartLocal,
    int? quietEndLocal,
  }) {
    return NotificationPreferencesModel(
      enabled: enabled ?? this.enabled,
      categories: categories ?? this.categories,
      ritualTimeLocal: ritualTimeLocal ?? this.ritualTimeLocal,
      passageTimeLocal: passageTimeLocal ?? this.passageTimeLocal,
      quietStartLocal: quietStartLocal ?? this.quietStartLocal,
      quietEndLocal: quietEndLocal ?? this.quietEndLocal,
    );
  }
}
