import 'package:flutter/material.dart';

class EmptyState extends StatelessWidget {
  final String message;
  const EmptyState({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24.0),
      child: Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.notes_outlined, size: 48, color: Theme.of(context).disabledColor),
          const SizedBox(height: 12),
          Text(message, style: TextStyle(color: Theme.of(context).disabledColor))
        ]),
      ),
    );
  }
}
