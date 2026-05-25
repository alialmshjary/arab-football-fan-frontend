class DateTimeUtils {
  const DateTimeUtils._();

  /// Parses dates coming from the ASP.NET API.
  ///
  /// The backend stores dates with DateTime.UtcNow, but SQL Server/ASP.NET may
  /// serialize them without a trailing `Z`, for example: 2026-05-24T18:30:00.
  /// Dart treats values without timezone as local time, which causes the UI to
  /// show an incorrect relative time such as "منذ 4 س" right after publishing.
  /// This helper treats timezone-less API dates as UTC, then converts them to
  /// the device local time before the app calculates "time ago".
  static DateTime parseApiUtcDate(dynamic value, {DateTime? fallback}) {
    final safeFallback = fallback ?? DateTime.now();

    if (value == null) return safeFallback;
    if (value is DateTime) {
      return value.isUtc ? value.toLocal() : value;
    }

    var raw = value.toString().trim();
    if (raw.isEmpty || raw.toLowerCase() == 'null') return safeFallback;

    // Normalize SQL Server precision when it is longer than Dart needs.
    // Example: 2026-05-24T18:30:00.1234567
    final fractionalMatch = RegExp(r'^(.*\.)(\d{6})\d+(.*)$').firstMatch(raw);
    if (fractionalMatch != null) {
      raw = '${fractionalMatch.group(1)}${fractionalMatch.group(2)}${fractionalMatch.group(3)}';
    }

    final hasTimeZone = raw.endsWith('Z') || RegExp(r'[+-]\d{2}:?\d{2}$').hasMatch(raw);
    final normalized = hasTimeZone ? raw : '${raw}Z';

    final parsed = DateTime.tryParse(normalized);
    if (parsed == null) return safeFallback;

    return parsed.isUtc ? parsed.toLocal() : parsed;
  }
}
