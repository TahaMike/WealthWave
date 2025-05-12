import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:csv/csv.dart';
import 'package:wealthwave/core/utils/theme/app_custom_theme.dart';
import 'package:wealthwave/domain/entities/transaction.dart';
import 'package:wealthwave/infrastructure/services/prediction_service.dart';
import 'package:intl/intl.dart';

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
  final formattedDate = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());

  String predictionResult = '';
  String amountPrediction = '';
  List<Transaction> transactions = [];
  @override
  void initState() {
    super.initState();
    // Prefill date with today's date
    dateController.text = formattedDate;
  }

  void handleFileImport(PlatformFile file) async {
    try {
      final csvString = String.fromCharCodes(file.bytes!);
      final rows = CsvToListConverter().convert(csvString);

      final parsedTransactions =
          rows.skip(1).map((row) {
            return Transaction(
              id: '',
              title: row[3].toString(),
              amount: double.tryParse(row[2].toString()) ?? 0.0,
              date: DateTime.tryParse(row[0].toString()) ?? DateTime.now(),
              type:
                  row[1].toString().toLowerCase() == 'income'
                      ? TransactionType.income
                      : TransactionType.expense,
            );
          }).toList();

      setState(() {
        transactions.addAll(parsedTransactions);
      });
      widget.onImportTransactions(parsedTransactions);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to import file: $e')));
    }
  }

  void uploadFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv'],
    );

    if (result != null && result.files.single.bytes != null) {
      handleFileImport(result.files.single);
    }
  }

  void predict() async {
    final result = await PredictionService.predictPriorityLevel(
      dateController.text,
      double.parse(amountController.text).toDouble(),
    );
    setState(() {
      predictionResult =
          'Priority: ${result['priority']} | Level: ${result['level']}';
    });
  }

  void predictNext() async {
    final history =
        historyController.text
            .split(',')
            .map((e) => double.tryParse(e.trim()) ?? 0)
            .toList();
    final result = await PredictionService.predictNextAmount(history);
    setState(() {
      amountPrediction =
          'Predicted next amount: \$${result['predicted_next_amount']}';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Add Transaction")),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color.fromARGB(255, 205, 247, 206),
              const Color.fromARGB(255, 201, 226, 173),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView(
            children: [
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Manual Entry",
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: dateController,
                        decoration: InputDecoration(
                          labelText: 'Date (YYYY-MM-DD)',
                        ),
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        value:
                            typeController.text.isNotEmpty
                                ? typeController.text
                                : null,
                        items:
                            ['Income', 'Expense']
                                .map(
                                  (type) => DropdownMenuItem(
                                    value: type,
                                    child: Text(type),
                                  ),
                                )
                                .toList(),
                        onChanged:
                            (value) => setState(
                              () => typeController.text = value ?? '',
                            ),
                        decoration: InputDecoration(labelText: 'Type'),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: amountController,
                        decoration: InputDecoration(labelText: 'Amount'),
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: titleController,
                        decoration: InputDecoration(labelText: 'Title'),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              final tx = Transaction(
                                id: '',
                                title: titleController.text,
                                amount: double.parse(amountController.text),
                                date:
                                    dateController.text.isNotEmpty
                                        ? DateTime.parse(dateController.text)
                                        : DateTime.now(),
                                type:
                                    typeController.text.toLowerCase() ==
                                            'income'
                                        ? TransactionType.income
                                        : TransactionType.expense,
                              );
                              setState(() {
                                transactions.add(tx);
                                typeController.text = '';
                                amountController.text = '';
                                titleController.text = '';
                                dateController.text.isNotEmpty
                                    ? DateTime.parse(dateController.text).add(
                                      Duration(
                                        hours: DateTime.now().hour,
                                        minutes: DateTime.now().minute,
                                        seconds: DateTime.now().second,
                                      ),
                                    )
                                    : DateTime.now();
                              });
                              widget.onAddTransaction(tx);
                            },
                            child: Text("Add Transaction"),
                          ),
                          ElevatedButton.icon(
                            icon: Icon(Icons.file_upload),
                            label: Text("Import CSV"),
                            onPressed: uploadFile,
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  Theme.of(context).colorScheme.primary,
                              foregroundColor:
                                  Theme.of(context).colorScheme.onPrimary,
                            ),
                          ),
                        ],
                      ),
                      if (predictionResult.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            predictionResult,
                            style: TextStyle(color: Colors.blue),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
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
                        decoration: InputDecoration(
                          labelText: 'History (comma separated values)',
                        ),
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: predictNext,
                        child: Text("Predict"),
                      ),
                      if (amountPrediction.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            amountPrediction,
                            style: TextStyle(color: Colors.green),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                "Transactions",
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 10),
              ...transactions.map(
                (tx) => Card(
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  child: ListTile(
                    title: Text(tx.title),
                    subtitle: Text(
                      '₹${tx.amount} on ${DateFormat('yyyy-MM-dd HH:mm:ss').format(tx.date.toLocal())}',

                    ),
                    trailing: Text(tx.type.name),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
