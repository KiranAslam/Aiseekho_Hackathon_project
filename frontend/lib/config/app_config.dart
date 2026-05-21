class AppConfig {
  const AppConfig._();

  static const appName = 'Rahe-Sehat Healthcare AI';
  static const tagline = 'AI healthcare coordination for urgent care decisions';
  static const defaultCity = String.fromEnvironment(
    'DEFAULT_CITY',
    defaultValue: 'Karachi',
  );
  static const apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://kcu28-aiseekho-backend.hf.space',
  );
}
