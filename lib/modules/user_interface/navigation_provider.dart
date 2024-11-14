import 'package:auto_route/auto_route.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../router/router.dart';

class NavigationProvider extends StateNotifier<PageRouteInfo> {
  PageRouteInfo? previousPage;

  NavigationProvider() : super(MainRoute());

  // Update state to a new page without widget management
  void navigateTo(PageRouteInfo newPage) {
    if (state.runtimeType != newPage.runtimeType) {
      previousPage = state;
      state = newPage;
    }
  }

  bool isBackNavigation(PageRouteInfo targetPage) {
    return previousPage?.runtimeType == targetPage.runtimeType;
  }
}