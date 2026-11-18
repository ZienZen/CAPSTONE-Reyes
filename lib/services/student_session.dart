import 'package:shared_preferences/shared_preferences.dart';

/// "Login" is just a remembered student ID. No passwords, no Firebase Auth.
class StudentSession {
  static const _key = 'student_id';

  static Future<String?> load() async {
    final p = await SharedPreferences.getInstance();
    return p.getString(_key);
  }

  static Future<void> save(String id) async {
    final p = await SharedPreferences.getInstance();
    await p.setString(_key, id);
  }

  static Future<void> clear() async {
    final p = await SharedPreferences.getInstance();
    await p.remove(_key);
  }
}
