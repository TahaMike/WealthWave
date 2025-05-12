import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../domain/entities/transaction.dart';

class ExpensesChart extends StatelessWidget {
  final List<Transaction> transactions;

  const ExpensesChart({super.key, required this.transactions});

  @override
  Widget build(BuildContext context) {
    final Map<int, double> incomeByMonth = {};
    final Map<int, double> expenseByMonth = {};

    for (var tx in transactions) {
      final month = tx.date.month;
      if (tx.type == TransactionType.expense) {
        expenseByMonth[month] = (expenseByMonth[month] ?? 0) + tx.amount;
      } else if (tx.type == TransactionType.income) {
        incomeByMonth[month] = (incomeByMonth[month] ?? 0) + tx.amount;
      }
    }

    final monthlyData = List.generate(12, (index) {
      final month = index + 1;
      return {
        'income': incomeByMonth[month] ?? 0,
        'expense': expenseByMonth[month] ?? 0,
      };
    });

    final allValues = [...incomeByMonth.values, ...expenseByMonth.values];
    final maxY =
        allValues.isEmpty
            ? 1000
            : (allValues.reduce((a, b) => a > b ? a : b) * 1.2);

    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: SizedBox(
        height: 300,
        child: BarChart(
          BarChartData(
            maxY: maxY.toDouble(),
            barGroups: _buildBarGroups(monthlyData),
            gridData: FlGridData(show: true),
            borderData: FlBorderData(show: false),
            titlesData: FlTitlesData(
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 40,
                  interval: _calculateInterval(maxY.toDouble()),
                  getTitlesWidget: (value, meta) {
                    return Text(
                      '₹${(value ~/ 1000)}K',
                      style: const TextStyle(fontSize: 10),
                    );
                  },
                ),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget:
                      (value, meta) => Text(_monthLabel(value.toInt())),
                ),
              ),
              rightTitles: AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            ),
            barTouchData: BarTouchData(
              enabled: true,
              touchTooltipData: BarTouchTooltipData(
                getTooltipItem: (group, groupIndex, rod, rodIndex) {
                  final isIncome = rod.color == Colors.green;
                  final label = isIncome ? 'Income' : 'Expense';
                  return BarTooltipItem(
                    '$label\n₹${rod.toY.toStringAsFixed(2)}',
                    const TextStyle(color: Colors.white, fontSize: 12),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<BarChartGroupData> _buildBarGroups(
    List<Map<String, double>> monthlyData,
  ) {
    return List.generate(monthlyData.length, (index) {
      final data = monthlyData[index];
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: data['income']!,
            width: 7,
            color: Colors.green,
            borderRadius: BorderRadius.circular(4),
          ),
          BarChartRodData(
            toY: data['expense']!,
            width: 7,
            color: Colors.red,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
        barsSpace: 3,
      );
    });
  }

  String _monthLabel(int month) {
    const labels = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    if (month >= 0 && month < labels.length) {
      return labels[month];
    }
    return '';
  }

  double _calculateInterval(double max) {
    if (max <= 1000) return 200;
    if (max <= 5000) return 1000;
    if (max <= 10000) return 2000;
    return 5000;
  }
}
