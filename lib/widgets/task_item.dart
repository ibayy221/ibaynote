import 'package:flutter/material.dart';

class TaskItem extends StatelessWidget {
  final String text;
  final bool done;
  final ValueChanged<bool?> onChanged;
  final VoidCallback onDelete;

  const TaskItem({super.key, required this.text, required this.done, required this.onChanged, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(text + done.toString()),
      direction: DismissDirection.endToStart,
      background: Container(
        color: Colors.redAccent,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (_) => onDelete(),
      child: CheckboxListTile(
        value: done,
        onChanged: onChanged,
        title: Text(text, style: done ? const TextStyle(decoration: TextDecoration.lineThrough) : null),
      ),
    );
  }
}
