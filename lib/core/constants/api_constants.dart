class ApiConstants {
  ApiConstants._();

  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:5259',
  );

  static const String auth = '/api/Auth';
  static const String fans = '/api/Fans';
  static const String posts = '/api/Posts';
  static const String comments = '/api/Comments';
  static const String likes = '/api/Likes';
  static const String bookmarks = '/api/Bookmarks';
  static const String predictions = '/api/Predictions';
  static const String follows = '/api/Fans';
  static const String matches = '/api/Matches';
  static const String chats = '/api/Chats';
}
