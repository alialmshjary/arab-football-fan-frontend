class MatchModel {
  const MatchModel({
    required this.id,
    required this.homeTeam,
    this.homeTeamLogoUrl,
    required this.awayTeam,
    this.awayTeamLogoUrl,
    required this.league,
    required this.matchDate,
    required this.hour,
    required this.minute,
    required this.period,
    required this.status,
    required this.predictionState,
  });

  final int id;
  final String homeTeam;
  final String? homeTeamLogoUrl;
  final String awayTeam;
  final String? awayTeamLogoUrl;
  final String league;
  final String matchDate;
  final int hour;
  final int minute;
  final String period;
  final String status;
  final String predictionState;

  factory MatchModel.fromJson(Map<String, dynamic> json) {
    int parseInt(dynamic value) {
      if (value is int) return value;
      return int.tryParse('$value') ?? 0;
    }

    String? parseNullableString(dynamic value) {
      if (value == null) return null;
      final text = value.toString().trim();
      return text.isEmpty ? null : text;
    }

    return MatchModel(
      id: parseInt(json['id'] ?? json['Id']),
      homeTeam: (json['homeTeam'] ?? json['HomeTeam'] ?? '').toString(),
      homeTeamLogoUrl: parseNullableString(
        json['homeTeamLogoUrl'] ?? json['HomeTeamLogoUrl'],
      ),
      awayTeam: (json['awayTeam'] ?? json['AwayTeam'] ?? '').toString(),
      awayTeamLogoUrl: parseNullableString(
        json['awayTeamLogoUrl'] ?? json['AwayTeamLogoUrl'],
      ),
      league: (json['league'] ?? json['League'] ?? '').toString(),
      matchDate: (json['matchDate'] ?? json['MatchDate'] ?? '').toString(),
      hour: parseInt(json['hour'] ?? json['Hour']),
      minute: parseInt(json['minute'] ?? json['Minute']),
      period: (json['period'] ?? json['Period'] ?? '').toString(),
      status: parseStatus(json['status'] ?? json['Status']),
      predictionState: parsePredictionState(
        json['predictionState'] ?? json['PredictionState'],
      ),
    );
  }

  String get formattedTime =>
      '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')} $period';

  DateTime? get startDateTime {
    try {
      final parts = matchDate.split('-');

      if (parts.length != 3) return null;

      final year = int.tryParse(parts[0]);
      final month = int.tryParse(parts[1]);
      final day = int.tryParse(parts[2]);

      if (year == null || month == null || day == null) return null;

      var h = hour;

      final normalizedPeriod = period.trim();

      if (normalizedPeriod.contains('مساء') ||
          normalizedPeriod.toLowerCase() == 'pm') {
        if (h < 12) h += 12;
      }

      if (normalizedPeriod.contains('صباح') ||
          normalizedPeriod.toLowerCase() == 'am') {
        if (h == 12) h = 0;
      }

      return DateTime(year, month, day, h, minute);
    } catch (_) {
      return null;
    }
  }

  bool get hasStarted {
    final start = startDateTime;

    if (start == null) return false;

    return !DateTime.now().isBefore(start);
  }

  bool get predictionsOpen {
    return predictionState.trim() == 'مفتوحة' && !hasStarted;
  }

  String get effectivePredictionState {
    return predictionsOpen ? 'مفتوحة' : 'مغلقة';
  }

  static String parseStatus(dynamic value) {
    final text = value?.toString().trim().toLowerCase();

    switch (text) {
      case '0':
      case 'upcoming':
      case 'قادمة':
        return 'قادمة';

      case '1':
      case 'live':
      case 'مباشرة':
        return 'مباشرة';

      case '2':
      case 'finished':
      case 'منتهية':
        return 'منتهية';

      default:
        return value?.toString() ?? 'غير معروف';
    }
  }

  static String parsePredictionState(dynamic value) {
    final text = value?.toString().trim().toLowerCase();

    switch (text) {
      case '0':
      case 'closed':
      case 'مغلقة':
        return 'مغلقة';

      case '1':
      case 'open':
      case 'مفتوحة':
        return 'مفتوحة';

      default:
        return value?.toString() ?? 'غير معروف';
    }
  }
}
