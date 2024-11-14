import 'package:auto_route/auto_route.dart';
import 'package:flutter/widgets.dart';

import '../../screens/main_page.dart';
import '../../screens/real_time_data_page.dart';
import '../data_management/screens/data_management_page.dart';
import '../../router/router.dart';
import '../provider_setup/providers.dart';

final Map<Type, Widget> _widgetCache = {};

Widget getSingletonPageInstance(PageRouteInfo route) {
  return _widgetCache.putIfAbsent(route.runtimeType, () {
    if (route is MainRoute) {
      return MainPage();
    } else if (route is RealTimeDataRoute) {
      return RealTimeDataPage();
    } else if (route is DataManagementRoute) {
      return DataManagementPage();
    }
    throw Exception("Unknown route: $route");
  });
}

void clearPageCache() {
  _widgetCache.clear();
}