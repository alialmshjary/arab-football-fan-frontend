class PaginatedResult<T> {
  const PaginatedResult({
    required this.items,
    required this.currentPage,
    required this.totalPage,
    required this.totalCount,
    required this.pageSize,
    required this.hasPreviousPage,
    required this.hasNextPage,
  });

  final List<T> items;
  final int currentPage;
  final int totalPage;
  final int totalCount;
  final int pageSize;
  final bool hasPreviousPage;
  final bool hasNextPage;

  factory PaginatedResult.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic json) itemDecoder,
  ) {
    int parseInt(dynamic value) {
      if (value is int) return value;
      return int.tryParse('$value') ?? 0;
    }

    bool parseBool(dynamic value) {
      if (value is bool) return value;
      return value.toString().toLowerCase() == 'true';
    }

    final rawItems = json['items'] ?? json['Items'] ?? [];

    return PaginatedResult<T>(
      items: rawItems is List ? rawItems.map(itemDecoder).toList() : <T>[],
      currentPage: parseInt(json['currentPage'] ?? json['CurrentPage']),
      totalPage: parseInt(json['totalPage'] ?? json['TotalPage']),
      totalCount: parseInt(json['totalCount'] ?? json['TotalCount']),
      pageSize: parseInt(json['pageSize'] ?? json['PageSize']),
      hasPreviousPage: parseBool(json['hasPreviousPage'] ?? json['HasPreviousPage']),
      hasNextPage: parseBool(json['hasNextPage'] ?? json['HasNextPage']),
    );
  }
}