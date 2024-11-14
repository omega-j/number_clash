import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../router/router.dart';
import '../modules/provider_setup/providers.dart';
import 'package:auto_size_text/auto_size_text.dart';

@RoutePage()
class MainPage extends ConsumerWidget {
  MainPage({Key? key})
      : super(key: key ?? GlobalKey(debugLabel: 'MainPage-${UniqueKey()}'));

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final localization = ref.watch(localizationProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: Text(localization.translate('dashboard')),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              localization.translate('welcome'),
              style: theme.textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            // Interactive Quick Access Grid
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                children: [
                  _buildDashboardCard(
                    context,
                    icon: Icons.settings,
                    label: localization.translate('setup_device'),
                    onTap: () => context.router.push(SetupRoute()),
                  ),
                  _buildDashboardCard(
                    context,
                    icon: Icons.tune,
                    label: localization.translate('calibrate_device'),
                    onTap: () => context.router.push(CalibrationRoute()),
                  ),
                  _buildDashboardCard(
                    context,
                    icon: Icons.show_chart,
                    label: localization.translate('view_real_time_data'),
                    onTap: () => context.router.push(RealTimeDataRoute()),
                  ),
                  _buildDashboardCard(
                    context,
                    icon: Icons.storage,
                    label: localization.translate('data_management_page'),
                    onTap: () => context.router.push(DataManagementRoute()),
                  ),
                  _buildDashboardCard(
                    context,
                    icon: Icons.settings_applications,
                    label: localization.translate('settings_page'),
                    onTap: () => context.router.push(SettingsRoute()),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Data Summary Section
            Text(
              localization.translate('recent_activity'),
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(8.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 4,
                    offset: Offset(2, 2),
                  ),
                ],
              ),
              child: Text(
                localization.translate('recent_activity_placeholder'),
                style: theme.textTheme.bodyLarge,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardCard(BuildContext context,
    {required IconData icon,
    required String label,
    required VoidCallback onTap}) {
  final theme = Theme.of(context);
  return GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(2, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 36, color: theme.colorScheme.primary),
          const SizedBox(height: 8),
          AutoSizeText(
            label,
            style: theme.textTheme.titleMedium,
            textAlign: TextAlign.center,
            maxLines: 2, // Limits the number of lines to prevent overflow
            minFontSize: 10, // Smallest font size to avoid unreadably small text
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    ),
  );
}
}
