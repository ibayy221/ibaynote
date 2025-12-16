import 'package:flutter/material.dart';

class SimpleProgressBar extends StatelessWidget {
  final double value; // 0..1
  const SimpleProgressBar({super.key, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            minHeight: 8,
            value: value,
            backgroundColor: Theme.of(context).dividerColor.withOpacity(.1),
          ),
        ),
        const SizedBox(height: 6),
      ],
    );
  }
}
