import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:csv/csv.dart';
import '../../domain/entities/transaction.dart';

class CsvExporter {
  static Future<String> exportTransactionsToCSV(List<Transaction> transactions) async {
    List<List<dynamic>> rows = [
      ['Date', 'Type', 'Amount', 'Title'],
      ...transactions.map((t) => [
        t.date.toIso8601String(),
        t.type.name,
        t.amount.toString(),
        t.title
      ])
    ];

    String csvData = const ListToCsvConverter().convert(rows);

    final directory = await getApplicationDocumentsDirectory();
    final path = "${directory.path}/wealthwave_transactions.csv";
    final file = File(path);

    await file.writeAsString(csvData);
    return path;
  }
}
