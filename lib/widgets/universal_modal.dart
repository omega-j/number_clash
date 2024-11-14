import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../enums/common_enums.dart';
import '../modules/analytics/providers/i_analytics_provider.dart';
import '../modules/localization/providers/i_localization_provider.dart';
import '../modules/provider_setup/providers.dart';

class UniversalModal extends ConsumerStatefulWidget {
  final DialogType type;
  final String message;
  final VoidCallback? onOk;
  final VoidCallback? onYes;
  final VoidCallback? onNo;
  final String? customTitle;
  final List<Widget> customActions;

  UniversalModal({
    Key? key,
    required this.type,
    required this.message,
    this.onOk,
    this.onYes,
    this.onNo,
    this.customTitle,
    this.customActions = const [],
  }) : super(key: key ?? UniqueKey());


  @override
  _UniversalModalState createState() => _UniversalModalState();
}

class _UniversalModalState extends ConsumerState<UniversalModal> {
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _focusNode.requestFocus();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // final IAnalyticsProvider analytics = ref.read(analyticsProvider);
    final ILocalizationProvider localization = ref.watch(localizationProvider.notifier);

    return AlertDialog(
      title: Semantics(
        focused: true,
        liveRegion: true,
        container: true,
        child: Text(
          widget.customTitle ?? _getTitle(localization),
        ),
      ),
      content: Semantics(
        focused: true,
        liveRegion: true,
        container: true,
        child: SingleChildScrollView(
          child: Text(widget.message),
        ),
      ),
      actions: widget.customActions.isNotEmpty
          ? widget.customActions
          : _getActions(context, localization),
    );
  }

  String _getTitle(ILocalizationProvider localizationProvider) {
    switch (widget.type) {
      case DialogType.error:
        return localizationProvider.translate('error');
      case DialogType.warning:
        return localizationProvider.translate('warning');
      default:
        return localizationProvider.translate('info');
    }
  }

  List<Widget> _getActions(
    BuildContext context,
    // IAnalyticsProvider analytics,
    ILocalizationProvider localization,
  ) {
    return [
      if (widget.type != DialogType.info)
        TextButton(
          onPressed: () {
            widget.onNo?.call();
            // analytics.logEvent('error_or_warning_no_clicked');
            Navigator.of(context).pop();
          },
          child: Semantics(
            label: localization.translate('no_action_label'),
            child: Text(
              localization.translate('no'),
            ),
          ),
        ),
      TextButton(
        onPressed: () {
          if (widget.type == DialogType.info) {
            widget.onOk?.call();
          } else {
            widget.onYes?.call();
          }
          // analytics.logEvent('info_ok_or_yes_clicked');
          Navigator.of(context).pop();
        },
        child: Semantics(
          label: localization.translate('ok_action_label'),
          child: Text(
            widget.type == DialogType.info
                ? localization.translate('ok')
                : localization.translate('yes'),
          ),
        ),
      ),
    ];
  }
}