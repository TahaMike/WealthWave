import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../domain/entities/transaction.dart';

class TransactionNotifier extends StateNotifier<List<Transaction>> {
  TransactionNotifier() : super(_initialTransactions);

  void addTransaction(Transaction tx) {
    state = [...state, tx];
  }

  void importTransactions(List<Transaction> txs) {
    state = [...state, ...txs];
  }
}

// Preloaded static data for graph (a few examples shown)
final List<Transaction> _initialTransactions = [
  Transaction(
    id: '1',
    title: 'Groceries',
    amount: 1935.71,
    date: DateTime.parse('2025-03-04 04:00:00'),
    type: TransactionType.expense,
  ),
  Transaction(
    id: '2',
    title: 'Restaurant',
    amount: 934.2,
    date: DateTime.parse('2025-01-04 14:00:00'),
    type: TransactionType.expense,
  ),
  Transaction(
    id: '3',
    title: 'Electronics',
    amount: 1466.34,
    date: DateTime.parse('2025-03-15 13:00:00'),
    type: TransactionType.expense,
  ),
  Transaction(
    id: '4',
    title: 'Shopping',
    amount: 2244.94,
    date: DateTime.parse('2025-03-29 20:00:00'),
    type: TransactionType.expense,
  ),
  Transaction(
    id: '5',
    title: 'Medical',
    amount: 2503.1,
    date: DateTime.parse('2025-01-01 07:00:00'),
    type: TransactionType.expense,
  ),
  Transaction(
    id: '6',
    title: 'Salary',
    amount: 2503.1,
    date: DateTime.parse('2025-01-01 07:00:00'),
    type: TransactionType.income,
  ),
  Transaction(
    id: '7',
    title: 'Noodles',
    amount: 25,
    date: DateTime.parse('2025-02-02 06:00:00'),
    type: TransactionType.expense,
  ),
  Transaction(
    id: '8',
    title: 'Medical',
    amount: 2332.1,
    date: DateTime.parse('2025-02-02 05:00:00'),
    type: TransactionType.expense,
  ),
  Transaction(
    id: '9',
    title: 'Salary',
    amount: 15003.1,
    date: DateTime.parse('2025-02-02 07:00:00'),
    type: TransactionType.income,
  ),
];

final transactionProvider =
    StateNotifierProvider<TransactionNotifier, List<Transaction>>(
  (ref) => TransactionNotifier(),
);
