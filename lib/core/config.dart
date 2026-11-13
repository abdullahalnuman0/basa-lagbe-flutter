abstract final class AppConfig {
  // static const baseUrl = 'http://192.168.0.132:8081/api/v1/';
  static const baseUrl = String.fromEnvironment(
    'BASE_URL',
    defaultValue: 'https://basha-lagbe-backend.onrender.com/api/v1/',
  );

  static const appName = 'DormEasy';
}
