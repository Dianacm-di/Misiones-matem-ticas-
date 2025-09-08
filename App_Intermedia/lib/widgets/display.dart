import 'package:flutter/material.dart';

import '../utils/colors.dart';

class Display extends StatelessWidget {
  final String expression;
  final String result;

  const Display({super.key, required this.expression, required this.result});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            expression,
            style: const TextStyle(fontSize: 24, color: AppColors.displayText),
          ),
          const SizedBox(height: 8),
          Text(
            "= $result",
            style: const TextStyle(
                fontSize: 36,
                color: AppColors.resultText,
                fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
