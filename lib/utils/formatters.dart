String formatCurrency(double amount) {
  final fixed = amount.abs().toStringAsFixed(2).split('.');
  final whole = fixed[0].replaceAllMapped(
    RegExp(r'\B(?=(\d{3})+(?!\d))'),
    (match) => ',',
  );
  final sign = amount < 0 ? '-' : '';
  return '$sign₱$whole.${fixed[1]}';
}

String formatDate(DateTime date) =>
    '${date.day.toString().padLeft(2, '0')}/'
    '${date.month.toString().padLeft(2, '0')}/${date.year}';

String? validatePositiveAmount(String? value) {
  final amount = double.tryParse(value?.trim() ?? '');
  if (amount == null || !amount.isFinite) {
    return 'Enter a valid amount.';
  }
  if (amount <= 0) {
    return 'Amount must be greater than zero.';
  }
  return null;
}

String? validateNonNegativeAmount(String? value) {
  final amount = double.tryParse(value?.trim() ?? '');
  if (amount == null || !amount.isFinite) {
    return 'Enter a valid amount.';
  }
  if (amount < 0) {
    return 'Amount cannot be negative.';
  }
  return null;
}
