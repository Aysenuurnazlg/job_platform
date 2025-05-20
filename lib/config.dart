class Config {
  static const String apiUrl = 'http://127.0.0.1:8000';

  // Auth
  static String get tokenUrl => '$apiUrl/token';

  // User
  static String get meUrl => '$apiUrl/users/me'; // Güncelledik!
  static String get usersUrl => '$apiUrl/users';
  static String userDetailUrl(int id) => '$usersUrl/$id';

  // Job
  static String get jobsUrl => '$apiUrl/jobs';
  static String jobDetailUrl(int id) => '$jobsUrl/$id';
  static String jobApplicationUrl(int jobId) => '$jobsUrl/$jobId/applications';

  static Map<String, String> get headers => {
        'Content-Type': 'application/json',
      };
}
