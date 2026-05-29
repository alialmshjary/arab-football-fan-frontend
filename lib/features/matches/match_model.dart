class MatchModel {
  const MatchModel({
    required this.id,
    required this.homeTeam,
    required this.awayTeam,
    required this.league,
    required this.matchDate,
    required this.hour,
    required this.minute,
    required this.period,
    required this.status,
    required this.predictionState,
    this.chatUrl,
  });

  final int id;
  final String homeTeam;
  final String awayTeam;
  final String league;
  final String matchDate;
  final int hour;
  final int minute;
  final String period;
  final String status;
  final String predictionState;
  final String? chatUrl;

  factory MatchModel.fromJson(Map<String, dynamic> json) {
    int parseInt(dynamic value) {
      if (value is int) return value;
      return int.tryParse('$value') ?? 0;
    }

    return MatchModel(
      id: parseInt(json['id'] ?? json['Id']),
      homeTeam: (json['homeTeam'] ?? json['HomeTeam'] ?? '').toString(),
      awayTeam: (json['awayTeam'] ?? json['AwayTeam'] ?? '').toString(),
      league: (json['league'] ?? json['League'] ?? '').toString(),
      matchDate: (json['matchDate'] ?? json['MatchDate'] ?? '').toString(),
      hour: parseInt(json['hour'] ?? json['Hour']),
      minute: parseInt(json['minute'] ?? json['Minute']),
      period: (json['period'] ?? json['Period'] ?? '').toString(),
      status: parseStatus(json['status'] ?? json['Status']),
      predictionState: parsePredictionState(json['predictionState'] ?? json['PredictionState'],),
      chatUrl: json['chatUrl'] ?? json['ChatUrl'],
    );
  }

  String get formattedTime =>
      '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')} $period';



  static String parseStatus(dynamic value) {
  switch ('$value') {
    case '0':
      return 'قادمة';
    case '1':
      return 'مباشرة';
    case '2':
      return 'منتهية';
    default:
      return value?.toString() ?? 'غير معروف';
    }
  }

  static String parsePredictionState(dynamic value) {
    switch ('$value') {
      case '0':
        return 'مفتوحة';
      case '1':
        return 'مغلقة';
      default:
        return value?.toString() ?? 'غير معروف';
    }
  }

}


