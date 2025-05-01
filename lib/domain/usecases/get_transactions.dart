import '../entities/transaction.dart';

abstract class GetTransactionsUseCase {
  Future<List<Transaction>> call();
}
