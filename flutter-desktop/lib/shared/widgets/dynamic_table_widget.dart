import 'package:flutter/material.dart';

// Configuration class for table columns
class TableColumnConfig<T> {
  final String header;
  final TableColumnWidth columnWidth;
  final Widget Function(T item, int index)? cellBuilder;
  final Widget? headerWidget;
  final bool sortable;
  final String? tooltip;

  const TableColumnConfig({
    required this.header,
    this.columnWidth = const FlexColumnWidth(1),
    this.cellBuilder,
    this.headerWidget,
    this.sortable = false,
    this.tooltip,
  });
}

// Configuration for table actions
class TableActionConfig<T> {
  final IconData icon;
  final Color? color;
  final String? tooltip;
  final void Function(T item, int index) onPressed;

  const TableActionConfig({
    required this.icon,
    required this.onPressed,
    this.color,
    this.tooltip,
  });
}

// Main dynamic table widget
class DynamicTableWidget<T> extends StatelessWidget {
  final List<T> items;
  final List<TableColumnConfig<T>> columns;
  final List<TableActionConfig<T>>? actions;
  final String emptyMessage;
  final Widget? emptyWidget;
  final void Function(T item, int index)? onRowTap;
  final Color? headerColor;
  final Color? borderColor;
  final bool showActions;
  final double? actionColumnWidth;

  const DynamicTableWidget({
    Key? key,
    required this.items,
    required this.columns,
    this.actions,
    this.emptyMessage = 'No data found',
    this.emptyWidget,
    this.onRowTap,
    this.headerColor = const Color(0xFFF9FAFB),
    this.borderColor = const Color(0xFFE5E7EB),
    this.showActions = true,
    this.actionColumnWidth = 120,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return emptyWidget ?? _buildEmptyState();
    }

    // Calculate column widths
    final Map<int, TableColumnWidth> columnWidths = {};
    for (int i = 0; i < columns.length; i++) {
      columnWidths[i] = columns[i].columnWidth;
    }
    
    // Add actions column if actions are provided
    if (showActions && actions != null && actions!.isNotEmpty) {
      columnWidths[columns.length] = FixedColumnWidth(actionColumnWidth ?? 120);
    }

    return Table(
      columnWidths: columnWidths,
      children: [
        _buildHeaderRow(),
        ...items.asMap().entries.map((entry) {
          return _buildDataRow(entry.value, entry.key);
        }).toList(),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Center(
        child: Text(
          emptyMessage,
          style: const TextStyle(
            fontSize: 16,
            color: Color(0xFF6B7280),
          ),
        ),
      ),
    );
  }

  TableRow _buildHeaderRow() {
    List<Widget> headerCells = columns.map((column) {
      return _buildHeaderCell(
        child: column.headerWidget ?? 
          Row(
            children: [
              SizedBox(
                width: 100, // Fixed width for header cells
                child: Text(
                  column.header,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF6B7280),
                    overflow: TextOverflow.ellipsis
                  ),
                ),
              ),
              if (column.tooltip != null) ...[
                const SizedBox(width: 4),
                Icon(
                  Icons.help_outline,
                  size: 14,
                  color: Colors.grey.shade400,
                ),
              ],
            ],
          ),
      );
    }).toList();

    // Add actions header if actions are provided
    if (showActions && actions != null && actions!.isNotEmpty) {
      headerCells.add(
        _buildHeaderCell(
          child: const Text(
            'Actions',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Color(0xFF6B7280),
            ),
          ),
        ),
      );
    }

    return TableRow(
      decoration: BoxDecoration(
        color: headerColor,
        border: Border(
          bottom: BorderSide(color: borderColor!),
        ),
      ),
      children: headerCells,
    );
  }

  TableRow _buildDataRow(T item, int index) {
    List<Widget> dataCells = columns.map((column) {
      Widget cellContent = column.cellBuilder?.call(item, index) ?? 
        const Text('N/A', style: TextStyle(fontSize: 14, color: Color(0xFF6B7280)));
      
      return _buildDataCell(
        child: onRowTap != null 
          ? InkWell(
              onTap: () => onRowTap!(item, index),
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                child: cellContent,
              ),
            )
          : cellContent,
      );
    }).toList();

    // Add actions cell if actions are provided
    if (showActions && actions != null && actions!.isNotEmpty) {
      dataCells.add(
        _buildDataCell(
          child: _buildActionButtons(item, index),
        ),
      );
    }

    return TableRow(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: borderColor!),
        ),
      ),
      children: dataCells,
    );
  }

  Widget _buildActionButtons(T item, int index) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: actions!.map((action) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2),
          child: IconButton(
            onPressed: () => action.onPressed(item, index),
            icon: Icon(
              action.icon,
              color: action.color ?? const Color(0xFF6B7280),
              size: 16,
            ),
            padding: const EdgeInsets.all(2),
            constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
            tooltip: action.tooltip,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildHeaderCell({required Widget child}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      child: child,
    );
  }

  Widget _buildDataCell({required Widget child}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      child: child,
    );
  }
}

// Helper widgets for common cell types
class TableCellHelpers {
  static Widget textCell(String text, {TextStyle? style}) {
    return Text(
      text,
      style: style ?? const TextStyle(
        fontSize: 14,
        color: Color(0xFF6B7280),
        
      ),
    );
  }

  static Widget badgeCell(String text, {Color? backgroundColor, Color? textColor}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor ?? const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: textColor ?? const Color(0xFF374151),
        ),
      ),
    );
  }

  static Widget avatarCell(String text, {Color? backgroundColor}) {
    return CircleAvatar(
      radius: 20,
      backgroundColor: backgroundColor ?? Colors.blue,
      child: Text(
        text.isNotEmpty ? text.substring(0, 2).toUpperCase() : 'N/A',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  static Widget linkCell(String text, VoidCallback onTap, {TextStyle? style}) {
    return InkWell(
      onTap: onTap,
      child: Text(
        text,
        style: style ?? const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Color(0xFF374151),
          decoration: TextDecoration.underline,
        ),
      ),
    );
  }
}