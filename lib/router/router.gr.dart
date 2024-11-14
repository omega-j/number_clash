// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

part of 'router.dart';

/// generated route for
/// [CalibrationCompletionPage]
class CalibrationCompletionRoute
    extends PageRouteInfo<CalibrationCompletionRouteArgs> {
  CalibrationCompletionRoute({
    Key? key,
    List<PageRouteInfo>? children,
  }) : super(
          CalibrationCompletionRoute.name,
          args: CalibrationCompletionRouteArgs(key: key),
          initialChildren: children,
        );

  static const String name = 'CalibrationCompletionRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<CalibrationCompletionRouteArgs>(
          orElse: () => const CalibrationCompletionRouteArgs());
      return CalibrationCompletionPage(key: args.key);
    },
  );
}

class CalibrationCompletionRouteArgs {
  const CalibrationCompletionRouteArgs({this.key});

  final Key? key;

  @override
  String toString() {
    return 'CalibrationCompletionRouteArgs{key: $key}';
  }
}

/// generated route for
/// [CalibrationDataPage]
class CalibrationDataRoute extends PageRouteInfo<CalibrationDataRouteArgs> {
  CalibrationDataRoute({
    Key? key,
    List<PageRouteInfo>? children,
  }) : super(
          CalibrationDataRoute.name,
          args: CalibrationDataRouteArgs(key: key),
          initialChildren: children,
        );

  static const String name = 'CalibrationDataRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<CalibrationDataRouteArgs>(
          orElse: () => const CalibrationDataRouteArgs());
      return CalibrationDataPage(key: args.key);
    },
  );
}

class CalibrationDataRouteArgs {
  const CalibrationDataRouteArgs({this.key});

  final Key? key;

  @override
  String toString() {
    return 'CalibrationDataRouteArgs{key: $key}';
  }
}

/// generated route for
/// [CalibrationPage]
class CalibrationRoute extends PageRouteInfo<CalibrationRouteArgs> {
  CalibrationRoute({
    Key? key,
    List<PageRouteInfo>? children,
  }) : super(
          CalibrationRoute.name,
          args: CalibrationRouteArgs(key: key),
          initialChildren: children,
        );

  static const String name = 'CalibrationRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<CalibrationRouteArgs>(
          orElse: () => const CalibrationRouteArgs());
      return CalibrationPage(key: args.key);
    },
  );
}

class CalibrationRouteArgs {
  const CalibrationRouteArgs({this.key});

  final Key? key;

  @override
  String toString() {
    return 'CalibrationRouteArgs{key: $key}';
  }
}

/// generated route for
/// [CalibrationStepPage]
class CalibrationStepRoute extends PageRouteInfo<CalibrationStepRouteArgs> {
  CalibrationStepRoute({
    Key? key,
    List<PageRouteInfo>? children,
  }) : super(
          CalibrationStepRoute.name,
          args: CalibrationStepRouteArgs(key: key),
          initialChildren: children,
        );

  static const String name = 'CalibrationStepRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<CalibrationStepRouteArgs>(
          orElse: () => const CalibrationStepRouteArgs());
      return CalibrationStepPage(key: args.key);
    },
  );
}

class CalibrationStepRouteArgs {
  const CalibrationStepRouteArgs({this.key});

  final Key? key;

  @override
  String toString() {
    return 'CalibrationStepRouteArgs{key: $key}';
  }
}

/// generated route for
/// [DataManagementPage]
class DataManagementRoute extends PageRouteInfo<DataManagementRouteArgs> {
  DataManagementRoute({
    Key? key,
    List<PageRouteInfo>? children,
  }) : super(
          DataManagementRoute.name,
          args: DataManagementRouteArgs(key: key),
          initialChildren: children,
        );

  static const String name = 'DataManagementRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<DataManagementRouteArgs>(
          orElse: () => const DataManagementRouteArgs());
      return DataManagementPage(key: args.key);
    },
  );
}

class DataManagementRouteArgs {
  const DataManagementRouteArgs({this.key});

  final Key? key;

  @override
  String toString() {
    return 'DataManagementRouteArgs{key: $key}';
  }
}

/// generated route for
/// [MainGamePage]
class MainGameRoute extends PageRouteInfo<void> {
  const MainGameRoute({List<PageRouteInfo>? children})
      : super(
          MainGameRoute.name,
          initialChildren: children,
        );

  static const String name = 'MainGameRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const MainGamePage();
    },
  );
}

/// generated route for
/// [MainPage]
class MainRoute extends PageRouteInfo<MainRouteArgs> {
  MainRoute({
    Key? key,
    List<PageRouteInfo>? children,
  }) : super(
          MainRoute.name,
          args: MainRouteArgs(key: key),
          initialChildren: children,
        );

  static const String name = 'MainRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args =
          data.argsAs<MainRouteArgs>(orElse: () => const MainRouteArgs());
      return MainPage(key: args.key);
    },
  );
}

class MainRouteArgs {
  const MainRouteArgs({this.key});

  final Key? key;

  @override
  String toString() {
    return 'MainRouteArgs{key: $key}';
  }
}

/// generated route for
/// [RealTimeDataPage]
class RealTimeDataRoute extends PageRouteInfo<RealTimeDataRouteArgs> {
  RealTimeDataRoute({
    Key? key,
    List<PageRouteInfo>? children,
  }) : super(
          RealTimeDataRoute.name,
          args: RealTimeDataRouteArgs(key: key),
          initialChildren: children,
        );

  static const String name = 'RealTimeDataRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<RealTimeDataRouteArgs>(
          orElse: () => const RealTimeDataRouteArgs());
      return RealTimeDataPage(key: args.key);
    },
  );
}

class RealTimeDataRouteArgs {
  const RealTimeDataRouteArgs({this.key});

  final Key? key;

  @override
  String toString() {
    return 'RealTimeDataRouteArgs{key: $key}';
  }
}

/// generated route for
/// [SettingsPage]
class SettingsRoute extends PageRouteInfo<SettingsRouteArgs> {
  SettingsRoute({
    Key? key,
    List<PageRouteInfo>? children,
  }) : super(
          SettingsRoute.name,
          args: SettingsRouteArgs(key: key),
          initialChildren: children,
        );

  static const String name = 'SettingsRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<SettingsRouteArgs>(
          orElse: () => const SettingsRouteArgs());
      return SettingsPage(key: args.key);
    },
  );
}

class SettingsRouteArgs {
  const SettingsRouteArgs({this.key});

  final Key? key;

  @override
  String toString() {
    return 'SettingsRouteArgs{key: $key}';
  }
}

/// generated route for
/// [SetupPage]
class SetupRoute extends PageRouteInfo<SetupRouteArgs> {
  SetupRoute({
    Key? key,
    List<PageRouteInfo>? children,
  }) : super(
          SetupRoute.name,
          args: SetupRouteArgs(key: key),
          initialChildren: children,
        );

  static const String name = 'SetupRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args =
          data.argsAs<SetupRouteArgs>(orElse: () => const SetupRouteArgs());
      return SetupPage(key: args.key);
    },
  );
}

class SetupRouteArgs {
  const SetupRouteArgs({this.key});

  final Key? key;

  @override
  String toString() {
    return 'SetupRouteArgs{key: $key}';
  }
}
