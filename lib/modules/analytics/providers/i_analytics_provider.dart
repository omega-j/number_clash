// abstract class IAnalyticsProvider {
//   /// Logs a custom event with the specified name and parameters.
//   Future<void> logEvent(String name, {Map<String, Object>? parameters});
  
//   /// Sets the user ID for the analytics provider.
//   Future<void> setUserId(String? id);
  
//   /// Sets a user property with a specified name and value.
//   Future<void> setUserProperty(String name, String value);
  
//   /// Logs a screen view event, optionally specifying the screen class.
//   Future<void> logScreenView(String screenName, {String? screenClass});
  
//   /// Enables or disables analytics tracking.
//   Future<void> setAnalyticsEnabled(bool enabled);
// }