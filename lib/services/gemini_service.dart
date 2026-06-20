import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'supabase_service.dart';

/// Handles every call out to Google's Gemini API.
///
/// Key resolution order (first one found wins):
///   1. A key the user typed in themselves (stored on-device only)
///   2. A global key the admin set in the admin panel (stored in Supabase
///      `app_config` table, key = 'gemini_api_key') — lets the admin
///      provide AI features to everyone without each user needing their
///      own key.
class GeminiService {
  static const _userKeyPref = 'ebro_user_gemini_key';
  static const _userModelPref = 'ebro_user_gemini_model';

  static Future<String?> _resolveApiKey() async {
    final prefs = await SharedPreferences.getInstance();
    final userKey = prefs.getString(_userKeyPref);
    if (userKey != null && userKey.isNotEmpty) return userKey;

    // Fall back to the admin's global key from Supabase.
    return SupabaseService.getConfigValue('gemini_api_key');
  }

  static Future<String> _resolveModel() async {
    final prefs = await SharedPreferences.getInstance();
    final userModel = prefs.getString(_userModelPref);
    if (userModel != null && userModel.isNotEmpty) return userModel;

    final adminModel = await SupabaseService.getConfigValue('gemini_model');
    return adminModel ?? 'gemini-1.5-flash';
  }

  static Future<void> saveUserApiKey(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKeyPref, key);
  }

  static Future<String?> getUserApiKey() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userKeyPref);
  }

  /// Sends a prompt to Gemini and returns the plain-text response.
  /// Throws a descriptive Exception on failure so the UI can show it.
  static Future<String> generate(String prompt) async {
    final apiKey = await _resolveApiKey();
    if (apiKey == null || apiKey.isEmpty) {
      throw Exception(
        'No Gemini API key found. Add your own key in Settings, '
        'or ask the admin to set one in the Admin Panel.',
      );
    }

    final model = await _resolveModel();
    final uri = Uri.parse(
      'https://generativelanguage.googleapis.com/v1beta/models/$model:generateContent?key=$apiKey',
    );

    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'contents': [
          {'parts': [{'text': prompt}]}
        ]
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Gemini API error (${response.statusCode}): ${response.body}');
    }

    final data = jsonDecode(response.body);
    final candidates = data['candidates'] as List?;
    if (candidates == null || candidates.isEmpty) {
      throw Exception('Gemini returned no response. Try again.');
    }

    final parts = candidates[0]['content']['parts'] as List;
    return parts.map((p) => p['text'] as String).join('\n');
  }

  // ---------- Prompt templates for each AI tool ----------

  static String noBsPrompt(String input) => '''
You are a No-BS filter. The user gave you this content: "$input"

If it's a headline: rewrite it factually without clickbait in one clear sentence, then explain what the article actually says.
If it's a URL or description: describe what the page likely contains and strip manipulative language.

Format:
REAL HEADLINE: [one sentence]
WHAT'S ACTUALLY HAPPENING: [2-3 sentences]
MANIPULATION TACTICS DETECTED: [list, or "None detected"]
''';

  static String factCheckPrompt(String input) => '''
Fact-check this statement: "$input"

Format:
VERDICT: [TRUE / FALSE / MISLEADING / UNVERIFIABLE]
EXPLANATION: [2-3 sentences]
CONFIDENCE: [High/Medium/Low]
''';

  static String explainPrompt(String input) => '''
Explain this in simple, plain language a 12-year-old would understand: "$input"

Format:
SIMPLE EXPLANATION: [your explanation]
IMPORTANT TO KNOW: [key points to watch for, if any]
''';

  static String tonePrompt(String input) => '''
Analyze the tone and intent of this content: "$input"

Format:
PRIMARY TONE: [neutral/angry/fearful/manipulative/sensationalist/etc]
INTENT: [what the writer wants you to feel]
BIAS DETECTED: [yes/no + why]
VERDICT: [should you trust this content?]
''';

  static String darkPatternPrompt(String input) => '''
Analyze this for dark patterns — deceptive UI or copy designed to manipulate users: "$input"

Format:
DARK PATTERNS FOUND: [list, or "None detected"]
MANIPULATION SCORE: [1-10]
WHAT TO WATCH OUT FOR: [practical advice]
''';

  static String scamCheckPrompt(String input) => '''
Check if this is a scam, based on known fraud/phishing/spam patterns (especially in India): "$input"

Format:
SCAM LIKELIHOOD: [High/Medium/Low/Unknown]
RED FLAGS: [list, or "None found"]
WHAT TO DO: [practical advice]
''';

  static String truePricePrompt(String input) => '''
Analyze this product listing for hidden costs (shipping, GST, subscription traps): "$input"

Format:
LISTED PRICE: [from input]
ESTIMATED HIDDEN FEES: [list]
TRUE ESTIMATED PRICE: [total]
WARNING: [anything to watch for]
''';

  static String fakeReviewPrompt(String input) => '''
Analyze these reviews for authenticity (bot patterns, repetitive language, paid-review indicators): "$input"

Format:
REAL REVIEW ESTIMATE: [percentage]
RED FLAGS: [list]
TRUST SCORE: [1-10]
VERDICT: [should you trust these reviews?]
''';
}
