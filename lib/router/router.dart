import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

import '../modules/calibration/screens/calibration_completion_page.dart';
import '../modules/calibration/screens/calibration_data_page.dart';
import '../modules/calibration/screens/calibration_page.dart';
import '../modules/calibration/screens/calibration_step_page.dart';
import '../modules/data_management/screens/data_management_page.dart';
import '../screens/main_page.dart';
import '../screens/real_time_data_page.dart';
import '../modules/settings/screens/settings_page.dart';
import '../screens/setup_page.dart';

part 'router.gr.dart';

@AutoRouterConfig()
class AppRouter extends RootStackRouter {
  AppRouter({super.navigatorKey});

  @override
  List<AutoRoute> get routes => [
        CustomRoute(
          page: MainRoute.page,
          initial: true,
          transitionsBuilder: _slideTransition,
          durationInMilliseconds: 500,
        ),
        CustomRoute(
          page: SetupRoute.page,
          transitionsBuilder: _slideTransition,
          durationInMilliseconds: 500,
        ),
        CustomRoute(
          page: CalibrationRoute.page,
          transitionsBuilder: _slideTransition,
          durationInMilliseconds: 500,
        ),
        CustomRoute(
          page: CalibrationStepRoute.page,
          transitionsBuilder: _slideTransition,
          durationInMilliseconds: 500,
        ),
        CustomRoute(
          page: RealTimeDataRoute.page,
          transitionsBuilder: _slideTransition,
          durationInMilliseconds: 500,
        ),
        CustomRoute(
          page: DataManagementRoute.page,
          transitionsBuilder: _slideTransition,
          durationInMilliseconds: 500,
        ),
        CustomRoute(
          page: SettingsRoute.page,
          transitionsBuilder: _slideTransition,
          durationInMilliseconds: 500,
        ),
        CustomRoute(
          page: CalibrationDataRoute.page,
          transitionsBuilder: _slideTransition,
          durationInMilliseconds: 500,
        ),
        CustomRoute(
          page: CalibrationCompletionRoute.page,
          transitionsBuilder: _slideTransition,
          durationInMilliseconds: 500,
        ),
      ];

  // Transition builder for sliding both pages with a custom curve
  static Widget _slideTransition(
      BuildContext context,
      Animation<double> animation,
      Animation<double> secondaryAnimation,
      Widget child) {
    // Apply easing curves for smooth acceleration/deceleration
    final curvedAnimation = CurvedAnimation(
      parent: animation,
      curve: Curves.easeInOut, // Smooth start and end
    );

    final curvedSecondaryAnimation = CurvedAnimation(
      parent: secondaryAnimation,
      curve: Curves.easeInOut,
    );

    return SlideTransition(
      position: Tween<Offset>(
        begin: Offset(1.0, 0.0), // Slide in from right
        end: Offset.zero,
      ).animate(curvedAnimation),
      child: SlideTransition(
        position: Tween<Offset>(
          begin: Offset.zero, // Slide out to left
          end: Offset(-1.0, 0.0),
        ).animate(curvedSecondaryAnimation),
        child: child,
      ),
    );
  }
}