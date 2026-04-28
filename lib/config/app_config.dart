/// Centralized application configuration.
/// All secrets, base URLs, and environment-specific values belong here.
class AppConfig {
  AppConfig._();

  static const String googleMapsApiKey =
      "AIzaSyDl8LFLQn24CbaZyQ0F4wnzoF9NY3_gMWY";

  static const String baseUrl = "https://www.ordervite.com/api";

  static const Duration autoCancelDuration = Duration(minutes: 20);
  static const Duration orderPollingInterval = Duration(seconds: 10);
}
