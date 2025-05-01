import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:csv/csv.dart';
import 'package:wealthwave/domain/entities/transaction.dart';
import 'package:wealthwave/infrastructure/services/prediction_service.dart';

class AddTransactionScreen extends StatefulWidget {
  final Function(Transaction) onAddTransaction;
  final Function(List<Transaction>) onImportTransactions;

  const AddTransactionScreen({
    super.key,
    required this.onAddTransaction,
    required this.onImportTransactions,
  });

  @override
  AddTransactionScreenState createState() => AddTransactionScreenState();
}

class AddTransactionScreenState extends State<AddTransactionScreen> {
  final TextEditingController dateController = TextEditingController();
  final TextEditingController typeController = TextEditingController();
  final TextEditingController amountController = TextEditingController();
  final TextEditingController titleController = TextEditingController();
  final TextEditingController historyController = TextEditingController();

  String predictionResult = '';
  String amountPrediction = '';
  List<Transaction> transactions = [];

  void uploadFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv'],
    );

    if (result != null && result.files.single.bytes != null) {
      final csvString = String.fromCharCodes(result.files.single.bytes!);
      final rows = CsvToListConverter().convert(csvString);
      final parsedTransactions = rows.skip(1).map((row) {
        return Transaction(
          id: '',
          title: row[3],
          amount: row[2],
          date: DateTime.parse(row[0]),
          type: row[1] == 'Income' ? TransactionType.income : TransactionType.expense,
        );
      }).toList();

      setState(() {
        transactions = parsedTransactions;
      });

      widget.onImportTransactions(parsedTransactions);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('File uploaded successfully!')));
    }
  }

  void predict() async {
    final result = await PredictionService.predictPriorityLevel(
      dateController.text,
      double.parse(amountController.text),
    );
    setState(() {
      predictionResult = 'Priority: ${result['priority']} | Level: ${result['level']}';
    });
  }

  void predictNext() async {
    final history = historyController.text
        .split(',')
        .map((e) => double.tryParse(e.trim()) ?? 0)
        .toList();
    final result = await PredictionService.predictNextAmount(history);
    setState(() {
      amountPrediction = 'Predicted next amount: \$${result['predicted_next_amount']}';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Add Transaction")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Manual Entry",
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16), // Space below the section title
                    TextField(
                      controller: dateController,
                      decoration: InputDecoration(labelText: 'Date (YYYY-MM-DD)'),
                    ),
                    const SizedBox(height: 12), // Space between TextFields
                    DropdownButtonFormField<String>(
                      value: typeController.text.isNotEmpty ? typeController.text : null,
                      items: ['Income', 'Expense']
                          .map((type) => DropdownMenuItem(value: type, child: Text(type)))
                          .toList(),
                      onChanged: (value) => setState(() => typeController.text = value ?? ''),
                      decoration: InputDecoration(labelText: 'Type'),
                    ),
                    const SizedBox(height: 12), // Space between TextFields
                    TextField(
                      controller: amountController,
                      decoration: InputDecoration(labelText: 'Amount'),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 12), // Space between TextFields
                    TextField(
                      controller: titleController,
                      decoration: InputDecoration(labelText: 'Title'),
                    ),
                    const SizedBox(height: 12), // Space between TextFields and buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            final tx = Transaction(
                              id: '',
                              title: titleController.text,
                              amount: double.parse(amountController.text),
                              date: DateTime.parse(dateController.text),
                              type: typeController.text.toLowerCase() == 'income'
                                  ? TransactionType.income
                                  : TransactionType.expense,
                            );
                            setState(() {
                              transactions.add(tx);
                              dateController.text = '';
                              typeController.text = '';
                              amountController.text = '';
                              titleController.text = '';
                            });
                            widget.onAddTransaction(tx);
                          },
                          child: Text("Add Transaction"),
                        ),
                        ElevatedButton(
                          onPressed: predict,
                          child: Text("Predict Priority"),
                        ),
                      ],
                    ),
                    if (predictionResult.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(predictionResult, style: TextStyle(color: Colors.blue)),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16), // Space below the card
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Predict Next Amount",
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: historyController,
                      decoration: InputDecoration(labelText: 'History (comma separated values)'),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(onPressed: predictNext, child: Text("Predict")),
                    if (amountPrediction.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(amountPrediction, style: TextStyle(color: Colors.green)),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16), // Space below the card
            ElevatedButton(onPressed: uploadFile, child: Text("Upload CSV")),
            const SizedBox(height: 10),
            Text(
              "Transactions",
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 10),
            ...transactions.map((tx) => Card(
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  child: ListTile(
                    title: Text(tx.title),
                    subtitle: Text('\$${tx.amount} on ${tx.date.toLocal().toString().split(' ')[0]}'),
                    trailing: Text(tx.type.name),
                  ),
                )),
          ],
        ),
      ),
    );
  }

  
}
