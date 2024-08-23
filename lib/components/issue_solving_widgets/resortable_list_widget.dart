import 'package:flutter/material.dart';

class ResortableListWidget<T> extends StatefulWidget {
  final List<T> items;
  final String Function(T) getItemDescription;
  final void Function(int index, T item)? onEdit;
  final void Function(int index, T item)? onDelete;

  const ResortableListWidget({
    super.key,
    required this.items,
    required this.getItemDescription,
    this.onEdit,
    this.onDelete,
  });

  @override
  ResortableListWidgetState<T> createState() => ResortableListWidgetState<T>();
}

class ResortableListWidgetState<T> extends State<ResortableListWidget<T>> {
  void _reorderItems(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }
      final item = widget.items.removeAt(oldIndex);
      widget.items.insert(newIndex, item);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ReorderableListView.builder(
        itemCount: widget.items.length,
        itemBuilder: (context, index) {
          final item = widget.items[index];
          return Card(
            key: ValueKey(item),
            elevation: 2.0,
            margin: const EdgeInsets.symmetric(
              vertical: 8.0,
              horizontal: 5.0,
            ),
            child: ListTile(
              tileColor: Theme.of(context).colorScheme.tertiary,
              leading: IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () => widget.onEdit?.call(index, item),
              ),
              title: Text(widget.getItemDescription(item)),
              onTap: () => widget.onEdit?.call(index, item),
              trailing: IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () => widget.onDelete?.call(index, item),
              ),
            ),
          );
        },
        onReorder: _reorderItems,
        proxyDecorator: (Widget child, int index, Animation<double> animation) {
          return child;
        },
      ),
    );
  }
}
