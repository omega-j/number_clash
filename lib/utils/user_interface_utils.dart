import 'package:beta_app/widgets/universal_modal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../enums/common_enums.dart';
import '../modules/analytics/providers/i_analytics_provider.dart';
import '../modules/localization/providers/i_localization_provider.dart';
import '../modules/provider_setup/providers.dart';

class UserInterfaceUtils {
  // Removed `late` and `initialize` method; refactored to direct access
  // static IAnalyticsProvider getAnalyticsProvider(WidgetRef ref) =>
  //     ref.read(analyticsProvider);

  static ILocalizationProvider getLocalizationController(WidgetRef ref) =>
      ref.watch(localizationProvider.notifier);

  static Widget buildIconButton(BuildContext context, WidgetRef ref,
      {required IconData icon,
      required String labelKey,
      required VoidCallback? onPressed}) {
    final localizationController = getLocalizationController(ref);
    return Semantics(
      label: localizationController.translate(labelKey),
      child: IconButton(
        icon: Icon(icon),
        onPressed: onPressed,
      ),
    );
  }

  static Future<void> showErrorMessage(
    BuildContext context,
    String message, {
    VoidCallback? onOk,
    VoidCallback? onNo,
  }) {
    return showDialog(
      context: context,
      builder: (context) {
        return UniversalModal(
          type: DialogType.error,
          message: message,
          onOk: () {
            if (onOk != null) {
              onOk();
            }
          },
          onNo: () {
            if (onNo != null) {
              onNo();
            }
          },
        );
      },
    );
  }
}
