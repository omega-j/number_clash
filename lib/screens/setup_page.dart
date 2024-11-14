import 'package:auto_route/auto_route.dart';
import 'package:beta_app/modules/bluetooth_management/models/responses/info_response.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import '../enums/bluetooth_enums.dart';
import '../modules/bluetooth_management/providers/bluetooth_datasource_provider.dart';
import '../router/router.dart';
import '../modules/theming/theme_provider.dart';
import '../modules/provider_setup/providers.dart';

@RoutePage()
class SetupPage extends ConsumerWidget {
  SetupPage({Key? key}) : super(key: key ?? UniqueKey());

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeProviderInstance);
final bluetooth = ref.watch(bluetoothDatasourceProvider);
    final connectionStatus = ref.watch(connectionStatusProvider).asData?.value;
    final availableDevices =
        ref.watch(availableDevicesProvider).asData?.value ?? [];
    final deviceInfo = ref.watch(deviceInfoProvider);
    final isScanning = ref.watch(isScanningProvider).asData?.value ?? false;
    final isDeviceConnected = bluetooth.isConnected;

    return Scaffold(
      appBar: AppBar(
        title: Text('setup_page_title'.tr()),
        backgroundColor: theme.currentThemeData.appBarTheme.backgroundColor,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildScanButton(ref, isScanning),
            if (isDeviceConnected) const SizedBox(height: 20),
            if (isDeviceConnected)
              _buildCalibrationNavigationButton(ref, context),
            _buildScanError(ref, theme),
            const SizedBox(height: 20),
            _buildStatusBox(ref, theme),
            if (isDeviceConnected && !isScanning) const SizedBox(height: 20),
            if (isDeviceConnected && !isScanning)
              _buildDeviceInfoDisplay(ref, theme, deviceInfo),
            const SizedBox(height: 20),
            if (!isScanning)
              _buildDeviceList(ref, theme, availableDevices, connectionStatus),
          ],
        ),
      ),
      floatingActionButton:
          isDeviceConnected ? _buildCalibrationControls(context) : null,
    );
  }

  Widget _buildStatusBox(WidgetRef ref, ThemeProvider theme) {
    final connectionStatus = ref.watch(connectionStatusProvider).asData?.value;
    final message = _getConnectionStatusMessage(connectionStatus);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      child: Text(
        message,
        style: theme.currentThemeData.textTheme.bodyLarge,
        semanticsLabel: message,
      ),
    );
  }

  Widget _buildScanButton(WidgetRef ref, bool isScanning) {
    return ElevatedButton(
      onPressed: isScanning
          ? ref.read(bluetoothDatasourceProvider).stopScan
          : () => _startScan(ref),
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(double.infinity, 48),
      ),
      child: isScanning
          ? Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 4,
                    semanticsLabel: 'scanning_indicator'.tr(),
                  ),
                ),
                const SizedBox(width: 10),
                Text('cancel_scan'.tr()),
              ],
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.search),
                const SizedBox(width: 8),
                Text('scan_for_devices'.tr()),
              ],
            ),
    );
  }

  Widget _buildDeviceInfoDisplay(
      WidgetRef ref, ThemeProvider theme, InfoResponse? deviceInfo) {
    if (deviceInfo == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: theme.currentThemeData.colorScheme.surface,
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'device_information'.tr(),
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Text('${'product_id'.tr()}: ${deviceInfo.productID}'),
          Text('${'serial_number'.tr()}: ${deviceInfo.serialNumber}'),
          Text(
              '${'firmware_version'.tr()}: ${deviceInfo.firmwareMajor}.${deviceInfo.firmwareMinor}'),
          Text('${'hardware_version'.tr()}: ${deviceInfo.hardwareVersion}'),
          Text('${'output_type'.tr()}: ${deviceInfo.outputType}'),
          Text(
              '${'auto_notify'.tr()}: ${deviceInfo.autoNotifyEnabled ? 'enabled'.tr() : 'disabled'.tr()}'),
          Text(
            '${'interval'.tr()}: ${'interval_seconds'.plural(deviceInfo.interval, namedArgs: {
                  'interval': deviceInfo.interval.toString()
                })}',
          ),
        ],
      ),
    );
  }

  Widget _buildDeviceList(
      WidgetRef ref,
      ThemeProvider theme,
      List<BluetoothDevice> availableDevices,
      BleConnectionStatusCode? connectionStatus) {
    if (availableDevices.isEmpty &&
        connectionStatus == BleConnectionStatusCode.scanCompleted) {
      return Text(
        'no_devices_found'.tr(),
        style: theme.currentThemeData.textTheme.bodyMedium,
      );
    }

    return Column(
      children: availableDevices
          .map((device) => _buildDeviceTile(ref, theme, device))
          .toList(),
    );
  }

  Widget _buildDeviceTile(
      WidgetRef ref, ThemeProvider theme, BluetoothDevice device) {
    final bluetoothDatasource = ref.read(bluetoothDatasourceProvider);
    final isConnected = bluetoothDatasource.connectedDevice == device;

    return Container(
      margin: const EdgeInsets.only(bottom: 12.0),
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: theme.currentThemeData.colorScheme.surface,
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(device.name, style: theme.currentThemeData.textTheme.bodyLarge),
          const SizedBox(height: 8),
          Text(device.id.toString(),
              style: theme.currentThemeData.textTheme.bodySmall),
          const SizedBox(height: 8),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 48),
            ),
            onPressed: isConnected
                ? bluetoothDatasource.disconnect
                : () => _connectToDevice(ref, device),
            child: Text(isConnected ? 'disconnect'.tr() : 'connect'.tr()),
          ),
        ],
      ),
    );
  }

  Widget _buildCalibrationNavigationButton(
      WidgetRef ref, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: ElevatedButton.icon(
        icon: Icon(Icons.tune),
        label: Text('begin_calibration_process'.tr()),
        onPressed: () => context.router.push(CalibrationRoute()),
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(double.infinity, 48),
        ),
      ),
    );
  }

  Widget _buildScanError(WidgetRef ref, ThemeProvider theme) {
    final scanError = ref.watch(scanErrorProvider).asData?.value;
    return scanError?.isNotEmpty ?? false
        ? Padding(
            padding: const EdgeInsets.only(top: 20),
            child: Text(
              scanError!,
              semanticsLabel: 'scan_error'.tr(),
              style: theme.currentThemeData.textTheme.bodyLarge,
            ),
          )
        : const SizedBox.shrink();
  }

  Widget _buildCalibrationControls(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 10),
      ],
    );
  }

  void _startScan(WidgetRef ref) {
    final bluetoothDatasource = ref.read(bluetoothDatasourceProvider);
    bluetoothDatasource.startScan();
  }

  void _connectToDevice(WidgetRef ref, BluetoothDevice device) async {
    final bluetoothController = ref.read(bluetoothDatasourceProvider);
    final result = await bluetoothController.connectToDevice(device);

    if (result.isSuccessfulAndDataIsNotNull) {
      ref.read(deviceInfoProvider.notifier).state = result.data;
    }
  }

  String _getConnectionStatusMessage(BleConnectionStatusCode? statusCode) {
    if (statusCode == BleConnectionStatusCode.connected) {
      return "${'congratulations_connected_message'.tr()}\n${'ready_for_calibration'.tr()}";
    }
    switch (statusCode) {
      case BleConnectionStatusCode.scanning:
        return 'scanning_message'.tr();
      case BleConnectionStatusCode.scanCompleted:
        return 'devices_found_message'.tr();
      case BleConnectionStatusCode.disconnected:
        return 'disconnected_message'.tr();
      default:
        return 'setup_welcome_message'.tr();
    }
  }
}
