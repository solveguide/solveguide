import 'package:flutter/material.dart';

class ResortableListWidget<T> extends StatelessWidget {
  final List<T> items;
  final String Function(T) getItemDescription;
  final void Function(int oldIndex, int newIndex) onReorder;
  final void Function(int index, T item)? onEdit;
  final void Function(int index, T item)? onDelete;

  const ResortableListWidget({
    super.key,
    required this.items,
    required this.getItemDescription,
    required this.onReorder,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ReorderableListView.builder(
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          return Card(
            key: ValueKey(item),
            elevation: 2.0,
            margin: const EdgeInsets.symmetric(
              vertical: 8.0,
              horizontal: 5.0,
            ),
            child: ListTile(
              tileColor: Theme.of(context).colorScheme.tertiary,
              // leading: IconButton(
              //   icon: const Icon(Icons.edit),
              //   onPressed: () => onEdit?.call(index, item),
              // ),
              title: Text(getItemDescription(item)),
              onTap: () => onEdit?.call(index, item),
              // trailing: IconButton(
              //   icon: const Icon(Icons.delete),
              //   onPressed: () => onDelete?.call(index, item),
              // ),
            ),
          );
        },
        onReorder: onReorder,
        proxyDecorator: (Widget child, int index, Animation<double> animation) {
          return child;
        },
      ),
    );
  }
}
