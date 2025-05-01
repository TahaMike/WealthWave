// transaction_provider.dart
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../domain/entities/transaction.dart';

class TransactionNotifier extends StateNotifier<List<Transaction>> {
  TransactionNotifier() : super([]);

  void addTransaction(Transaction tx) {
    state = [...state, tx];
  }

  void importTransactions(List<Transaction> txs) {
    state = [...state, ...txs];
  }
}

final transactionProvider = StateNotifierProvider<TransactionNotifier, List<Transaction>>(
  (ref) => TransactionNotifier(),
);
