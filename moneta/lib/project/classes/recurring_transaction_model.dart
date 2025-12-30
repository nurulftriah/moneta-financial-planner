import 'package:flutter/material.dart';

class RecurringTransactionModel {
  String? id;
  double? amount;
  String? category;
  String? description;
  String? type; // 'Expense' or 'Income'
  String? frequency; // 'Daily', 'Weekly', 'Monthly', 'Yearly'
  String? startDate; // Format: dd/MM/yyyy
  String? nextOccurrenceDate; // Format: dd/MM/yyyy
  bool? isEnabled;
  String? time; // Format: HH:mm
  Color? color;

  RecurringTransactionModel({
    this.id,
    this.amount,
    this.category,
    this.description,
    this.type,
    this.frequency,
    this.startDate,
    this.nextOccurrenceDate,
    this.isEnabled = true,
    this.time,
    this.color,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'amount': amount,
      'category': category,
      'description': description,
      'type': type,
      'frequency': frequency,
      'startDate': startDate,
      'nextOccurrenceDate': nextOccurrenceDate,
      'isEnabled': isEnabled,
      'time': time,
    };
  }

  static RecurringTransactionModel fromMap(Map<String, dynamic> map) {
    return RecurringTransactionModel(
      id: map['id'],
      amount: map['amount'],
      category: map['category'],
      description: map['description'],
      type: map['type'],
      frequency: map['frequency'],
      startDate: map['startDate'],
      nextOccurrenceDate: map['nextOccurrenceDate'],
      isEnabled: map['isEnabled'],
      time: map['time'],
    );
  }
}
