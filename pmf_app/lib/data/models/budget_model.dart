import 'package:flutter/material.dart';

class BudgetModel {
  final String categoryId;
  final String categoryName;
  final double limitAmount;
  final double spentAmount;

  BudgetModel({
    required this.categoryId,
    required this.categoryName,
    required this.limitAmount,
    this.spentAmount = 0.0,
  });

  double get remainingAmount => limitAmount - spentAmount;

  double get percentageRemaining => limitAmount > 0 ? (remainingAmount / limitAmount).clamp(0, 1) : 0.0;

  Color get statusColor {
    if(percentageRemaining < 0.15) return Colors.redAccent;
    if(percentageRemaining < 0.50) return Colors.orangeAccent;
    return Colors.greenAccent;
  }
}