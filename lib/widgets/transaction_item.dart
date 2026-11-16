import 'package:material_ui/material_ui.dart';

import '../models/expense.dart';
import '../utils/formatters.dart';

class TransactionItem extends StatelessWidget {
  const TransactionItem({super.key, required this.expense, this.onDelete});

  final Expense expense;
  final VoidCallback? onDelete;

  IconData get _icon {
    switch (expense.category) {
      case 'Food':
        return Icons.restaurant_outlined;
      case 'Transportation':
        return Icons.directions_bus_outlined;
      case 'School Supplies':
        return Icons.menu_book_outlined;
      case 'Personal Needs':
        return Icons.face_outlined;
      case 'Entertainment':
        return Icons.movie_outlined;
      default:
        return Icons.shopping_bag_outlined;
    }
  }

  @override
  Widget build(BuildContext context) => Card(
    margin: const EdgeInsets.only(bottom: 10),
    child: ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      leading: CircleAvatar(
        backgroundColor: const Color(0xFFE8F5E9),
        child: Icon(_icon, color: const Color(0xFF2E7D32)),
      ),
      title: Text(
        expense.name,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Text('${expense.category} · ${formatDate(expense.date)}'),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '-${formatCurrency(expense.amount)}',
            style: const TextStyle(
              color: Color(0xFFE53935),
              fontWeight: FontWeight.w600,
            ),
          ),
          if (onDelete != null)
            IconButton(
              tooltip: 'Delete expense',
              onPressed: onDelete,
              icon: const Icon(Icons.delete_outline, color: Colors.red),
            ),
        ],
      ),
    ),
  );
}
