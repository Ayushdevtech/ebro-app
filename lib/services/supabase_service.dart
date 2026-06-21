import 'package:supabase_flutter/supabase_flutter.dart';

/// Wraps every Supabase call the app needs: auth, history, bookmarks,
/// and reading admin-set config (like which Gemini key/model to use).
///
/// IMPORTANT — fill these in before running the app:
///   1. Create a project at https://supabase.com
///   2. Run the SQL in supabase_schema.sql (same one used for the web version)
///   3. Paste your Project URL and anon key below.
class SupabaseConfig {
  static const String url = 'https://jjtrddbxjalpzwgvrqxy.supabase.co';
  static const String anonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImpqdHJkZGJ4amFscHp3Z3ZycXh5Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODE0NDgxNTYsImV4cCI6MjA5NzAyNDE1Nn0.Cq6uGXrIDMu-MYgHmJ0UBrv-6BYoPObvMdDQhvumaOg';
}

class SupabaseService {
  static final SupabaseClient client = Supabase.instance.client;

  static Future<void> init() async {
    await Supabase.initialize(
      url: SupabaseConfig.url,
      anonKey: SupabaseConfig.anonKey,
    );
  }

  static User? get currentUser => client.auth.currentUser;
  static bool get isLoggedIn => currentUser != null;

  // ---------- AUTH ----------

  static Future<String?> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final res = await client.auth.signUp(
        email: email,
        password: password,
        data: {'full_name': name},
      );
      if (res.user != null) {
        await client.from('users').insert({
          'id': res.user!.id,
          'email': email,
          'full_name': name,
          'plan': 'free',
          'pages_visited': 0,
          'trackers_blocked': 0,
          'ads_blocked': 0,
        });
      }
      return null; // null means success
    } catch (e) {
      return e.toString();
    }
  }

  static Future<String?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      await client.auth.signInWithPassword(email: email, password: password);
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  static Future<void> signOut() async {
    await client.auth.signOut();
  }

  // ---------- PROFILE ----------

  static Future<Map<String, dynamic>?> getProfile() async {
    final user = currentUser;
    if (user == null) return null;
    final data = await client.from('users').select().eq('id', user.id).maybeSingle();
    return data;
  }

  static Future<void> updateName(String name) async {
    final user = currentUser;
    if (user == null) return;
    await client.from('users').update({'full_name': name}).eq('id', user.id);
  }

  static Future<void> incrementPagesVisited() async {
    final user = currentUser;
    if (user == null) return;
    await client.rpc('increment_pages_visited', params: {'uid': user.id}).catchError((_) {
      // Falls back silently if the RPC function hasn't been created —
      // see supabase_schema.sql for the optional increment function.
    });
  }

  // ---------- HISTORY ----------

  static Future<void> addHistory(String url, String title) async {
    final user = currentUser;
    if (user == null) return;
    await client.from('history').insert({
      'user_id': user.id,
      'url': url,
      'title': title,
    });
  }

  static Future<List<Map<String, dynamic>>> getHistory({int limit = 50}) async {
    final user = currentUser;
    if (user == null) return [];
    final data = await client
        .from('history')
        .select()
        .eq('user_id', user.id)
        .order('visited_at', ascending: false)
        .limit(limit);
    return List<Map<String, dynamic>>.from(data);
  }

  static Future<void> clearHistory() async {
    final user = currentUser;
    if (user == null) return;
    await client.from('history').delete().eq('user_id', user.id);
  }

  // ---------- BOOKMARKS ----------

  static Future<void> addBookmark(String url, String title, {String? summary}) async {
    final user = currentUser;
    if (user == null) return;
    await client.from('bookmarks').insert({
      'user_id': user.id,
      'url': url,
      'title': title,
      'summary': summary,
    });
  }

  static Future<List<Map<String, dynamic>>> getBookmarks() async {
    final user = currentUser;
    if (user == null) return [];
    final data = await client
        .from('bookmarks')
        .select()
        .eq('user_id', user.id)
        .order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(data);
  }

  static Future<void> removeBookmark(int id) async {
    await client.from('bookmarks').delete().eq('id', id);
  }

  // ---------- ADMIN-CONFIGURED SETTINGS ----------
  // The admin panel writes rows into an `app_config` table (key/value).
  // This lets the admin change the Gemini API key or model without
  // anyone having to rebuild and resubmit the app.

  static Future<String?> getConfigValue(String key) async {
    try {
      final data = await client.from('app_config').select('value').eq('key', key).maybeSingle();
      return data?['value'] as String?;
    } catch (_) {
      return null;
    }
  }
}
