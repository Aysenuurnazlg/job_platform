class ApiConfig {
  static const String baseUrl = 'http://127.0.0.1:8000';

  // Auth endpoints
  static String get tokenUrl => '$baseUrl/token';

  // Job endpoints
  static String get jobsUrl => '$baseUrl/jobs';
  static String jobDetailUrl(int id) => '$jobsUrl/$id';
  static String jobApplicationUrl(int jobId) => '$jobsUrl/$jobId/applications';

  // User endpoints
  static String get usersUrl => '$baseUrl/users';
  static String userDetailUrl(int id) => '$usersUrl/$id';
}
