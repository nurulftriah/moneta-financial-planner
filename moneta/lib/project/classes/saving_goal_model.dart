class SavingGoalModel {
  String? id;
  String name;
  double targetAmount;
  double currentAmount;
  String? targetDate; // ISO 8601 String
  int color; // Value of the color
  int? iconCodePoint;
  String? iconFontFamily;
  String? iconFontPackage;

  SavingGoalModel({
    this.id,
    required this.name,
    required this.targetAmount,
    this.currentAmount = 0.0,
    this.targetDate,
    required this.color,
    this.iconCodePoint,
    this.iconFontFamily,
    this.iconFontPackage,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'targetAmount': targetAmount,
      'currentAmount': currentAmount,
      'targetDate': targetDate,
      'color': color,
      'iconCodePoint': iconCodePoint,
      'iconFontFamily': iconFontFamily,
      'iconFontPackage': iconFontPackage,
    };
  }

  factory SavingGoalModel.fromMap(Map<String, dynamic> map) {
    return SavingGoalModel(
      id: map['id'],
      name: map['name'] ?? '',
      targetAmount: (map['targetAmount'] ?? 0.0).toDouble(),
      currentAmount: (map['currentAmount'] ?? 0.0).toDouble(),
      targetDate: map['targetDate'],
      color: map['color'] ?? 0xFF2196F3, // Default Blue
      iconCodePoint: map['iconCodePoint'],
      iconFontFamily: map['iconFontFamily'],
      iconFontPackage: map['iconFontPackage'],
    );
  }
}
