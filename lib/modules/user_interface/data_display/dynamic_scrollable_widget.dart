import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../provider_setup/providers.dart'; // Ensure this provider is set up

class DynamicScrollableWidget extends ConsumerStatefulWidget {
  final ScrollController scrollController;
  final List<Widget> children;

  DynamicScrollableWidget({
    Key? key,
    required this.scrollController,
    required this.children,
  }): super(key: key ?? UniqueKey());

  @override
  DynamicScrollableWidgetState createState() => DynamicScrollableWidgetState();
}

class DynamicScrollableWidgetState extends ConsumerState<DynamicScrollableWidget> {
  final double itemHeight = 50.0; // Adjust based on your item height
  late int visibleItemsCount;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _calculateVisibleItemsCount();
    });
  }

  void _calculateVisibleItemsCount() {
    final height = MediaQuery.of(context).size.height -
        AppBar().preferredSize.height; // Get height without AppBar
    visibleItemsCount = (height / itemHeight).floor();
  }

  void scrollToNext() {
    if (visibleItemsCount > 0) {
      final offset =
          (widget.scrollController.offset + (itemHeight * visibleItemsCount))
              .clamp(0, widget.scrollController.position.maxScrollExtent);
      widget.scrollController.animateTo(
        offset.toDouble(),
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void scrollToPrevious() {
    if (visibleItemsCount > 0) {
      final offset =
          (widget.scrollController.offset - (itemHeight * visibleItemsCount))
              .clamp(0, widget.scrollController.position.maxScrollExtent);
      widget.scrollController.animateTo(
        offset.toDouble(),
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizationController = ref.watch(localizationProvider.notifier);

    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            controller: widget.scrollController,
            itemCount: widget.children.length,
            itemBuilder: (context, index) {
              return widget.children[index];
            },
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Semantics(
              label: localizationController.translate('scroll_up'),
              button: true,
              child: IconButton(
                icon: const Icon(Icons.arrow_upward),
                onPressed: scrollToPrevious,
                tooltip: localizationController.translate('scroll_up'),
              ),
            ),
            Semantics(
              label: localizationController.translate('scroll_down'),
              button: true,
              child: IconButton(
                icon: const Icon(Icons.arrow_downward),
                onPressed: scrollToNext,
                tooltip: localizationController.translate('scroll_down'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}