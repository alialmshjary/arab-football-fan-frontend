class PredictionModel {
  const PredictionModel({
    required this.id,
    required this.matchId,
    required this.predictedHomeScore,
    required this.predictedAwayScore,
    required this.isProcessed,
    required this.pointsEarned,
    required this.createdAt,
  });

  final int id;
  final int matchId;
  final int predictedHomeScore;
  final int predictedAwayScore;
  final bool isProcessed;
  final int pointsEarned;
  final DateTime createdAt;

  factory PredictionModel.fromJson(Map<String, dynamic> json) {
    int readInt(List<String> keys) {
      for (final key in keys) {
        final value = json[key];
        if (value is int) return value;
        final parsed = int.tryParse('$value');
        if (parsed != null) return parsed;
      }
      return 0;
    }

    bool readBool(List<String> keys) {
      for (final key in keys) {
        final value = json[key];
        if (value is bool) return value;
        if (value is num) return value != 0;
        if (value is String) {
          final normalized = value.toLowerCase().trim();
          if (normalized == 'true') return true;
          if (normalized == 'false') return false;
        }
      }
      return false;
    }

    DateTime readDate() {
      final raw = json['createdAt'] ?? json['CreatedAt'];
      if (raw == null) return DateTime.now();
      return DateTime.tryParse(raw.toString()) ?? DateTime.now();
    }

    return PredictionModel(
      id: readInt(['id', 'Id']),
      matchId: readInt(['matchId', 'MatchId']),
      predictedHomeScore: readInt(['predictedHomeScore', 'PredictedHomeScore']),
      predictedAwayScore: readInt(['predictedAwayScore', 'PredictedAwayScore']),
      isProcessed: readBool(['isProcessed', 'IsProcessed']),
      pointsEarned: readInt(['pointsEarned', 'PointsEarned']),
      createdAt: readDate(),
    );
  }
}
