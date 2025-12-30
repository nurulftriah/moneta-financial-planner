class BudgetModel {
  String? id;
  String category;
  double amount; // The budget limit
  double spent; // Calculated value, not necessarily stored but can be helpful

  BudgetModel({
    this.id,
    required this.category,
    required this.amount,
    this.spent = 0.0,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'category': category,
      'amount': amount,
    };
  }

  factory BudgetModel.fromMap(Map<String, dynamic> map) {
    return BudgetModel(
      id: map['id'],
      category: map['category'],
      amount: map['amount']?.toDouble() ?? 0.0,
    );
  }
}
