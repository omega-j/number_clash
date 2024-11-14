// import 'package:firebase_analytics/firebase_analytics.dart';
// import 'i_analytics_provider.dart';

// class FirebaseAnalyticsProvider implements IAnalyticsProvider {
//   // Singleton instance
//   static final FirebaseAnalyticsProvider _instance = FirebaseAnalyticsProvider._internal();

//   // Private FirebaseAnalytics instance
//   final FirebaseAnalytics _firebaseAnalytics;

//   // Private internal constructor
//   FirebaseAnalyticsProvider._internal() : _firebaseAnalytics = FirebaseAnalytics.instance;

//   // Factory constructor to return the singleton instance
//   factory FirebaseAnalyticsProvider() {
//     return _instance;
//   }

//   @override
//   Future<void> logEvent(String name, {Map<String, Object>? parameters}) async {
//     await _firebaseAnalytics.logEvent(
//       name: name,
//       parameters: parameters,
//     );
//   }

//   @override
//   Future<void> setUserId(String? id) async {
//     await _firebaseAnalytics.setUserId(id: id);
//   }

//   @override
//   Future<void> setUserProperty(String name, String value) async {
//     await _firebaseAnalytics.setUserProperty(name: name, value: value);
//   }

//   @override
//   Future<void> logScreenView(String screenName, {String? screenClass}) async {
//     await _firebaseAnalytics.logEvent(
//       name: 'screen_view',
//       parameters: {
//         'screen_name': screenName,
//         'screen_class': screenClass ?? 'Flutter',
//       },
//     );
//   }

//   @override
//   Future<void> setAnalyticsEnabled(bool enabled) async {
//     if (!enabled) {
//       await logEvent('analytics_disabled');
//     }
//   }
// }