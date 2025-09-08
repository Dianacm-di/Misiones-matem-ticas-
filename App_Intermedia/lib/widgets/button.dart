import 'package:flutter/material.dart';

import '../utils/colors.dart';

class CalculatorButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final bool isOperation;

  const CalculatorButton(
      {super.key,
      required this.label,
      required this.onTap,
      this.isOperation = false});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: BoxDecoration(
          color: isOperation ? AppColors.pink : AppColors.buttonBackground,
          border: Border.all(color: AppColors.buttonBorder),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isOperation ? Colors.white : AppColors.buttonText,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
