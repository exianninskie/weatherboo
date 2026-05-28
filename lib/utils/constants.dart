export '../theme/app_theme.dart' show AppColors;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConstants {
  static const String supabaseUrl = 'https://uxocyymrtwnhdyfmdvnt.supabase.co';
  static const String supabaseAnonKey = 'sb_publishable_cOii7ugj7q5mzhpmiVOk1w_XriGWbMl';
  static String get geminiApiKey => dotenv.env['GEMINI_API_KEY'] ?? '';
  static const String weatherApiKey = '26d3bfd8976b6ab0128e45b5039d2e72';
}
