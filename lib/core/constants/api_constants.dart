class ApiConstants {
  ApiConstants._();

  static const String serverUrl = String.fromEnvironment(
    'API_SERVER_URL',
    defaultValue: 'http://10.0.2.2:5259',
  );

  static const String baseUrl = '$serverUrl/api';

  static const String auth = '/api/Auth';
  static const String fans = '/api/Fans';
  static const String posts = '/api/Posts';
  static const String comments = '/api/Comments';
  static const String likes = '/api/Likes';
  static const String bookmarks = '/api/Bookmarks';
  static const String follows = '/api/Fans';
  static const String matches = '/api/Matches';
  static const String chats = '/api/Chats';
  static const String chatMembers = '/api/ChatMembers';
  static const String messages = '/api/Message';
  static const String reports = '/api/Reports';
}
