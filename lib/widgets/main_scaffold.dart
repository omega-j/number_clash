import 'dart:ui';
import 'package:beta_app/main.dart';
import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../modules/provider_setup/providers.dart';
import '../modules/theming/theme_provider.dart';
import '../modules/user_interface/navigation_provider.dart';
import '../router/router.dart';
import '../utils/common_utils.dart';
import '../utils/preferences_helper.dart';
import 'loading_widget.dart';

class MainScaffold extends ConsumerStatefulWidget {
  final Widget body;
  final String title;

  MainScaffold({
    Key? key,
    required this.body,
    required this.title,
  }) : super(key: key ?? UniqueKey());

  @override
  MainScaffoldState createState() => MainScaffoldState();
}

class MainScaffoldState extends ConsumerState<MainScaffold> {
  final FocusNode _focusNode = FocusNode();
  bool _isDrawerOpen = false;
  double _textScaler = 1.0;
  Future<Image?>? _logoFuture;

  @override
  void initState() {
    super.initState();
    _loadTextScaler();
    _initializeLogo();
  }

  Future<void> _loadTextScaler() async {
    double scaler = await PreferencesHelper.getTextScaler();
    setState(() {
      _textScaler = scaler;
    });
  }

  void _initializeLogo() {
    _logoFuture = _loadLogo();
  }

  Future<Image?> _loadLogo() async {
    final theme = ref.read(themeProviderInstance);
    return await CommonUtils.getLogoImageForApp(theme.logoPath, ref);
  }

  void _changeTextScale(double change) async {
    double newScaler = (_textScaler + change).clamp(1.0, 3.0);
    setState(() {
      _textScaler = newScaler;
    });
    await PreferencesHelper.setTextScaler(newScaler);
  }

  void _toggleDrawer() {
    setState(() {
      _isDrawerOpen = !_isDrawerOpen;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeProviderInstance);
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    return MediaQuery(
      data: MediaQuery.of(context).copyWith(
        textScaler: TextScaler.linear(_textScaler),
      ),
      child: Stack(
        children: [
          Scaffold(
            appBar: isLandscape ? null : _buildAppBar(),
            body: widget.body,
            bottomNavigationBar:
                isLandscape ? null : _buildCustomBottomAppBar(),
          ),
          if (_isDrawerOpen)
            GestureDetector(
              onTap: _toggleDrawer, // Close drawer when tapping outside
              child: Container(
                color: Colors.black.withOpacity(
                    0.3), // Transparent overlay to block interactions
                child: Stack(
                  children: [
                    Positioned(
                      left: 0,
                      top: 0,
                      bottom: 0,
                      width: MediaQuery.of(context).size.width * 0.75,
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
                        child: Container(
                          color: theme.currentThemeData.colorScheme.surface
                              .withOpacity(0.9),
                        ),
                      ),
                    ),
                    // Drawer content
                    Positioned(
                      left: 0,
                      top: 0,
                      bottom: 0,
                      width: MediaQuery.of(context).size.width * 0.75,
                      child: Material(
                        color: Colors.transparent,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SafeArea(
                              child: SizedBox(
                                height: 120,
                                child: DrawerHeader(
                                  padding: EdgeInsets.zero,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      _buildAppLogo(),
                                      const SizedBox(width: 4),
                                      Flexible(
                                        child: FittedBox(
                                          fit: BoxFit.scaleDown,
                                          child: Text(
                                            theme.appTitle,
                                            style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            _buildDrawerItem(
                                Icons.home, 'main_page', MainRoute()),
                            _buildDrawerItem(
                                Icons.build, 'setup_page', SetupRoute()),
                            _buildDrawerItem(Icons.insert_chart_outlined,
                                'real_time_data_page', RealTimeDataRoute()),
                            _buildDrawerItem(Icons.storage,
                                'data_management_page', DataManagementRoute()),
                            _buildDrawerItem(Icons.settings, 'settings_page',
                                SettingsRoute()),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    final theme = ref.read(themeProviderInstance);
    return AppBar(
      elevation: 7.0,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: Align(
              alignment: Alignment.center,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildAppLogo(),
                  const SizedBox(width: 8),
                  Flexible(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        theme.appTitle,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.text_decrease),
          onPressed: () => _changeTextScale(-0.1),
          tooltip: tr('decrease_font_size'),
        ),
        IconButton(
          icon: const Icon(Icons.text_increase),
          onPressed: () => _changeTextScale(0.1),
          tooltip: tr('increase_font_size'),
        ),
      ],
      leading: IconButton(
        icon: Icon(Icons.menu),
        onPressed: _toggleDrawer,
      ),
    );
  }

  Widget _buildAppLogo() {
    return FutureBuilder<Image?>(
      future: _logoFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const LoadingWidget(size: 23.0);
        } else if (snapshot.hasError || snapshot.data == null) {
          debugPrint('Failed to load logo in main scaffold.');
          return const Icon(Icons.apps, size: 23);
        } else {
          return ClipRect(
            child: Image(
              image: snapshot.data!.image,
              fit: BoxFit.contain,
              height: 23,
              width: 23,
            ),
          );
        }
      },
    );
  }

  Widget _buildDrawerItem(IconData icon, String label, PageRouteInfo route) {
    final currentPage = ref.watch(navigationProvider);
    return ListTile(
      leading: Icon(
        icon,
        color: currentPage.runtimeType == route.runtimeType
            ? Theme.of(context).primaryColorLight
            : Theme.of(context).primaryColorDark,
      ),
      title: Text(
        tr(label),
        style: TextStyle(
          color: currentPage.runtimeType == route.runtimeType
              ? Theme.of(context).primaryColorLight
              : Theme.of(context).primaryColorDark,
        ),
      ),
      onTap: currentPage.runtimeType == route.runtimeType
          ? null
          : () {
              ref.read(navigationProvider.notifier).navigateTo(route);
              appRouter.replace(route);
              _toggleDrawer(); // Close drawer on navigation
            },
    );
  }

  Widget _buildCustomBottomAppBar() {
    final currentPage = ref.watch(navigationProvider);
    return BottomAppBar(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildBottomNavigationItem(
            icon: Icons.home,
            route: MainRoute(),
            isSelected: currentPage.runtimeType == MainRoute,
          ),
          _buildBottomNavigationItem(
            icon: Icons.build,
            route: SetupRoute(),
            isSelected: currentPage.runtimeType == SetupRoute,
          ),
          _buildBottomNavigationItem(
            icon: Icons.insert_chart_outlined,
            route: RealTimeDataRoute(),
            isSelected: currentPage.runtimeType == RealTimeDataRoute,
          ),
          _buildBottomNavigationItem(
            icon: Icons.storage,
            route: DataManagementRoute(),
            isSelected: currentPage.runtimeType == DataManagementRoute,
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigationItem({
    required IconData icon,
    required PageRouteInfo route,
    required bool isSelected,
  }) {
    return IconButton(
      icon: Icon(
        icon,
        color: isSelected
            ? Theme.of(context).primaryColorLight
            : Theme.of(context).primaryColorDark,
      ),
      onPressed: isSelected
          ? null
          : () {
              ref.read(navigationProvider.notifier).navigateTo(route);
              appRouter.replace(route);
            },
    );
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }
}
