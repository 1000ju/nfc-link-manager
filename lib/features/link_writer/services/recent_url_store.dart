import 'package:shared_preferences/shared_preferences.dart';

abstract interface class RecentUrlStore {
  Future<String?> loadRecentUrl();

  Future<void> saveRecentUrl(String url);

  Future<void> clearRecentUrl();
}

final class SharedPreferencesRecentUrlStore implements RecentUrlStore {
  const SharedPreferencesRecentUrlStore();

  static const recentUrlKey = 'recent_url';

  @override
  Future<String?> loadRecentUrl() async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.getString(recentUrlKey);
  }

  @override
  Future<void> saveRecentUrl(String url) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(recentUrlKey, url);
  }

  @override
  Future<void> clearRecentUrl() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.remove(recentUrlKey);
  }
}
