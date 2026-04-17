class EnvironmentConfig {
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://gzbunfngfjvxxsjzjabu.supabase.co',
  );

  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imd6YnVuZm5nZmp2eHhzanpqYWJ1Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzU1NjAyOTYsImV4cCI6MjA5MTEzNjI5Nn0.BNxrxIXikLU3HgLcY5gCoCLmpPLPQUuUnfS35k0gpiI',
  );

  static const String openaiApiKey = String.fromEnvironment(
    'OPENAI_API_KEY',
    defaultValue: '',
  );

  static bool get isProduction => const bool.fromEnvironment('dart.vm.product');
}
