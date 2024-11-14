import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'modules/database/models/data_record.dart';
import 'modules/localization/providers/i_localization_provider.dart';
import 'modules/localization/providers/locales_provider.dart';
import 'modules/provider_setup/providers.dart';
import 'router/router.dart';
import 'widgets/loading_page.dart';
import 'widgets/main_scaffold.dart';

final appRouter = AppRouter();

Future<void> initializeApp(ProviderContainer container) async {
  // Initialize other services here, like Firebase if needed
  await EasyLocalization.ensureInitialized();
  print("EasyLocalization initialized");

  final localizationInitResult =
      await container.read(localizationProvider.notifier).initialize();
  print("Localization initialized: $localizationInitResult");

  // Initialize logging listener
  container.read(logListenerProvider).initialize();
  print("LogListener initialized");

  // Initialize the database provider
  final database = container.read(databaseProvider.notifier);
  await database.init();
  print("Database initialized");
}

void main() async {
  await Hive.initFlutter();
  Hive.registerAdapter(DataRecordAdapter());
  WidgetsFlutterBinding.ensureInitialized();

  final container = ProviderContainer();

  try {
    await initializeApp(container);

    FlutterError.onError = (FlutterErrorDetails details) {
      container.read(loggingProvider).logError(
            details.exceptionAsString(),
            stackTrace: details.stack,
          );
    };

    runZonedGuarded(() {
      runApp(ProviderScope(
        parent: container,
        child: const AlphaApp(),
      ));
    }, (error, stackTrace) {
      container.read(loggingProvider).logError(
            "Unhandled async error: $error",
            stackTrace: stackTrace,
          );
    });
  } catch (e) {
    print("Initialization error: $e");
  }
}

class AlphaApp extends ConsumerWidget {
  const AlphaApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localizationNotifier = ref.watch(localizationProvider.notifier);
    final localizationState = ref.watch(localizationProvider);

    // Show loading screen if LocalizationProvider is loading
    if (localizationNotifier.isLoading) {
      return const LoadingPage();
    }

    // Ensure EasyLocalization follows current language changes
    ref.listen<ILocalizationProvider>(localizationProvider.notifier, (_, __) {
      EasyLocalization.of(context)
          ?.setLocale(Locale(localizationNotifier.currentLanguageCode.value));
    });

    final supportedLocalesAsync = ref.watch(supportedLocalesProvider);
    final themeProvider = ref.watch(themeProviderInstance);

    // Configure light and dark themes
    final effectiveLightTheme = themeProvider.isInitialized
        ? themeProvider.lightThemeData
        : ThemeData(primarySwatch: Colors.blue, brightness: Brightness.light);

    final effectiveDarkTheme = themeProvider.isInitialized
        ? themeProvider.darkThemeData
        : ThemeData(
            primarySwatch: Colors.blueGrey, brightness: Brightness.dark);

    final effectiveThemeMode =
        themeProvider.isInitialized ? themeProvider.themeMode : ThemeMode.light;

    // Use supported locales to set EasyLocalization
    return supportedLocalesAsync.when(
      data: (supportedLocales) => EasyLocalization(
        supportedLocales: supportedLocales,
        path: 'assets/translations',
        fallbackLocale: const Locale('en'),
        startLocale: Locale(localizationNotifier.currentLanguageCode.value),
        child: Builder(
          builder: (context) => MaterialApp.router(
            title: tr('app_title'),
            theme: effectiveLightTheme,
            darkTheme: effectiveDarkTheme,
            themeMode: effectiveThemeMode,
            locale: context.locale,
            supportedLocales: supportedLocales,
            localizationsDelegates: EasyLocalization.of(context)?.delegates,
            routerDelegate: appRouter.delegate(),
            routeInformationParser: appRouter.defaultRouteParser(),
            builder: (context, child) => Overlay(
              initialEntries: [
                OverlayEntry(
                  builder: (context) => MainScaffold(
                    title: tr('app_title'),
                    body: child ?? const SizedBox.shrink(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      loading: () => const LoadingPage(),
      error: (err, stack) {
        ref.read(loggingProvider).logError("Error loading locales: $err");
        return Center(child: Text('Error loading locales: $err'));
      },
    );
  }
}