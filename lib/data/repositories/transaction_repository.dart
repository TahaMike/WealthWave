import '../../domain/entities/transaction.dart';
import '../../domain/usecases/get_transactions.dart';

class TransactionRepository implements GetTransactionsUseCase {
  @override
  Future<List<Transaction>> call() async {
    await Future.delayed(Duration(seconds: 1)); // Simulate loading
    return [
      Transaction(id: '1', title: 'Groceries', amount: 50.0, date: DateTime.now(), type: TransactionType.expense),
      Transaction(id: '2', title: 'Coffee', amount: 5.0, date: DateTime.now(), type: TransactionType.expense),
    ];
  }
}
