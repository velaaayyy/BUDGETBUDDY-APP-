class Allowance {
  const Allowance({
    required this.id,
    required this.amount,
    required this.frequency,
    required this.date,
  });

  final String id;
  final double amount;
  final String frequency;
  final DateTime date;

  Map<String, Object> toJson() => {
    'id': id,
    'amount': amount,
    'frequency': frequency,
    'date': date.toIso8601String(),
  };

  factory Allowance.fromJson(Map<String, dynamic> json) => Allowance(
    id: json['id'] as String,
    amount: (json['amount'] as num).toDouble(),
    frequency: json['frequency'] as String,
    date: DateTime.parse(json['date'] as String),
  );
}
