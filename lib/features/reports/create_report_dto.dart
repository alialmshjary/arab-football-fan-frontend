class CreateReportDto {
  const CreateReportDto({
    required this.targetType,
    required this.targetId,
    required this.reason,
  });

  final int targetType;
  final int targetId;
  final int reason;

  Map<String, dynamic> toJson() {
    return {
      'targetType': targetType,
      'targetId': targetId,
      'reason': reason,
    };
  }
}