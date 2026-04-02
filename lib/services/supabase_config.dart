import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  static const String supabaseUrl = 'https://jqefylvzvgvikkfbgupl.supabase.co';
  static const String supabaseAnonKey = 'sb_publishable_UDaZ6x_wy4H3xg6ueyysug_w_e3edf5';

  static Future<void> init() async {
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
    );
  }
}