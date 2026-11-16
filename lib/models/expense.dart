class Expense {
  const Expense({
    required this.id,
    required this.name,
    required this.category,
    required this.amount,
    required this.date,
  });

  final String id;
  final String name;
  final String category;
  final double amount;
  final DateTime date;

  Map<String, Object> toJson() => {
    'id': id,
    'name': name,
    'category': category,
    'amount': amount,
    'date': date.toIso8601String(),
  };

  factory Expense.fromJson(Map<String, dynamic> json) => Expense(
    id: json['id'] as String,
    name: json['name'] as String,
    category: json['category'] as String,
    amount: (json['amount'] as num).toDouble(),
    date: DateTime.parse(json['date'] as String),
  );
}
