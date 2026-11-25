/// "Login" is just the student ID typed in. No passwords, no Firebase Auth.
/// Kept in memory only (no plugins), so it is forgotten when the app restarts.
class StudentSession {
  static String? _id;

  static Future<String?> load() async => _id;

  static Future<void> save(String id) async => _id = id;

  static Future<void> clear() async => _id = null;
}
