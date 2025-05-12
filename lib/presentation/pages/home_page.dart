import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:wealthwave/core/utils/theme/app_custom_theme.dart';
import 'package:wealthwave/presentation/widgets/expense_chart.dart';
import '../../application/providers/transaction_provider.dart';
import 'add_transaction_screen.dart';

class HomePage extends HookConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactionsAsync = ref.watch(transactionProvider);

    // Sort transactions by date (newest first)
    final sortedTransactions = [...transactionsAsync]
      ..sort((a, b) => b.date.compareTo(a.date));

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 208, 243, 209),
      appBar: AppBar(title: Text("WealthWave")),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 40),
            SizedBox(
              height: 250,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: ExpensesChart(transactions: sortedTransactions),
              ),
            ),
            const Divider(),
            ListView.builder(
              physics: NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: sortedTransactions.length,
              itemBuilder: (context, index) {
                final tx = sortedTransactions[index];
                return ListTile(
                  title: Text(tx.title),
                  subtitle: Text(
                    '₹${tx.amount.toStringAsFixed(2)} on ${tx.date.toLocal()}',
                  ),
                  trailing: Text(tx.type.name),
                );
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (_) => AddTransactionScreen(
                    onAddTransaction: (tx) {
                      ref.read(transactionProvider.notifier).addTransaction(tx);
                    },
                    onImportTransactions: (list) {
                      ref
                          .read(transactionProvider.notifier)
                          .importTransactions(list);
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
