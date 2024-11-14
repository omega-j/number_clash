import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../provider_setup/providers.dart';

class CustomDataTable extends StatelessWidget {
  final List<String> headers;
  final List<List<String>> dataRows;
  final WidgetRef ref;
  final BuildContext context;
  final bool enableScrollControls;
  final double cellHeight;
  final Widget Function(String fileName)? trailingIconBuilder;

  CustomDataTable({
    Key? key,
    required this.headers,
    required this.dataRows,
    required this.ref,
    required this.context,
    this.enableScrollControls = true,
    this.cellHeight = 50.0,
    this.trailingIconBuilder,
  }) : super(key: key);

  Widget _buildTableHeaderCell(BuildContext context, String label) {
    final localization = ref.watch(localizationProvider.notifier);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
      child: Text(
        localization.translate(label),
        style: const TextStyle(fontWeight: FontWeight.bold),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildTableCell(String text, bool isAlternate) {
    Color baseColor = Theme.of(context).colorScheme.surface;
    Color lighterColor = Color.lerp(baseColor, Colors.white, 0.07)!;
    return Container(
      decoration: BoxDecoration(
        color: isAlternate ? baseColor : lighterColor,
      ),
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
      height: cellHeight,
      alignment: Alignment.center,
      child: Text(
        text,
        textAlign: TextAlign.center,
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
        style: const TextStyle(fontSize: 14),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> headerCells = headers.map((header) {
      return _buildTableHeaderCell(context, header);
    }).toList();

    // Add trailing column header space if needed
    if (trailingIconBuilder != null) {
      headerCells.add(SizedBox.shrink());
    }

    List<TableRow> rows = dataRows.asMap().entries.map((entry) {
      int index = entry.key;
      List<String> row = entry.value;

      List<Widget> rowCells = row
          .map((cellData) => _buildTableCell(cellData, index % 2 == 0))
          .toList();

      if (trailingIconBuilder != null) {
        rowCells.add(Container(
          alignment: Alignment.centerRight,
          child: trailingIconBuilder!(row[0]),
        ));
      }

      return TableRow(
        children: rowCells,
      );
    }).toList();

    return SingleChildScrollView(
      child: Table(
        border: TableBorder.symmetric(),
        columnWidths: {
          for (var index in List.generate(headerCells.length, (index) => index))
            index: const FlexColumnWidth(),
        },
        children: [
          TableRow(children: headerCells),
          ...rows,
        ],
      ),
    );
  }
}