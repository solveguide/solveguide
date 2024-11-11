import 'package:flutter/material.dart';

class ResortableListWidget<T> extends StatelessWidget {
  const ResortableListWidget({
    required this.items,
    required this.getItemDescription,
    required this.onReorder,
    super.key,
    this.onEdit,
    this.onDelete,
  });

  final List<T> items;
  final String Function(T) getItemDescription;
  final void Function(int oldIndex, int newIndex) onReorder;
  final void Function(int index, T item)? onEdit;
  final void Function(int index, T item)? onDelete;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: 1000,
        ),
        child: ReorderableListView.builder(
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            return Card(
              key: ValueKey(item),
              elevation: 2,
              margin: const EdgeInsets.symmetric(
                vertical: 8,
                horizontal: 5,
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
          proxyDecorator:
              (Widget child, int index, Animation<double> animation) {
            return child;
          },
        ),
      ),
    );
  }
}
