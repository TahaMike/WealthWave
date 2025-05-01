import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../application/providers/transaction_provider.dart';
import '../../core/utils/csv_exporter.dart';
import 'add_transaction_screen.dart';

class HomePage extends HookConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactionsAsync = ref.watch(transactionProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text("WealthWave"),
        actions: [
          IconButton(
            icon: Icon(Icons.download),
            onPressed: () async {
              final transactions = transactionsAsync;
              final path = await CsvExporter.exportTransactionsToCSV(transactions);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Exported to $path')),
              );
            },
          )
        ],
      ),
      body: transactionsAsync.isEmpty
          ? Center(child: Text('No transactions yet'))
          : ListView.builder(
              itemCount: transactionsAsync.length,
              itemBuilder: (context, index) {
                final tx = transactionsAsync[index];
                return ListTile(
                  title: Text(tx.title),
                  subtitle: Text('₹${tx.amount} on ${tx.date.toLocal()}'),
                  trailing: Text(tx.type.name),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AddTransactionScreen(
                onAddTransaction: (tx) {
                  ref.read(transactionProvider.notifier).addTransaction(tx);
                },
                onImportTransactions: (list) {
                  ref.read(transactionProvider.notifier).importTransactions(list);
                },
              ),
            ),
          );
        },
        tooltip: "Add Transaction",
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
